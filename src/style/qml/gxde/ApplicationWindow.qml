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

T.ApplicationWindow {
  id: window

  color: GxdePalette.window

  palette.window: GxdePalette.window
  palette.windowText: GxdePalette.text
  palette.base: GxdePalette.editBackground
  palette.alternateBase: GxdePalette.itemHover
  palette.text: GxdePalette.text
  palette.button: GxdePalette.buttonTop
  palette.buttonText: GxdePalette.buttonText
  palette.brightText: "#ffffff"
  palette.highlight: GxdePalette.highlight
  palette.highlightedText: GxdePalette.highlightedText
  palette.placeholderText: GxdePalette.textDisabled
  palette.toolTipBase: GxdePalette.toolTipBackground
  palette.toolTipText: GxdePalette.toolTipText
  palette.mid: GxdePalette.frameBorder
  palette.link: GxdePalette.flatText
  palette.disabled.windowText: GxdePalette.textDisabled
  palette.disabled.text: GxdePalette.textDisabled
  palette.disabled.buttonText: GxdePalette.buttonDisabledText
}
