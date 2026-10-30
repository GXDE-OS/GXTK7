/*
 * Copyright (C) 2026 CharOfString <root@charofstring.cc>
 * Copyright (C) 2026 shenmo <shenmo@spark-app.store>
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
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Gxde

T.AbstractButton {
  id: control

  implicitWidth: 210
  implicitHeight: 120
  padding: 18
  spacing: 8
  hoverEnabled: true
  display: T.AbstractButton.TextUnderIcon
  font.pixelSize: 14

  icon.width: 48
  icon.height: 48
  icon.color: GxdePalette.text

  contentItem: IconLabel {
    spacing: control.spacing
    mirrored: control.mirrored
    display: control.display

    icon: control.icon
    text: control.text
    font: control.font
    color: GxdePalette.text
  }

  background: Rectangle {
    radius: 12
    color: control.down ? GxdePalette.settingsTilePress
         : control.hovered ? GxdePalette.settingsTileHover : GxdePalette.settingsTile
    border.width: control.visualFocus ? 1 : 0
    border.color: GxdePalette.buttonFocusBorder
  }

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }
}
