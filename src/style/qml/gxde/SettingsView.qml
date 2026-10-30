/*
 * Copyright (C) 2026 CharOfString <root@charofstring.cc>
 * Copyright (C) 2026 shenmo <shenmo@spark-app.store>
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
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls.Gxde

T.Control {
  id: control

  default property list<SettingsModule> modules
  property string homeTitle: qsTr("All Settings")
  property int columns: 3

  readonly property string currentModule: d.current
  readonly property var availableModules: {
    const result = []
    for (let i = 0; i < modules.length; ++i) {
      if (modules[i].available)
        result.push(modules[i])
    }
    return result
  }

  function findModule(name) {
    for (let i = 0; i < modules.length; ++i) {
      if (modules[i].name === name)
        return modules[i]
    }
    return null
  }

  function showHome() {
    d.current = ""
  }

  function showModule(name, page) {
    const module = findModule(name)
    if (!module || !module.available) {
      showHome()
      return
    }
    d.current = name
    const view = d.currentView
    if (view && view.depth > 1)
      view.pop(null, T.StackView.Immediate)
    if (page)
      module.pageRequested(page)
  }

  QtObject {
    id: d

    property string current
    readonly property SettingsModule module: control.findModule(current)
    readonly property T.StackView currentView: {
      for (let i = 0; i < pages.count; ++i) {
        const loader = pages.itemAt(i)
        if (loader && loader.current)
          return loader.item
      }
      return null
    }
  }

  contentItem: Item {
    ColumnLayout {
      anchors.fill: parent
      anchors.leftMargin: 24
      anchors.rightMargin: 24
      anchors.topMargin: 20
      anchors.bottomMargin: 20
      spacing: 16
      visible: control.currentModule === ""

      Label {
        text: control.homeTitle
        font.pixelSize: 20
        font.weight: Font.Medium
      }

      Flickable {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentWidth: width
        contentHeight: grid.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar { }

        GridLayout {
          id: grid
          columns: control.columns
          rowSpacing: 16
          columnSpacing: 16

          Repeater {
            model: control.availableModules

            ModuleTile {
              required property SettingsModule modelData

              text: modelData.title
              icon.source: modelData.iconSource
              onClicked: control.showModule(modelData.name)
            }
          }
        }
      }
    }

    RowLayout {
      anchors.fill: parent
      spacing: 0
      visible: control.currentModule !== ""

      Rectangle {
        Layout.preferredWidth: 200
        Layout.fillHeight: true
        color: GxdePalette.settingsNav

        ListView {
          anchors.fill: parent
          anchors.margins: 8
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          model: control.availableModules
          currentIndex: control.availableModules.findIndex(m => m.name === control.currentModule)

          ScrollBar.vertical: ScrollBar { }

          delegate: ModuleListDelegate {
            required property SettingsModule modelData

            width: ListView.view.width
            text: modelData.title
            icon.source: modelData.iconSource
            highlighted: ListView.isCurrentItem
            onClicked: control.showModule(modelData.name)
          }
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        Layout.topMargin: 12
        spacing: 8

        RowLayout {
          spacing: 8

          ToolButton {
            padding: 0
            focusPolicy: Qt.NoFocus
            icon.source: "assets/common/back.png"
            icon.width: 24
            icon.height: 24
            icon.color: pressed ? GxdePalette.highlight : GxdePalette.text
            background: null
            onClicked: {
              const view = d.currentView
              if (view && view.depth > 1)
                view.pop()
              else
                control.showHome()
            }
          }

          Label {
            Layout.fillWidth: true
            text: {
              const view = d.currentView
              if (view && view.depth > 1 && view.currentItem && view.currentItem.title)
                return view.currentItem.title
              return d.module ? d.module.title : ""
            }
            font.pixelSize: 16
            font.weight: Font.Medium
            elide: Text.ElideRight
          }
        }

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true

          Repeater {
            id: pages
            model: control.modules

            Loader {
              id: pageLoader

              required property SettingsModule modelData
              readonly property bool current: modelData.name === control.currentModule
              property bool loaded: false

              anchors.fill: parent
              visible: current
              active: loaded || current
              onCurrentChanged: {
                if (current)
                  loaded = true
              }

              sourceComponent: StackView {
                initialItem: pageLoader.modelData.page
              }

              Connections {
                target: pageLoader.modelData

                function onAvailableChanged() {
                  if (!pageLoader.modelData.available && pageLoader.current)
                    control.showHome()
                }
              }
            }
          }
        }
      }
    }
  }
}
