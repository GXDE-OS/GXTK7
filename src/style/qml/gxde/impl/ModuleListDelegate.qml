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

T.ItemDelegate {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: 40

  leftPadding: 8
  rightPadding: 8
  spacing: 8
  focusPolicy: Qt.NoFocus

  icon.width: 24
  icon.height: 24
  icon.color: GxdePalette.text

  contentItem: IconLabel {
    spacing: control.spacing
    mirrored: control.mirrored
    display: control.display
    alignment: Qt.AlignLeft

    icon: control.icon
    text: control.text
    font: control.font
    color: GxdePalette.text
  }

  background: Rectangle {
    radius: 8
    color: control.highlighted ? GxdePalette.settingsNavSelected
         : control.hovered ? GxdePalette.settingsNavHover : "transparent"
  }
}
