/*
 * Copyright (C) 2026 CharOfString <root@charofstring.cc>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "file_system_model.h"

#include <QCollator>
#include <QDir>
#include <QFileInfo>
#include <QHash>
#include <QImageReader>
#include <QLocale>
#include <QMimeDatabase>
#include <QSet>
#include <algorithm>
#include <array>

namespace gxde {

namespace {

// Pictures bigger than this get no thumbnail; decoding them would stall.
constexpr qint64 kMaxThumbnailSize = qint64{30} * 1024 * 1024;
// How long the folder must stay quiet before the rows are updated.
constexpr int kSyncDelayMs = 200;
// The size units of DFM's FileUtils::formatSize.
constexpr std::array<const char*, 5> kSizeUnits = {" B", " KiB", " MiB", " GiB", " TiB"};

const QSet<QString>& ThumbnailMimeTypes() {
  static const QSet<QString> types = [] {
    QSet<QString> result;
    for (const QByteArray& type : QImageReader::supportedMimeTypes()) {
      result.insert(QString::fromLatin1(type));
    }
    return result;
  }();
  return types;
}

// -1, 0 or 1 as a is less than, equal to or greater than b.
template <typename T>
int Compare(const T& a, const T& b) {
  if (a < b) {
    return -1;
  }
  return b < a ? 1 : 0;
}

QCollator& NameCollator() {
  static QCollator collator = [] {
    QCollator result;
    result.setNumericMode(true);
    result.setCaseSensitivity(Qt::CaseInsensitive);
    return result;
  }();
  return collator;
}

// DFM's FileUtils::formatSize: IEC units, one decimal, no trailing zeros.
QString FormatSize(qint64 size) {
  auto value = static_cast<qreal>(qMax<qint64>(size, 0));
  std::size_t unit = 0;
  while (value >= 1024 && unit + 1 < kSizeUnits.size()) {
    value /= 1024;
    ++unit;
  }
  QString number = QString::number(value, 'f', 1);
  while (number.endsWith(QLatin1Char('0'))) {
    number.chop(1);
  }
  if (number.endsWith(QLatin1Char('.'))) {
    number.chop(1);
  }
  return number + QLatin1String(kSizeUnits.at(unit));
}

// Like DFM: "1 item" or "N items" for folders, a byte size for files.
QString SizeText(bool is_dir, qint64 size, int child_count) {
  if (is_dir) {
    return child_count == 1 ? FileSystemModel::tr("1 item")
                            : FileSystemModel::tr("%1 items").arg(child_count);
  }
  return FormatSize(size);
}

}  // namespace

bool FileSystemModel::Entry::operator==(const Entry& other) const {
  return name == other.name && path == other.path && is_dir == other.is_dir &&
         is_hidden == other.is_hidden && is_symlink == other.is_symlink && size == other.size &&
         child_count == other.child_count && modified == other.modified &&
         mime_type == other.mime_type;
}

FileSystemModel::FileSystemModel(QObject* parent) : QAbstractListModel(parent) {
  sync_timer_.setSingleShot(true);
  sync_timer_.setInterval(kSyncDelayMs);
  connect(&sync_timer_, &QTimer::timeout, this, &FileSystemModel::Sync);
  connect(&watcher_, &QFileSystemWatcher::directoryChanged, &sync_timer_,
          qOverload<>(&QTimer::start));
}

QUrl FileSystemModel::Folder() const {
  return folder_;
}

void FileSystemModel::SetFolder(const QUrl& folder) {
  if (folder_ == folder) {
    return;
  }
  folder_ = folder;
  emit folderChanged();
  Reset();
}

QUrl FileSystemModel::ParentFolder() const {
  if (!folder_.isLocalFile()) {
    return {};
  }
  QDir dir(folder_.toLocalFile());
  if (dir.isRoot() || !dir.cdUp()) {
    return {};
  }
  return QUrl::fromLocalFile(dir.absolutePath());
}

bool FileSystemModel::ShowHidden() const {
  return show_hidden_;
}

void FileSystemModel::SetShowHidden(bool show) {
  if (show_hidden_ == show) {
    return;
  }
  show_hidden_ = show;
  emit showHiddenChanged();
  Sync();
}

bool FileSystemModel::ShowFiles() const {
  return show_files_;
}

void FileSystemModel::SetShowFiles(bool show) {
  if (show_files_ == show) {
    return;
  }
  show_files_ = show;
  emit showFilesChanged();
  Sync();
}

QStringList FileSystemModel::NameFilters() const {
  return name_filters_;
}

void FileSystemModel::SetNameFilters(const QStringList& filters) {
  if (name_filters_ == filters) {
    return;
  }
  name_filters_ = filters;
  emit nameFiltersChanged();
  Sync();
}

FileSystemModel::SortField FileSystemModel::GetSortField() const {
  return sort_field_;
}

void FileSystemModel::SetSortField(SortField field) {
  if (sort_field_ == field) {
    return;
  }
  sort_field_ = field;
  emit sortFieldChanged();
  Reset();
}

Qt::SortOrder FileSystemModel::SortOrder() const {
  return sort_order_;
}

void FileSystemModel::SetSortOrder(Qt::SortOrder order) {
  if (sort_order_ == order) {
    return;
  }
  sort_order_ = order;
  emit sortOrderChanged();
  Reset();
}

bool FileSystemModel::Exists() const {
  return exists_;
}

QVariantMap FileSystemModel::get(int row) const {
  QVariantMap result;
  if (row < 0 || row >= entries_.size()) {
    return result;
  }
  const QModelIndex idx = index(row);
  const QHash<int, QByteArray> roles = roleNames();
  for (auto it = roles.cbegin(); it != roles.cend(); ++it) {
    result.insert(QString::fromLatin1(it.value()), data(idx, it.key()));
  }
  return result;
}

int FileSystemModel::indexOf(const QString& path) const {
  const QString clean = QDir::cleanPath(path);
  for (int i = 0; i < entries_.size(); ++i) {
    if (entries_.at(i).path == clean) {
      return i;
    }
  }
  return -1;
}

QItemSelection FileSystemModel::selectionOf(const QList<int>& rows) const {
  QList<int> sorted = rows;
  std::sort(sorted.begin(), sorted.end());
  QItemSelection selection;
  int first = -1;
  int last = -1;
  for (const int row : sorted) {
    if (row < 0 || row >= entries_.size()) {
      continue;
    }
    if (first >= 0 && row <= last + 1) {
      last = std::max(last, row);
      continue;
    }
    if (first >= 0) {
      selection.select(index(first), index(last));
    }
    first = row;
    last = row;
  }
  if (first >= 0) {
    selection.select(index(first), index(last));
  }
  return selection;
}

void FileSystemModel::refresh() {
  Sync();
}

int FileSystemModel::rowCount(const QModelIndex& parent) const {
  return parent.isValid() ? 0 : static_cast<int>(entries_.size());
}

QVariant FileSystemModel::data(const QModelIndex& index, int role) const {
  if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid)) {
    return {};
  }
  const Entry& entry = entries_.at(index.row());
  switch (role) {
    case Qt::DisplayRole:
    case FileNameRole:
      return entry.name;
    case FilePathRole:
      return entry.path;
    case FileUrlRole:
      return QUrl::fromLocalFile(entry.path);
    case IsDirRole:
      return entry.is_dir;
    case IsHiddenRole:
      return entry.is_hidden;
    case IsSymLinkRole:
      return entry.is_symlink;
    case SizeRole:
      return entry.size;
    case SizeTextRole:
      return SizeText(entry.is_dir, entry.size, entry.child_count);
    case ModifiedRole:
      return entry.modified;
    case ModifiedTextRole:
      // DFM's format.
      return QLocale().toString(entry.modified, QStringLiteral("yyyy/MM/dd HH:mm:ss"));
    case MimeTypeRole:
      return entry.mime_type;
    case TypeNameRole:
      return entry.type_name;
    case IconNameRole:
      return entry.icon_name;
    case FallbackIconNameRole:
      return entry.fallback_icon_name;
    case ThumbnailableRole:
      return entry.thumbnailable;
    default:
      return {};
  }
}

QHash<int, QByteArray> FileSystemModel::roleNames() const {
  return {
      {FileNameRole, "fileName"},
      {FilePathRole, "filePath"},
      {FileUrlRole, "fileUrl"},
      {IsDirRole, "isDir"},
      {IsHiddenRole, "isHidden"},
      {IsSymLinkRole, "isSymLink"},
      {SizeRole, "size"},
      {SizeTextRole, "sizeText"},
      {ModifiedRole, "modified"},
      {ModifiedTextRole, "modifiedText"},
      {MimeTypeRole, "mimeType"},
      {TypeNameRole, "typeName"},
      {IconNameRole, "iconName"},
      {FallbackIconNameRole, "fallbackIconName"},
      {ThumbnailableRole, "thumbnailable"},
  };
}

void FileSystemModel::classBegin() {
  complete_ = false;
}

void FileSystemModel::componentComplete() {
  complete_ = true;
  Reset();
}

QVector<FileSystemModel::Entry> FileSystemModel::Load(bool* exists) const {
  QVector<Entry> result;
  *exists = false;
  if (!folder_.isLocalFile()) {
    return result;
  }

  QDir dir(folder_.toLocalFile());
  if (!dir.exists() || !dir.isReadable()) {
    return result;
  }
  *exists = true;

  QDir::Filters filters = QDir::AllDirs | QDir::NoDotAndDotDot | QDir::System;
  if (show_files_) {
    filters |= QDir::Files;
  }
  if (show_hidden_) {
    filters |= QDir::Hidden;
  }

  static const QMimeDatabase mime_db;
  const QFileInfoList infos = dir.entryInfoList(filters, QDir::NoSort);
  result.reserve(infos.size());
  for (const QFileInfo& info : infos) {
    Entry entry;
    entry.name = info.fileName();
    entry.path = info.absoluteFilePath();
    entry.is_dir = info.isDir();
    if (!entry.is_dir && !name_filters_.isEmpty() && !QDir::match(name_filters_, entry.name)) {
      continue;
    }
    entry.is_hidden = entry.name.startsWith(QLatin1Char('.'));
    entry.is_symlink = info.isSymLink();
    entry.size = entry.is_dir ? 0 : info.size();
    entry.modified = info.lastModified();
    if (entry.is_dir) {
      const QDir child(entry.path);
      entry.child_count =
          static_cast<int>(child
                               .entryList(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::System |
                                          (show_hidden_ ? QDir::Hidden : QDir::Filters()))
                               .size());
    }
    // By extension only: reading every file would make big folders slow.
    // Links take the type of their target, like in DFM.
    const QFileInfo target = entry.is_symlink ? QFileInfo(info.symLinkTarget()) : info;
    const QMimeType mime = entry.is_dir
                               ? mime_db.mimeTypeForName(QStringLiteral("inode/directory"))
                               : mime_db.mimeTypeForFile(target, QMimeDatabase::MatchExtension);
    entry.mime_type = mime.name();
    entry.type_name = mime.comment();
    entry.icon_name = mime.iconName();
    entry.fallback_icon_name = mime.genericIconName();
    entry.thumbnailable = !entry.is_dir && entry.size <= kMaxThumbnailSize &&
                          ThumbnailMimeTypes().contains(entry.mime_type);
    result.append(entry);
  }
  Sort(&result);
  return result;
}

bool FileSystemModel::LessThan(const Entry& a, const Entry& b) const {
  // Folders always come first, whatever the order.
  if (a.is_dir != b.is_dir) {
    return a.is_dir;
  }

  int compare = 0;
  switch (sort_field_) {
    case Modified:
      compare = Compare(a.modified, b.modified);
      break;
    case Size:
      if (a.is_dir) {
        compare = a.child_count - b.child_count;
      } else {
        compare = Compare(a.size, b.size);
      }
      break;
    case Type:
      compare = NameCollator().compare(a.type_name, b.type_name);
      break;
    case Name:
      break;
  }
  if (compare == 0) {
    compare = NameCollator().compare(a.name, b.name);
  }
  if (compare == 0) {
    compare = QString::compare(a.name, b.name);
  }
  return sort_order_ == Qt::AscendingOrder ? compare < 0 : compare > 0;
}

void FileSystemModel::Sort(QVector<Entry>* entries) const {
  std::sort(entries->begin(), entries->end(),
            [this](const Entry& a, const Entry& b) { return LessThan(a, b); });
}

void FileSystemModel::Reset() {
  if (!complete_) {
    return;
  }
  sync_timer_.stop();
  const int old_count = rowCount();
  bool exists = false;
  beginResetModel();
  entries_ = Load(&exists);
  endResetModel();
  WatchFolder();
  SetExists(exists);
  if (old_count != rowCount()) {
    emit countChanged();
  }
}

void FileSystemModel::Sync() {
  if (!complete_) {
    return;
  }
  sync_timer_.stop();
  const int old_count = rowCount();
  bool exists = false;
  const QVector<Entry> fresh = Load(&exists);

  // Drop the rows that are gone, from the bottom so rows stay valid.
  QSet<QString> fresh_paths;
  fresh_paths.reserve(fresh.size());
  for (const Entry& entry : fresh) {
    fresh_paths.insert(entry.path);
  }
  for (int row = static_cast<int>(entries_.size()) - 1; row >= 0; --row) {
    if (fresh_paths.contains(entries_.at(row).path)) {
      continue;
    }
    beginRemoveRows({}, row, row);
    entries_.remove(row);
    endRemoveRows();
  }

  // Now entries_ holds a subset of fresh; walk fresh and move, insert or
  // update rows until both match.
  for (int row = 0; row < fresh.size(); ++row) {
    const Entry& wanted = fresh.at(row);
    if (row < entries_.size() && entries_.at(row).path == wanted.path) {
      if (!(entries_.at(row) == wanted)) {
        entries_[row] = wanted;
        emit dataChanged(index(row), index(row));
      }
      continue;
    }
    int from = -1;
    for (int i = row + 1; i < entries_.size(); ++i) {
      if (entries_.at(i).path == wanted.path) {
        from = i;
        break;
      }
    }
    if (from >= 0) {
      beginMoveRows({}, from, from, {}, row);
      entries_.move(from, row);
      endMoveRows();
      if (!(entries_.at(row) == wanted)) {
        entries_[row] = wanted;
        emit dataChanged(index(row), index(row));
      }
    } else {
      beginInsertRows({}, row, row);
      entries_.insert(row, wanted);
      endInsertRows();
    }
  }

  WatchFolder();
  SetExists(exists);
  if (old_count != rowCount()) {
    emit countChanged();
  }
}

void FileSystemModel::SetExists(bool exists) {
  if (exists_ == exists) {
    return;
  }
  exists_ = exists;
  emit existsChanged();
}

void FileSystemModel::WatchFolder() {
  const QString path = exists_ || folder_.isLocalFile() ? folder_.toLocalFile() : QString();
  const QStringList watched = watcher_.directories();
  if (watched.size() == 1 && watched.first() == path) {
    return;
  }
  if (!watched.isEmpty()) {
    watcher_.removePaths(watched);
  }
  if (!path.isEmpty() && QFileInfo(path).isDir()) {
    watcher_.addPath(path);
  }
}

}  // namespace gxde
