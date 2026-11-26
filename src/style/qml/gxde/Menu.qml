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
  // Qt does not grow popup windows by negative insets on Wayland, which
  // would clip the shadow.  There the shadow room is padding inside the
  // window instead, and the window moves back by it.
  readonly property int windowMargin: wayland ? shadowMargin : 0
  property bool blurBehind: false

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          contentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           contentHeight + topPadding + bottomPadding)

  leftPadding: windowMargin
  rightPadding: windowMargin
  topPadding: 4 + windowMargin
  bottomPadding: 4 + windowMargin
  margins: 0
  overlap: 0
  popupType: T.Popup.Window
  leftInset: windowMargin - shadowMargin
  rightInset: windowMargin - shadowMargin
  topInset: windowMargin - shadowMargin
  bottomInset: windowMargin - shadowMargin

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
    // As wide as the widest item, so long texts are not cut; the menu
    // keeps the background's width as its least width.
    implicitWidth: {
      let width = 0
      for (let i = 0; i < control.count; ++i) {
        const item = control.itemAt(i)
        if (item)
          width = Math.max(width, item.implicitWidth)
      }
      return width
    }
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

    // On Wayland the menu opens at the bottom left of its parent, with the
    // window there, not the panel inside its shadow room.  Qt reads the
    // offset when it shows the window, right after the menu moves into it.
    Window.onWindowChanged: {
      const window = Window.window
      if (control.windowMargin > 0 && window
          && (!control.parent || window !== control.parent.Window.window))
        WindowEffects.setPopupOffset(window, -control.windowMargin, -control.windowMargin)
    }

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
