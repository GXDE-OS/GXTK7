# Copyright (C) 2026 CharOfString <root@charofstring.cc>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.20)

project(GXTK7
  VERSION 0.1.0
  DESCRIPTION "GXDE Qt Quick Style library and components based on dtk2widget"
  LANGUAGES CXX
)

option(GXTK7_BUILD_EXAMPLES "Build the example applications" ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS
  Core
  DBus
  Gui
  Qml
  Quick
  QuickControls2
)
find_package(GxdeBerneseQt6 0.1.1 REQUIRED)

# QWindowKit, vendored in libs/qwindowkit, makes GXMainWindow frameless.  Only
# its Quick module is needed; it is built static and linked into the style
# library, so nothing of it is installed.
set(QWINDOWKIT_BUILD_STATIC ON)
set(QWINDOWKIT_BUILD_WIDGETS OFF)
set(QWINDOWKIT_BUILD_QUICK ON)
set(QWINDOWKIT_BUILD_EXAMPLES OFF)
set(QWINDOWKIT_BUILD_TESTS OFF)
set(QWINDOWKIT_BUILD_DOCUMENTATIONS OFF)
set(QWINDOWKIT_INSTALL OFF)
set(QWINDOWKIT_ENABLE_STYLE_AGENT OFF)
# QWindowKit looks for Qt 6 or Qt 5 itself and can take Qt 5 when both are
# installed, as on the riscv64 builder; a preset major version makes it use
# the Qt 6 found above.
set(QT_VERSION_MAJOR 6)
add_subdirectory(libs/qwindowkit EXCLUDE_FROM_ALL)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

qt_add_library(gxde_style_plugin SHARED
  src/style/avatar_image/avatar_image.h
  src/style/avatar_image/avatar_image.cc
  src/style/file_system_model/file_system_model.h
  src/style/file_system_model/file_system_model.cc
  src/style/gxde_theme/gxde_theme.h
  src/style/gxde_theme/gxde_theme.cc
  src/style/main_window_background/main_window_background.h
  src/style/main_window_background/main_window_background.cc
  src/style/theme_icon/theme_icon.h
  src/style/theme_icon/theme_icon.cc
  src/style/window_agent/window_agent.h
  src/style/window_agent/window_agent.cc
  src/style/window_effects/window_effects.h
  src/style/window_effects/window_effects.cc
)

target_include_directories(gxde_style_plugin
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
  PRIVATE
    # The generated QML type registration includes QML_ELEMENT headers by
    # file name only.
    ${CMAKE_CURRENT_SOURCE_DIR}/src/style/avatar_image
    ${CMAKE_CURRENT_SOURCE_DIR}/src/style/file_system_model
    ${CMAKE_CURRENT_SOURCE_DIR}/src/style/gxde_theme
    ${CMAKE_CURRENT_SOURCE_DIR}/src/style/main_window_background
    ${CMAKE_CURRENT_SOURCE_DIR}/src/style/theme_icon
    ${CMAKE_CURRENT_SOURCE_DIR}/src/style/window_agent
    ${CMAKE_CURRENT_SOURCE_DIR}/src/style/window_effects
)

target_link_libraries(gxde_style_plugin
  PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
  PRIVATE
    Qt6::DBus
    GxdeBernese::Qt6
    QWindowKit::Quick
)

set(GXDE_STYLE_QML_DIR src/style/qml/gxde)
set(GXDE_STYLE_QML_FILES
  ${GXDE_STYLE_QML_DIR}/ApplicationWindow.qml
  ${GXDE_STYLE_QML_DIR}/ArrowRectangle.qml
  ${GXDE_STYLE_QML_DIR}/Avatar.qml
  ${GXDE_STYLE_QML_DIR}/BusyIndicator.qml
  ${GXDE_STYLE_QML_DIR}/Button.qml
  ${GXDE_STYLE_QML_DIR}/CheckBox.qml
  ${GXDE_STYLE_QML_DIR}/ComboBox.qml
  ${GXDE_STYLE_QML_DIR}/Dialog.qml
  ${GXDE_STYLE_QML_DIR}/DialogButtonBox.qml
  ${GXDE_STYLE_QML_DIR}/Frame.qml
  ${GXDE_STYLE_QML_DIR}/GXAboutDialog.qml
  ${GXDE_STYLE_QML_DIR}/GXFileView.qml
  ${GXDE_STYLE_QML_DIR}/GroupBox.qml
  ${GXDE_STYLE_QML_DIR}/GXMainWindow.qml
  ${GXDE_STYLE_QML_DIR}/GXSideBar.qml
  ${GXDE_STYLE_QML_DIR}/GXTitleBar.qml
  ${GXDE_STYLE_QML_DIR}/GxdePalette.qml
  ${GXDE_STYLE_QML_DIR}/ImageButton.qml
  ${GXDE_STYLE_QML_DIR}/ItemDelegate.qml
  ${GXDE_STYLE_QML_DIR}/Label.qml
  ${GXDE_STYLE_QML_DIR}/Menu.qml
  ${GXDE_STYLE_QML_DIR}/MenuItem.qml
  ${GXDE_STYLE_QML_DIR}/MenuSeparator.qml
  ${GXDE_STYLE_QML_DIR}/Page.qml
  ${GXDE_STYLE_QML_DIR}/Pane.qml
  ${GXDE_STYLE_QML_DIR}/Popup.qml
  ${GXDE_STYLE_QML_DIR}/ProgressBar.qml
  ${GXDE_STYLE_QML_DIR}/RadioButton.qml
  ${GXDE_STYLE_QML_DIR}/ScrollBar.qml
  ${GXDE_STYLE_QML_DIR}/SettingsModule.qml
  ${GXDE_STYLE_QML_DIR}/SettingsView.qml
  ${GXDE_STYLE_QML_DIR}/Slider.qml
  ${GXDE_STYLE_QML_DIR}/SpinBox.qml
  ${GXDE_STYLE_QML_DIR}/Switch.qml
  ${GXDE_STYLE_QML_DIR}/TabBar.qml
  ${GXDE_STYLE_QML_DIR}/TabButton.qml
  ${GXDE_STYLE_QML_DIR}/TextArea.qml
  ${GXDE_STYLE_QML_DIR}/TextField.qml
  ${GXDE_STYLE_QML_DIR}/ToolBar.qml
  ${GXDE_STYLE_QML_DIR}/ToolButton.qml
  ${GXDE_STYLE_QML_DIR}/ToolTip.qml
  ${GXDE_STYLE_QML_DIR}/impl/ButtonPanel.qml
  ${GXDE_STYLE_QML_DIR}/impl/EditFrame.qml
  ${GXDE_STYLE_QML_DIR}/impl/ModuleListDelegate.qml
  ${GXDE_STYLE_QML_DIR}/impl/ModuleTile.qml
  ${GXDE_STYLE_QML_DIR}/impl/TitleBarButton.qml
)

# RectangularShadow was added to QtQuick.Effects in Qt 6.9, but Menu.qml uses
# it unconditionally.  When building against an older Qt, compile a drop-in
# internal type of the same name into the module instead; Qt 6.9+ builds keep
# the stock Qt type and never see this file.
if(Qt6_VERSION VERSION_LESS 6.9)
  list(APPEND GXDE_STYLE_QML_FILES
    ${GXDE_STYLE_QML_DIR}/RectangularShadow.qml
  )
endif()

file(GLOB_RECURSE GXDE_STYLE_ASSETS CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  ${GXDE_STYLE_QML_DIR}/assets/*.png
  ${GXDE_STYLE_QML_DIR}/assets/*.svg
)

set_source_files_properties(${GXDE_STYLE_QML_DIR}/GxdePalette.qml
  PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)
set_source_files_properties(
  ${GXDE_STYLE_QML_DIR}/impl/ButtonPanel.qml
  ${GXDE_STYLE_QML_DIR}/impl/EditFrame.qml
  ${GXDE_STYLE_QML_DIR}/impl/ModuleListDelegate.qml
  ${GXDE_STYLE_QML_DIR}/impl/ModuleTile.qml
  ${GXDE_STYLE_QML_DIR}/impl/TitleBarButton.qml
  PROPERTIES QT_QML_INTERNAL_TYPE TRUE
)

if(Qt6_VERSION VERSION_LESS 6.9)
  set_source_files_properties(${GXDE_STYLE_QML_DIR}/RectangularShadow.qml
    PROPERTIES QT_QML_INTERNAL_TYPE TRUE
  )
endif()

foreach(file IN LISTS GXDE_STYLE_QML_FILES GXDE_STYLE_ASSETS)
  string(REPLACE "${GXDE_STYLE_QML_DIR}/" "" alias "${file}")
  set_source_files_properties(${file} PROPERTIES QT_RESOURCE_ALIAS "${alias}")
endforeach()

qt_policy(SET QTP0004 NEW)

qt_add_qml_module(gxde_style_plugin
  URI "QtQuick.Controls.Gxde"
  VERSION 1.0
  RESOURCE_PREFIX "/qt-project.org/imports"
  OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/QtQuick/Controls/Gxde"
  IMPORTS QtQuick.Controls.Basic
  QML_FILES ${GXDE_STYLE_QML_FILES}
  RESOURCES ${GXDE_STYLE_ASSETS}
)

# The QML files are compiled into the backing library's resources, so the
# module directory only needs the qmldir, the type info, the plugin and the
# backing library it loads through $ORIGIN.
qt_query_qml_module(gxde_style_plugin
  TARGET_PATH GXDE_STYLE_TARGET_PATH
  PLUGIN_TARGET GXDE_STYLE_PLUGIN_TARGET
  QMLDIR GXDE_STYLE_QMLDIR
  TYPEINFO GXDE_STYLE_TYPEINFO
)
set(GXDE_STYLE_INSTALL_DIR "${QT6_INSTALL_QML}/${GXDE_STYLE_TARGET_PATH}")

set_target_properties(${GXDE_STYLE_PLUGIN_TARGET} PROPERTIES
  INSTALL_RPATH "$ORIGIN"
)

install(TARGETS gxde_style_plugin ${GXDE_STYLE_PLUGIN_TARGET}
  LIBRARY DESTINATION "${GXDE_STYLE_INSTALL_DIR}"
)
install(FILES "${GXDE_STYLE_QMLDIR}" "${GXDE_STYLE_TYPEINFO}"
  DESTINATION "${GXDE_STYLE_INSTALL_DIR}"
)

if(GXTK7_BUILD_EXAMPLES)
  add_subdirectory(examples/gallery)
  add_subdirectory(examples/control_center)
endif()
