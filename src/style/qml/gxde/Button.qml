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

T.Button {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding)

  topPadding: 5
  bottomPadding: 5
  leftPadding: 6
  rightPadding: 6
  spacing: 4

  icon.width: 16
  icon.height: 16
  icon.color: GxdePalette.buttonTextColor(control, control.highlighted)

  contentItem: IconLabel {
    spacing: control.spacing
    mirrored: control.mirrored
    display: control.display

    icon: control.icon
    text: control.text
    font: control.font
    color: GxdePalette.buttonTextColor(control, control.highlighted)
  }

  background: ButtonPanel {
    target: control
    suggest: control.highlighted
    implicitWidth: control.text && !control.flat ? 80 : 22
    visible: !control.flat
  }
}
