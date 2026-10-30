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
import QtQuick.Controls.Gxde
import QtQuick.Layouts

ApplicationWindow {
  id: window

  property string initialModule
  property string initialPage

  width: 960
  height: 640
  minimumWidth: 720
  minimumHeight: 480
  visible: true
  title: qsTr("Control Center")

  Component.onCompleted: {
    GxdeTheme.isDark = true
    if (initialModule)
      settings.showModule(initialModule, initialPage)
  }

  SettingsView {
    id: settings
    anchors.fill: parent

    SettingsModule {
      name: "accounts"
      title: qsTr("Accounts")
      iconSource: Qt.resolvedUrl("icons/nav_accounts.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "cloudsync"
      title: qsTr("Cloud Sync")
      iconSource: Qt.resolvedUrl("icons/nav_cloudsync.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "display"
      title: qsTr("Display")
      iconSource: Qt.resolvedUrl("icons/nav_display.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "defapp"
      title: qsTr("Default Applications")
      iconSource: Qt.resolvedUrl("icons/nav_defapp.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "personalization"
      title: qsTr("Personalization")
      iconSource: Qt.resolvedUrl("icons/nav_personalization.svg")
      page: personalizationPage
    }
    SettingsModule {
      name: "network"
      title: qsTr("Network")
      iconSource: Qt.resolvedUrl("icons/nav_network.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "bluetooth"
      title: qsTr("Bluetooth")
      iconSource: Qt.resolvedUrl("icons/nav_bluetooth.svg")
      page: placeholderPage
    }
    SettingsModule {
      id: soundModule
      name: "sound"
      title: qsTr("Sound")
      iconSource: Qt.resolvedUrl("icons/nav_sound.svg")
      page: soundPage
    }
    SettingsModule {
      name: "datetime"
      title: qsTr("Time and Date")
      iconSource: Qt.resolvedUrl("icons/nav_datetime.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "power"
      title: qsTr("Power Management")
      iconSource: Qt.resolvedUrl("icons/nav_power.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "mouse"
      title: qsTr("Mouse")
      iconSource: Qt.resolvedUrl("icons/nav_mouse.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "keyboard"
      title: qsTr("Keyboard and Language")
      iconSource: Qt.resolvedUrl("icons/nav_keyboard.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "wacom"
      title: qsTr("Wacom")
      iconSource: Qt.resolvedUrl("icons/nav_wacom.svg")
      page: placeholderPage

      available: false
    }
    SettingsModule {
      name: "update"
      title: qsTr("Update")
      iconSource: Qt.resolvedUrl("icons/nav_update.svg")
      page: placeholderPage
    }
    SettingsModule {
      name: "systeminfo"
      title: qsTr("System Information")
      iconSource: Qt.resolvedUrl("icons/nav_systeminfo.svg")
      page: placeholderPage
    }
  }

  Component {
    id: placeholderPage

    Page {
      Label {
        anchors.centerIn: parent
        text: qsTr("This module is not ported to QML yet.")
        color: GxdePalette.textDisabled
      }
    }
  }

  Component {
    id: personalizationPage

    Page {
      ColumnLayout {
        width: parent.width
        spacing: 10

        GroupBox {
          Layout.fillWidth: true
          title: qsTr("Theme")

          RowLayout {
            anchors.fill: parent

            Label {
              Layout.fillWidth: true
              text: qsTr("Dark")
            }

            Switch {
              checked: GxdeTheme.isDark
              onToggled: GxdeTheme.isDark = checked
            }
          }
        }
      }
    }
  }

  Component {
    id: soundPage

    Page {
      id: soundRoot

      Connections {
        target: soundModule

        function onPageRequested(page) {
          if (page === "advanced")
            soundRoot.StackView.view.push(advancedSoundPage)
        }
      }

      ColumnLayout {
        width: parent.width
        spacing: 10

        GroupBox {
          Layout.fillWidth: true
          title: qsTr("Speaker")

          GridLayout {
            anchors.fill: parent
            columns: 2
            columnSpacing: 10

            Label {
              text: qsTr("Output Volume")
            }
            Slider {
              Layout.fillWidth: true
              to: 100
              value: 60
            }

            Label {
              text: qsTr("Left/Right Balance")
            }
            Slider {
              Layout.fillWidth: true
              from: -1
              to: 1
              value: 0
            }
          }
        }

        Button {
          text: qsTr("Advanced Settings")
          onClicked: soundRoot.StackView.view.push(advancedSoundPage)
        }
      }
    }
  }

  Component {
    id: advancedSoundPage

    Page {
      title: qsTr("Advanced Settings")

      ColumnLayout {
        width: parent.width
        spacing: 10

        CheckBox {
          text: qsTr("Sound Effects")
          checked: true
        }

        RowLayout {
          Label {
            text: qsTr("Output Device")
          }
          ComboBox {
            model: [qsTr("Speaker"), qsTr("Headphones"), qsTr("HDMI")]
          }
        }
      }
    }
  }
}
