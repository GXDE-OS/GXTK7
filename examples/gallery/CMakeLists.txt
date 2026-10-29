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

qt_add_executable(gxde_gallery
  ${CMAKE_CURRENT_SOURCE_DIR}/main.cc
)

target_include_directories(gxde_gallery
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}
)

target_link_libraries(gxde_gallery
  PRIVATE
    gxde_style_plugin
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

qt_add_resources(gxde_gallery "gallery_resources"
  PREFIX "/"
  FILES
    main.qml
)
