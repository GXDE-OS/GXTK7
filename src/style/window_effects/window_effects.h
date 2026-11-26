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

  /**
   * @brief Check if the desktop composites windows.
   *
   * Without a compositor, the transparent parts of a window show black, so
   * client side shadows and rounded corners must not be drawn.
   * @return True on X11 with a compositing manager and on every other
   *         platform.
   */
  Q_INVOKABLE bool hasCompositing() const;  // NOLINT

  /**
   * @brief Asks the Wayland compositor not to draw a title bar.
   *
   * @note Call this again after each show.
   * @param window The window, may be null.
   * @param no_title_bar True to remove the title bar.
   * @return True when the request was sent.
   */
  Q_INVOKABLE bool setNoTitleBar(QWindow* window, bool no_title_bar);  // NOLINT

  /**
   * @brief Moves a Wayland popup from where the compositor puts it.
   *
   * On Wayland, a menu opens at the bottom left of its parent item.  Popups
   * that draw a shadow inside the window need moving back by its size.
   * @note Call this before the popup is shown.
   * @param window The popup window, may be null.
   * @param x Offset to the right, in logical pixels.
   * @param y Offset down, in logical pixels.
   */
  Q_INVOKABLE void setPopupOffset(QWindow* window, int x, int y);  // NOLINT
};

}  // namespace gxde

#endif  // SRC_STYLE_WINDOW_EFFECTS_WINDOW_EFFECTS_H_
