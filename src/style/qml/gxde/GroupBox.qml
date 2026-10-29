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

T.GroupBox {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          contentWidth + leftPadding + rightPadding,
                          implicitLabelWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           contentHeight + topPadding + bottomPadding)

  readonly property real titleHeight: control.title.length > 0 ? implicitLabelHeight : 0

  spacing: 6
  padding: 10
  topPadding: Math.max(padding, titleHeight + spacing)

  label: Text {
    x: control.leftPadding
    width: Math.min(implicitWidth, control.availableWidth)

    text: control.title
    font: control.font
    color: control.enabled ? GxdePalette.text : GxdePalette.textDisabled
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
  }

  background: Item {
    Rectangle {
      y: control.titleHeight / 2
      width: parent.width
      height: parent.height - y
      radius: 4
      color: "transparent"
      border.width: 1
      border.color: GxdePalette.frameBorder
    }

    Rectangle {
      x: control.label.x - 4
      y: control.titleHeight / 2 - 1
      width: control.label.width + 8
      height: 3
      visible: control.titleHeight > 0
      color: GxdePalette.window
    }
  }
}
