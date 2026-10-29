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

T.ProgressBar {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding)

  leftInset: 2
  rightInset: 2
  leftPadding: 2
  rightPadding: 2

  contentItem: Item {
    implicitWidth: 84
    implicitHeight: 20

    readonly property real chunkWidth: control.indeterminate ? width / 4 : control.position * width
    property real chunkX: 0

    Rectangle {
      x: control.mirrored && !control.indeterminate ? parent.width - width : parent.chunkX
      width: parent.chunkWidth
      height: parent.height
      visible: width > 0
      radius: 4
      color: GxdePalette.progressContent
      border.width: 1
      border.color: GxdePalette.progressContentBorder
    }

    SequentialAnimation on chunkX {
      running: control.indeterminate && control.visible
      loops: Animation.Infinite

      NumberAnimation {
        from: 0
        to: control.availableWidth * 3 / 4
        duration: 1000
        easing.type: Easing.InOutSine
      }
      NumberAnimation {
        from: control.availableWidth * 3 / 4
        to: 0
        duration: 1000
        easing.type: Easing.InOutSine
      }
    }
  }

  background: Rectangle {
    implicitWidth: 84
    implicitHeight: 20
    radius: 4
    color: GxdePalette.progressGroove
    border.width: 1
    border.color: GxdePalette.progressGrooveBorder
  }
}
