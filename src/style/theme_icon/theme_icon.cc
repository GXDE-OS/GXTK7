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

#include "theme_icon.h"

#include <QCoreApplication>
#include <QFileInfo>
#include <QGuiApplication>
#include <QPainter>

namespace gxde {

namespace {

// Whether an icon theme of this name is installed.
bool IsThemeInstalled(const QString& name) {
  if (name.isEmpty()) {
    return false;
  }
  for (const QString& path : QIcon::themeSearchPaths()) {
    if (QFileInfo::exists(path + QLatin1Char('/') + name + QStringLiteral("/index.theme"))) {
      return true;
    }
  }
  return false;
}

}  // namespace

ThemeIcon::ThemeIcon(QQuickItem* parent) : QQuickPaintedItem(parent) {
  EnsureIconTheme();
}

QString ThemeIcon::Name() const {
  return name_;
}

void ThemeIcon::SetName(const QString& name) {
  if (name_ == name) {
    return;
  }
  name_ = name;
  emit nameChanged();
  Reload();
}

QString ThemeIcon::FallbackName() const {
  return fallback_name_;
}

void ThemeIcon::SetFallbackName(const QString& name) {
  if (fallback_name_ == name) {
    return;
  }
  fallback_name_ = name;
  emit fallbackNameChanged();
  Reload();
}

bool ThemeIcon::IsValid() const {
  return !icon_.isNull();
}

void ThemeIcon::paint(QPainter* painter) {
  if (icon_.isNull()) {
    return;
  }
  const QIcon::Mode mode = isEnabled() ? QIcon::Normal : QIcon::Disabled;
  icon_.paint(painter, boundingRect().toAlignedRect(), Qt::AlignCenter, mode);
}

void ThemeIcon::EnsureIconTheme() {
  static bool done = false;
  if (done || qobject_cast<QGuiApplication*>(QCoreApplication::instance()) == nullptr) {
    return;
  }
  done = true;

  const QString theme = QIcon::themeName();
  if (IsThemeInstalled(theme) && theme != QLatin1String("hicolor")) {
    return;
  }
  if (IsThemeInstalled(QIcon::fallbackThemeName()) &&
      QIcon::fallbackThemeName() != QLatin1String("hicolor")) {
    return;
  }

  for (const char* candidate : {"gxde", "deepin", "bloom", "Papirus", "breeze", "Adwaita"}) {
    const QString name = QString::fromLatin1(candidate);
    if (IsThemeInstalled(name)) {
      QIcon::setFallbackThemeName(name);
      return;
    }
  }
}

void ThemeIcon::Reload() {
  const bool was_valid = IsValid();
  icon_ = QIcon();
  for (const QString& name : {name_, fallback_name_}) {
    if (name.isEmpty()) {
      continue;
    }
    icon_ = QIcon::fromTheme(name);
    if (!icon_.isNull()) {
      break;
    }
  }
  if (was_valid != IsValid()) {
    emit validChanged();
  }
  update();
}

}  // namespace gxde

namespace {

// Also helps the IconImage items of the style, such as the title bar icon.
void GxdeEnsureIconTheme() {
  gxde::ThemeIcon::EnsureIconTheme();
}

}  // namespace

Q_COREAPP_STARTUP_FUNCTION(GxdeEnsureIconTheme)
