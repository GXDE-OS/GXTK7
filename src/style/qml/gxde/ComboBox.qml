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
import QtQuick.Templates as T
import QtQuick.Controls.Gxde

T.ComboBox {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          implicitContentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           implicitContentHeight + topPadding + bottomPadding,
                           implicitIndicatorHeight + topPadding + bottomPadding)

  leftPadding: control.editable ? 6 : 7
  rightPadding: 24
  topPadding: 3
  bottomPadding: 3
  implicitContentWidthPolicy: T.ComboBox.WidestText

  readonly property color labelColor: control.editable
      ? (control.enabled ? GxdePalette.text : GxdePalette.textDisabled)
      : GxdePalette.pick(control, GxdePalette.buttonText, GxdePalette.buttonHoverText,
                         GxdePalette.buttonPressText, GxdePalette.buttonText,
                         GxdePalette.buttonDisabledText)

  delegate: T.ItemDelegate {
    id: delegate

    required property var model
    required property int index

    width: ListView.view.width
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
    leftPadding: 7
    rightPadding: 7
    topPadding: 3
    bottomPadding: 4
    highlighted: control.highlightedIndex === index
    hoverEnabled: control.hoverEnabled

    contentItem: Text {
      text: delegate.model[control.textRole]
      font: control.font
      color: delegate.highlighted ? GxdePalette.highlightedText
           : delegate.enabled ? GxdePalette.text : GxdePalette.textDisabled
      elide: Text.ElideRight
      verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
      visible: delegate.highlighted
      color: GxdePalette.highlight
    }
  }

  indicator: Item {
    x: control.mirrored ? 2 : control.width - width - 2
    y: 2
    width: 16
    height: control.height - 4

    Image {
      anchors.centerIn: parent
      source: GxdePalette.dark ? "assets/dark/header_arrow_down.svg"
                               : "assets/light/header_arrow_down.png"
      sourceSize: Qt.size(12, 12)
      opacity: control.enabled ? 1 : 0.4
    }

    Rectangle {
      visible: control.editable
      x: control.mirrored ? parent.width : -1
      y: -1
      width: 1
      height: parent.height + 2
      color: !control.enabled ? GxdePalette.editDisabledBorder
           : control.activeFocus ? GxdePalette.editFocusBorder
           : GxdePalette.editBorder
    }
  }

  contentItem: T.TextField {
    text: control.editable ? control.editText : control.displayText

    enabled: control.editable
    autoScroll: control.editable
    readOnly: control.down
    inputMethodHints: control.inputMethodHints
    validator: control.validator
    selectByMouse: control.selectTextByMouse

    font: control.font
    color: control.labelColor
    selectionColor: GxdePalette.highlight
    selectedTextColor: GxdePalette.highlightedText
    verticalAlignment: Text.AlignVCenter
  }

  background: Loader {
    sourceComponent: control.editable ? editFrame : buttonFrame

    Component {
      id: buttonFrame
      ButtonPanel {
        target: control
        implicitWidth: 62
        visible: !control.flat || control.down || control.hovered
      }
    }

    Component {
      id: editFrame
      EditFrame {
        target: control
        implicitWidth: 62
        implicitHeight: 22
      }
    }
  }

  popup: T.Popup {
    y: control.height
    width: control.width
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    topMargin: 6
    bottomMargin: 6
    padding: 1
    topPadding: 4
    bottomPadding: 4

    contentItem: ListView {
      clip: true
      implicitHeight: contentHeight
      model: control.delegateModel
      currentIndex: control.highlightedIndex
      highlightMoveDuration: 0

      T.ScrollIndicator.vertical: ScrollIndicator { }
    }

    background: Rectangle {
      radius: 4
      color: GxdePalette.window
      border.width: 1
      border.color: GxdePalette.menuBorder
    }
  }
}
