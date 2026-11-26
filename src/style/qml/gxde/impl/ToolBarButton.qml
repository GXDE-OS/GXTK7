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

T.AbstractButton {
  id: control

  property string iconName
  property bool grouped: false
  property bool bordered: true
  property bool roundLeft: true
  property bool roundRight: true
  property real radius: 4
  property string pressStyle: "hover"
  property bool hoverOverChecked: false

  readonly property bool dark: GxdeTheme.isDark
  readonly property string look: !enabled ? "disabled"
                                : pressed && (dark || pressStyle !== "hover") ? "press"
                                : checked && !(hovered && hoverOverChecked) ? "checked"
                                : hovered || pressed ? "hover"
                                : "normal"

  implicitWidth: 24
  implicitHeight: 24
  focusPolicy: Qt.NoFocus
  hoverEnabled: true

  T.ToolTip.text: text
  T.ToolTip.visible: hovered && text.length > 0
  T.ToolTip.delay: 500

  Gradient {
    id: hoverGradient

    GradientStop { position: 0; color: "#8ccfff" }
    GradientStop { position: 1; color: "#4bb8ff" }
  }

  background: Rectangle {
    readonly property bool lightHover: !control.dark && control.look === "hover"
    readonly property bool lightFill: !control.dark
                                      && (control.look === "checked"
                                          || control.look === "press" && control.pressStyle === "fill")
    readonly property bool lightOutline: !control.dark && control.look === "press"
                                         && control.pressStyle === "outline"
    readonly property bool plain: control.look === "normal" || control.look === "disabled"

    topLeftRadius: control.roundLeft ? control.radius : 0
    bottomLeftRadius: control.roundLeft ? control.radius : 0
    topRightRadius: control.roundRight ? control.radius : 0
    bottomRightRadius: control.roundRight ? control.radius : 0

    gradient: lightHover ? hoverGradient : null
    color: {
      if (control.dark) {
        switch (control.look) {
        case "checked": return GxdePalette.accent
        case "hover": return Qt.rgba(1, 1, 1, 0.3)
        case "press": return Qt.rgba(1, 1, 1, 0.1)
        case "disabled": return Qt.rgba(1, 1, 1, 0.06)
        default: return Qt.rgba(1, 1, 1, 0.15)
        }
      }
      if (lightFill)
        return GxdePalette.accent
      if (plain && control.grouped)
        return "transparent"
      return "#ffffff"
    }

    border.width: control.dark || (plain && (control.grouped || !control.bordered)) ? 0 : 1
    border.color: lightHover ? "#3caafd"
                : lightFill ? "#2794ff"
                : lightOutline ? "#1088ff"
                : Qt.rgba(0, 0, 0, 0.1)
  }

  contentItem: Item {
    Image {
      readonly property bool navigation: ["back", "forward", "up"].includes(control.iconName)
      readonly property bool png: navigation && !control.dark
      readonly property string iconState: control.look === "disabled" && !navigation ? "normal"
                                    : control.look === "checked" && navigation ? "normal"
                                    : control.look

      anchors.centerIn: parent
      // PNG icons come with @2x variants, which a source size would hide.
      sourceSize: png ? undefined : Qt.size(16, 16)
      opacity: control.look === "disabled" && !navigation ? 0.4 : 1
      source: control.iconName
              ? "../assets/%1/toolbar/%2_%3.%4".arg(control.dark ? "dark" : "light")
                                              .arg(control.iconName).arg(iconState)
                                              .arg(png ? "png" : "svg")
              : ""
    }
  }
}
