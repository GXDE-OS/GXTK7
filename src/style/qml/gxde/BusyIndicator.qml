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

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

T.BusyIndicator {
  id: control

  implicitWidth: implicitContentWidth + leftPadding + rightPadding
  implicitHeight: implicitContentHeight + topPadding + bottomPadding

  padding: 0

  contentItem: Item {
    id: spinner

    readonly property real radius: Math.min(width, height) / 2
    readonly property real dotRadius: radius / 4 * 1.1
    readonly property list<color> colors: [Qt.rgba(200 / 255, 46 / 255, 1, 1),
                                           Qt.rgba(207 / 255, 225 / 255, 0, 1),
                                           Qt.rgba(0, 1, 241 / 255, 1)]
    readonly property list<real> trail: [1.0, 0.3, 0.15, 0.1, 0.05, 0.04, 0.03, 0.02, 0.01]

    implicitWidth: 32
    implicitHeight: 32
    opacity: control.running ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
      OpacityAnimator { duration: 250 }
    }

    Item {
      id: rotor
      anchors.fill: parent

      Repeater {
        model: spinner.colors.length * spinner.trail.length

        Rectangle {
          required property int index
          readonly property int indicator: Math.floor(index / spinner.trail.length)
          readonly property int step: index % spinner.trail.length
          readonly property real angle: (indicator * 120 - step * 10) * Math.PI / 180
          readonly property real orbit: spinner.radius - spinner.dotRadius

          x: spinner.width / 2 + orbit * Math.cos(angle) - width / 2
          y: spinner.height / 2 + orbit * Math.sin(angle) - height / 2
          width: spinner.dotRadius * 2
          height: width
          radius: width / 2
          color: spinner.colors[indicator]
          opacity: spinner.trail[step]
        }
      }

      RotationAnimator on rotation {
        from: 0
        to: 360
        duration: 771
        loops: Animation.Infinite
        running: control.running && control.visible
      }
    }
  }
}
