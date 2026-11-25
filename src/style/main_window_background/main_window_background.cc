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

#include "src/style/main_window_background/main_window_background.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QUrlQuery>

#include "src/style/gxde_theme/gxde_theme.h"

namespace gxde {

namespace {

constexpr int kPlaceCount = MainWindowBackground::FullWindow + 1;

// File name parts of each place, in Place order.  They must stay the same as
// DTK2's, so both libraries read the same files.
const char* const kPlaceNames[kPlaceCount] = {
    "TopLeft",    "TopCenter", "TopRight",     "CenterLeft",  "Center",
    "CenterRight", "BottomLeft", "BottomCenter", "BottomRight", "FullWindow",
};

const char* ThemeName(MainWindowBackground::Theme theme) {
  return theme == MainWindowBackground::Dark ? "dark" : "light";
}

bool IsValidPlace(MainWindowBackground::Place place) {
  return place >= MainWindowBackground::TopLeft && place <= MainWindowBackground::FullWindow;
}

QString ToLocalPath(const QString& path_or_url) {
  const QUrl url(path_or_url);
  return url.isLocalFile() ? url.toLocalFile() : path_or_url;
}

}  // namespace

MainWindowBackground::MainWindowBackground(QObject* parent)
    : QObject(parent), app_name_(QCoreApplication::applicationName()) {
  connect(GxdeTheme::Instance(), &GxdeTheme::themeChanged, this, &MainWindowBackground::refresh);
  refresh();
}

QString MainWindowBackground::AppName() const {
  return app_name_;
}

void MainWindowBackground::SetAppName(const QString& name) {
  if (app_name_ == name) {
    return;
  }
  app_name_ = name;
  emit appNameChanged();
  refresh();
}

bool MainWindowBackground::UseGlobalBackground() const {
  return use_global_background_;
}

void MainWindowBackground::SetUseGlobalBackground(bool use) {
  if (use_global_background_ == use) {
    return;
  }
  use_global_background_ = use;
  emit useGlobalBackgroundChanged();
  refresh();
}

QStringList MainWindowBackground::CustomBackgroundPaths() const {
  return custom_background_paths_;
}

void MainWindowBackground::SetCustomBackgroundPaths(const QStringList& paths) {
  if (custom_background_paths_ == paths) {
    return;
  }
  custom_background_paths_ = paths;
  emit customBackgroundPathsChanged();
  refresh();
}

bool MainWindowBackground::IsSet() const {
  return is_set_;
}

bool MainWindowBackground::UserBackgroundSet() const {
  return user_background_set_;
}

QList<QUrl> MainWindowBackground::Sources() const {
  return sources_;
}

void MainWindowBackground::refresh() {  // NOLINT(readability-identifier-naming)
  const QString theme = QLatin1String(GxdeTheme::Instance()->IsDark() ? "dark" : "light");
  const QString home = QDir::homePath();

  QStringList bases;
  if (use_global_background_) {
    bases << QStringLiteral("/usr/share/backgrounds/GXDE/dtk2/global/background-") + theme
          << home + QStringLiteral("/.config/GXDE/dtk2/global/background-") + theme;
  }
  if (!app_name_.isEmpty()) {
    bases << QStringLiteral("/usr/share/backgrounds/GXDE/dtk2/") + app_name_ +
                 QStringLiteral("/background-") + theme
          << home + QStringLiteral("/.config/GXDE/") + app_name_ + QStringLiteral("/background-") +
                 theme;
  }
  bases << custom_background_paths_;

  // The query only makes the URL new, so QML reloads a file that was
  // replaced under the same name.  Local file loading ignores it.
  ++revision_;
  QUrlQuery query;
  query.addQueryItem(QStringLiteral("r"), QString::number(revision_));

  QList<QUrl> sources;
  sources.reserve(kPlaceCount);
  bool is_set = false;
  for (const char* place_name : kPlaceNames) {
    const QString suffix = QLatin1Char('-') + QLatin1String(place_name) + QStringLiteral(".png");
    QString found;
    for (const QString& base : bases) {
      const QString path = base + suffix;
      if (QFileInfo(path).isFile()) {
        found = path;
      }
    }

    QUrl url;
    if (!found.isEmpty()) {
      url = QUrl::fromLocalFile(found);
      url.setQuery(query);
      is_set = true;
    }
    sources.append(url);
  }

  sources_ = sources;
  is_set_ = is_set;
  user_background_set_ = isUserBackgroundSet(FullWindow);
  emit backgroundChanged();
}

QUrl MainWindowBackground::source(Place place) const {  // NOLINT(readability-identifier-naming)
  if (!IsValidPlace(place) || sources_.size() != kPlaceCount) {
    return {};
  }
  return sources_.at(place);
}

bool MainWindowBackground::setUserBackground(  // NOLINT(readability-identifier-naming)
    Theme theme, const QString& image_path, Place place) {
  if (!IsValidPlace(place) || app_name_.isEmpty()) {
    return false;
  }
  const QString source = ToLocalPath(image_path);
  if (!QFileInfo(source).isFile()) {
    return false;
  }

  const QString target = UserPath(theme, place);
  if (!QDir().mkpath(QFileInfo(target).absolutePath())) {
    return false;
  }
  if (QFile::exists(target) && !QFile::remove(target)) {
    return false;
  }
  return QFile::copy(source, target);
}

bool MainWindowBackground::removeUserBackground(  // NOLINT(readability-identifier-naming)
    Theme theme, Place place) {
  if (!IsValidPlace(place) || app_name_.isEmpty()) {
    return false;
  }
  const QString target = UserPath(theme, place);
  return !QFile::exists(target) || QFile::remove(target);
}

bool MainWindowBackground::isUserBackgroundSet(  // NOLINT(readability-identifier-naming)
    Place place) const {
  if (!IsValidPlace(place) || app_name_.isEmpty()) {
    return false;
  }
  return QFile::exists(UserPath(Light, place)) || QFile::exists(UserPath(Dark, place));
}

QString MainWindowBackground::UserPath(Theme theme, Place place) const {
  return QDir::homePath() + QStringLiteral("/.config/GXDE/") + app_name_ +
         QStringLiteral("/background-") + QLatin1String(ThemeName(theme)) + QLatin1Char('-') +
         QLatin1String(kPlaceNames[place]) + QStringLiteral(".png");
}

}  // namespace gxde
