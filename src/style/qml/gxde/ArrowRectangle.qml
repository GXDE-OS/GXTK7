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
import QtQuick.Shapes
import QtQuick.Templates as T
import QtQuick.Controls.Gxde

// DArrowRectangle: a rounded panel with an arrow on one side, for bubbles
// that point at an item. The arrow side gets more padding, so the content
// does not cover the arrow.
T.Control {
  id: control

  enum ArrowDirection {
    ArrowLeft,
    ArrowRight,
    ArrowTop,
    ArrowBottom
  }

  property int arrowDirection: ArrowRectangle.ArrowRight
  // Arrow tip position on its side. Negative means centered.
  property real arrowPosition: -1
  property real arrowWidth: 12
  property real arrowHeight: 10
  property real radius: 8
  property real margin: 8
  property real borderWidth: 1
  property color backgroundColor: GxdePalette.dark ? GxdePalette.menuBackground : "#ffffff"
  property color borderColor: Qt.rgba(0, 0, 0, 0.1)

  readonly property bool vertical: arrowDirection === ArrowRectangle.ArrowTop
                                   || arrowDirection === ArrowRectangle.ArrowBottom

  implicitWidth: implicitContentWidth + leftPadding + rightPadding
  implicitHeight: implicitContentHeight + topPadding + bottomPadding

  leftPadding: margin + (arrowDirection === ArrowRectangle.ArrowLeft ? arrowHeight : 0)
  rightPadding: margin + (arrowDirection === ArrowRectangle.ArrowRight ? arrowHeight : 0)
  topPadding: margin + (arrowDirection === ArrowRectangle.ArrowTop ? arrowHeight : 0)
  bottomPadding: margin + (arrowDirection === ArrowRectangle.ArrowBottom ? arrowHeight : 0)

  background: Shape {
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: control.backgroundColor
      strokeColor: control.borderWidth > 0 ? control.borderColor : "transparent"
      strokeWidth: control.borderWidth
      PathSvg { path: control.outlinePath() }
    }
  }

  // Same path as DArrowRectanglePrivate: clockwise from the top-left corner,
  // with the arrow on its side.
  function outlinePath() {
    const half = borderWidth / 2
    const dir = arrowDirection
    const left = half + (dir === ArrowRectangle.ArrowLeft ? arrowHeight : 0)
    const right = width - half - (dir === ArrowRectangle.ArrowRight ? arrowHeight : 0)
    const top = half + (dir === ArrowRectangle.ArrowTop ? arrowHeight : 0)
    const bottom = height - half - (dir === ArrowRectangle.ArrowBottom ? arrowHeight : 0)
    const r = Math.max(0, Math.min(radius, (bottom - top) / 2, (right - left) / 2))
    const span = vertical ? width : height
    const tip = arrowPosition >= 0 ? arrowPosition : span / 2
    const w = arrowWidth / 2

    const arc = (x, y) => `A ${r} ${r} 0 0 1 ${x} ${y} `
    let p = `M ${left + r} ${top} `
    if (dir === ArrowRectangle.ArrowTop)
      p += `L ${tip - w} ${top} L ${tip} ${half} L ${tip + w} ${top} `
    p += `L ${right - r} ${top} ` + arc(right, top + r)
    if (dir === ArrowRectangle.ArrowRight)
      p += `L ${right} ${tip - w} L ${width - half} ${tip} L ${right} ${tip + w} `
    p += `L ${right} ${bottom - r} ` + arc(right - r, bottom)
    if (dir === ArrowRectangle.ArrowBottom)
      p += `L ${tip + w} ${bottom} L ${tip} ${height - half} L ${tip - w} ${bottom} `
    p += `L ${left + r} ${bottom} ` + arc(left, bottom - r)
    if (dir === ArrowRectangle.ArrowLeft)
      p += `L ${left} ${tip + w} L ${half} ${tip} L ${left} ${tip - w} `
    p += `L ${left} ${top + r} ` + arc(left + r, top) + "Z"
    return p
  }
}
