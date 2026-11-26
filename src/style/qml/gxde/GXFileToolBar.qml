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
import QtQuick.Controls.impl
import QtQuick.Controls.Gxde

// The tool bar of the file manager made for the title bar:
//
//   GXMainWindow {
//     titlebar.customAlignment: Qt.AlignVCenter
//     titlebar.customItem: GXFileToolBar {
//       folder: view.folder
//       onFolderRequested: url => view.folder = url
//     }
//   }
//
// It keeps the history of the folders it was shown, for back and forward.
FocusScope {
  id: control

  // The shown folder.  Set it from the view; the buttons only request
  // changes with folderRequested().
  property url folder
  property int viewMode: GXFileView.IconMode
  property bool sideBarVisible: true
  property bool detailsVisible: false

  // The application icon at the start, as DFM shows it in its title bar.
  property string iconName
  property url iconSource

  property bool sideBarButtonVisible: true
  property bool viewButtonsVisible: true
  property bool detailsButtonVisible: true
  property bool newTabButtonVisible: false
  // Alt+Left, Alt+Right, Alt+Up, Ctrl+L, Ctrl+F, Ctrl+1 and Ctrl+2.
  property bool shortcutsEnabled: true
  property font font: Qt.application.font

  readonly property bool canGoBack: priv.index > 0
  readonly property bool canGoForward: priv.index >= 0 && priv.index < priv.history.length - 1
  readonly property bool canGoUp: parentFolder(folder).toString().length > 0
  readonly property alias crumbBar: crumbBarItem

  signal folderRequested(url folder)
  signal searchRequested(string text)
  signal newTabRequested()

  implicitWidth: layout.implicitWidth
  implicitHeight: 40

  // The folder above a local folder, or an empty URL.
  function parentFolder(url) {
    const path = crumbBarItem.localPath(url)
    if (!path || path === "/")
      return ""
    const parent = path.slice(0, path.lastIndexOf("/"))
    return crumbBarItem.fileUrl(parent || "/")
  }

  function back() {
    if (canGoBack)
      priv.go(priv.index - 1)
  }

  function forward() {
    if (canGoForward)
      priv.go(priv.index + 1)
  }

  function up() {
    if (canGoUp)
      control.folderRequested(parentFolder(folder))
  }

  function clearHistory() {
    priv.history = folder.toString() ? [folder.toString()] : []
    priv.index = priv.history.length - 1
  }

  onFolderChanged: priv.visit(folder.toString())
  Component.onCompleted: priv.visit(folder.toString())

  QtObject {
    id: priv

    property var history: []
    property int index: -1
    // The history entry back() or forward() asked for, until it is shown.
    property int pending: -1

    function go(target) {
      pending = target
      control.folderRequested(history[target])
    }

    function visit(url) {
      if (!url)
        return
      if (pending >= 0 && history[pending] === url) {
        index = pending
        pending = -1
        return
      }
      pending = -1
      if (index >= 0 && history[index] === url)
        return
      const list = history.slice(0, index + 1)
      list.push(url)
      history = list
      index = list.length - 1
    }
  }

  RowLayout {
    id: layout

    anchors.fill: parent
    spacing: 0

    IconImage {
      Layout.leftMargin: 6
      Layout.rightMargin: 12
      Layout.preferredWidth: 24
      Layout.preferredHeight: 24
      visible: control.iconName.length > 0 || control.iconSource.toString().length > 0
      sourceSize: Qt.size(24, 24)
      name: control.iconName
      source: control.iconSource
    }

    ToolBarButton {
      Layout.leftMargin: 14
      Layout.rightMargin: 6
      visible: control.sideBarButtonVisible
      iconName: "sidebar"
      text: qsTranslate("DToolBar", "Show/hide sidebar")
      checkable: true
      checked: control.sideBarVisible
      pressStyle: "fill"
      hoverOverChecked: true
      onToggled: control.sideBarVisible = checked
    }

    // Back, forward and up share a frame.
    Rectangle {
      Layout.leftMargin: control.sideBarButtonVisible ? 0 : 14
      Layout.preferredWidth: navigation.width
      Layout.preferredHeight: 24
      radius: 4
      // Dark buttons draw their own backgrounds, without borders.
      color: GxdeTheme.isDark ? "transparent" : "#ffffff"
      border.width: GxdeTheme.isDark ? 0 : 1
      border.color: Qt.rgba(0, 0, 0, 0.1)

      Row {
        id: navigation

        ToolBarButton {
          iconName: "back"
          grouped: true
          roundRight: false
          enabled: control.canGoBack
          onClicked: control.back()
        }

        ToolBarButton {
          iconName: "forward"
          grouped: true
          roundLeft: false
          roundRight: false
          enabled: control.canGoForward
          onClicked: control.forward()
        }

        ToolBarButton {
          iconName: "up"
          grouped: true
          roundLeft: false
          enabled: control.canGoUp
          onClicked: control.up()
        }
      }
    }

    GXCrumbBar {
      id: crumbBarItem

      Layout.fillWidth: true
      Layout.leftMargin: 10
      Layout.preferredHeight: 24
      Layout.minimumWidth: 1
      folder: control.folder
      font: control.font
      onFolderRequested: url => control.folderRequested(url)
      onSearchRequested: text => control.searchRequested(text)
    }

    ToolBarButton {
      Layout.leftMargin: 10
      iconName: "search"
      pressStyle: "outline"
      onClicked: {
        if (crumbBarItem.addressBarVisible && crumbBarItem.searchMode)
          crumbBarItem.hideAddressBar()
        else
          crumbBarItem.showAddressBar(true)
      }
    }

    // The view mode buttons, in a frame one pixel around them.
    Rectangle {
      Layout.leftMargin: 3
      Layout.preferredWidth: viewButtons.width + 2
      Layout.preferredHeight: 24
      visible: control.viewButtonsVisible
      radius: 4
      color: Qt.rgba(0, 0, 0, 0.1)

      Row {
        id: viewButtons

        x: 1
        y: 1

        ToolBarButton {
          width: 22
          height: 22
          iconName: "icon_view"
          bordered: false
          radius: 3
          roundRight: false
          checked: control.viewMode === GXFileView.IconMode
          onClicked: control.viewMode = GXFileView.IconMode
        }

        ToolBarButton {
          width: 22
          height: 22
          iconName: "list_view"
          bordered: false
          radius: 3
          roundLeft: false
          roundRight: !control.detailsButtonVisible
          checked: control.viewMode === GXFileView.ListMode
          onClicked: control.viewMode = GXFileView.ListMode
        }

        ToolBarButton {
          width: 22
          height: 22
          visible: control.detailsButtonVisible
          iconName: "details"
          bordered: false
          radius: 3
          roundLeft: false
          checkable: true
          checked: control.detailsVisible
          onToggled: control.detailsVisible = checked
        }
      }
    }

    Button {
      Layout.leftMargin: 14
      Layout.preferredWidth: 25
      Layout.preferredHeight: 25
      visible: control.newTabButtonVisible
      padding: 0
      text: "+"
      font.pixelSize: control.font.pixelSize > 0 ? control.font.pixelSize : 13
      font.weight: Font.Light
      focusPolicy: Qt.NoFocus
      onClicked: control.newTabRequested()
    }

    Item {
      Layout.preferredWidth: 12
    }
  }

  Shortcut {
    enabled: control.shortcutsEnabled
    sequence: "Alt+Left"
    onActivated: control.back()
  }

  Shortcut {
    enabled: control.shortcutsEnabled
    sequence: "Alt+Right"
    onActivated: control.forward()
  }

  Shortcut {
    enabled: control.shortcutsEnabled
    sequence: "Alt+Up"
    onActivated: control.up()
  }

  Shortcut {
    enabled: control.shortcutsEnabled
    sequence: "Ctrl+L"
    onActivated: crumbBarItem.showAddressBar(false)
  }

  Shortcut {
    enabled: control.shortcutsEnabled
    sequences: [StandardKey.Find]
    onActivated: crumbBarItem.showAddressBar(true)
  }

  Shortcut {
    enabled: control.shortcutsEnabled
    sequence: "Ctrl+1"
    onActivated: control.viewMode = GXFileView.IconMode
  }

  Shortcut {
    enabled: control.shortcutsEnabled
    sequence: "Ctrl+2"
    onActivated: control.viewMode = GXFileView.ListMode
  }
}
