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

#ifndef SRC_STYLE_AVATAR_IMAGE_AVATAR_IMAGE_H_
#define SRC_STYLE_AVATAR_IMAGE_AVATAR_IMAGE_H_

#include <QtQmlIntegration/qqmlintegration.h>

#include <QImage>
#include <QQuickPaintedItem>
#include <QUrl>

namespace gxde {

/**
 * @class AvatarImage
 * @brief Paints a picture in a circle, like DTK's AvatarWidget.
 *
 * It uses QPainter, so it looks the same on every scene graph backend, also
 * the software one.
 */
class AvatarImage : public QQuickPaintedItem {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(QUrl source READ Source WRITE SetSource NOTIFY sourceChanged)
  Q_PROPERTY(bool selected READ IsSelected WRITE SetSelected NOTIFY
                 selectedChanged)
  Q_PROPERTY(int ringWidth READ RingWidth WRITE SetRingWidth NOTIFY
                 ringWidthChanged)

 public:
  /**
   * @brief Constructs the item.
   * @param parent The optional parent item.
   */
  explicit AvatarImage(QQuickItem* parent = nullptr);

  /**
   * @brief Returns the picture to paint.
   * @return A local file or Qt resource URL.
   */
  [[nodiscard]] QUrl Source() const;

  /**
   * @brief Sets the picture to paint and loads it.
   * @param source A local file or Qt resource URL.
   */
  void SetSource(const QUrl& source);

  /**
   * @brief Returns whether the white selection ring is shown.
   * @return True when selected.
   */
  [[nodiscard]] bool IsSelected() const;

  /**
   * @brief Shows or hides the white selection ring.
   * @param selected True to show the ring.
   */
  void SetSelected(bool selected);

  /**
   * @brief Returns the visible width of the selection ring.
   * @return Width in logical pixels.
   */
  [[nodiscard]] int RingWidth() const;

  /**
   * @brief Sets the visible width of the selection ring.
   * @param width Width in logical pixels.
   */
  void SetRingWidth(int width);

  /**
   * @brief Paints the clipped picture and the ring.
   * @param painter Painter of the item.
   */
  void paint(QPainter* painter) override;

 signals:
  void sourceChanged();     // NOLINT(readability-identifier-naming)
  void selectedChanged();   // NOLINT(readability-identifier-naming)
  void ringWidthChanged();  // NOLINT(readability-identifier-naming)

 protected:
  /**
   * @brief Drops the scaled picture when the size changes.
   * @param new_geometry New geometry of the item.
   * @param old_geometry Old geometry of the item.
   */
  void geometryChange(const QRectF& new_geometry,
                      const QRectF& old_geometry) override;

 private:
  QUrl source_;
  QImage image_;
  // image_ scaled to the item size, in device pixels.
  QImage scaled_;
  bool selected_{false};
  int ring_width_{2};
};

}  // namespace gxde

#endif  // SRC_STYLE_AVATAR_IMAGE_AVATAR_IMAGE_H_
