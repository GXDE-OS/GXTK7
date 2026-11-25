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

#ifndef SRC_STYLE_MAIN_WINDOW_BACKGROUND_MAIN_WINDOW_BACKGROUND_H_
#define SRC_STYLE_MAIN_WINDOW_BACKGROUND_MAIN_WINDOW_BACKGROUND_H_

#include <QtQmlIntegration/qqmlintegration.h>

#include <QList>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QUrl>

namespace gxde {

/**
 * @class MainWindowBackground
 * @brief Finds the window background pictures, like DTK2's
 *        DMainWindowBackground.
 *
 * The pictures are looked up in the same places DTK2 uses, so a background
 * set for a DTK2 application also shows in GXTK7 applications:
 *
 * - `/usr/share/backgrounds/GXDE/dtk2/global/background-<theme>-<place>.png`
 * - `~/.config/GXDE/dtk2/global/background-<theme>-<place>.png`
 * - `/usr/share/backgrounds/GXDE/dtk2/<app>/background-<theme>-<place>.png`
 * - `~/.config/GXDE/<app>/background-<theme>-<place>.png`
 * - every entry of customBackgroundPaths, as `<path>-<place>.png`
 *
 * A later entry wins over an earlier one.  The global entries are skipped
 * when useGlobalBackground is false.  `<theme>` follows GxdeTheme.isDark.
 *
 * The object only finds the files; GXMainWindow draws them.
 */
class MainWindowBackground : public QObject {
  Q_OBJECT
  QML_NAMED_ELEMENT(GXMainWindowBackground)

  Q_PROPERTY(QString appName READ AppName WRITE SetAppName NOTIFY appNameChanged)
  Q_PROPERTY(bool useGlobalBackground READ UseGlobalBackground WRITE SetUseGlobalBackground NOTIFY
                 useGlobalBackgroundChanged)
  Q_PROPERTY(QStringList customBackgroundPaths READ CustomBackgroundPaths WRITE
                 SetCustomBackgroundPaths NOTIFY customBackgroundPathsChanged)
  Q_PROPERTY(bool isSet READ IsSet NOTIFY backgroundChanged)
  Q_PROPERTY(bool userBackgroundSet READ UserBackgroundSet NOTIFY backgroundChanged)
  Q_PROPERTY(QList<QUrl> sources READ Sources NOTIFY backgroundChanged)

 public:
  /**
   * @brief Where a picture is drawn in the window.
   *
   * The values match DTK2's DMainWindowBackground::BackgroundPlace.
   */
  enum Place {
    TopLeft = 0,
    TopCenter = 1,
    TopRight = 2,
    CenterLeft = 3,
    Center = 4,
    CenterRight = 5,
    BottomLeft = 6,
    BottomCenter = 7,
    BottomRight = 8,
    FullWindow = 9,  ///< Covers the window, cropped to keep its aspect ratio.
  };
  Q_ENUM(Place)

  /**
   * @brief The theme a user picture belongs to.
   */
  enum Theme {
    Light = 0,
    Dark = 1,
  };
  Q_ENUM(Theme)

  /**
   * @brief Constructs the object and looks up the pictures.
   * @param parent The optional QObject parent.
   */
  explicit MainWindowBackground(QObject* parent = nullptr);

  /**
   * @brief Returns the application name used in the lookup paths.
   * @return The name; QCoreApplication::applicationName() by default.
   */
  [[nodiscard]] QString AppName() const;

  /**
   * @brief Sets the application name used in the lookup paths.
   * @param name The new name.
   */
  void SetAppName(const QString& name);

  /**
   * @brief Returns whether the GXDE wide pictures are used.
   * @return True by default.
   */
  [[nodiscard]] bool UseGlobalBackground() const;

  /**
   * @brief Sets whether the GXDE wide pictures are used.
   * @param use True to use them.
   */
  void SetUseGlobalBackground(bool use);

  /**
   * @brief Returns the extra lookup paths.
   * @return Path prefixes, without the `-<place>.png` suffix.
   */
  [[nodiscard]] QStringList CustomBackgroundPaths() const;

  /**
   * @brief Sets the extra lookup paths.
   * @param paths Path prefixes, without the `-<place>.png` suffix.
   */
  void SetCustomBackgroundPaths(const QStringList& paths);

  /**
   * @brief Returns whether any picture was found.
   * @return True when there is something to draw.
   */
  [[nodiscard]] bool IsSet() const;

  /**
   * @brief Returns whether the user set a full window picture for this
   *        application, for either theme.
   * @return True when such a picture exists.
   */
  [[nodiscard]] bool UserBackgroundSet() const;

  /**
   * @brief Returns the picture of each place.
   *
   * The list is indexed by Place.  A place without a picture has an empty
   * URL.  The URLs carry a query that changes on every refresh(), so images
   * loaded from them reload even when the file name stays the same.
   * @return Ten URLs.
   */
  [[nodiscard]] QList<QUrl> Sources() const;

  /**
   * @brief Looks up the pictures again.
   */
  Q_INVOKABLE void refresh();  // NOLINT(readability-identifier-naming)

  /**
   * @brief Returns the picture of one place.
   * @param place The place.
   * @return The URL, empty when there is no picture.
   */
  Q_INVOKABLE QUrl source(  // NOLINT(readability-identifier-naming)
      gxde::MainWindowBackground::Place place) const;

  /**
   * @brief Copies a picture to the user configuration of this application.
   * @param theme The theme the picture is for.
   * @param image_path A local file path or file URL.
   * @param place The place of the picture.
   * @return True when the copy worked.
   */
  Q_INVOKABLE bool setUserBackground(  // NOLINT(readability-identifier-naming)
      gxde::MainWindowBackground::Theme theme, const QString& image_path,
      gxde::MainWindowBackground::Place place);

  /**
   * @brief Removes a picture from the user configuration of this
   *        application.
   * @param theme The theme the picture is for.
   * @param place The place of the picture.
   * @return True when there is no such picture any more.
   */
  Q_INVOKABLE bool removeUserBackground(  // NOLINT(readability-identifier-naming)
      gxde::MainWindowBackground::Theme theme, gxde::MainWindowBackground::Place place);

  /**
   * @brief Returns whether the user set a picture for a place, for either
   *        theme.
   * @param place The place.
   * @return True when such a picture exists.
   */
  Q_INVOKABLE bool isUserBackgroundSet(  // NOLINT(readability-identifier-naming)
      gxde::MainWindowBackground::Place place) const;

 signals:
  void appNameChanged();                 // NOLINT(readability-identifier-naming)
  void useGlobalBackgroundChanged();     // NOLINT(readability-identifier-naming)
  void customBackgroundPathsChanged();   // NOLINT(readability-identifier-naming)
  void backgroundChanged();              // NOLINT(readability-identifier-naming)

 private:
  [[nodiscard]] QString UserPath(Theme theme, Place place) const;

  QString app_name_;
  bool use_global_background_{true};
  QStringList custom_background_paths_;
  QList<QUrl> sources_;
  bool is_set_{false};
  bool user_background_set_{false};
  quint64 revision_{0};
};

}  // namespace gxde

#endif  // SRC_STYLE_MAIN_WINDOW_BACKGROUND_MAIN_WINDOW_BACKGROUND_H_
