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

pragma Singleton

import QtQuick
import QtQuick.Controls.Gxde

QtObject {
  readonly property bool dark: GxdeTheme.isDark

  readonly property color window: dark ? "#202020" : "#ffffff"
  readonly property color text: dark ? "#ffffff" : Qt.rgba(25 / 255, 25 / 255, 25 / 255, 1)
  readonly property color textDisabled: dark ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(0, 0, 0, 0.4)
  readonly property color highlight: dark ? "#61b5f8" : "#2ca7f8"
  readonly property color highlightedText: "#ffffff"
  readonly property color accent: "#2ca7f8"
  readonly property color frameBorder: dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1)
  readonly property color itemHover: dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.05)

  readonly property color buttonTop: dark ? Qt.rgba(1, 1, 1, 0.15) : "#ffffff"
  readonly property color buttonBottom: dark ? Qt.rgba(1, 1, 1, 0.15) : "#fdfdfd"
  readonly property color buttonHoverTop: dark ? Qt.rgba(1, 1, 1, 0.3) : "#8ccfff"
  readonly property color buttonHoverBottom: dark ? Qt.rgba(1, 1, 1, 0.3) : "#4bb8ff"
  readonly property color buttonPressTop: dark ? Qt.rgba(1, 1, 1, 0.1) : "#0b8cff"
  readonly property color buttonPressBottom: dark ? Qt.rgba(1, 1, 1, 0.1) : "#0aa1ff"
  readonly property color buttonDisabledTop: dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.4)
  readonly property color buttonDisabledBottom: dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(253 / 255, 253 / 255, 253 / 255, 0.4)
  readonly property color buttonText: dark ? "#dcdcdc" : "#000000"
  readonly property color buttonHoverText: "#ffffff"
  readonly property color buttonPressText: dark ? "#2ca7f8" : "#ffffff"
  readonly property color buttonDisabledText: dark ? "#40dcdcdc" : "#aeaeae"
  readonly property color buttonBorder: dark ? "transparent" : Qt.rgba(0, 0, 0, 0.1)
  readonly property color buttonHoverBorder: dark ? "transparent" : Qt.rgba(0, 117 / 255, 243 / 255, 0.2)
  readonly property color buttonPressBorder: Qt.rgba(0, 0, 0, 0.05)
  readonly property color buttonFocusBorder: "#2ca7f8"
  readonly property color buttonDisabledBorder: dark ? "transparent" : Qt.rgba(0, 0, 0, 0.04)
  readonly property color suggestText: Qt.rgba(0, 132 / 255, 1, 1)
  readonly property color suggestBorder: Qt.rgba(0, 132 / 255, 1, 0.4)
  readonly property color suggestHoverBorder: dark ? suggestBorder : Qt.rgba(0, 117 / 255, 243 / 255, 0.2)
  readonly property color suggestPressBorder: dark ? suggestBorder : Qt.rgba(29 / 255, 129 / 255, 1, 0.3)
  readonly property color suggestDisabledBorder: dark ? suggestBorder : Qt.rgba(0, 0, 0, 0.04)
  readonly property color flatText: "#0082fa"
  readonly property color flatHoverText: "#16b8ff"
  readonly property color flatDisabledText: "#0060b9"

  readonly property color editBackground: dark ? Qt.rgba(1, 1, 1, 0.15) : "#ffffff"
  readonly property color editFocusBackground: dark ? Qt.rgba(1, 1, 1, 0.05) : "#ffffff"
  readonly property color editDisabledBackground: dark ? Qt.rgba(1, 1, 1, 0.04) : "#ffffff"
  readonly property color editBorder: dark ? "transparent" : Qt.rgba(0, 0, 0, 0.1)
  readonly property color editFocusBorder: dark ? Qt.rgba(43 / 255, 167 / 255, 248 / 255, 0.6) : "#2ca7f8"
  readonly property color editDisabledBorder: dark ? "transparent" : Qt.rgba(0, 0, 0, 0.04)
  readonly property color spinBorder: dark ? "#000000" : Qt.rgba(0, 0, 0, 0.1)
  readonly property color spinFocusBorder: dark ? Qt.rgba(43 / 255, 167 / 255, 248 / 255, 0.6) : "#2ca7f8"
  readonly property color spinDisabledBorder: dark ? "#000000" : Qt.rgba(0, 0, 0, 0.04)

  readonly property color sliderGroove: dark ? Qt.rgba(1, 1, 1, 0.2) : "#a4a4a4"
  readonly property color sliderGrooveDisabled: dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(163 / 255, 163 / 255, 163 / 255, 0.4)
  readonly property color sliderTickmark: dark ? Qt.rgba(1, 1, 1, 0.6) : Qt.rgba(0, 0, 0, 0.6)

  readonly property color progressGroove: dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.05)
  readonly property color progressGrooveBorder: dark ? "transparent" : Qt.rgba(1, 1, 1, 0.05)
  readonly property color progressContent: "#2ca7f8"
  readonly property color progressContentBorder: "#378cfa"

  readonly property color scrollHandle: dark ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(16 / 255, 16 / 255, 16 / 255, 0.5)
  readonly property color scrollHandleHover: dark ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(16 / 255, 16 / 255, 16 / 255, 0.5)
  readonly property color scrollHandlePress: dark ? Qt.rgba(96 / 255, 96 / 255, 96 / 255, 0.3) : Qt.rgba(16 / 255, 16 / 255, 16 / 255, 0.55)

  readonly property color menuBackground: dark ? "#313131" : "#ffffff"
  readonly property color menuBorder: Qt.rgba(0, 0, 0, 0.1)
  readonly property color menuSeparator: dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1)
  readonly property color menuGlyph: dark ? "#dcdcdc" : "#303030"

  readonly property color tabHover: dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.05)
  readonly property color tabBorder: Qt.rgba(0, 0, 0, 0.1)
  readonly property color tabText: dark ? "#c0c0c0" : "#000000"
  readonly property color tabSelectedText: "#2ca7f8"
  readonly property color tabDisabledText: "#949494"

  readonly property color switchOff: Qt.rgba(207 / 255, 214 / 255, 230 / 255, 1)
  readonly property color switchOn: Qt.rgba(44 / 255, 167 / 255, 248 / 255, 1)

  readonly property color dialogBackground: dark ? Qt.rgba(30 / 255, 31 / 255, 35 / 255, 1) : "#ffffff"
  readonly property color dialogBorder: dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.08)
  readonly property color dialogTitle: dark ? "#f0f0f0" : "#000000"
  readonly property color dialogMessage: dark ? "#b8b8b8" : "#444444"
  readonly property color dialogActionBorder: dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.06)
  readonly property color dialogActionText: dark ? "#d0d0d0" : "#303030"
  readonly property color dialogRecommendText: dark ? "#4cc2ff" : "#0087ff"

  readonly property color titlebarTop: dark ? Qt.rgba(28 / 255, 29 / 255, 32 / 255, 0.7) : Qt.rgba(1, 1, 1, 0.72)
  readonly property color titlebarBottom: dark ? Qt.rgba(22 / 255, 23 / 255, 26 / 255, 0.55) : Qt.rgba(248 / 255, 249 / 255, 252 / 255, 0.52)

  readonly property color toolTipBackground: "#ffffff"
  readonly property color toolTipText: "#000000"

  readonly property string assetDir: dark ? "dark" : "light"

  function pick(control, normal, hover, press, focus, disabled) {
    if (!control.enabled)
      return disabled
    if (control.down || control.pressed)
      return press
    if (control.hovered)
      return hover
    if (control.activeFocus)
      return focus
    return normal
  }

  function buttonTextColor(control, suggest) {
    if (control.flat)
      return pick(control, flatText, flatHoverText, flatText, flatText, flatDisabledText)
    return pick(control, suggest ? suggestText : buttonText, buttonHoverText,
                buttonPressText, suggest ? suggestText : buttonText, buttonDisabledText)
  }

  function indicatorImage(control, prefix) {
    const state = control.checkState ?? (control.checked ? Qt.Checked : Qt.Unchecked)
    let name = prefix + (state === Qt.Checked ? "_checked"
                         : state === Qt.PartiallyChecked ? "_mixed" : "_unchecked")
    return name + pick(control, "", "_hover", "_press", "_focus", "_insensitive")
  }
}
