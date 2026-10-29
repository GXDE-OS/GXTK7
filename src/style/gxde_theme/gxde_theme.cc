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

#include "src/style/gxde_theme/gxde_theme.h"

namespace gxde {

GxdeTheme::GxdeTheme(QObject* parent) : QObject(parent) {}

GxdeTheme* GxdeTheme::Instance() {
  static GxdeTheme instance(nullptr);
  return &instance;
}

GxdeTheme* GxdeTheme::create(  // NOLINT(readability-identifier-naming)
    QQmlEngine* /*engine*/, QJSEngine* /*script_engine*/) {
  GxdeTheme* theme = Instance();
  QJSEngine::setObjectOwnership(theme, QJSEngine::CppOwnership);
  return theme;
}

bool GxdeTheme::IsDark() const {
  return is_dark_;
}

void GxdeTheme::SetDark(bool dark) {
  if (is_dark_ != dark) {
    is_dark_ = dark;
    emit themeChanged();
  }
}

}  // namespace gxde
