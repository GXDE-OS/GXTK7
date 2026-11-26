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

import QtCore
import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Gxde

// The location bar of the file manager
FocusScope {
  id: control

  // The shown location.  Set it from the view
  property url folder
  // Locations under it start with a Home crumb, like DFM.
  property string homePath: localPath(StandardPaths.writableLocation(StandardPaths.HomeLocation))
  property font font: Qt.application.font

  readonly property bool addressBarVisible: priv.editing
  readonly property bool searchMode: priv.searchMode
  readonly property var crumbs: crumbsOf(folder)

  readonly property bool dark: GxdeTheme.isDark

  signal folderRequested(url folder)
  signal searchRequested(string text)

  implicitWidth: 200
  implicitHeight: 24

  // The local path of a file URL, or an empty string.
  function localPath(url) {
    const text = url.toString()
    if (!text.startsWith("file://"))
      return ""
    const path = decodeURIComponent(text.slice("file://".length))
    return path.length > 1 && path.endsWith("/") ? path.slice(0, -1) : path
  }

  function fileUrl(path) {
    return "file://" + encodeURI(path).replace(/#/g, "%23").replace(/\?/g, "%3F")
  }

  function crumbsOf(url) {
    const text = url.toString()
    if (!text)
      return []

    const path = localPath(url)
    if (!path && !text.startsWith("file:")) {
      const scheme = text.slice(0, text.indexOf(":"))
      const names = {
        computer: qsTranslate("PathManager", "Computer"),
        trash: qsTranslate("PathManager", "Trash"),
        recent: qsTranslate("PathManager", "Recent"),
        network: qsTranslate("PathManager", "Network")
      }
      return [{ url: text, text: names[scheme] ?? text, kind: scheme in names ? scheme : "" }]
    }

    let prefix = "/"
    const list = []
    const home = homePath
    const media = /^(\/run)?\/media\/[^/]+\/[^/]+/.exec(path)
    if (home && (path === home || path.startsWith(home + "/"))) {
      prefix = home
      list.push({ url: fileUrl(home), text: qsTranslate("PathManager", "Home"), kind: "home" })
    } else if (media) {
      // A removable disk shows its icon only, as DFM does.
      prefix = media[0]
      list.push({ url: fileUrl(prefix), text: "", kind: "usb" })
    } else {
      list.push({ url: "file:///", text: qsTranslate("PathManager", "System Disk"), kind: "disk" })
    }

    const rest = path.slice(prefix.length).split("/").filter(part => part.length > 0)
    let current = prefix === "/" ? "" : prefix
    for (const part of rest) {
      current += "/" + part
      list.push({ url: fileUrl(current), text: part, kind: "" })
    }
    return list
  }

  // Shows the address bar.  A search starts empty with a search indicator;
  // otherwise it holds the location.
  function showAddressBar(search) {
    priv.searchMode = search === true
    addressField.text = priv.searchMode ? "" : (localPath(folder) || folder.toString())
    priv.editing = true
    addressField.forceActiveFocus()
    addressField.cursorPosition = addressField.length
    priv.updateCompletions()
  }

  function hideAddressBar() {
    completer.close()
    priv.editing = false
  }

  // Opens what the address bar holds: a folder, a URL, or else a search.
  function accept(text) {
    let target = text.trim()
    if (!target) {
      hideAddressBar()
      return
    }
    if (target === "~" || target.startsWith("~/"))
      target = homePath + target.slice(1)

    if (target.startsWith("/")) {
      probe.folder = fileUrl(target)
      const exists = probe.exists
      probe.folder = ""
      if (!exists) {
        // Like DFM, a missing location keeps the bar open to be fixed.
        addressField.selectAll()
        return
      }
      hideAddressBar()
      control.folderRequested(fileUrl(target))
    } else if (/^[a-z][a-z0-9+.-]*:/i.test(target)) {
      hideAddressBar()
      control.folderRequested(target)
    } else {
      hideAddressBar()
      control.searchRequested(target)
    }
  }

  onCrumbsChanged: Qt.callLater(priv.scrollToEnd)
  onActiveFocusChanged: {
    if (!activeFocus && priv.editing)
      hideAddressBar()
  }

  QtObject {
    id: priv

    property bool editing: false
    property bool searchMode: false
    // Folder names completing the last part of the typed path.
    property var completions: []
    // The typed path up to its last part, to which completions are added.
    property string completionBase

    // Measured against the whole bar: the arrows take room from the crumbs.
    readonly property bool overflow: crumbRow.width + 30 > control.width
    readonly property bool jumpIndicator: {
      const text = addressField.text
      if (!text)
        return !searchMode
      return text.startsWith("/") || text.startsWith("~") || /^[a-z][a-z0-9+.-]*:/i.test(text)
    }

    function scrollToEnd() {
      crumbView.contentX = Math.max(0, crumbView.contentWidth - crumbView.width)
    }

    function scrollBy(delta) {
      crumbView.contentX = Math.max(0, Math.min(crumbView.contentWidth - crumbView.width,
                                                crumbView.contentX + delta))
    }

    function updateCompletions() {
      let text = addressField.text
      if (text === "~" || text.startsWith("~/"))
        text = control.homePath + text.slice(1)
      if (!editing || !text.startsWith("/")) {
        completions = []
        completer.close()
        return
      }

      const slash = text.lastIndexOf("/")
      const base = text.slice(0, slash + 1)
      const part = text.slice(slash + 1).toLowerCase()
      completionModel.showHidden = part.startsWith(".")
      completionModel.folder = control.fileUrl(base)

      const names = []
      for (let row = 0; row < completionModel.count && names.length < 100; ++row) {
        const name = completionModel.get(row).fileName
        if (name.toLowerCase().startsWith(part) && name.toLowerCase() !== part)
          names.push(name)
      }
      completionBase = addressField.text.slice(0, addressField.text.lastIndexOf("/") + 1)
      completions = names
      completionList.currentIndex = -1
      if (names.length > 0)
        completer.open()
      else
        completer.close()
    }

    // Puts a completion into the address bar.  A folder chosen to go on
    // typing gets a slash, which lists its own folders.
    function complete(index, goOn) {
      const name = completions[index]
      if (name === undefined)
        return
      addressField.text = completionBase + name + (goOn ? "/" : "")
      addressField.cursorPosition = addressField.length
      if (goOn)
        updateCompletions()
      else
        completer.close()
    }
  }

  GXFileSystemModel {
    id: completionModel

    showFiles: false
  }

  GXFileSystemModel {
    id: probe

    showFiles: false
  }

  // The crumbs.
  Rectangle {
    anchors.fill: parent
    visible: !priv.editing
    radius: 4
    color: control.dark ? "#343434" : "#ffffff"
    border.width: control.dark ? 0 : 1
    border.color: Qt.rgba(0, 0, 0, 30 / 255)

    ToolBarButton {
      id: leftArrow

      width: 26
      height: parent.height
      visible: priv.overflow
      enabled: crumbView.contentX > 0
      iconName: "back"
      roundRight: false
      onClicked: priv.scrollBy(-crumbView.width)
    }

    Flickable {
      id: crumbView

      x: priv.overflow ? leftArrow.width : 0
      width: parent.width - (priv.overflow ? leftArrow.width + rightArrow.width : 0)
      height: parent.height
      contentWidth: Math.max(width, crumbRow.width + 30)
      contentHeight: height
      interactive: false
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      onWidthChanged: Qt.callLater(priv.scrollToEnd)

      // A click on the empty part opens the address bar.
      MouseArea {
        width: crumbView.contentWidth
        height: crumbView.height
        acceptedButtons: Qt.LeftButton
        onClicked: control.showAddressBar(false)
        onWheel: wheel => {
          const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x
          priv.scrollBy(-delta / 2)
        }
      }

      Row {
        id: crumbRow

        height: crumbView.height

        Repeater {
          model: control.crumbs

          delegate: T.AbstractButton {
            id: crumb

            required property var modelData
            required property int index
            readonly property bool current: crumb.index === control.crumbs.length - 1
            readonly property bool hasIcon: modelData.kind.length > 0

            height: crumbRow.height
            leftPadding: hasIcon ? 4 : 10
            rightPadding: hasIcon ? 4 : 10
            implicitWidth: implicitContentWidth + leftPadding + rightPadding
            checked: current
            focusPolicy: Qt.NoFocus
            hoverEnabled: true
            font: control.font
            text: modelData.text

            onClicked: {
              if (!current)
                control.folderRequested(crumb.modelData.url)
            }

            contentItem: Row {
              spacing: 4

              Image {
                anchors.verticalCenter: parent.verticalCenter
                visible: crumb.hasIcon
                sourceSize: Qt.size(16, 16)
                source: !crumb.hasIcon ? ""
                      : crumb.checked ? "assets/crumb/%1_checked.svg".arg(crumb.modelData.kind)
                      : "assets/%1/sidebar/%2_normal.svg".arg(control.dark ? "dark" : "light")
                                                        .arg(crumb.modelData.kind)
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: text.length > 0
                text: crumb.text
                font: crumb.font
                color: crumb.checked ? "#ffffff" : GxdePalette.buttonText
              }
            }

            background: Rectangle {
              visible: crumb.checked
              color: GxdePalette.accent
              radius: 4
              topLeftRadius: crumb.hasIcon ? 4 : 0
              bottomLeftRadius: crumb.hasIcon ? 4 : 0
              border.width: crumb.hasIcon || control.dark ? 0 : 1
              border.color: "#1088ff"
            }
          }
        }
      }
    }

    ToolBarButton {
      id: rightArrow

      anchors.right: parent.right
      width: 26
      height: parent.height
      visible: priv.overflow
      enabled: crumbView.contentX < crumbView.contentWidth - crumbView.width - 1
      iconName: "forward"
      roundLeft: false
      onClicked: priv.scrollBy(crumbView.width)
    }
  }

  // The address bar.
  T.TextField {
    id: addressField

    anchors.fill: parent
    visible: priv.editing
    leftPadding: 24
    rightPadding: 24
    topPadding: 0
    bottomPadding: 0
    font: control.font
    color: GxdePalette.text
    selectionColor: GxdePalette.highlight
    selectedTextColor: GxdePalette.highlightedText
    verticalAlignment: TextInput.AlignVCenter
    selectByMouse: true
    placeholderText: qsTranslate("DFMAddressBar", "Search or enter address")
    placeholderTextColor: Qt.alpha(GxdePalette.text, 0.5)

    onTextEdited: priv.updateCompletions()
    onAccepted: {
      if (completer.opened && completionList.currentIndex >= 0)
        priv.complete(completionList.currentIndex, false)
      control.accept(text)
    }

    Keys.onPressed: event => {
      switch (event.key) {
      case Qt.Key_Escape:
        control.hideAddressBar()
        event.accepted = true
        break
      case Qt.Key_Down:
      case Qt.Key_Up:
        if (completer.opened) {
          // -1 is the typed text itself, above the first completion.
          const index = completionList.currentIndex + (event.key === Qt.Key_Down ? 1 : -1)
          completionList.currentIndex = Math.max(-1, Math.min(priv.completions.length - 1, index))
          completionList.positionViewAtIndex(Math.max(0, completionList.currentIndex), ListView.Contain)
          event.accepted = true
        }
        break
      case Qt.Key_Tab:
        if (completer.opened)
          priv.complete(Math.max(0, completionList.currentIndex), true)
        event.accepted = true
        break
      }
    }

    // Like DFM, the placeholder sits in the middle.
    Text {
      anchors.fill: parent
      anchors.leftMargin: addressField.leftPadding
      anchors.rightMargin: addressField.rightPadding
      visible: !addressField.length && !addressField.preeditText
      text: addressField.placeholderText
      font: addressField.font
      color: addressField.placeholderTextColor
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
    }

    Image {
      x: 4
      anchors.verticalCenter: parent.verticalCenter
      sourceSize: Qt.size(16, 16)
      source: "assets/%1/toolbar/indicator_%2.svg".arg(control.dark ? "dark" : "light")
                                                   .arg(priv.jumpIndicator ? "jump" : "search")

      MouseArea {
        anchors.fill: parent
        onClicked: control.accept(addressField.text)
      }
    }

    Image {
      id: clearButton

      anchors.right: parent.right
      anchors.rightMargin: 4
      anchors.verticalCenter: parent.verticalCenter
      visible: addressField.length > 0
      sourceSize: Qt.size(16, 16)
      source: "assets/%1/toolbar/clear_%2.svg".arg(control.dark ? "dark" : "light")
                                               .arg(clearArea.pressed ? "press"
                                                    : clearArea.containsMouse ? "hover" : "normal")

      MouseArea {
        id: clearArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          addressField.clear()
          priv.updateCompletions()
        }
      }
    }

    background: EditFrame {
      target: addressField
    }
  }

  T.Popup {
    id: completer

    y: control.height + 2
    width: control.width
    height: Math.min(completionList.contentHeight, 24 * 10) + topPadding + bottomPadding
    padding: 1
    topPadding: 4
    bottomPadding: 4
    focus: false
    closePolicy: T.Popup.CloseOnPressOutsideParent

    contentItem: ListView {
      id: completionList

      clip: true
      model: priv.completions
      currentIndex: -1
      boundsBehavior: Flickable.StopAtBounds

      T.ScrollIndicator.vertical: ScrollIndicator { }

      delegate: Rectangle {
        id: completion

        required property string modelData
        required property int index
        readonly property bool current: ListView.isCurrentItem || completionArea.containsMouse

        width: ListView.view.width
        height: 24
        color: current ? GxdePalette.highlight : "transparent"

        Text {
          anchors.fill: parent
          anchors.leftMargin: 24
          anchors.rightMargin: 8
          verticalAlignment: Text.AlignVCenter
          text: completion.modelData
          font: control.font
          elide: Text.ElideRight
          color: completion.current ? GxdePalette.highlightedText : GxdePalette.text
        }

        MouseArea {
          id: completionArea

          anchors.fill: parent
          hoverEnabled: true
          onClicked: priv.complete(completion.index, true)
        }
      }
    }

    background: Rectangle {
      radius: 4
      color: GxdePalette.menuBackground
      border.width: 1
      border.color: GxdePalette.frameBorder
    }
  }
}
