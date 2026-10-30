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
import QtQuick.Effects
import QtQuick.Templates as T
import QtQuick.Controls.Gxde
import QtQuick.Window

T.Menu {
  id: control

  readonly property bool wayland: Qt.platform.pluginName.startsWith("wayland")
  readonly property int radius: wayland ? 8 : 4
  readonly property int shadowMargin: wayland ? 18 : 20
  property bool blurBehind: false

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          contentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           contentHeight + topPadding + bottomPadding)

  leftPadding: 0
  rightPadding: 0
  topPadding: 4
  bottomPadding: 4
  margins: 0
  overlap: 0
  popupType: T.Popup.Window
  leftInset: -shadowMargin
  rightInset: -shadowMargin
  topInset: -shadowMargin
  bottomInset: -shadowMargin

  function updateBlur() {
    const window = background.Window.window
    if (!opened || !window || (parent && window === parent.Window.window))
      return

    blurBehind = WindowEffects.isBlurSupported()
    if (blurBehind)
      WindowEffects.setBlurBehind(window, panel.mapToItem(null, 0, 0, panel.width, panel.height),
                                  radius)
  }

  onOpened: Qt.callLater(updateBlur)
  onWidthChanged: Qt.callLater(updateBlur)
  onHeightChanged: Qt.callLater(updateBlur)

  delegate: MenuItem { }

  contentItem: ListView {
    implicitHeight: contentHeight
    model: control.contentModel
    interactive: Window.window
                 ? contentHeight + control.topPadding + control.bottomPadding > control.height
                 : false
    clip: true
    currentIndex: control.currentIndex

    T.ScrollIndicator.vertical: ScrollIndicator { }
  }

  background: Item {
    implicitWidth: 159 + 2 * control.shadowMargin
    implicitHeight: 19 + 2 * control.shadowMargin

    Item {
      id: shadow

      anchors.fill: parent
      visible: false
      layer.enabled: true

      RectangularShadow {
        x: panel.x
        y: panel.y
        width: panel.width
        height: panel.height
        offset.y: control.wayland ? 3 : 4
        radius: control.radius
        blur: control.wayland ? 14 : 15
        color: control.wayland ? Qt.rgba(0, 0, 0, 0.18) : Qt.rgba(0, 0, 0, 100 / 255)
      }
    }

    Item {
      id: panelShape

      anchors.fill: parent
      visible: false
      layer.enabled: true

      Rectangle {
        x: panel.x
        y: panel.y
        width: panel.width
        height: panel.height
        radius: control.radius
      }
    }

    // Shadow outside panel
    MultiEffect {
      anchors.fill: parent
      source: shadow
      maskEnabled: true
      maskInverted: true
      maskSource: panelShape
    }

    Rectangle {
      id: panel

      anchors.fill: parent
      anchors.margins: control.shadowMargin
      radius: control.radius
      color: control.blurBehind ? Qt.alpha(GxdePalette.menuBackground, control.wayland ? 0.45 : 0.6)
                                : GxdePalette.menuBackground
      border.width: 1
      border.color: control.wayland ? Qt.rgba(0, 0, 0, 20 / 255) : GxdePalette.menuBorder
    }
  }

  T.Overlay.modal: Rectangle {
    color: Qt.rgba(0, 0, 0, 0.3)
  }

  T.Overlay.modeless: Rectangle {
    color: "transparent"
  }
}
