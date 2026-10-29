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

T.Slider {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitHandleWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitHandleHeight + topPadding + bottomPadding)

  padding: 0

  handle: Image {
    x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width)
                                                 : (control.availableWidth - width) / 2)
    y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2
                                                : control.visualPosition * (control.availableHeight - height))
    sourceSize: Qt.size(24, 24)
    source: "assets/" + GxdePalette.assetDir + "/slider/slider_handle_"
            + (!control.enabled ? "insensitive"
               : control.pressed ? "press"
               : control.activeFocus ? "focus" : "normal") + ".svg"
  }

  background: Item {
    readonly property real inset: 2 + 6
    readonly property real handleCenter: control.horizontal
        ? control.handle.x - x + control.handle.width / 2
        : control.handle.y - y + control.handle.height / 2

    x: control.leftPadding
    y: control.topPadding
    implicitWidth: control.horizontal ? 84 : 24
    implicitHeight: control.horizontal ? 24 : 84
    width: control.availableWidth
    height: control.availableHeight

    Rectangle {
      x: control.horizontal ? parent.inset : (parent.width - width) / 2
      y: control.horizontal ? (parent.height - height) / 2 : parent.inset
      width: control.horizontal ? parent.width - 2 * parent.inset : 2
      height: control.horizontal ? 2 : parent.height - 2 * parent.inset
      radius: 1
      color: control.enabled ? GxdePalette.sliderGroove : GxdePalette.sliderGrooveDisabled
    }

    Rectangle {
      readonly property bool fromFar: !control.horizontal || control.mirrored
      readonly property real length: control.horizontal ? parent.width : parent.height
      readonly property real start: fromFar ? parent.handleCenter : parent.inset
      readonly property real end: fromFar ? length - parent.inset : parent.handleCenter

      visible: control.enabled
      x: control.horizontal ? start : (parent.width - width) / 2
      y: control.horizontal ? (parent.height - height) / 2 : start
      width: control.horizontal ? Math.max(0, end - start) : 2
      height: control.horizontal ? 2 : Math.max(0, end - start)
      radius: 1
      color: GxdePalette.accent
    }
  }
}
