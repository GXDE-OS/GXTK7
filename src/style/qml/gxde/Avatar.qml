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

T.AbstractButton {
  id: control

  property url source
  property bool selected: false
  property int ringWidth: 2

  implicitWidth: 60
  implicitHeight: 60
  padding: 0
  hoverEnabled: true
  focusPolicy: Qt.NoFocus

  contentItem: AvatarImage {
    source: control.source
    selected: control.selected
    ringWidth: control.ringWidth
  }
}
