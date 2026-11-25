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

#include "src/style/gxde_theme/gxde_theme.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QGuiApplication>
#include <QStyleHints>

namespace gxde {

namespace {

const char kPortalService[] = "org.freedesktop.portal.Desktop";
const char kPortalPath[] = "/org/freedesktop/portal/desktop";
const char kPortalInterface[] = "org.freedesktop.portal.Settings";
const char kAppearanceGroup[] = "org.freedesktop.appearance";
const char kColorSchemeKey[] = "color-scheme";

// The theme is read while the first window loads, so do not let a missing
// portal hold it up for long.
constexpr int kPortalTimeoutMs = 300;

// Settings.Read wraps the value in one more variant than Settings.ReadOne
// and SettingChanged do, so unwrap as many as there are.
QVariant Unwrap(QVariant value) {
  while (value.metaType() == QMetaType::fromType<QDBusVariant>()) {
    value = qvariant_cast<QDBusVariant>(value).variant();
  }
  return value;
}

int ToColorScheme(const QVariant& value) {
  bool ok = false;
  const uint scheme = Unwrap(value).toUInt(&ok);
  return ok && scheme <= 2 ? static_cast<int>(scheme) : -1;
}

}  // namespace

GxdeTheme::GxdeTheme(QObject* parent) : QObject(parent) {
  WatchSystem();
}

GxdeTheme* GxdeTheme::Instance() {
  static GxdeTheme instance(nullptr);
  return &instance;
}

GxdeTheme* GxdeTheme::create(  // NOLINT(readability-identifier-naming)
    QQmlEngine* /*engine*/, QJSEngine* /*script_engine*/) {
  GxdeTheme* theme = Instance();
  QJSEngine::setObjectOwnership(theme, QJSEngine::CppOwnership);
  return theme;
}

bool GxdeTheme::IsDark() const {
  return is_dark_;
}

void GxdeTheme::SetDark(bool dark) {
  SetFollowSystem(false);
  ApplyDark(dark);
}

bool GxdeTheme::FollowSystem() const {
  return follow_system_;
}

void GxdeTheme::SetFollowSystem(bool follow) {
  if (follow_system_ == follow) {
    return;
  }
  follow_system_ = follow;
  emit followSystemChanged();
  if (follow_system_) {
    ApplyDark(system_dark_);
  }
}

bool GxdeTheme::SystemDark() const {
  return system_dark_;
}

void GxdeTheme::OnPortalSettingChanged(const QString& group, const QString& key,
                                       const QDBusVariant& value) {
  if (group != QLatin1String(kAppearanceGroup) || key != QLatin1String(kColorSchemeKey)) {
    return;
  }
  portal_scheme_ = ToColorScheme(value.variant());
  UpdateSystemDark();
}

void GxdeTheme::WatchSystem() {
  // The singleton may in theory be made before the application; then there
  // is nothing to watch and the theme stays light.
  if (qGuiApp == nullptr) {
    return;
  }

  connect(QGuiApplication::styleHints(), &QStyleHints::colorSchemeChanged, this,
          &GxdeTheme::UpdateSystemDark);

  QDBusConnection bus = QDBusConnection::sessionBus();
  if (bus.isConnected()) {
    bus.connect(QLatin1String(kPortalService), QLatin1String(kPortalPath),
                QLatin1String(kPortalInterface), QStringLiteral("SettingChanged"), this,
                SLOT(OnPortalSettingChanged(QString, QString, QDBusVariant)));
    portal_scheme_ = ReadPortalColorScheme();
  }

  UpdateSystemDark();
}

int GxdeTheme::ReadPortalColorScheme() {
  QDBusConnection bus = QDBusConnection::sessionBus();
  // ReadOne is portal version 2; Read is the older call.
  for (const char* method : {"ReadOne", "Read"}) {
    QDBusMessage call = QDBusMessage::createMethodCall(
        QLatin1String(kPortalService), QLatin1String(kPortalPath),
        QLatin1String(kPortalInterface), QLatin1String(method));
    call << QLatin1String(kAppearanceGroup) << QLatin1String(kColorSchemeKey);
    const QDBusMessage reply = bus.call(call, QDBus::Block, kPortalTimeoutMs);
    if (reply.type() == QDBusMessage::ReplyMessage && !reply.arguments().isEmpty()) {
      return ToColorScheme(reply.arguments().constFirst());
    }
    // Only an old portal makes trying Read worth it.
    if (reply.errorName() != QLatin1String("org.freedesktop.DBus.Error.UnknownMethod")) {
      break;
    }
  }
  return -1;
}

void GxdeTheme::UpdateSystemDark() {
  bool dark = false;
  if (portal_scheme_ == 1) {
    dark = true;
  } else if (portal_scheme_ == 2) {
    dark = false;
  } else if (qGuiApp != nullptr) {
    // No portal, or no preference there.
    dark = QGuiApplication::styleHints()->colorScheme() == Qt::ColorScheme::Dark;
  }

  if (system_dark_ != dark) {
    system_dark_ = dark;
    emit systemDarkChanged();
  }
  if (follow_system_) {
    ApplyDark(system_dark_);
  }
}

void GxdeTheme::ApplyDark(bool dark) {
  if (is_dark_ != dark) {
    is_dark_ = dark;
    emit themeChanged();
  }
}

}  // namespace gxde
