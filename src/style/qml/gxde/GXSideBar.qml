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

import QtCore
import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Gxde

// The left side bar of DFM (DFMSideBar): places in groups, the groups
// split by lines.
//
// model is an array of entries, objects with these fields:
//   group      Name of the group; a line separates two groups.
//   text       The label.
//   url        Where the place is; currentUrl selects the entry.
//   kind       Picks a DFM icon: android, bookmarks, computer, desktop,
//              disk, documents, downloads, dvd, file, home, iphone, music,
//              network, pictures, recent, trash, usb, usershare, videos.
//   iconName   A theme icon, used when kind is not set.
//   ejectable  Shows the eject button of DFM's device items.
T.Control {
  id: control

  property var model: defaultModel
  // DFM's default places.  Computer and Network have DFM's own URLs, which
  // only the application can open.
  readonly property var defaultModel: [
    folderEntry("common", "home", qsTranslate("DFMSideBar", "Home"), StandardPaths.HomeLocation),
    folderEntry("common", "desktop", qsTranslate("DFMSideBar", "Desktop"), StandardPaths.DesktopLocation),
    folderEntry("common", "videos", qsTranslate("DFMSideBar", "Videos"), StandardPaths.MoviesLocation),
    folderEntry("common", "music", qsTranslate("DFMSideBar", "Music"), StandardPaths.MusicLocation),
    folderEntry("common", "pictures", qsTranslate("DFMSideBar", "Pictures"), StandardPaths.PicturesLocation),
    folderEntry("common", "documents", qsTranslate("DFMSideBar", "Documents"), StandardPaths.DocumentsLocation),
    folderEntry("common", "downloads", qsTranslate("DFMSideBar", "Downloads"), StandardPaths.DownloadLocation),
    {
      group: "common",
      kind: "trash",
      text: qsTranslate("DFMSideBar", "Trash"),
      url: StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + "/Trash/files"
    },
    { group: "device", kind: "computer", text: qsTranslate("DFMSideBar", "Computer"), url: "computer:///" },
    { group: "device", kind: "disk", text: qsTranslate("DFMSideBar", "System Disk"), url: "file:///" },
    { group: "network", kind: "network", text: qsTranslate("DFMSideBar", "Network"), url: "network:///" }
  ]

  // The entry whose url this is shows as checked.
  property url currentUrl

  readonly property bool dark: GxdeTheme.isDark
  readonly property color textColor: dark ? "#afafaf" : "#000000"
  readonly property color checkedColor: "#2ca7f8"
  readonly property color hoverColor: dark ? "#1affffff" : "#0c000000"
  readonly property color checkedBackground: "#332ca7f8"
  readonly property color separatorColor: dark ? "#0dffffff" : "#19000000"

  // A click on an entry; currentUrl is already set to it.
  signal activated(var entry)
  signal ejectRequested(var entry)
  // position is in the coordinates of the side bar.
  signal contextMenuRequested(var entry, point position)

  function folderEntry(group, kind, text, location) {
    return { group: group, kind: kind, text: text, url: StandardPaths.writableLocation(location) }
  }

  // Compares URLs, ignoring a trailing slash.
  function sameUrl(a, b) {
    const strip = url => String(url).replace(/(.)\/+$/, "$1")
    return strip(a) === strip(b)
  }

  function iconSource(kind, state) {
    return Qt.resolvedUrl("assets/%1/sidebar/%2_%3.svg".arg(dark ? "dark" : "light").arg(kind).arg(state))
  }

  implicitWidth: 200
  implicitHeight: list.contentHeight

  background: Rectangle {
    color: control.dark ? "#67252525" : "#67f9f9fa"
  }

  contentItem: ListView {
    id: list

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    model: control.model
    ScrollBar.vertical: ScrollBar { }

    delegate: Item {
      id: entryItem

      required property var modelData
      required property int index

      readonly property var entry: modelData
      readonly property bool startsGroup: index > 0
                                         && control.model[index - 1].group !== entry.group
      readonly property bool checked: control.sameUrl(entry.url, control.currentUrl)
      readonly property bool pressed: rowMouse.pressed && rowMouse.pressedButtons === Qt.LeftButton
      readonly property bool hovered: rowMouse.containsMouse
      // DFM shows the active icon and color while pressed, too.
      readonly property bool active: checked || pressed

      width: ListView.view.width
      height: (startsGroup ? separator.height : 0) + row.height

      Item {
        id: separator

        visible: entryItem.startsGroup
        width: parent.width
        height: 5

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width
          height: 1
          color: control.separatorColor
        }
      }

      Item {
        id: row

        y: entryItem.startsGroup ? separator.height : 0
        width: parent.width
        height: 30

        Rectangle {
          anchors.fill: parent
          color: entryItem.active ? control.checkedBackground
               : entryItem.hovered ? control.hoverColor
               : "transparent"
        }

        Image {
          id: kindIcon

          x: 13
          anchors.verticalCenter: parent.verticalCenter
          width: 16
          height: 16
          sourceSize: Qt.size(16, 16)
          visible: (entryItem.entry.kind ?? "") !== ""
          source: visible ? control.iconSource(entryItem.entry.kind, entryItem.active ? "active" : "normal")
                          : ""
        }

        GXThemeIcon {
          anchors.fill: kindIcon
          visible: !kindIcon.visible
          name: entryItem.entry.iconName ?? ""
        }

        Text {
          anchors.left: kindIcon.right
          anchors.leftMargin: 8
          anchors.right: eject.visible ? eject.left : parent.right
          anchors.rightMargin: eject.visible ? 8 : 13
          anchors.verticalCenter: parent.verticalCenter
          text: entryItem.entry.text ?? ""
          elide: Text.ElideRight
          color: entryItem.active ? control.checkedColor : control.textColor
        }

        MouseArea {
          id: rowMouse

          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
              control.contextMenuRequested(entryItem.entry, mapToItem(control, mouse.x, mouse.y))
              return
            }
            control.currentUrl = entryItem.entry.url
            control.activated(entryItem.entry)
          }
        }

        Image {
          id: eject

          anchors.right: parent.right
          anchors.rightMargin: 13
          anchors.verticalCenter: parent.verticalCenter
          visible: entryItem.entry.ejectable === true
          sourceSize: Qt.size(16, 16)
          source: visible ? control.iconSource("unmount", ejectMouse.pressed ? "press"
                                                         : ejectMouse.containsMouse ? "hover"
                                                         : entryItem.checked ? "active"
                                                         : "normal")
                          : ""

          MouseArea {
            id: ejectMouse

            anchors.fill: parent
            hoverEnabled: true
            onClicked: control.ejectRequested(entryItem.entry)
          }
        }

        // The checked mark on the right edge.
        Rectangle {
          anchors.right: parent.right
          width: 3
          height: parent.height
          visible: entryItem.checked
          color: control.checkedColor
        }
      }
    }
  }
}
