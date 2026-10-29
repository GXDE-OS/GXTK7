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

import QtQuick
import QtQuick.Controls.Gxde

Rectangle {
  id: panel

  required property Item target
  property bool suggest: false

  implicitWidth: 80
  implicitHeight: 22
  radius: 3.5

  border.width: 1
  border.color: suggest
      ? GxdePalette.pick(target, GxdePalette.suggestBorder, GxdePalette.suggestHoverBorder,
                         GxdePalette.suggestPressBorder, GxdePalette.suggestBorder,
                         GxdePalette.suggestDisabledBorder)
      : GxdePalette.pick(target, GxdePalette.buttonBorder, GxdePalette.buttonHoverBorder,
                         GxdePalette.buttonPressBorder, GxdePalette.buttonFocusBorder,
                         GxdePalette.buttonDisabledBorder)

  gradient: Gradient {
    GradientStop {
      position: 0
      color: GxdePalette.pick(panel.target, GxdePalette.buttonTop, GxdePalette.buttonHoverTop,
                              GxdePalette.buttonPressTop, GxdePalette.buttonTop,
                              GxdePalette.buttonDisabledTop)
    }
    GradientStop {
      position: 1
      color: GxdePalette.pick(panel.target, GxdePalette.buttonBottom, GxdePalette.buttonHoverBottom,
                              GxdePalette.buttonPressBottom, GxdePalette.buttonBottom,
                              GxdePalette.buttonDisabledBottom)
    }
  }
}
