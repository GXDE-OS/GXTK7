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

// DImageButton: a button that is just one picture per state. A state with
// no picture uses the normal one.
T.AbstractButton {
  id: control

  property url normalSource
  property url hoverSource
  property url pressSource
  property url checkedSource
  property url disabledSource

  readonly property url currentSource: {
    if (!enabled && disabledSource.toString())
      return disabledSource
    if (pressed && pressSource.toString())
      return pressSource
    // Keep the checked picture on hover.
    if (checked && checkedSource.toString())
      return checkedSource
    if (hovered && hoverSource.toString())
      return hoverSource
    return normalSource
  }

  implicitWidth: implicitContentWidth + leftPadding + rightPadding
  implicitHeight: implicitContentHeight + topPadding + bottomPadding

  padding: 0
  hoverEnabled: true
  focusPolicy: Qt.NoFocus

  contentItem: Image {
    source: control.currentSource
    fillMode: Image.Pad
    horizontalAlignment: Image.AlignHCenter
    verticalAlignment: Image.AlignVCenter
  }
}
