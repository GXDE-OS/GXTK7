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

#ifndef SRC_STYLE_FILE_SYSTEM_MODEL_FILE_SYSTEM_MODEL_H_
#define SRC_STYLE_FILE_SYSTEM_MODEL_FILE_SYSTEM_MODEL_H_

#include <QtQmlIntegration/qqmlintegration.h>

#include <QAbstractListModel>
#include <QDateTime>
#include <QFileSystemWatcher>
#include <QItemSelection>
#include <QQmlParserStatus>
#include <QStringList>
#include <QTimer>
#include <QUrl>
#include <QVector>

namespace gxde {

/**
 * @class FileSystemModel
 * @brief Lists the files of a local folder for GXFileView.
 *
 * Folders come first, then files, sorted like DFM: names naturally, with
 * numbers compared by value.  The folder is watched, and changes update the
 * rows in place, so views keep their selection and scroll position.
 */
class FileSystemModel : public QAbstractListModel, public QQmlParserStatus {
  Q_OBJECT
  Q_INTERFACES(QQmlParserStatus)
  QML_NAMED_ELEMENT(GXFileSystemModel)

  Q_PROPERTY(QUrl folder READ Folder WRITE SetFolder NOTIFY folderChanged)
  Q_PROPERTY(QUrl parentFolder READ ParentFolder NOTIFY folderChanged)
  Q_PROPERTY(bool showHidden READ ShowHidden WRITE SetShowHidden NOTIFY showHiddenChanged)
  Q_PROPERTY(bool showFiles READ ShowFiles WRITE SetShowFiles NOTIFY showFilesChanged)
  Q_PROPERTY(
      QStringList nameFilters READ NameFilters WRITE SetNameFilters NOTIFY nameFiltersChanged)
  Q_PROPERTY(SortField sortField READ GetSortField WRITE SetSortField NOTIFY sortFieldChanged)
  Q_PROPERTY(Qt::SortOrder sortOrder READ SortOrder WRITE SetSortOrder NOTIFY sortOrderChanged)
  Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
  Q_PROPERTY(bool exists READ Exists NOTIFY existsChanged)

 public:
  /// The columns of the list view, which rows can be sorted by.
  enum SortField { Name, Modified, Size, Type };
  Q_ENUM(SortField)

  enum Role {
    FileNameRole = Qt::UserRole + 1,
    FilePathRole,
    FileUrlRole,
    IsDirRole,
    IsHiddenRole,
    IsSymLinkRole,
    SizeRole,
    SizeTextRole,
    ModifiedRole,
    ModifiedTextRole,
    MimeTypeRole,
    TypeNameRole,
    IconNameRole,
    FallbackIconNameRole,
    ThumbnailableRole,
  };
  Q_ENUM(Role)

  /**
   * @brief Constructs an empty model.
   * @param parent The optional QObject parent.
   */
  explicit FileSystemModel(QObject* parent = nullptr);

  /// @brief Returns the listed folder.
  [[nodiscard]] QUrl Folder() const;
  /// @brief Lists another folder.  Only local files are supported.
  void SetFolder(const QUrl& folder);

  /// @brief Returns the folder above, or an empty URL at the root.
  [[nodiscard]] QUrl ParentFolder() const;

  /// @brief Returns whether dot files are listed.
  [[nodiscard]] bool ShowHidden() const;
  /// @brief Lists dot files or not.
  void SetShowHidden(bool show);

  /// @brief Returns whether files are listed, not only folders.
  [[nodiscard]] bool ShowFiles() const;
  /// @brief Lists files or folders only.
  void SetShowFiles(bool show);

  /// @brief Returns the wildcards files must match.  Folders always show.
  [[nodiscard]] QStringList NameFilters() const;
  /// @brief Sets the wildcards files must match, such as "*.png".
  void SetNameFilters(const QStringList& filters);

  /// @brief Returns the field rows are sorted by.
  [[nodiscard]] SortField GetSortField() const;
  /// @brief Sorts the rows by another field.
  void SetSortField(SortField field);

  /// @brief Returns the sort order.
  [[nodiscard]] Qt::SortOrder SortOrder() const;
  /// @brief Sets the sort order.  Folders stay first either way.
  void SetSortOrder(Qt::SortOrder order);

  /// @brief Returns whether the folder exists and could be read.
  [[nodiscard]] bool Exists() const;

  /**
   * @brief Returns all roles of a row.
   * @param row The row.
   * @return The roles by name, or an empty map for a bad row.
   */
  // NOLINTNEXTLINE(readability-identifier-naming)
  [[nodiscard]] Q_INVOKABLE QVariantMap get(int row) const;

  /**
   * @brief Finds the row of a file.
   * @param path Absolute path of the file.
   * @return The row, or -1.
   */
  // NOLINTNEXTLINE(readability-identifier-naming)
  [[nodiscard]] Q_INVOKABLE int indexOf(const QString& path) const;

  /**
   * @brief Turns rows into one selection, for ItemSelectionModel.select().
   *
   * Selecting many rows this way emits one selection change, not one a row.
   * @param rows The rows, in any order.
   * @return The rows as ranges.
   */
  // NOLINTNEXTLINE(readability-identifier-naming)
  [[nodiscard]] Q_INVOKABLE QItemSelection selectionOf(const QList<int>& rows) const;

  /// @brief Reads the folder again.
  Q_INVOKABLE void refresh();  // NOLINT(readability-identifier-naming)

  [[nodiscard]] int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  [[nodiscard]] QVariant data(const QModelIndex& index, int role) const override;
  [[nodiscard]] QHash<int, QByteArray> roleNames() const override;

  void classBegin() override;
  void componentComplete() override;

 signals:
  void folderChanged();       // NOLINT(readability-identifier-naming)
  void showHiddenChanged();   // NOLINT(readability-identifier-naming)
  void showFilesChanged();    // NOLINT(readability-identifier-naming)
  void nameFiltersChanged();  // NOLINT(readability-identifier-naming)
  void sortFieldChanged();    // NOLINT(readability-identifier-naming)
  void sortOrderChanged();    // NOLINT(readability-identifier-naming)
  void countChanged();        // NOLINT(readability-identifier-naming)
  void existsChanged();       // NOLINT(readability-identifier-naming)

 private:
  struct Entry {
    QString name;
    QString path;
    bool is_dir{false};
    bool is_hidden{false};
    bool is_symlink{false};
    qint64 size{0};
    // Number of children, for folders.
    int child_count{0};
    QDateTime modified;
    QString mime_type;
    QString type_name;
    QString icon_name;
    QString fallback_icon_name;
    bool thumbnailable{false};

    bool operator==(const Entry& other) const;
  };

  // Reads the folder into sorted entries.
  [[nodiscard]] QVector<Entry> Load(bool* exists) const;
  [[nodiscard]] bool LessThan(const Entry& a, const Entry& b) const;
  void Sort(QVector<Entry>* entries) const;
  // Replaces all rows, for a new folder or order.
  void Reset();
  // Updates the rows in place after the folder changed on disk.
  void Sync();
  void SetExists(bool exists);
  void WatchFolder();

  QUrl folder_;
  bool show_hidden_{false};
  bool show_files_{true};
  QStringList name_filters_;
  SortField sort_field_{Name};
  Qt::SortOrder sort_order_{Qt::AscendingOrder};
  bool exists_{false};
  bool complete_{true};
  QVector<Entry> entries_;
  QFileSystemWatcher watcher_;
  // Folds bursts of changes into one Sync().
  QTimer sync_timer_;
};

}  // namespace gxde

#endif  // SRC_STYLE_FILE_SYSTEM_MODEL_FILE_SYSTEM_MODEL_H_
