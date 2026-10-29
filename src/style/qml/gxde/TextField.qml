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

T.TextField {
  id: control

  implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                 || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           contentHeight + topPadding + bottomPadding,
                           placeholder.implicitHeight + topPadding + bottomPadding)

  padding: 6
  topPadding: 4
  bottomPadding: 4

  color: enabled ? GxdePalette.text : GxdePalette.textDisabled
  selectionColor: GxdePalette.highlight
  selectedTextColor: GxdePalette.highlightedText
  placeholderTextColor: GxdePalette.textDisabled
  verticalAlignment: TextInput.AlignVCenter

  PlaceholderText {
    id: placeholder
    x: control.leftPadding
    y: control.topPadding
    width: control.width - (control.leftPadding + control.rightPadding)
    height: control.height - (control.topPadding + control.bottomPadding)

    text: control.placeholderText
    font: control.font
    color: control.placeholderTextColor
    verticalAlignment: control.verticalAlignment
    visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
    elide: Text.ElideRight
    renderType: control.renderType
  }

  background: EditFrame {
    target: control
  }
}
