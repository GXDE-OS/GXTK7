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

#ifndef SRC_STYLE_WINDOW_AGENT_WINDOW_AGENT_H_
#define SRC_STYLE_WINDOW_AGENT_WINDOW_AGENT_H_

#include <QtQmlIntegration/qqmlintegration.h>

#include <QList>
#include <QObject>
#include <QPair>
#include <QPointer>
#include <QQmlParserStatus>
#include <QQuickItem>
#include <QQuickWindow>

namespace QWK {
class QuickWindowAgent;
}

namespace gxde {

/**
 * @class WindowAgent
 * @brief Makes a window frameless with QWindowKit, from QML.
 *
 * A declarative wrapper of QWK::QuickWindowAgent.  QWindowKit takes over
 * what a system title bar does: dragging the title bar moves the window, a
 * double click maximizes it, a right click shows the system window menu,
 * and the window edges resize it.  The system buttons are given to it so
 * the platform knows them (Windows 11 snap layouts, for example).
 *
 * The window is set up once, when both the component is complete and
 * window is set.  The other properties may change at any time.
 */
class WindowAgent : public QObject, public QQmlParserStatus {
  Q_OBJECT
  Q_INTERFACES(QQmlParserStatus)
  QML_NAMED_ELEMENT(GXWindowAgent)

  Q_PROPERTY(QQuickWindow* window READ Window WRITE SetWindow NOTIFY windowChanged)
  Q_PROPERTY(QQuickItem* titleBar READ TitleBar WRITE SetTitleBar NOTIFY titleBarChanged)
  Q_PROPERTY(QQuickItem* minimizeButton READ MinimizeButton WRITE SetMinimizeButton NOTIFY
                 minimizeButtonChanged)
  Q_PROPERTY(QQuickItem* maximizeButton READ MaximizeButton WRITE SetMaximizeButton NOTIFY
                 maximizeButtonChanged)
  Q_PROPERTY(QQuickItem* closeButton READ CloseButton WRITE SetCloseButton NOTIFY
                 closeButtonChanged)
  Q_PROPERTY(bool ready READ IsReady NOTIFY readyChanged)

 public:
  /**
   * @brief Constructs the agent.
   * @param parent The optional QObject parent.
   */
  explicit WindowAgent(QObject* parent = nullptr);
  ~WindowAgent() override;

  /// @brief Returns the window to make frameless.
  [[nodiscard]] QQuickWindow* Window() const;
  /// @brief Sets the window to make frameless.  Only the first one is used.
  void SetWindow(QQuickWindow* window);

  /// @brief Returns the item that acts as the title bar.
  [[nodiscard]] QQuickItem* TitleBar() const;
  /// @brief Sets the item that acts as the title bar.
  void SetTitleBar(QQuickItem* item);

  /// @brief Returns the minimize button.
  [[nodiscard]] QQuickItem* MinimizeButton() const;
  /// @brief Sets the minimize button.
  void SetMinimizeButton(QQuickItem* item);

  /// @brief Returns the maximize button.
  [[nodiscard]] QQuickItem* MaximizeButton() const;
  /// @brief Sets the maximize button.
  void SetMaximizeButton(QQuickItem* item);

  /// @brief Returns the close button.
  [[nodiscard]] QQuickItem* CloseButton() const;
  /// @brief Sets the close button.
  void SetCloseButton(QQuickItem* item);

  /**
   * @brief Returns whether QWindowKit manages the window.
   * @return True after a successful setup.
   */
  [[nodiscard]] bool IsReady() const;

  /**
   * @brief Marks an item in the title bar as taking its own mouse input.
   *
   * Without this, presses on the item move the window instead.
   * @param item The item, may be null.
   * @param visible False to make the item part of the drag area again.
   */
  Q_INVOKABLE void setHitTestVisible(  // NOLINT(readability-identifier-naming)
      QQuickItem* item, bool visible = true);

  /**
   * @brief Shows the system window menu.
   * @param pos Position in global logical pixels.
   */
  Q_INVOKABLE void showSystemMenu(const QPoint& pos);  // NOLINT(readability-identifier-naming)

  void classBegin() override;
  void componentComplete() override;

 signals:
  void windowChanged();          // NOLINT(readability-identifier-naming)
  void titleBarChanged();        // NOLINT(readability-identifier-naming)
  void minimizeButtonChanged();  // NOLINT(readability-identifier-naming)
  void maximizeButtonChanged();  // NOLINT(readability-identifier-naming)
  void closeButtonChanged();     // NOLINT(readability-identifier-naming)
  void readyChanged();           // NOLINT(readability-identifier-naming)

 private:
  // Sets the window up once everything needed is there, then hands over
  // the items.
  void TrySetup();
  void ApplyItems();
  void ApplyButton(int button, QQuickItem* item);

  QWK::QuickWindowAgent* agent_;
  QPointer<QQuickWindow> window_;
  QPointer<QQuickItem> title_bar_;
  QPointer<QQuickItem> minimize_button_;
  QPointer<QQuickItem> maximize_button_;
  QPointer<QQuickItem> close_button_;
  // Hit test changes asked for before the setup, applied by it.
  QList<QPair<QPointer<QQuickItem>, bool>> pending_hit_test_;
  bool complete_{false};
  bool ready_{false};
};

}  // namespace gxde

#endif  // SRC_STYLE_WINDOW_AGENT_WINDOW_AGENT_H_
