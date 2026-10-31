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

/*
 * Qt 6.8 and older fallback for QtQuick.Effects' RectangularShadow, which was
 * introduced in Qt 6.9.  Menu.qml uses that type directly, so without this
 * stand-in the whole Menu type - and every application using it - fails to
 * load on older Qt with "RectangularShadow is not a type".
 *
 * The file is only added to the QML module by CMake when Qt is older than
 * 6.9 (and is marked as an internal type), so Qt 6.9+ builds keep using the
 * stock type and this copy never shadows it.
 *
 * The API mirrors the subset of RectangularShadow that the style uses: a
 * rounded rectangle of the item's size, offset, blurred with `blur` and
 * filled with `color`, drawn without the rectangle itself.
 */

import QtQuick
import QtQuick.Effects

Item {
  id: root

  property real radius: 0
  property real blur: 0
  property vector2d offset: Qt.vector2d(0, 0)
  property color color: "black"

  Rectangle {
    id: shade

    x: root.offset.x
    y: root.offset.y
    width: root.width
    height: root.height
    radius: root.radius
    color: root.color
    visible: false
  }

  /*
   * MultiEffect blurs the rectangle into a shadow.  Its blur is relative to
   * blurMax, so pick blurMax = 2 * blur and half strength to end up with a
   * blur radius of roughly the requested `blur` pixels - the same shape
   * RectangularShadow produces with a Gaussian blur of that radius.
   */
  MultiEffect {
    anchors.fill: parent
    source: shade
    blurEnabled: true
    blur: 0.5
    blurMax: Math.max(2, Math.round(root.blur * 2))
    autoPaddingEnabled: true
  }
}
