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

#ifndef SRC_STYLE_GXDE_THEME_GXDE_THEME_H_
#define SRC_STYLE_GXDE_THEME_GXDE_THEME_H_

#include <QtQmlIntegration/qqmlintegration.h>

#include <QObject>
#include <QQmlEngine>

namespace gxde {

/**
 * @class GxdeTheme
 * @brief Holds the theme state shared by the Gxde QML style and C++.
 */
class GxdeTheme : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  Q_PROPERTY(bool isDark READ IsDark WRITE SetDark NOTIFY themeChanged)

 public:
  /**
   * @brief Constructs the GxdeTheme instance.
   * @param parent The optional QObject parent, if any.
   */
  explicit GxdeTheme(QObject* parent);

  /**
   * @brief Destructor for GxdeTheme.
   */
  ~GxdeTheme() override = default;

  /**
   * @brief Returns the global GxdeTheme instance.
   *
   * @note This is a singleton instance.
   * @return Singleton GxdeTheme pointer.
   */
  static GxdeTheme* Instance();

  /**
   * @brief QML singleton provider callback.
   *
   * QML_SINGLETON requires this exact name.
   * @param engine QML engine reference.
   * @param script_engine JS engine reference.
   * @return Shared singleton instance, owned by C++.
   */
  static GxdeTheme* create(  // NOLINT(readability-identifier-naming)
      QQmlEngine* engine, QJSEngine* script_engine);

  /**
   * @brief Gets whether dark theme mode is enabled.
   * @return True if dark mode is active.
   */
  [[nodiscard]] bool IsDark() const;

  /**
   * @brief Sets the theme mode.
   * @param dark Boolean indicating dark mode on/off.
   */
  void SetDark(bool dark);

 signals:
  /**
   * @brief Emitted when the theme mode changes.
   *
   * QML only binds on<Signal> handlers to signals starting in lowercase.
   */
  void themeChanged();  // NOLINT(readability-identifier-naming)

 private:
  bool is_dark_{false};
};

}  // namespace gxde

#endif  // SRC_STYLE_GXDE_THEME_GXDE_THEME_H_
