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

T.CheckBox {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding,
                           implicitIndicatorHeight + topPadding + bottomPadding)

  padding: 0
  topPadding: 1
  spacing: 4

  indicator: Item {
    implicitWidth: 20
    implicitHeight: 20
    x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding)
                    : control.leftPadding + (control.availableWidth - width) / 2
    y: control.topPadding + (control.availableHeight - height) / 2

    Image {
      anchors.centerIn: parent
      source: "assets/" + GxdePalette.assetDir + "/checkbox/"
              + GxdePalette.indicatorImage(control, "checkbox") + ".png"
    }
  }

  contentItem: Text {
    leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
    rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0

    text: control.text
    font: control.font
    color: control.enabled ? GxdePalette.text : GxdePalette.textDisabled
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
  }
}
