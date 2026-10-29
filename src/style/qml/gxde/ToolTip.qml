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

T.ToolTip {
  id: control

  x: parent ? (parent.width - implicitWidth) / 2 : 0
  y: -implicitHeight - 3

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          contentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           contentHeight + topPadding + bottomPadding)

  margins: 6
  padding: 4

  closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

  contentItem: Text {
    text: control.text
    font: control.font
    wrapMode: Text.Wrap
    color: GxdePalette.toolTipText
  }

  background: Rectangle {
    radius: 4
    color: GxdePalette.toolTipBackground
    border.width: 1
    border.color: Qt.rgba(0, 0, 0, 0.1)
  }
}
