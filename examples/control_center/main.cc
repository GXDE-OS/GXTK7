/*
 * Copyright (C) 2026 CharOfString <root@charofstring.cc>
 * Copyright (C) 2026 shenmo <shenmo@spark-app.store>
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

#include <QCommandLineParser>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QUrl>
#include <QVariantMap>

int main(int argc, char** argv) {
  QGuiApplication app(argc, argv);
  QGuiApplication::setOrganizationName("GXDE");
  QGuiApplication::setApplicationName("gxde-quick-control-center");

  // Same as the -m and -p options of gxde-control-center --window.
  QCommandLineParser parser;
  parser.addHelpOption();
  const QCommandLineOption module_option({"m", "module"}, "Module to show.", "module");
  const QCommandLineOption page_option({"p", "page"}, "Page of the module to show.", "page");
  parser.addOption(module_option);
  parser.addOption(page_option);
  parser.process(app);

  QQuickStyle::setStyle("QtQuick.Controls.Gxde");
  QQuickStyle::setFallbackStyle("Basic");

  QQmlApplicationEngine engine;
  engine.setInitialProperties({
      {"initialModule", parser.value(module_option)},
      {"initialPage", parser.value(page_option)},
  });

  const QUrl url(QStringLiteral("qrc:/main.qml"));
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreated, &app,
      [url](QObject* obj, const QUrl& obj_url) {
        if (!obj && url == obj_url) {
          QCoreApplication::exit(-1);
        }
      },
      Qt::QueuedConnection);

  engine.load(url);

  return QGuiApplication::exec();
}
