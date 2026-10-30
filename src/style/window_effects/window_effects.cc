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

#include "src/style/window_effects/window_effects.h"

#include <bernese/window_effects.h>

namespace gxde {

WindowEffects::WindowEffects(QObject* parent) : QObject(parent) {}

bool WindowEffects::isBlurSupported() const {  // NOLINT
  return bernese::window_effects::IsBlurBehindSupported();
}

bool WindowEffects::setBlurBehind(QWindow* window,  // NOLINT
                                  const QRectF& area, int radius) {
  return bernese::window_effects::SetBlurBehind(
      window, {area.toAlignedRect()}, radius);
}

bool WindowEffects::clearBlurBehind(QWindow* window) {  // NOLINT
  return bernese::window_effects::ClearBlurBehind(window);
}

}  // namespace gxde
