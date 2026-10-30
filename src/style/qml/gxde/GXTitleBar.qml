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
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Gxde

T.Control {
  id: control

  property QtObject targetWindow: Window.window

  property string title: targetWindow && targetWindow.title ? targetWindow.title
                                                             : Qt.application.name

  property string iconName
  property url iconSource

  property int barHeight: 40

  property bool embedMode: false
  property bool backgroundTransparent: false
  property bool separatorVisible: false

  property bool autoHideOnFullscreen: false

  property int disableFlags: 0

  property T.Menu menu: null

  property bool helpVisible: false
  property bool menuVisible: windowType === Qt.Window
  property bool menuDisabled: false

  property Item customItem: null
  property int customAlignment: Qt.AlignCenter

  property bool fixCenterPos: false

  readonly property bool customMode: customItem !== null || priv.slots.length > 0
  readonly property int buttonAreaWidth: buttonRow.width
  readonly property T.Menu currentMenu: menu ?? defaultMenu

  readonly property int windowType: (targetWindow ? targetWindow.flags : Qt.Window) & 0xff
  readonly property bool fullScreen: targetWindow !== null
                                     && targetWindow.visibility === Window.FullScreen
  readonly property bool maximized: targetWindow !== null
                                    && targetWindow.visibility === Window.Maximized

  signal optionClicked()
  signal doubleClicked()
  signal mousePressed(int buttons)
  signal mouseMoving(int button)
  signal helpRequested()
  signal aboutRequested()

  function toggleWindowState() {
    if (!targetWindow || (disableFlags & Qt.WindowMaximizeButtonHint))
      return
    if (maximized)
      targetWindow.showNormal()
    else if (!fullScreen && maxButton.visible)
      targetWindow.showMaximized()
  }

  function showMenu() {
    const menu = currentMenu
    addDefaultMenuItems(menu)
    menu.popup(optionButton, 0, optionButton.height)
  }

  function addItem(item, alignment) {
    if (!item)
      return
    const slot = slotComponent.createObject(customRow, {
      target: item,
      alignment: alignment === undefined ? Qt.AlignCenter : alignment
    })
    priv.slots = priv.slots.concat([slot])
  }

  function addDefaultMenuItems(menu) {
    if (priv.extendedMenus.includes(menu))
      return
    priv.extendedMenus.push(menu)

    if (menu.count > 0)
      menu.addItem(separatorComponent.createObject(null))
    if (helpVisible)
      menu.addItem(menuItemComponent.createObject(null, {
        text: qsTranslate("TitleBarMenu", "Help"),
        handler: () => control.helpRequested()
      }))
    menu.addItem(menuItemComponent.createObject(null, {
      text: qsTranslate("TitleBarMenu", "About"),
      handler: () => control.aboutRequested()
    }))
    menu.addItem(menuItemComponent.createObject(null, {
      text: qsTranslate("TitleBarMenu", "Exit"),
      handler: () => Qt.quit()
    }))
  }

  function rebuildCustomArea() {
    for (const slot of priv.slots) {
      if (slot.target)
        slot.target.parent = null
      slot.destroy()
    }
    priv.slots = []
    if (customItem)
      addItem(customItem, customAlignment)
  }

  function windowFlags() {
    let flags = targetWindow ? targetWindow.flags : Qt.Window
    if (flags & Qt.CustomizeWindowHint)
      return flags
    const common = Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowCloseButtonHint
    if (windowType === Qt.Dialog || windowType === Qt.Sheet || windowType === Qt.Tool)
      return flags | common
    if (!(flags & Qt.FramelessWindowHint))
      return flags | common | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint
    return flags
  }

  onCustomItemChanged: rebuildCustomArea()
  onCustomAlignmentChanged: rebuildCustomArea()
  onTitleChanged: {

    if (embedMode && targetWindow && title)
      targetWindow.title = title
  }

  implicitWidth: buttonRow.width + 6
  implicitHeight: priv.hideForFullScreen ? 0 : barHeight
  z: 100

  QtObject {
    id: priv

    property var slots: []
    property var extendedMenus: []
    property bool revealed: false

    readonly property int flags: control.windowFlags()

    readonly property bool forceShow: Qt.platform.pluginName === "xcb"
    readonly property bool forceHide: control.embedMode || control.fullScreen
    readonly property bool showTitle: ((flags & Qt.WindowTitleHint) || forceShow)
                                      && !control.embedMode
    readonly property bool resizable: !control.targetWindow
                                      || control.targetWindow.minimumWidth !== control.targetWindow.maximumWidth
                                      || control.targetWindow.minimumHeight !== control.targetWindow.maximumHeight
    readonly property bool hideForFullScreen: control.autoHideOnFullscreen && control.fullScreen
    readonly property bool iconSet: control.iconName !== "" || control.iconSource.toString() !== ""

    onHideForFullScreenChanged: revealed = false
  }

  Component {
    id: separatorComponent
    MenuSeparator { }
  }

  Component {
    id: menuItemComponent
    MenuItem {
      property var handler
      onTriggered: handler()
    }
  }

  Component {
    id: slotComponent

    Item {
      id: slot

      property Item target
      property int alignment
      readonly property int horizontal: alignment & (Qt.AlignLeft | Qt.AlignRight | Qt.AlignHCenter)
      readonly property int vertical: alignment & (Qt.AlignTop | Qt.AlignBottom | Qt.AlignVCenter)

      readonly property real targetWidth: target ? target.width : 0
      readonly property real targetHeight: target ? target.height : 0

      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.preferredWidth: target ? (horizontal ? targetWidth : target.implicitWidth) : 0

      Component.onCompleted: target.parent = slot

      Binding {
        target: slot.target
        when: slot.target !== null
        property: "x"
        value: slot.horizontal & Qt.AlignRight ? slot.width - slot.targetWidth
             : slot.horizontal & Qt.AlignHCenter ? Math.round((slot.width - slot.targetWidth) / 2)
             : 0
      }
      Binding {
        target: slot.target
        when: slot.target !== null
        property: "y"
        value: slot.vertical & Qt.AlignBottom ? slot.height - slot.targetHeight
             : slot.vertical & Qt.AlignVCenter ? Math.round((slot.height - slot.targetHeight) / 2)
             : 0
      }
      Binding {
        target: slot.target
        when: slot.target !== null && !slot.horizontal
        property: "width"
        value: slot.width
      }
      Binding {
        target: slot.target
        when: slot.target !== null && !slot.vertical
        property: "height"
        value: slot.height
      }
    }
  }

  Menu {
    id: defaultMenu
  }

  Item {
    width: control.width
    height: 2
    visible: priv.hideForFullScreen && !priv.revealed

    HoverHandler {
      onHoveredChanged: {
        if (hovered)
          priv.revealed = true
      }
    }
  }

  Item {
    id: panel

    width: control.width
    height: control.barHeight
    visible: !priv.hideForFullScreen || priv.revealed

    HoverHandler {
      onHoveredChanged: {
        if (!hovered && priv.hideForFullScreen && !control.currentMenu.opened)
          priv.revealed = false
      }
    }

    Rectangle {
      anchors.fill: parent
      visible: !control.backgroundTransparent
      gradient: Gradient {
        GradientStop { position: 0; color: GxdePalette.titlebarTop }
        GradientStop { position: 1; color: GxdePalette.titlebarBottom }
      }
    }

    MouseArea {
      property bool moveOnDrag: false

      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onPressed: mouse => {

        if (mouse.button === Qt.RightButton)
          return
        moveOnDrag = mouse.buttons === Qt.LeftButton
        control.mousePressed(mouse.buttons)
      }
      onPositionChanged: mouse => {
        if (mouse.buttons !== Qt.LeftButton)
          return
        control.mouseMoving(Qt.LeftButton)

        if (moveOnDrag && control.targetWindow) {
          moveOnDrag = false
          control.targetWindow.startSystemMove()
        }
      }
      onReleased: moveOnDrag = false
      onDoubleClicked: mouse => {
        if (mouse.button !== Qt.LeftButton)
          return
        moveOnDrag = false
        control.doubleClicked()
        control.toggleWindowState()
      }
    }

    Item {
      id: titleArea

      x: 6
      width: control.width - x - buttonRow.width
      height: parent.height
      visible: !control.customMode

      IconImage {
        id: iconImage

        x: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        sourceSize: Qt.size(24, 24)
        name: control.iconName
        source: control.iconSource
        visible: priv.showTitle
      }

      Text {
        id: titleText

        readonly property int rightMargin: priv.iconSet ? 0 : 24 + 10
        readonly property real minX: iconImage.x + iconImage.width + buttonRow.width
        readonly property real maxX: titleArea.width - 24 - 10 - rightMargin

        x: Math.max(minX, Math.round((minX + maxX - implicitWidth) / 2))
        width: Math.min(implicitWidth, Math.max(0, maxX - minX))
        anchors.verticalCenter: parent.verticalCenter
        visible: priv.showTitle
        text: control.title
        elide: Text.ElideRight
        font.family: control.font.family
        font.pixelSize: 12
        color: GxdePalette.text
      }
    }

    Item {
      x: 6
      width: control.width - x - buttonRow.width
      height: parent.height
      visible: control.customMode

      RowLayout {
        id: customRow

        anchors.fill: parent
        spacing: 0

        Item {
          visible: control.fixCenterPos
          Layout.preferredWidth: buttonRow.width
          Layout.fillHeight: true
        }
      }
    }

    Row {
      id: buttonRow

      anchors.right: parent.right
      height: parent.height

      TitleBarButton {
        id: optionButton
        objectName: "GXTitleBarOptionButton"
        height: parent.height
        name: "menu"
        visible: control.menuVisible
        enabled: !control.menuDisabled
        onClicked: {
          control.optionClicked()
          control.showMenu()
        }
      }

      TitleBarButton {
        id: minButton
        objectName: "GXTitleBarMinButton"
        height: parent.height
        name: "minimize"
        visible: ((priv.flags & Qt.WindowMinimizeButtonHint) || priv.forceShow) && !priv.forceHide
        enabled: !(control.disableFlags & Qt.WindowMinimizeButtonHint)
        onClicked: control.targetWindow.showMinimized()
      }

      TitleBarButton {
        id: maxButton
        objectName: "GXTitleBarMaxButton"
        height: parent.height
        name: control.maximized ? "unmaximize" : "maximize"
        visible: ((priv.flags & Qt.WindowMaximizeButtonHint) || priv.forceShow)
                 && !priv.forceHide && priv.resizable
        enabled: !(control.disableFlags & Qt.WindowMaximizeButtonHint)
        onClicked: control.toggleWindowState()
      }

      TitleBarButton {
        id: closeButton
        objectName: "GXTitleBarCloseButton"
        height: parent.height
        name: "close"
        visible: ((priv.flags & Qt.WindowCloseButtonHint) || priv.forceShow) && !priv.forceHide
        enabled: !(control.disableFlags & Qt.WindowCloseButtonHint)
        onClicked: control.targetWindow.close()
      }

      TitleBarButton {
        id: quitFullButton
        objectName: "GXTitleBarQuitFullscreenButton"
        height: parent.height
        name: "quit_fullscreen"
        hasDisabledPicture: false
        visible: priv.hideForFullScreen
        onClicked: {
          if (control.fullScreen)
            control.targetWindow.showNormal()
          else
            control.targetWindow.showFullScreen()
        }
      }
    }

    Rectangle {
      width: parent.width
      height: 1
      color: Qt.rgba(0, 0, 0, 20 / 255)
      visible: control.embedMode
    }

    Rectangle {
      y: parent.height - height
      width: parent.width
      height: 1
      color: Qt.rgba(0, 0, 0, 20 / 255)
      visible: control.separatorVisible
    }
  }
}
