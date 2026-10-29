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
import QtQuick.Controls.Gxde

T.ScrollBar {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding)

  padding: 0
  readonly property real length: orientation === Qt.Horizontal ? width : height
  minimumSize: length > 0 ? Math.min(1, 40 / length) : 0
  visible: control.policy !== T.ScrollBar.AlwaysOff

  contentItem: Item {
    implicitWidth: control.interactive ? 12 : 4
    implicitHeight: control.interactive ? 12 : 4
    opacity: control.policy === T.ScrollBar.AlwaysOn || control.active || control.hovered ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: control.active ? 0 : 500 }
    }

    Rectangle {
      readonly property bool expanded: control.hovered || control.pressed
      readonly property real thickness: expanded
          ? (control.horizontal ? parent.height : parent.width) - 4
          : (control.horizontal ? parent.height : parent.width) / 3

      anchors.centerIn: parent
      width: control.horizontal ? parent.width : thickness
      height: control.horizontal ? thickness : parent.height
      radius: thickness / 2
      color: control.pressed ? GxdePalette.scrollHandlePress
           : control.hovered ? GxdePalette.scrollHandleHover
           : GxdePalette.scrollHandle
    }
  }
}
