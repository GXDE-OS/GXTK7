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
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Gxde

Dialog {
  id: control

  property string productName: Qt.application.displayName || Qt.application.name
  // The product icon, from the icon theme or from a file.
  property string productIconName: Qt.application.name
  property url productIconSource
  property string version: Qt.application.version
                           ? qsTranslate("DAboutDialog", "Version: %1").arg(Qt.application.version)
                           : ""
  property string description
  // Shown under the description, for example "%1 is released under %2".
  property string license
  property url companyLogo: Qt.resolvedUrl("assets/common/gxde_logo.png")
  property string websiteName: "www.gxde.top"
  property string websiteLink: "https://www.gxde.top"
  property string acknowledgementLink
  property bool acknowledgementVisible: acknowledgementLink !== ""

  // Opens the links in the browser by default.  Set openLinks to false to
  // handle linkActivated alone.
  property bool openLinks: true
  signal linkActivated(string link)

  readonly property bool dark: GxdeTheme.isDark
  readonly property color linkColor: dark ? "#4cc2ff" : "#004EE5"

  function activateLink(link) {
    linkActivated(link)
    if (openLinks)
      Qt.openUrlExternally(link)
  }

  // Rich text takes the link color from the palette, not from linkColor, so
  // set it in the link like DTK2 does.
  function linkText(link, name) {
    return "<a href=\"%1\" style=\"text-decoration: none; color: %2\">%3</a>"
        .arg(link).arg(linkColor).arg(name)
  }

  anchors.centerIn: T.Overlay.overlay
  width: 400
  modal: true
  closePolicy: T.Popup.CloseOnEscape
  leftPadding: 11
  rightPadding: 11
  topPadding: 0
  bottomPadding: 10

  header: Item {
    implicitHeight: closeButton.implicitHeight

    TitleBarButton {
      id: closeButton

      anchors.right: parent.right
      anchors.rightMargin: 1
      anchors.top: parent.top
      anchors.topMargin: 1
      name: "close"
      hasDisabledPicture: false
      onClicked: control.close()
    }
  }

  contentItem: ColumnLayout {
    spacing: 0

    IconImage {
      Layout.alignment: Qt.AlignHCenter
      Layout.preferredWidth: 96
      Layout.preferredHeight: 96
      sourceSize: Qt.size(96, 96)
      name: control.productIconName
      source: control.productIconSource
      visible: status === Image.Ready
    }

    Text {
      Layout.alignment: Qt.AlignHCenter
      Layout.topMargin: 3
      text: control.productName
      visible: text !== ""
      font.pixelSize: 18
      color: control.dark ? "#f0f0f0" : GxdePalette.text
    }

    Text {
      Layout.alignment: Qt.AlignHCenter
      Layout.topMargin: 6
      text: control.version
      visible: text !== ""
      font.pixelSize: 12
      color: control.dark ? "#999999" : "#666666"
    }

    Image {
      Layout.alignment: Qt.AlignHCenter
      Layout.topMargin: 8
      source: control.companyLogo
      visible: status === Image.Ready
    }

    LinkLabel {
      Layout.preferredHeight: 24
      text: control.linkText(control.websiteLink, control.websiteName)
      visible: control.websiteName !== ""
    }

    LinkLabel {
      Layout.preferredHeight: 24
      Layout.topMargin: 5
      text: control.linkText(control.acknowledgementLink,
                             qsTranslate("DAboutDialog", "Acknowledgements"))
      visible: control.acknowledgementVisible
    }

    BodyLabel {
      Layout.topMargin: 12
      text: control.description
    }

    BodyLabel {
      Layout.topMargin: 7
      text: control.license
    }
  }

  component LinkLabel: Text {
    Layout.alignment: Qt.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    // Rich text, as styled text always underlines links.
    textFormat: Text.RichText
    font.pixelSize: 13
    color: control.linkColor
    onLinkActivated: link => control.activateLink(link)

    HoverHandler {
      cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
  }

  component BodyLabel: Text {
    Layout.fillWidth: true
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    textFormat: Text.StyledText
    visible: text !== ""
    font.pixelSize: 11
    color: control.dark ? "#c0c0c0" : "#1A1A1A"
    linkColor: control.linkColor
    onLinkActivated: link => control.activateLink(link)

    HoverHandler {
      cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
  }
}
