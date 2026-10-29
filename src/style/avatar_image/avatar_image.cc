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

#include "src/style/avatar_image/avatar_image.h"

#include <QPainter>
#include <QPainterPath>
#include <QQuickWindow>

namespace gxde {

namespace {

/**
 * @brief Turns a QML URL into a path for QImage.
 * @param url A local file or Qt resource URL.
 * @return The path, or an empty string for other schemes.
 */
QString LocalPath(const QUrl& url) {
  if (url.isLocalFile()) {
    return url.toLocalFile();
  }
  if (url.scheme() == QLatin1String("qrc")) {
    return QLatin1Char(':') + url.path();
  }
  // A plain path works too, like in AvatarWidget.
  return url.scheme().isEmpty() ? url.path() : QString();
}

}  // namespace

AvatarImage::AvatarImage(QQuickItem* parent) : QQuickPaintedItem(parent) {
  setAntialiasing(true);
}

QUrl AvatarImage::Source() const {
  return source_;
}

void AvatarImage::SetSource(const QUrl& source) {
  if (source_ == source) {
    return;
  }

  source_ = source;
  const QString path = LocalPath(source_);
  image_ = path.isEmpty() ? QImage() : QImage(path);
  scaled_ = QImage();
  update();
  emit sourceChanged();
}

bool AvatarImage::IsSelected() const {
  return selected_;
}

void AvatarImage::SetSelected(bool selected) {
  if (selected_ == selected) {
    return;
  }

  selected_ = selected;
  update();
  emit selectedChanged();
}

int AvatarImage::RingWidth() const {
  return ring_width_;
}

void AvatarImage::SetRingWidth(int width) {
  if (ring_width_ == width) {
    return;
  }

  ring_width_ = width;
  update();
  emit ringWidthChanged();
}

void AvatarImage::paint(QPainter* painter) {
  const QRectF rect = boundingRect();
  if (rect.isEmpty()) {
    return;
  }

  painter->setRenderHint(QPainter::Antialiasing);
  painter->setRenderHint(QPainter::SmoothPixmapTransform);

  QPainterPath circle;
  circle.addEllipse(rect);

  if (!image_.isNull()) {
    // Scale once with smooth scaling, like AvatarWidget does with
    // QPixmap::scaled().
    const qreal ratio = window() ? window()->effectiveDevicePixelRatio() : 1.0;
    const QSize target = (rect.size() * ratio).toSize();
    if (scaled_.size() != target) {
      scaled_ = image_.scaled(target, Qt::IgnoreAspectRatio,
                              Qt::SmoothTransformation);
      scaled_.setDevicePixelRatio(ratio);
    }

    painter->save();
    painter->setClipPath(circle);
    painter->drawImage(rect, scaled_);
    painter->restore();
  }

  if (selected_) {
    // Half the pen is outside the clip, so the ring is ringWidth wide.
    painter->setClipPath(circle);
    painter->setPen(QPen(Qt::white, ring_width_ * 2));
    painter->setBrush(Qt::NoBrush);
    painter->drawEllipse(rect);
  }
}

void AvatarImage::geometryChange(const QRectF& new_geometry,
                                 const QRectF& old_geometry) {
  QQuickPaintedItem::geometryChange(new_geometry, old_geometry);
  if (new_geometry.size() != old_geometry.size()) {
    scaled_ = QImage();
  }
}

}  // namespace gxde
