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
import QtQuick.Layouts

ApplicationWindow {
  id: window
  width: 960
  height: 700
  minimumWidth: 800
  minimumHeight: 600
  visible: true
  title: qsTr("GXDE Qt Quick Style Gallery")

  header: ToolBar {
    RowLayout {
      anchors.fill: parent
      spacing: 10

      Label {
        text: qsTr("GXDE Controls Gallery")
        font.weight: Font.Medium
      }

      Item { Layout.fillWidth: true }

      Label {
        text: qsTr("Dark Mode")
      }

      Switch {
        checked: GxdeTheme.isDark
        onToggled: GxdeTheme.isDark = checked
      }

      ToolButton {
        text: qsTr("Menu")
        onClicked: optionsMenu.popup()

        Menu {
          id: optionsMenu
          MenuItem {
            text: qsTr("Show Tooltips")
            checkable: true
            checked: true
          }
          MenuItem {
            text: qsTr("Compact Layout")
            checkable: true
          }
          MenuSeparator { }
          Menu {
            title: qsTr("Scheme")
            MenuItem {
              text: qsTr("Light")
              onTriggered: GxdeTheme.isDark = false
            }
            MenuItem {
              text: qsTr("Dark")
              onTriggered: GxdeTheme.isDark = true
            }
          }
          MenuItem {
            text: qsTr("Unavailable")
            enabled: false
          }
          MenuSeparator { }
          MenuItem {
            text: qsTr("About")
            onTriggered: testDialog.open()
          }
        }
      }
    }
  }

  TabBar {
    id: galleryTabs
    width: parent.width

    TabButton {
      text: qsTr("Buttons && Toggles")
    }
    TabButton {
      text: qsTr("Inputs && Sliders")
    }
    TabButton {
      text: qsTr("Containers && Popups")
    }
  }

  StackLayout {
    anchors.top: galleryTabs.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: 16
    currentIndex: galleryTabs.currentIndex

    Flickable {
      contentWidth: width
      contentHeight: buttonsColumn.implicitHeight
      clip: true

      ScrollBar.vertical: ScrollBar { }

      ColumnLayout {
        id: buttonsColumn
        width: parent.width - 12
        spacing: 16

        GroupBox {
          title: qsTr("Buttons")
          Layout.fillWidth: true

          RowLayout {
            spacing: 10

            Button {
              text: qsTr("Normal")
            }

            Button {
              text: qsTr("Suggested")
              highlighted: true
              onClicked: testDialog.open()
            }

            Button {
              text: qsTr("Flat")
              flat: true
            }

            Button {
              text: qsTr("Disabled")
              enabled: false
            }

            ToolButton {
              text: qsTr("Tool")
            }
          }
        }

        GroupBox {
          title: qsTr("Switches")
          Layout.fillWidth: true

          RowLayout {
            spacing: 24

            Switch {
              text: qsTr("Wi-Fi")
              checked: true
            }

            Switch {
              text: qsTr("Bluetooth")
            }

            Switch {
              text: qsTr("Disabled")
              enabled: false
              checked: true
            }
          }
        }

        GroupBox {
          title: qsTr("Check Boxes & Radio Buttons")
          Layout.fillWidth: true

          RowLayout {
            spacing: 40

            ColumnLayout {
              spacing: 6
              CheckBox {
                text: qsTr("Enable window transparency")
                checked: true
              }
              CheckBox {
                text: qsTr("Enable compositor shadows")
              }
              CheckBox {
                text: qsTr("Partially selected")
                tristate: true
                checkState: Qt.PartiallyChecked
              }
              CheckBox {
                text: qsTr("Disabled")
                enabled: false
                checked: true
              }
            }

            ColumnLayout {
              spacing: 6
              RadioButton {
                text: qsTr("High quality (OpenGL)")
                checked: true
              }
              RadioButton {
                text: qsTr("Balanced")
              }
              RadioButton {
                text: qsTr("Power saver")
              }
              RadioButton {
                text: qsTr("Disabled")
                enabled: false
              }
            }
          }
        }

        GroupBox {
          title: qsTr("Activity & Progress")
          Layout.fillWidth: true

          RowLayout {
            anchors.fill: parent
            spacing: 24

            BusyIndicator {
              running: true
            }

            ColumnLayout {
              spacing: 8
              Layout.fillWidth: true

              Label {
                text: qsTr("Progress: %1%").arg(Math.round(sampleSlider.value * 100))
              }
              ProgressBar {
                Layout.fillWidth: true
                value: sampleSlider.value
              }
              ProgressBar {
                Layout.fillWidth: true
                indeterminate: true
              }
            }
          }
        }
      }
    }

    Flickable {
      contentWidth: width
      contentHeight: inputsColumn.implicitHeight
      clip: true

      ScrollBar.vertical: ScrollBar { }

      ColumnLayout {
        id: inputsColumn
        width: parent.width - 12
        spacing: 16

        GroupBox {
          title: qsTr("Text Inputs")
          Layout.fillWidth: true

          ColumnLayout {
            anchors.fill: parent
            spacing: 10

            TextField {
              Layout.fillWidth: true
              placeholderText: qsTr("Search keyword or user name")
            }

            TextField {
              Layout.fillWidth: true
              text: qsTr("Read-only system configuration")
              readOnly: true
            }

            TextField {
              Layout.fillWidth: true
              text: qsTr("Disabled")
              enabled: false
            }

            TextArea {
              Layout.fillWidth: true
              Layout.preferredHeight: 80
              placeholderText: qsTr("Multi-line description or notes")
            }
          }
        }

        GroupBox {
          title: qsTr("Sliders & Value Controls")
          Layout.fillWidth: true

          GridLayout {
            anchors.fill: parent
            columns: 3
            columnSpacing: 12
            rowSpacing: 12

            Label {
              text: qsTr("Volume:")
            }
            Slider {
              id: sampleSlider
              Layout.fillWidth: true
              value: 0.65
            }
            Label {
              text: Math.round(sampleSlider.value * 100) + "%"
              Layout.preferredWidth: 40
            }

            Label {
              text: qsTr("Disabled:")
            }
            Slider {
              Layout.fillWidth: true
              value: 0.3
              enabled: false
            }
            Item { }

            Label {
              text: qsTr("Desktop scale:")
            }
            RowLayout {
              spacing: 12
              Layout.columnSpan: 2

              ComboBox {
                model: ["100%", "125%", "150%", "175%", "200%"]
              }

              ComboBox {
                editable: true
                model: ["Custom", "Large", "Small"]
              }

              SpinBox {
                from: 0
                to: 100
                value: 50
                editable: true
              }
            }
          }
        }
      }
    }

    RowLayout {
      spacing: 16

      Frame {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
          anchors.fill: parent
          spacing: 8

          Label {
            text: qsTr("Frame")
            font.weight: Font.Medium
          }

          Label {
            text: qsTr("A DFrame-style panel: a 6px rounded outline around the content.")
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            color: GxdePalette.textDisabled
          }

          Item { Layout.fillHeight: true }

          RowLayout {
            spacing: 10

            Button {
              text: qsTr("Open Dialog")
              highlighted: true
              onClicked: testDialog.open()
            }

            Button {
              id: tipButton
              text: qsTr("Hover Me")
              ToolTip.visible: hovered
              ToolTip.text: qsTr("A plain white dstyle tooltip")
            }
          }
        }
      }

      Pane {
        Layout.preferredWidth: 260
        Layout.fillHeight: true
        padding: 0

        ListView {
          anchors.fill: parent
          clip: true
          model: [qsTr("Display"), qsTr("Network"), qsTr("Sound"), qsTr("Personalization"),
              qsTr("Power"), qsTr("Mouse"), qsTr("Keyboard"), qsTr("Date and Time"),
              qsTr("Accounts"), qsTr("Updates"), qsTr("System Info")]
          currentIndex: 0

          delegate: ItemDelegate {
            required property string modelData
            required property int index

            width: ListView.view.width
            text: modelData
            highlighted: ListView.isCurrentItem
            onClicked: ListView.view.currentIndex = index
          }

          ScrollBar.vertical: ScrollBar { }
        }
      }
    }
  }

  Dialog {
    id: testDialog
    title: qsTr("GXDE Style")
    anchors.centerIn: parent
    modal: true

    Label {
      width: parent.width
      text: qsTr("Dialogs follow DDialog: a rounded panel and a full-width row of action buttons.")
      wrapMode: Text.Wrap
      color: GxdePalette.dialogMessage
    }

    standardButtons: Dialog.Cancel | Dialog.Ok
  }
}
