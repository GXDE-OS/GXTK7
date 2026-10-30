# Copyright (C) 2026 CharOfString <root@charofstring.cc>
# Copyright (C) 2026 shenmo <shenmo@spark-app.store>
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

qt_add_executable(gxde_control_center
  ${CMAKE_CURRENT_SOURCE_DIR}/main.cc
)

target_link_libraries(gxde_control_center
  PRIVATE
    gxde_style_plugin
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

file(GLOB CONTROL_CENTER_ICONS CONFIGURE_DEPENDS
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/icons/*.svg
)

qt_add_resources(gxde_control_center "control_center_resources"
  PREFIX "/"
  FILES
    main.qml
    ${CONTROL_CENTER_ICONS}
)
