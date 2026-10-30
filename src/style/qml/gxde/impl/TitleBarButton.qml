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
import QtQuick.Controls.Gxde

ImageButton {
  id: control

  property string name
  property bool hasDisabledPicture: true

  readonly property string prefix: Qt.resolvedUrl("../assets/%1/window/%2_"
                                                  .arg(GxdePalette.assetDir).arg(name))

  normalSource: prefix + "normal.svg"
  hoverSource: prefix + "hover.svg"
  pressSource: prefix + "press.svg"
  disabledSource: hasDisabledPicture ? prefix + "disabled.svg" : ""
}
