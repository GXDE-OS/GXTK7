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

T.Dialog {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          contentWidth + leftPadding + rightPadding,
                          implicitHeaderWidth,
                          implicitFooterWidth)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           contentHeight + topPadding + bottomPadding
                           + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                           + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))

  leftPadding: 20
  rightPadding: 20
  topPadding: control.header && control.header.visible ? 5 : 14
  bottomPadding: 14
  spacing: 0

  palette.windowText: GxdePalette.dialogMessage

  background: Rectangle {
    implicitWidth: 380
    radius: 8
    color: GxdePalette.dialogBackground
    border.width: 1
    border.color: GxdePalette.dialogBorder
  }

  header: Text {
    text: control.title
    visible: control.title
    elide: Text.ElideRight
    font.weight: Font.Medium
    color: GxdePalette.dialogTitle
    topPadding: 16
    bottomPadding: 2
    leftPadding: 20
    rightPadding: 20
  }

  footer: DialogButtonBox {
    visible: count > 0
  }

  T.Overlay.modal: Rectangle {
    color: Qt.rgba(0, 0, 0, 0.3)
  }

  T.Overlay.modeless: Rectangle {
    color: "transparent"
  }
}
