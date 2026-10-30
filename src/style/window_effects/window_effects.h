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

#ifndef SRC_STYLE_WINDOW_EFFECTS_WINDOW_EFFECTS_H_
#define SRC_STYLE_WINDOW_EFFECTS_WINDOW_EFFECTS_H_

#include <QtQmlIntegration/qqmlintegration.h>

#include <QObject>
#include <QRectF>
#include <QWindow>

namespace gxde {

/**
 * @class WindowEffects
 * @brief Blur behind a window from QML.
 *
 * The underlying work is handled by GXDE Bernese.
 */
class WindowEffects : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

 public:
  /**
   * @brief The constructor.
   * @param parent The optional QObject parent.
   */
  explicit WindowEffects(QObject* parent = nullptr);

  /**
   * @brief Check if blur is supportted.
   * @return True when blur works.
   */
  Q_INVOKABLE bool isBlurSupported() const;  // NOLINT

  /**
   * @brief Do a behind window blue.
   *
   * @note On Wayland, call this again after each show.
   * @param window The window, may be null.
   * @param area Area in logical pixels in the window.
   * @param radius Corner radius of the area in logical pixels.
   * @return True when the blur was sent.
   */
  Q_INVOKABLE bool setBlurBehind(QWindow* window, const QRectF& area,  // NOLINT
                                 int radius);

  /**
   * @brief Removes the blur from a window.
   * @param window The window, may be null.
   * @return True when the blur was removed.
   */
  Q_INVOKABLE bool clearBlurBehind(QWindow* window);  // NOLINT
};

}  // namespace gxde

#endif  // SRC_STYLE_WINDOW_EFFECTS_WINDOW_EFFECTS_H_
