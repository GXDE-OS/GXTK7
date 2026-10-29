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

T.TabBar {
  id: control

  implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                          contentWidth + leftPadding + rightPadding)
  implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                           contentHeight + topPadding + bottomPadding)

  spacing: 0

  contentItem: ListView {
    model: control.contentModel
    currentIndex: control.currentIndex

    spacing: control.spacing
    orientation: ListView.Horizontal
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.AutoFlickIfNeeded
    snapMode: ListView.SnapToItem

    highlightMoveDuration: 0
    highlightRangeMode: ListView.ApplyRange
    preferredHighlightBegin: 40
    preferredHighlightEnd: width - 40
  }

  background: Item { }
}
