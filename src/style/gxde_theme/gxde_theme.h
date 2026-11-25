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

#include <QDBusVariant>
#include <QObject>
#include <QQmlEngine>

namespace gxde {

/**
 * @class GxdeTheme
 * @brief Holds the theme state shared by the Gxde QML style and C++.
 *
 * Unlike DTK2, the theme follows the system light or dark preference by
 * default.  The preference is read from the XDG desktop portal
 * (`org.freedesktop.appearance` `color-scheme`, which GXDE's portal
 * provides), and from QStyleHints::colorScheme() when the portal has none.
 *
 * Setting isDark is a manual choice: it turns followSystem off, so later
 * system changes no longer apply.  Set followSystem back to true to follow
 * the system again.
 */
class GxdeTheme : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  Q_PROPERTY(bool isDark READ IsDark WRITE SetDark NOTIFY themeChanged)
  Q_PROPERTY(bool followSystem READ FollowSystem WRITE SetFollowSystem NOTIFY
                 followSystemChanged)
  Q_PROPERTY(bool systemDark READ SystemDark NOTIFY systemDarkChanged)

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
   * @brief Sets the theme mode by hand.
   *
   * This also turns followSystem off.
   * @param dark Boolean indicating dark mode on/off.
   */
  void SetDark(bool dark);

  /**
   * @brief Gets whether the theme follows the system preference.
   * @return True until the theme is set by hand.
   */
  [[nodiscard]] bool FollowSystem() const;

  /**
   * @brief Sets whether the theme follows the system preference.
   *
   * Turning it on applies the system preference right away.
   * @param follow True to follow the system.
   */
  void SetFollowSystem(bool follow);

  /**
   * @brief Gets the system preference.
   * @return True when the system prefers dark.
   */
  [[nodiscard]] bool SystemDark() const;

 signals:
  /**
   * @brief Emitted when the theme mode changes.
   *
   * QML only binds on<Signal> handlers to signals starting in lowercase.
   */
  void themeChanged();         // NOLINT(readability-identifier-naming)
  void followSystemChanged();  // NOLINT(readability-identifier-naming)
  void systemDarkChanged();    // NOLINT(readability-identifier-naming)

 private slots:
  // Slot for the portal's Settings.SettingChanged D-Bus signal.
  void OnPortalSettingChanged(const QString& group, const QString& key,
                              const QDBusVariant& value);

 private:
  // Sets up the system preference sources.  Needs a QGuiApplication.
  void WatchSystem();
  // Reads the portal color-scheme: 0 no preference, 1 dark, 2 light, or -1
  // when there is no portal.
  static int ReadPortalColorScheme();
  // Recomputes system_dark_ and applies it when following the system.
  void UpdateSystemDark();
  void ApplyDark(bool dark);

  bool is_dark_{false};
  bool follow_system_{true};
  bool system_dark_{false};
  // Last portal color-scheme, -1 when unknown.
  int portal_scheme_{-1};
};

}  // namespace gxde

#endif  // SRC_STYLE_GXDE_THEME_GXDE_THEME_H_
