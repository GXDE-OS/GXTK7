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

#ifndef SRC_STYLE_THEME_ICON_THEME_ICON_H_
#define SRC_STYLE_THEME_ICON_THEME_ICON_H_

#include <QtQmlIntegration/qqmlintegration.h>

#include <QIcon>
#include <QQuickPaintedItem>
#include <QString>

namespace gxde {

/**
 * @class ThemeIcon
 * @brief Paints an icon of the icon theme, trying fallback names in turn.
 *
 * Unlike IconImage, it takes a fallback name, which file icons need: the
 * icon of a MIME type is often missing while its generic icon is there.
 */
class ThemeIcon : public QQuickPaintedItem {
  Q_OBJECT
  QML_NAMED_ELEMENT(GXThemeIcon)

  Q_PROPERTY(QString name READ Name WRITE SetName NOTIFY nameChanged)
  Q_PROPERTY(
      QString fallbackName READ FallbackName WRITE SetFallbackName NOTIFY fallbackNameChanged)
  Q_PROPERTY(bool valid READ IsValid NOTIFY validChanged)

 public:
  /**
   * @brief Constructs the item.
   * @param parent The optional parent item.
   */
  explicit ThemeIcon(QQuickItem* parent = nullptr);

  /// @brief Returns the icon name tried first.
  [[nodiscard]] QString Name() const;
  /// @brief Sets the icon name tried first.
  void SetName(const QString& name);

  /// @brief Returns the icon name tried when the first one is missing.
  [[nodiscard]] QString FallbackName() const;
  /// @brief Sets the icon name tried when the first one is missing.
  void SetFallbackName(const QString& name);

  /**
   * @brief Returns whether one of the names was found.
   * @return True when there is something to paint.
   */
  [[nodiscard]] bool IsValid() const;

  /**
   * @brief Paints the icon centered in the item.
   * @param painter Painter of the item.
   */
  void paint(QPainter* painter) override;

  /**
   * @brief Makes theme icons work when the configured theme is missing.
   *
   * Some platform themes name an icon theme that is not installed, which
   * leaves QIcon::fromTheme with hicolor only.  Then this picks an installed
   * theme as the fallback theme.  Called once when the module loads.
   */
  static void EnsureIconTheme();

 signals:
  void nameChanged();          // NOLINT(readability-identifier-naming)
  void fallbackNameChanged();  // NOLINT(readability-identifier-naming)
  void validChanged();         // NOLINT(readability-identifier-naming)

 private:
  // Looks the icon up again after a name changed.
  void Reload();

  QString name_;
  QString fallback_name_;
  QIcon icon_;
};

}  // namespace gxde

#endif  // SRC_STYLE_THEME_ICON_THEME_ICON_H_
