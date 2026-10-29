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

pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Gxde

T.DialogButtonBox {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding)

  padding: 0
  spacing: 0
  buttonLayout: T.DialogButtonBox.GnomeLayout

  readonly property real cornerRadius: 8

  delegate: T.Button {
    id: action

    readonly property bool first: ObjectModel.index === 0
    readonly property bool last: ObjectModel.index === control.count - 1
    readonly property bool recommend: highlighted
                                      || T.DialogButtonBox.buttonRole === T.DialogButtonBox.AcceptRole

    width: control.count > 0 ? control.availableWidth / control.count : implicitWidth
    implicitWidth: Math.max(implicitBackgroundWidth, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: 28
    leftPadding: 12
    rightPadding: 12
    topInset: 1
    leftInset: first ? 0 : 1

    contentItem: IconLabel {
      text: action.text
      font.pixelSize: 13
      font.weight: action.recommend ? Font.Medium : Font.Normal
      color: action.down || action.hovered ? "#ffffff"
           : !action.enabled ? GxdePalette.textDisabled
           : action.recommend ? GxdePalette.dialogRecommendText
           : GxdePalette.dialogActionText
    }

    background: Rectangle {
      implicitWidth: 80
      visible: action.down || action.hovered
      bottomLeftRadius: action.first ? control.cornerRadius - 1 : 0
      bottomRightRadius: action.last ? control.cornerRadius - 1 : 0
      gradient: Gradient {
        GradientStop { position: 0; color: action.down ? "#0b8cff" : "#8ccfff" }
        GradientStop { position: 1; color: action.down ? "#0aa1ff" : "#4bb8ff" }
      }
    }
  }

  contentItem: ListView {
    implicitWidth: contentWidth
    implicitHeight: 28
    model: control.contentModel
    spacing: control.spacing
    orientation: ListView.Horizontal
    boundsBehavior: Flickable.StopAtBounds
    interactive: false
  }

  background: Item {
    Rectangle {
      width: parent.width
      height: 1
      color: GxdePalette.dialogActionBorder
    }

    Repeater {
      model: control.count - 1

      Rectangle {
        required property int index

        x: (index + 1) * parent.width / control.count
        y: 1
        width: 1
        height: parent.height - 1
        color: GxdePalette.frameBorder
      }
    }
  }
}
