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
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Window
import QtQuick.Controls.Gxde

ApplicationWindow {
  id: window

  default property alias content: body.data

  // DMainWindow's defaults on DXcb.
  property int windowRadius: 12
  property int borderWidth: 1
  property color borderColor: Qt.rgba(0, 0, 0, 28 / 255)
  property int shadowRadius: 28
  property point shadowOffset: Qt.point(0, 8)
  property color activeShadowColor: Qt.rgba(0, 0, 0, 0.6)
  property color inactiveShadowColor: Qt.rgba(0, 0, 0, 0.35)
  property color shadowColor: active ? activeShadowColor : inactiveShadowColor

  // Fill of the frame.  It is not drawn with translucentBackground, and made
  // see-through while the blur is on.
  property color windowColor: GxdePalette.window
  property bool translucentBackground: false
  property bool enableBlurWindow: false

  property bool enableSystemResize: true
  property bool enableSystemMove: true
  // Least room left outside the frame for resizing.  All of the room outside
  // the frame, shadow included, resizes the window.
  property int resizeHandleSize: 8

  // Shows "Set Window Background" in the title bar menu.  The background
  // pictures are drawn either way.
  property bool enableWindowBackground: false

  readonly property alias titlebar: titleBar
  // The QWindowKit agent that makes the window frameless.
  readonly property alias windowAgent: agent
  readonly property GXMainWindowBackground windowBackground: GXMainWindowBackground { }

  readonly property bool decorated: priv.decorated
  // True when the compositor draws the frame, see above.
  readonly property bool compositorFrame: priv.compositorFrame
  readonly property bool blurActive: enableBlurWindow && priv.blurSupported
  readonly property int frameMarginLeft: priv.marginLeft
  readonly property int frameMarginTop: priv.marginTop
  readonly property int frameMarginRight: priv.marginRight
  readonly property int frameMarginBottom: priv.marginBottom
  // The frame in window coordinates.
  readonly property rect frameRect: Qt.rect(frame.x, frame.y, frame.width, frame.height)

  // Lets the title bar items that take mouse input keep it, instead of
  // moving the window.
  function updateHitTest() {
    const items = [titleBar.optionButton, titleBar.quitFullscreenButton]
                  .concat(Array.from(titleBar.customItems))
                  .filter(item => item !== null)
    for (const old of priv.hitTestItems) {
      if (old && !items.includes(old))
        agent.setHitTestVisible(old, false)
    }
    for (const item of items)
      agent.setHitTestVisible(item, true)
    priv.hitTestItems = items
  }

  function refreshBackground() {
    windowBackground.refresh()
  }

  function updatePlatformWindow() {
    if (!visible)
      return
    if (WindowEffects.setNoTitleBar(window, true))
      priv.compositorFrame = true
    if (blurActive) {
      WindowEffects.setBlurBehind(window, frameRect, priv.radius)
      priv.blurSent = true
    } else if (priv.blurSent) {
      WindowEffects.clearBlurBehind(window)
      priv.blurSent = false
    }
  }

  flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowTitleHint | Qt.WindowSystemMenuHint
         | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint | Qt.WindowCloseButtonHint
  color: "transparent"
  title: Qt.application.displayName

  onVisibleChanged: Qt.callLater(updatePlatformWindow)
  onVisibilityChanged: Qt.callLater(updatePlatformWindow)
  onWidthChanged: Qt.callLater(updatePlatformWindow)
  onHeightChanged: Qt.callLater(updatePlatformWindow)
  onBlurActiveChanged: Qt.callLater(updatePlatformWindow)
  Component.onCompleted: {
    updateHitTest()
    Qt.callLater(updatePlatformWindow)
  }

  contentData: [
    QtObject {
      id: priv

      property bool blurSent: false
      property var hitTestItems: []
      property bool compositorFrame: false
      readonly property bool blurSupported: WindowEffects.isBlurSupported()
      readonly property bool compositing: WindowEffects.hasCompositing()

      readonly property bool decorated: compositing && !compositorFrame
                                        && window.visibility !== Window.Maximized
                                        && window.visibility !== Window.FullScreen
      readonly property int radius: decorated ? window.windowRadius : 0
      readonly property bool resizable: window.minimumWidth !== window.maximumWidth
                                        || window.minimumHeight !== window.maximumHeight

      // Leave room for the shadow, and for the resize band.
      readonly property int shadowExtent: window.shadowRadius > 0 ? window.shadowRadius : 0
      readonly property int band: window.enableSystemResize ? window.resizeHandleSize : 0
      readonly property int marginLeft: decorated
                                        ? Math.max(band, shadowExtent - window.shadowOffset.x) : 0
      readonly property int marginRight: decorated
                                         ? Math.max(band, shadowExtent + window.shadowOffset.x) : 0
      readonly property int marginTop: decorated
                                       ? Math.max(band, shadowExtent - window.shadowOffset.y) : 0
      readonly property int marginBottom: decorated
                                          ? Math.max(band, shadowExtent + window.shadowOffset.y) : 0

      // A see-through frame must not show the shadow under it.
      readonly property bool maskShadow: window.translucentBackground || window.blurActive
      readonly property color fill: window.translucentBackground ? "transparent"
                                  : window.blurActive ? Qt.alpha(window.windowColor, 0.7)
                                  : window.windowColor
    },

    // QWindowKit: dragging and double clicking the title bar, the system
    // window menu on a right click, and resizing at the window edges.
    GXWindowAgent {
      id: agent

      window: window
      titleBar: titleBar
      minimizeButton: titleBar.minimizeButton
      maximizeButton: titleBar.maximizeButton
      closeButton: titleBar.closeButton
    },

    FileDialog {
      id: backgroundDialog

      parentWindow: window
      title: qsTranslate("TitleBarMenu", "Choose the background image file")
      nameFilters: [
        qsTranslate("TitleBarMenu", "Image file (*.jpg *.jpeg *.png *.bmp *.gif *.svg)"),
        qsTranslate("TitleBarMenu", "All file (*)")
      ]
      onAccepted: {
        const bg = window.windowBackground
        bg.setUserBackground(GXMainWindowBackground.Light, selectedFile,
                             GXMainWindowBackground.FullWindow)
        bg.setUserBackground(GXMainWindowBackground.Dark, selectedFile,
                             GXMainWindowBackground.FullWindow)
        bg.refresh()
      }
    },

    Item {
      id: shadow

      anchors.fill: parent
      visible: priv.decorated && window.shadowRadius > 0
      layer.enabled: visible && priv.maskShadow
      layer.effect: MultiEffect {
        maskEnabled: true
        maskInverted: true
        maskSource: shadowMask
      }

      RectangularShadow {
        x: frame.x
        y: frame.y
        width: frame.width
        height: frame.height
        offset: Qt.vector2d(window.shadowOffset.x, window.shadowOffset.y)
        radius: priv.radius
        blur: window.shadowRadius
        color: window.shadowColor
      }
    },

    Item {
      id: shadowMask

      anchors.fill: parent
      visible: false
      layer.enabled: shadow.layer.enabled

      Rectangle {
        x: frame.x
        y: frame.y
        width: frame.width
        height: frame.height
        radius: priv.radius
      }
    },

    Rectangle {
      id: frameMask

      x: frame.x
      y: frame.y
      width: frame.width
      height: frame.height
      radius: priv.radius
      antialiasing: true
      visible: false
      layer.enabled: frame.layer.enabled
    },

    Item {
      id: frame

      x: priv.marginLeft
      y: priv.marginTop
      width: Math.max(0, window.width - priv.marginLeft - priv.marginRight)
      height: Math.max(0, window.height - priv.marginTop - priv.marginBottom)

      // Clip the content to the rounded corners.
      layer.enabled: priv.radius > 0
      layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: frameMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
      }

      Rectangle {
        anchors.fill: parent
        color: priv.fill
      }

      // DMainWindowBackground: the full window picture, the pictures at the
      // edges, and a veil so the content stays readable.
      Item {
        anchors.fill: parent
        visible: window.windowBackground.isSet
        clip: true

        Image {
          anchors.fill: parent
          source: window.windowBackground.sources[GXMainWindowBackground.FullWindow] ?? ""
          fillMode: Image.PreserveAspectCrop
          cache: false
        }

        Repeater {
          // DTK2's drawing order.
          model: [
            GXMainWindowBackground.Center,
            GXMainWindowBackground.TopCenter,
            GXMainWindowBackground.BottomCenter,
            GXMainWindowBackground.CenterLeft,
            GXMainWindowBackground.CenterRight,
            GXMainWindowBackground.TopLeft,
            GXMainWindowBackground.TopRight,
            GXMainWindowBackground.BottomLeft,
            GXMainWindowBackground.BottomRight
          ]

          Image {
            required property int modelData
            readonly property int column: modelData % 3
            readonly property int row: Math.floor(modelData / 3)

            x: column === 0 ? 0
             : column === 1 ? Math.round((parent.width - width) / 2)
             : parent.width - width
            y: row === 0 ? 0
             : row === 1 ? Math.round((parent.height - height) / 2)
             : parent.height - height
            source: window.windowBackground.sources[modelData] ?? ""
            cache: false
          }
        }

        Rectangle {
          anchors.fill: parent
          color: GxdeTheme.isDark ? "#99252525" : "#99ffffff"
        }
      }

      // Drag the window from any place the content leaves alone.
      MouseArea {
        property bool moveOnDrag: false

        anchors.fill: parent
        enabled: window.enableSystemMove
        acceptedButtons: Qt.LeftButton

        onPressed: moveOnDrag = true
        onReleased: moveOnDrag = false
        onPositionChanged: {
          if (moveOnDrag) {
            moveOnDrag = false
            window.startSystemMove()
          }
        }
      }

      GXTitleBar {
        id: titleBar

        width: parent.width
        targetWindow: window
        backgroundActionVisible: window.enableWindowBackground
        backgroundActionChecked: window.windowBackground.userBackgroundSet
        onCustomItemsChanged: window.updateHitTest()
        onBackgroundActionTriggered: checked => {
          if (checked) {
            backgroundDialog.open()
            return
          }
          const bg = window.windowBackground
          bg.removeUserBackground(GXMainWindowBackground.Light, GXMainWindowBackground.FullWindow)
          bg.removeUserBackground(GXMainWindowBackground.Dark, GXMainWindowBackground.FullWindow)
          bg.refresh()
        }
      }

      Item {
        id: body

        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
      }
    },

    Rectangle {
      x: frame.x
      y: frame.y
      width: frame.width
      height: frame.height
      radius: priv.radius
      color: "transparent"
      border.width: window.borderWidth
      border.color: window.borderColor
      visible: priv.decorated && window.borderWidth > 0
    },

    MouseArea {
      id: resizeArea

      function edgesAt(x, y) {
        const left = frame.x
        const top = frame.y
        const right = frame.x + frame.width
        const bottom = frame.y + frame.height
        const corner = Math.max(window.windowRadius, window.resizeHandleSize)

        let edges = 0
        if (x < left)
          edges |= Qt.LeftEdge
        else if (x >= right)
          edges |= Qt.RightEdge
        if (y < top)
          edges |= Qt.TopEdge
        else if (y >= bottom)
          edges |= Qt.BottomEdge

        // Grab the corners a bit along the sides too.
        if (edges === Qt.LeftEdge || edges === Qt.RightEdge) {
          if (y < top + corner)
            edges |= Qt.TopEdge
          else if (y >= bottom - corner)
            edges |= Qt.BottomEdge
        } else if (edges === Qt.TopEdge || edges === Qt.BottomEdge) {
          if (x < left + corner)
            edges |= Qt.LeftEdge
          else if (x >= right - corner)
            edges |= Qt.RightEdge
        }
        return edges
      }

      function cursorFor(edges) {
        switch (edges) {
        case Qt.LeftEdge:
        case Qt.RightEdge:
          return Qt.SizeHorCursor
        case Qt.TopEdge:
        case Qt.BottomEdge:
          return Qt.SizeVerCursor
        case Qt.LeftEdge | Qt.TopEdge:
        case Qt.RightEdge | Qt.BottomEdge:
          return Qt.SizeFDiagCursor
        case Qt.RightEdge | Qt.TopEdge:
        case Qt.LeftEdge | Qt.BottomEdge:
          return Qt.SizeBDiagCursor
        }
        return Qt.ArrowCursor
      }

      anchors.fill: parent
      enabled: window.enableSystemResize && priv.decorated && priv.resizable
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton

      // Everything outside the frame belongs to this area, so the frame
      // itself is left alone.  QWindowKit also resizes from the outermost
      // pixels of the window, which lie in this area too.
      containmentMask: QtObject {
        function contains(point: point): bool {
          return resizeArea.edgesAt(point.x, point.y) !== 0
        }
      }

      onPositionChanged: mouse => cursorShape = cursorFor(edgesAt(mouse.x, mouse.y))
      onPressed: mouse => {
        const edges = edgesAt(mouse.x, mouse.y)
        if (edges !== 0)
          window.startSystemResize(edges)
      }
    }
  ]
}
