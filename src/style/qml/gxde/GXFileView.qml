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
import QtQml.Models
import QtQuick.Controls.Gxde

// The file list of DFM (DFileView), in its three modes:
//   IconMode    Icons with their names below, in rows; Ctrl+wheel zooms.
//   ListMode    One row a file, with sortable, resizable columns.
//   ExtendMode  Columns of folders side by side; a click on a folder opens
//               it in the next column.  DFM only has a stub of this mode.
//
// Keys: arrows, Home and End move; Shift and Ctrl extend the selection;
// Enter opens; Ctrl+A selects all; Alt+Up goes up; Ctrl+H shows hidden
// files; Ctrl+1, 2 and 3 switch the mode; Ctrl+= and Ctrl+- zoom.
FocusScope {
  id: control

  enum ViewMode {
    IconMode,
    ListMode,
    ExtendMode
  }

  property url folder
  property int viewMode: GXFileView.IconMode
  // An index into iconSizes: DFM's 48, 64, 96, 128 and 256 pixels.
  property int iconSizeLevel: 1
  readonly property var iconSizes: [48, 64, 96, 128, 256]
  readonly property int iconSize: iconSizes[Math.max(0, Math.min(iconSizeLevel, iconSizes.length - 1))]
  // Opening a folder lists it here instead of only emitting activated.
  property bool navigateIntoFolders: true
  property bool showThumbnails: true
  property font font: Qt.application.font

  // The list mode columns after the name, which takes the rest.
  property int modifiedColumnWidth: 160
  property int sizeColumnWidth: 100
  property int typeColumnWidth: 140

  // The folder listing; set showHidden, sortField and the like on it.
  readonly property alias model: fsModel
  // The selected rows of model, in icon and list mode.
  readonly property alias selection: selectionModel
  readonly property int count: fsModel.count
  readonly property int currentRow: (priv.revision, selectionModel.currentIndex.row)
  readonly property var selectedPaths: {
    priv.revision
    if (viewMode === GXFileView.ExtendMode)
      return priv.extendSelection.length > 0 ? [priv.extendSelection[priv.extendSelection.length - 1]] : []
    const indexes = selectionModel.selectedIndexes
    const rows = []
    for (let i = 0; i < indexes.length; ++i)
      rows.push(indexes[i].row)
    rows.sort((a, b) => a - b)
    return rows.map(row => fsModel.data(fsModel.index(row, 0), GXFileSystemModel.FilePathRole))
  }

  readonly property bool dark: GxdeTheme.isDark
  readonly property color textColor: dark ? "#bdbdbd" : "#303030"
  readonly property color secondaryTextColor: dark ? "#8f8f8f" : "#797979"
  readonly property color hoverColor: dark ? Qt.rgba(1, 1, 1, 16 / 255) : Qt.rgba(0, 0, 0, 10 / 255)
  readonly property color selectionColor: withAlpha(GxdePalette.highlight, dark ? 76 : 58)
  readonly property color selectionBorderColor: withAlpha(GxdePalette.highlight, dark ? 150 : 130)

  // A file was opened: double clicked, or Enter pressed.  file holds the
  // roles of GXFileSystemModel, such as filePath and isDir.
  signal activated(var file)
  // A right click; paths are the selected files, position is in the
  // coordinates of the view.
  signal contextMenuRequested(var paths, point position)

  function withAlpha(color, alpha) {
    return Qt.rgba(color.r, color.g, color.b, alpha / 255)
  }

  function goUp() {
    if (fsModel.parentFolder.toString() !== "")
      folder = fsModel.parentFolder
  }

  function zoomIn() {
    iconSizeLevel = Math.min(iconSizeLevel + 1, iconSizes.length - 1)
  }

  function zoomOut() {
    iconSizeLevel = Math.max(iconSizeLevel - 1, 0)
  }

  function isRowSelected(row) {
    return selectionModel.isSelected(fsModel.index(row, 0))
  }

  function clearSelection() {
    selectionModel.clear()
    priv.anchorRow = -1
  }

  function selectAll() {
    const rows = []
    for (let row = 0; row < fsModel.count; ++row)
      rows.push(row)
    selectRows(rows)
  }

  // Selects a row like a click with these keyboard modifiers would.
  function selectRow(row, modifiers) {
    if (row < 0 || row >= fsModel.count)
      return
    const index = fsModel.index(row, 0)
    if ((modifiers & Qt.ShiftModifier) && priv.anchorRow >= 0) {
      const rows = []
      for (let r = Math.min(priv.anchorRow, row); r <= Math.max(priv.anchorRow, row); ++r)
        rows.push(r)
      selectionModel.select(fsModel.selectionOf(rows),
                            (modifiers & Qt.ControlModifier) ? ItemSelectionModel.Select
                                                              : ItemSelectionModel.ClearAndSelect)
      selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
    } else if (modifiers & Qt.ControlModifier) {
      selectionModel.setCurrentIndex(index, ItemSelectionModel.Toggle)
      priv.anchorRow = row
    } else {
      selectionModel.setCurrentIndex(index, ItemSelectionModel.ClearAndSelect)
      priv.anchorRow = row
    }
    priv.ensureVisible(row)
  }

  // Selects exactly these rows, with one selection change.
  function selectRows(rows) {
    if (rows.length === 0)
      selectionModel.clearSelection()
    else
      selectionModel.select(fsModel.selectionOf(rows), ItemSelectionModel.ClearAndSelect)
  }

  function activate(file) {
    if (!file || file.filePath === undefined)
      return
    activated(file)
    if (file.isDir && navigateIntoFolders && viewMode !== GXFileView.ExtendMode)
      folder = file.fileUrl
  }

  implicitWidth: 640
  implicitHeight: 480
  activeFocusOnTab: true

  onFolderChanged: {
    priv.anchorRow = -1
    priv.resetExtend()
  }

  Keys.onPressed: event => priv.handleKey(event)

  GXFileSystemModel {
    id: fsModel

    folder: control.folder
  }

  ItemSelectionModel {
    id: selectionModel

    model: fsModel
  }

  Connections {
    target: selectionModel

    function onSelectionChanged() {
      priv.selectedCount = selectionModel.selectedIndexes.length
      ++priv.revision
    }

    function onCurrentChanged() {
      ++priv.revision
    }
  }

  FontMetrics {
    id: metrics

    font: control.font
  }

  QtObject {
    id: priv

    // Bumped on every selection change; bindings read it to follow them.
    property int revision: 0
    property int selectedCount: 0
    // Where Shift+click selections start.
    property int anchorRow: -1
    readonly property int rowHeight: Math.max(Math.round(24 * 1.1), metrics.height)

    // Extend mode: the selected path of each column.
    property var extendSelection: []
    // Extend mode: the file models of the columns, by column.
    property var extendModels: []

    function ensureVisible(row) {
      const view = viewLoader.item ? viewLoader.item.itemView : null
      if (view)
        view.positionViewAtIndex(row, ItemView.Contain)
    }

    function resetExtend() {
      extendSelection = []
      extendModels = []
      extendColumns.clear()
      extendColumns.append({ folderUrl: String(control.folder) })
    }

    // Selects a file in an extend column; a folder opens in the next one.
    function extendSelect(column, file) {
      const selection = extendSelection.slice(0, column)
      selection.push(file.filePath)
      extendSelection = selection
      if (extendColumns.count > column + 1)
        extendColumns.remove(column + 1, extendColumns.count - column - 1)
      extendModels = extendModels.slice(0, column + 1)
      if (file.isDir)
        extendColumns.append({ folderUrl: String(file.fileUrl) })
    }

    function handleExtendKey(event) {
      const column = Math.max(0, extendSelection.length - 1)
      const model = extendModels[column]
      if (!model)
        return false
      const current = extendSelection.length > 0 ? model.indexOf(extendSelection[column]) : -1
      switch (event.key) {
      case Qt.Key_Up:
      case Qt.Key_Down: {
        const row = Math.max(0, Math.min(model.count - 1,
                                         current + (event.key === Qt.Key_Up ? -1 : 1)))
        if (row >= 0 && row < model.count)
          extendSelect(column, model.get(row))
        return true
      }
      case Qt.Key_Right: {
        const next = extendModels[column + 1]
        if (current >= 0 && next && next.count > 0)
          extendSelect(column + 1, next.get(0))
        return true
      }
      case Qt.Key_Left:
        if (column > 0) {
          const parentModel = extendModels[column - 1]
          extendSelect(column - 1, parentModel.get(parentModel.indexOf(extendSelection[column - 1])))
        }
        return true
      case Qt.Key_Return:
      case Qt.Key_Enter:
        if (current >= 0)
          control.activate(model.get(current))
        return true
      }
      return false
    }

    function handleKey(event) {
      const ctrl = event.modifiers & Qt.ControlModifier
      if (ctrl) {
        switch (event.key) {
        case Qt.Key_1: control.viewMode = GXFileView.IconMode; event.accepted = true; return
        case Qt.Key_2: control.viewMode = GXFileView.ListMode; event.accepted = true; return
        case Qt.Key_3: control.viewMode = GXFileView.ExtendMode; event.accepted = true; return
        case Qt.Key_H: fsModel.showHidden = !fsModel.showHidden; event.accepted = true; return
        case Qt.Key_Plus:
        case Qt.Key_Equal: control.zoomIn(); event.accepted = true; return
        case Qt.Key_Minus: control.zoomOut(); event.accepted = true; return
        case Qt.Key_A:
          if (control.viewMode !== GXFileView.ExtendMode) {
            control.selectAll()
            event.accepted = true
            return
          }
          break
        }
      }
      if (event.key === Qt.Key_Up && (event.modifiers & Qt.AltModifier)) {
        control.goUp()
        event.accepted = true
        return
      }
      if (control.viewMode === GXFileView.ExtendMode) {
        event.accepted = handleExtendKey(event)
        return
      }

      const count = fsModel.count
      if (count === 0)
        return
      const columns = control.viewMode === GXFileView.IconMode && viewLoader.item
                    ? viewLoader.item.columns : 1
      const current = control.currentRow
      let target = -1
      switch (event.key) {
      case Qt.Key_Left:
        target = columns > 1 ? current - 1 : -1
        break
      case Qt.Key_Right:
        target = columns > 1 ? current + 1 : -1
        break
      case Qt.Key_Up:
        target = current < 0 ? 0 : current - columns
        break
      case Qt.Key_Down:
        target = current < 0 ? 0 : current + columns
        break
      case Qt.Key_Home:
        target = 0
        break
      case Qt.Key_End:
        target = count - 1
        break
      case Qt.Key_Return:
      case Qt.Key_Enter:
        if (current >= 0)
          control.activate(fsModel.get(current))
        event.accepted = true
        return
      default:
        return
      }
      event.accepted = true
      if (target >= 0 && target < count)
        control.selectRow(target, event.modifiers & ~Qt.ControlModifier)
    }
  }

  ListModel {
    id: extendColumns
  }

  Loader {
    id: viewLoader

    anchors.fill: parent
    sourceComponent: control.viewMode === GXFileView.ListMode ? listViewComponent
                   : control.viewMode === GXFileView.ExtendMode ? extendViewComponent
                   : iconViewComponent
  }

  Text {
    anchors.centerIn: parent
    visible: fsModel.exists && fsModel.count === 0 && control.viewMode !== GXFileView.ExtendMode
    text: qsTranslate("DFileView", "Folder is empty")
    font.pixelSize: 20
    color: control.dark ? "#bdbdbd" : "#d0d0d0"
  }

  Component.onCompleted: priv.resetExtend()

  // Mouse handling of the icon and list views: selecting, the rubber band,
  // opening and the context menu.  It lies over the delegates, in the
  // content of the view, so it gets all clicks and lets the wheel through.
  // Under them, at a negative z, an interactive view keeps left presses.
  component SelectionArea: MouseArea {
    id: area

    // The view; it has rowAt(x, y), the row at a content position or -1,
    // and rowsIn(rect), the rows in a content rectangle.
    required property Flickable view

    readonly property int hoverRow: containsMouse ? view.rowAt(x + mouseX, y + mouseY) : -1
    property bool banding: false
    property point bandStart
    property point bandEnd
    readonly property rect band: Qt.rect(Math.min(bandStart.x, bandEnd.x), Math.min(bandStart.y, bandEnd.y),
                                         Math.abs(bandEnd.x - bandStart.x), Math.abs(bandEnd.y - bandStart.y))

    function updateBand(contentX, contentY) {
      bandEnd = Qt.point(contentX, contentY)
      control.selectRows(view.rowsIn(band))
    }

    x: view.originX
    y: view.originY
    // Over the delegates, also an expanded one.
    z: 3
    width: Math.max(view.width, view.contentWidth)
    height: Math.max(view.height, view.contentHeight)
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    preventStealing: true

    onPressed: mouse => {
      control.forceActiveFocus(Qt.MouseFocusReason)
      const row = view.rowAt(x + mouse.x, y + mouse.y)
      if (mouse.button === Qt.RightButton) {
        if (row < 0)
          control.clearSelection()
        else if (!control.isRowSelected(row))
          control.selectRow(row, 0)
        return
      }
      if (row >= 0) {
        control.selectRow(row, mouse.modifiers)
        return
      }
      if (!(mouse.modifiers & (Qt.ControlModifier | Qt.ShiftModifier)))
        control.clearSelection()
      bandStart = Qt.point(x + mouse.x, y + mouse.y)
      bandEnd = bandStart
      banding = true
    }
    onPositionChanged: mouse => {
      if (banding)
        updateBand(x + mouse.x, y + mouse.y)
    }
    onReleased: banding = false
    onCanceled: banding = false
    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        control.contextMenuRequested(control.selectedPaths, mapToItem(control, mouse.x, mouse.y))
    }
    onDoubleClicked: mouse => {
      const row = view.rowAt(x + mouse.x, y + mouse.y)
      if (mouse.button === Qt.LeftButton && row >= 0)
        control.activate(fsModel.get(row))
    }
    onWheel: wheel => {
      if ((wheel.modifiers & Qt.ControlModifier) && control.viewMode === GXFileView.IconMode) {
        if (wheel.angleDelta.y > 0)
          control.zoomIn()
        else if (wheel.angleDelta.y < 0)
          control.zoomOut()
        return
      }
      wheel.accepted = false
    }

    // Scrolls while the rubber band is dragged past an edge.
    Timer {
      interval: 16
      repeat: true
      running: area.banding && (area.mouseY + area.y < area.view.contentY
                                || area.mouseY + area.y > area.view.contentY + area.view.height)
      onTriggered: {
        const view = area.view
        const pointerY = area.mouseY + area.y
        const step = pointerY < view.contentY ? -Math.min(20, view.contentY - pointerY)
                                              : Math.min(20, pointerY - view.contentY - view.height)
        const maxY = view.originY + Math.max(0, view.contentHeight - view.height)
        view.contentY = Math.max(view.originY, Math.min(maxY, view.contentY + step))
        area.updateBand(area.x + area.mouseX, area.y + area.mouseY)
      }
    }

    Rectangle {
      visible: area.banding
      x: area.band.x - area.x
      y: area.band.y - area.y
      width: area.band.width
      height: area.band.height
      color: control.withAlpha(GxdePalette.highlight, 40)
      border.color: control.selectionBorderColor
    }
  }

  // The icon of a file: its theme icon, or a thumbnail of a picture, with
  // the link emblem of DFM.
  component FileIcon: Item {
    id: fileIcon

    required property string iconName
    required property string fallbackIconName
    required property url fileUrl
    required property bool thumbnailable
    required property bool isSymLink
    property bool thumbnail: false

    GXThemeIcon {
      anchors.fill: parent
      name: fileIcon.iconName
      fallbackName: fileIcon.fallbackIconName
      visible: thumb.status !== Image.Ready
    }

    Image {
      id: thumb

      anchors.fill: parent
      asynchronous: true
      fillMode: Image.PreserveAspectFit
      sourceSize: Qt.size(width * Screen.devicePixelRatio, height * Screen.devicePixelRatio)
      source: fileIcon.thumbnail && control.showThumbnails && fileIcon.thumbnailable ? fileIcon.fileUrl : ""
    }

    GXThemeIcon {
      readonly property real size: Math.min(24, fileIcon.width / 3)

      visible: fileIcon.isSymLink
      x: fileIcon.width - fileIcon.width / 8 - size / 2
      y: fileIcon.height - fileIcon.height / 8 - size / 2
      width: size
      height: size
      name: "emblem-symbolic-link"
    }
  }

  component IconDelegate: Item {
    id: cell

    required property int index
    required property string fileName
    required property url fileUrl
    required property bool isSymLink
    required property string iconName
    required property string fallbackIconName
    required property bool thumbnailable

    readonly property GridView view: GridView.view
    readonly property bool selected: priv.revision >= 0 && control.isRowSelected(index)
    readonly property bool hovered: view.hoverRow === index
    // A single selected file shows its whole name, over the files below.
    readonly property bool expanded: selected && priv.selectedCount === 1
                                     && fullLabel.implicitHeight > label.height + 1

    width: view.cellWidth
    height: view.cellHeight
    z: expanded ? 2 : 1

    Item {
      id: box

      x: (cell.width - cell.view.itemWidth) / 2
      y: 5
      width: cell.view.itemWidth
      height: cell.expanded ? Math.max(cell.view.itemHeight, fullLabel.y + fullLabel.height + 4)
                            : cell.view.itemHeight

      Rectangle {
        anchors.fill: parent
        visible: cell.expanded
        radius: 3
        color: GxdePalette.window
      }

      Rectangle {
        anchors.fill: parent
        visible: cell.selected || cell.hovered
        radius: 3
        color: cell.selected ? control.selectionColor : control.hoverColor
        border.width: cell.selected ? 1 : 0
        border.color: control.selectionBorderColor
      }

      FileIcon {
        x: (box.width - width) / 2
        width: control.iconSize
        height: control.iconSize
        iconName: cell.iconName
        fallbackIconName: cell.fallbackIconName
        fileUrl: cell.fileUrl
        thumbnailable: cell.thumbnailable
        isSymLink: cell.isSymLink
        thumbnail: true
      }

      Text {
        id: label

        x: 4
        y: control.iconSize + 4 + 5
        width: box.width - 8
        visible: !cell.expanded
        text: cell.fileName
        font: control.font
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        maximumLineCount: 3
        elide: Text.ElideRight
      }

      Text {
        id: fullLabel

        x: label.x
        y: label.y
        width: label.width
        visible: cell.expanded
        text: cell.fileName
        font: control.font
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
      }
    }
  }

  Component {
    id: iconViewComponent

    GridView {
      id: grid

      readonly property GridView itemView: grid
      readonly property int itemWidth: control.iconSize + 30
      readonly property int itemHeight: control.iconSize + 2 * 4 + 5 + 3 * metrics.height
      readonly property int columns: Math.max(1, Math.floor(width / (itemWidth + 10)))
      readonly property int hoverRow: area.hoverRow

      function rowAt(x, y) {
        const column = Math.floor(x / cellWidth)
        const line = Math.floor(y / cellHeight)
        if (column < 0 || column >= columns || line < 0)
          return -1
        const row = line * columns + column
        const localX = x - column * cellWidth - (cellWidth - itemWidth) / 2
        const localY = y - line * cellHeight - 5
        if (row >= count || localX < 0 || localX > itemWidth || localY < 0 || localY > itemHeight)
          return -1
        return row
      }

      function rowsIn(rect) {
        const rows = []
        const firstLine = Math.max(0, Math.floor(rect.y / cellHeight))
        const lastLine = Math.floor((rect.y + rect.height) / cellHeight)
        for (let line = firstLine; line <= lastLine; ++line) {
          for (let column = 0; column < columns; ++column) {
            const row = line * columns + column
            if (row >= count)
              return rows
            const left = column * cellWidth + (cellWidth - itemWidth) / 2
            const top = line * cellHeight + 5
            if (left < rect.x + rect.width && left + itemWidth > rect.x
                && top < rect.y + rect.height && top + itemHeight > rect.y)
              rows.push(row)
          }
        }
        return rows
      }

      cellWidth: Math.floor(width / columns)
      cellHeight: itemHeight + 10
      model: fsModel
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      keyNavigationEnabled: false
      ScrollBar.vertical: ScrollBar { }

      delegate: IconDelegate { }

      SelectionArea {
        id: area

        view: grid
      }
    }
  }

  component ListDelegate: Item {
    id: listRow

    required property int index
    required property string fileName
    required property url fileUrl
    required property bool isSymLink
    required property string iconName
    required property string fallbackIconName
    required property bool thumbnailable
    required property string modifiedText
    required property string sizeText
    required property string typeName

    readonly property ListView view: ListView.view
    readonly property bool selected: priv.revision >= 0 && control.isRowSelected(index)
    readonly property bool hovered: view.hoverRow === index

    width: view.width
    height: priv.rowHeight

    // DFM's alternate rows.
    Rectangle {
      x: 20
      width: parent.width - 40
      height: parent.height
      color: listRow.index % 2 === 0 ? (control.dark ? "#1a202020" : "#03000000")
                                      : (control.dark ? "#1a000000" : "transparent")
    }

    Rectangle {
      x: 20
      width: parent.width - 40
      height: parent.height
      visible: listRow.selected || listRow.hovered
      radius: 3
      color: listRow.selected ? control.selectionColor : control.hoverColor
      border.width: listRow.selected ? 1 : 0
      border.color: control.selectionBorderColor
    }

    FileIcon {
      id: rowIcon

      x: 30
      anchors.verticalCenter: parent.verticalCenter
      width: 24
      height: 24
      iconName: listRow.iconName
      fallbackIconName: listRow.fallbackIconName
      fileUrl: listRow.fileUrl
      thumbnailable: listRow.thumbnailable
      isSymLink: listRow.isSymLink
    }

    Text {
      x: rowIcon.x + rowIcon.width + 16
      width: 20 + listRow.view.nameWidth - x - 10
      anchors.verticalCenter: parent.verticalCenter
      text: listRow.fileName
      font: control.font
      color: control.textColor
      elide: Text.ElideRight
    }

    Repeater {
      model: [listRow.modifiedText, listRow.sizeText, listRow.typeName]

      Text {
        required property string modelData
        required property int index

        x: listRow.view.columnX(index + 1) + 10
        width: listRow.view.columnWidths[index] - 20
        anchors.verticalCenter: parent.verticalCenter
        text: modelData
        font: control.font
        color: control.secondaryTextColor
        elide: Text.ElideRight
      }
    }
  }

  Component {
    id: listViewComponent

    Item {
      id: table

      readonly property ListView itemView: list
      readonly property var columnTitles: [
        qsTranslate("DFileView", "Name"),
        qsTranslate("DFileView", "Time modified"),
        qsTranslate("DFileView", "Size"),
        qsTranslate("DFileView", "Type")
      ]
      readonly property var sortFields: [
        GXFileSystemModel.Name,
        GXFileSystemModel.Modified,
        GXFileSystemModel.Size,
        GXFileSystemModel.Type
      ]
      readonly property color lineColor: control.dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1)

      clip: true

      // The column headers of DFMHeaderView.
      Item {
        id: columnHeader

        width: parent.width
        height: 22

        Rectangle {
          anchors.fill: parent
          gradient: Gradient {
            GradientStop { position: 0; color: control.dark ? Qt.rgba(0, 0, 0, 0.1) : "#4df8f8f8" }
            GradientStop { position: 1; color: control.dark ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(1, 1, 1, 0.1) }
          }
        }

        Rectangle {
          anchors.bottom: parent.bottom
          width: parent.width
          height: 1
          color: Qt.rgba(0, 0, 0, 0.1)
        }

        Repeater {
          model: 4

          Item {
            id: section

            required property int index
            readonly property bool sorted: fsModel.sortField === table.sortFields[index]

            x: index === 0 ? 0 : list.columnX(index)
            width: index === 0 ? 20 + list.nameWidth : list.columnWidths[index - 1]
            height: columnHeader.height - 1

            Text {
              anchors.left: parent.left
              anchors.leftMargin: section.index === 0 ? 30 : 10
              anchors.right: arrow.visible ? arrow.left : parent.right
              anchors.rightMargin: 4
              anchors.verticalCenter: parent.verticalCenter
              text: table.columnTitles[section.index]
              font: control.font
              color: "#797979"
              elide: Text.ElideRight
            }

            Image {
              id: arrow

              anchors.right: parent.right
              anchors.rightMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              visible: section.sorted
              rotation: fsModel.sortOrder === Qt.AscendingOrder ? 180 : 0
              source: control.dark ? "assets/dark/header_arrow_down.svg"
                                   : "assets/light/header_arrow_down.png"
            }

            Rectangle {
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              width: 1
              height: parent.height - 8
              color: table.lineColor
            }

            MouseArea {
              anchors.fill: parent
              onClicked: {
                const field = table.sortFields[section.index]
                if (fsModel.sortField === field) {
                  fsModel.sortOrder = fsModel.sortOrder === Qt.AscendingOrder ? Qt.DescendingOrder
                                                                              : Qt.AscendingOrder
                } else {
                  fsModel.sortField = field
                  fsModel.sortOrder = Qt.AscendingOrder
                }
              }
            }

            // Drags the right edge of the section to resize the columns.
            MouseArea {
              property real pressX

              x: parent.width - 3
              width: 6
              height: parent.height
              z: 1
              cursorShape: Qt.SplitHCursor
              onPressed: mouse => pressX = mapToItem(columnHeader, mouse.x, 0).x
              onPositionChanged: mouse => {
                const headerX = mapToItem(columnHeader, mouse.x, 0).x
                const delta = Math.round(headerX - pressX)
                if (delta === 0)
                  return
                if (section.index === 0) {
                  // The name takes what the time column gives.
                  const width = Math.max(60, control.modifiedColumnWidth - delta)
                  pressX += control.modifiedColumnWidth - width
                  control.modifiedColumnWidth = width
                } else {
                  const names = ["modifiedColumnWidth", "sizeColumnWidth", "typeColumnWidth"]
                  const name = names[section.index - 1]
                  const width = Math.max(60, control[name] + delta)
                  pressX += width - control[name]
                  control[name] = width
                }
              }
            }
          }
        }
      }

      ListView {
        id: list

        readonly property var columnWidths: [control.modifiedColumnWidth,
                                             control.sizeColumnWidth,
                                             control.typeColumnWidth]
        readonly property int nameWidth: Math.max(140, width - 40 - columnWidths[0]
                                                  - columnWidths[1] - columnWidths[2])
        readonly property int hoverRow: area.hoverRow

        // Left edge of a column in the row, after the 20 pixel margin.
        function columnX(column) {
          let x = 20 + nameWidth
          for (let i = 1; i < column; ++i)
            x += columnWidths[i - 1]
          return x
        }

        function rowAt(x, y) {
          const row = Math.floor(y / priv.rowHeight)
          return x >= 20 && x <= width - 20 && row >= 0 && row < count ? row : -1
        }

        function rowsIn(rect) {
          const rows = []
          if (rect.x > width - 20 || rect.x + rect.width < 20)
            return rows
          const first = Math.max(0, Math.floor(rect.y / priv.rowHeight))
          const last = Math.min(count - 1, Math.floor((rect.y + rect.height) / priv.rowHeight))
          for (let row = first; row <= last; ++row)
            rows.push(row)
          return rows
        }

        anchors.top: columnHeader.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        model: fsModel
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: false
        ScrollBar.vertical: ScrollBar { }

        delegate: ListDelegate { }

        SelectionArea {
          id: area

          view: list
        }
      }
    }
  }

  component ExtendColumn: Item {
    id: column

    required property int index
    required property string folderUrl

    width: 220
    height: ListView.view.height

    GXFileSystemModel {
      id: columnModel

      folder: column.folderUrl
      showHidden: fsModel.showHidden
      nameFilters: fsModel.nameFilters
      sortField: fsModel.sortField
      sortOrder: fsModel.sortOrder
    }

    Component.onCompleted: {
      const models = priv.extendModels.slice(0, column.index)
      models[column.index] = columnModel
      priv.extendModels = models
    }

    ListView {
      id: rows

      anchors.fill: parent
      anchors.rightMargin: 1
      model: columnModel
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.vertical: ScrollBar { }

      delegate: Item {
        id: extendRow

        required property int index
        required property string fileName
        required property string filePath
        required property url fileUrl
        required property bool isDir
        required property bool isSymLink
        required property string iconName
        required property string fallbackIconName
        required property bool thumbnailable

        readonly property bool selected: priv.extendSelection[column.index] === filePath
        // Selected rows of the columns on the left, which lead here.
        readonly property bool inPath: selected && column.index < priv.extendSelection.length - 1

        width: rows.width
        height: priv.rowHeight

        Rectangle {
          x: 4
          width: parent.width - 8
          height: parent.height
          visible: extendRow.selected || rowMouse.containsMouse
          radius: 3
          color: extendRow.inPath ? control.hoverColor
               : extendRow.selected ? control.selectionColor
               : control.hoverColor
          border.width: extendRow.selected && !extendRow.inPath ? 1 : 0
          border.color: control.selectionBorderColor
        }

        FileIcon {
          id: extendIcon

          x: 10
          anchors.verticalCenter: parent.verticalCenter
          width: 20
          height: 20
          iconName: extendRow.iconName
          fallbackIconName: extendRow.fallbackIconName
          fileUrl: extendRow.fileUrl
          thumbnailable: extendRow.thumbnailable
          isSymLink: extendRow.isSymLink
        }

        Text {
          anchors.left: extendIcon.right
          anchors.leftMargin: 8
          anchors.right: chevron.visible ? chevron.left : parent.right
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          text: extendRow.fileName
          font: control.font
          color: control.textColor
          elide: Text.ElideRight
        }

        Image {
          id: chevron

          anchors.right: parent.right
          anchors.rightMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          visible: extendRow.isDir
          source: "assets/common/arrow-right.svg"
          sourceSize: Qt.size(10, 10)
        }

        MouseArea {
          id: rowMouse

          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onPressed: mouse => {
            control.forceActiveFocus(Qt.MouseFocusReason)
            priv.extendSelect(column.index, columnModel.get(extendRow.index))
          }
          onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
              control.contextMenuRequested(control.selectedPaths, mapToItem(control, mouse.x, mouse.y))
          }
          onDoubleClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
              control.activate(columnModel.get(extendRow.index))
          }
        }
      }
    }

    Rectangle {
      anchors.right: parent.right
      width: 1
      height: parent.height
      color: control.dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1)
    }
  }

  Component {
    id: extendViewComponent

    ListView {
      id: columns

      readonly property ListView itemView: columns

      orientation: ListView.Horizontal
      model: extendColumns
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.horizontal: ScrollBar { }

      delegate: ExtendColumn { }

      onCountChanged: Qt.callLater(positionViewAtEnd)
    }
  }
}
