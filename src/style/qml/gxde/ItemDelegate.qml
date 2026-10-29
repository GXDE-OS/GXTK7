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

T.ItemDelegate {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding,
                           implicitIndicatorHeight + topPadding + bottomPadding)

  leftPadding: 10
  rightPadding: 10
  topPadding: 6
  bottomPadding: 6
  spacing: 6

  readonly property bool selected: control.highlighted || control.down

  icon.width: 16
  icon.height: 16
  icon.color: control.selected ? GxdePalette.highlightedText
            : control.enabled ? GxdePalette.text : GxdePalette.textDisabled

  contentItem: IconLabel {
    spacing: control.spacing
    mirrored: control.mirrored
    display: control.display
    alignment: control.display === IconLabel.IconOnly || control.display === IconLabel.TextUnderIcon
               ? Qt.AlignCenter : Qt.AlignLeft

    icon: control.icon
    text: control.text
    font: control.font
    color: control.icon.color
  }

  background: Rectangle {
    implicitWidth: 100
    implicitHeight: 24
    color: control.selected ? GxdePalette.highlight
         : control.hovered ? GxdePalette.itemHover : "transparent"
  }
}
