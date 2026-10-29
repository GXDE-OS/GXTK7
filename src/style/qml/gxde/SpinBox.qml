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

T.SpinBox {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          contentItem.implicitWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding)

  readonly property int frameWidth: 2
  readonly property int buttonWidth: 16

  leftPadding: control.mirrored ? frameWidth + buttonWidth + 4 : 6
  rightPadding: control.mirrored ? 6 : frameWidth + buttonWidth + 4
  topPadding: 4
  bottomPadding: 4

  validator: IntValidator {
    locale: control.locale.name
    bottom: Math.min(control.from, control.to)
    top: Math.max(control.from, control.to)
  }

  contentItem: TextInput {
    z: 2
    text: control.displayText
    font: control.font
    color: control.enabled ? GxdePalette.text : GxdePalette.textDisabled
    selectionColor: GxdePalette.highlight
    selectedTextColor: GxdePalette.highlightedText
    horizontalAlignment: Qt.AlignLeft
    verticalAlignment: Qt.AlignVCenter
    clip: width < implicitWidth

    readOnly: !control.editable
    validator: control.validator
    inputMethodHints: control.inputMethodHints
  }

  up.indicator: Item {
    x: control.mirrored ? control.frameWidth : control.width - width - control.frameWidth
    y: control.frameWidth
    implicitWidth: control.buttonWidth
    implicitHeight: 10
    height: control.height / 2 - control.frameWidth

    Image {
      anchors.centerIn: parent
      source: "assets/" + GxdePalette.assetDir + "/spinbox/spinbutton_up_"
              + (!control.enabled || control.value >= Math.max(control.from, control.to) && !control.wrap
                 ? "insensitive"
                 : control.up.pressed ? "press" : control.up.hovered ? "hover" : "normal") + ".png"
    }
  }

  down.indicator: Item {
    x: control.mirrored ? control.frameWidth : control.width - width - control.frameWidth
    y: control.height / 2
    implicitWidth: control.buttonWidth
    implicitHeight: 10
    height: control.height / 2 - control.frameWidth

    Image {
      anchors.centerIn: parent
      source: "assets/" + GxdePalette.assetDir + "/spinbox/spinbutton_down_"
              + (!control.enabled || control.value <= Math.min(control.from, control.to) && !control.wrap
                 ? "insensitive"
                 : control.down.pressed ? "press" : control.down.hovered ? "hover" : "normal") + ".png"
    }
  }

  background: EditFrame {
    target: control
    implicitWidth: 60

    Rectangle {
      x: control.mirrored ? control.frameWidth + control.buttonWidth : parent.width - control.frameWidth - control.buttonWidth - 1
      y: 1
      width: 1
      height: parent.height - 2
      color: !control.enabled ? GxdePalette.spinDisabledBorder
           : control.activeFocus ? GxdePalette.spinFocusBorder
           : GxdePalette.spinBorder
    }
  }
}
