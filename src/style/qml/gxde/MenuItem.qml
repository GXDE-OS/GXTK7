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

T.MenuItem {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding,
                           implicitIndicatorHeight + topPadding + bottomPadding)

  readonly property bool hasIcon: control.icon.name !== "" || control.icon.source.toString() !== ""
  readonly property color foreground: !control.enabled ? GxdePalette.textDisabled
                                    : control.highlighted ? GxdePalette.highlightedText
                                    : GxdePalette.text

  leftPadding: 27 + (control.checkable && control.hasIcon ? 20 : 0)
  rightPadding: 10 + (control.subMenu ? 12 : 0)
  topPadding: 3
  bottomPadding: 4

  icon.width: 16
  icon.height: 16
  icon.color: control.foreground

  contentItem: Text {
    text: control.text
    font: control.font
    color: control.foreground
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
  }

  indicator: ColorImage {
    x: control.mirrored ? control.width - width - 10 : 10
    y: control.height / 2 - 4
    visible: control.checkable && control.checked
    source: "assets/common/check.svg"
    sourceSize: Qt.size(14, 13)
    color: control.enabled ? (control.highlighted ? GxdePalette.highlightedText : GxdePalette.menuGlyph)
                           : GxdePalette.textDisabled
  }

  arrow: ColorImage {
    readonly property real dim: Math.floor((control.height - 4) / 2)

    x: control.mirrored ? 3 : control.width - width - 3
    y: (control.height - height) / 2
    width: dim
    height: dim
    visible: control.subMenu
    mirror: control.mirrored
    fillMode: Image.PreserveAspectFit
    source: "assets/common/arrow-right.svg"
    sourceSize: Qt.size(6, 8)
    color: control.enabled ? (control.highlighted ? GxdePalette.highlightedText : GxdePalette.menuGlyph)
                           : GxdePalette.textDisabled
  }

  background: Item {
    implicitWidth: 159
    implicitHeight: 19

    Rectangle {
      anchors.fill: parent
      visible: control.highlighted && control.enabled
      color: GxdePalette.highlight
    }

    IconImage {
      readonly property real cellLeft: control.checkable ? 24 : 4

      x: control.mirrored ? control.width - cellLeft - 20 + (20 - width) / 2 : cellLeft + (20 - width) / 2
      y: (parent.height - height) / 2
      visible: control.hasIcon
      name: control.icon.name
      source: control.icon.source
      sourceSize: Qt.size(control.icon.width, control.icon.height)
      color: control.icon.color
    }
  }
}
