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
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Gxde

T.TabButton {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding)

  readonly property bool atBottom: control.T.TabBar.position === T.TabBar.Footer

  leftPadding: 8
  rightPadding: 8
  topPadding: 4
  bottomPadding: 4
  spacing: 4

  icon.width: 16
  icon.height: 16
  icon.color: !control.enabled ? GxdePalette.tabDisabledText
            : control.checked ? GxdePalette.tabSelectedText
            : GxdePalette.tabText

  contentItem: IconLabel {
    spacing: control.spacing
    mirrored: control.mirrored
    display: control.display

    icon: control.icon
    text: control.text
    font: control.font
    color: control.icon.color
  }

  background: Rectangle {
    implicitWidth: 80
    implicitHeight: 28
    color: control.hovered ? GxdePalette.tabHover : "transparent"

    Rectangle {
      x: control.mirrored ? parent.width - 1 : 0
      width: 1
      height: parent.height
      visible: control.T.TabBar.index > 0
      color: GxdePalette.tabBorder
    }

    Rectangle {
      y: control.atBottom ? 0 : parent.height - height
      width: parent.width
      height: Math.min(3, Math.floor(parent.height / 10))
      visible: control.checked
      color: GxdePalette.tabSelectedText
    }
  }
}
