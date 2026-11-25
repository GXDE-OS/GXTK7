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

#include "src/style/window_agent/window_agent.h"

#include <QWKQuick/quickwindowagent.h>

namespace gxde {

WindowAgent::WindowAgent(QObject* parent)
    : QObject(parent), agent_(new QWK::QuickWindowAgent(this)) {}

WindowAgent::~WindowAgent() = default;

QQuickWindow* WindowAgent::Window() const {
  return window_;
}

void WindowAgent::SetWindow(QQuickWindow* window) {
  if (window_ == window) {
    return;
  }
  if (ready_) {
    qWarning("GXWindowAgent: the window cannot change after the setup");
    return;
  }
  window_ = window;
  emit windowChanged();
  TrySetup();
}

QQuickItem* WindowAgent::TitleBar() const {
  return title_bar_;
}

void WindowAgent::SetTitleBar(QQuickItem* item) {
  if (title_bar_ == item) {
    return;
  }
  title_bar_ = item;
  emit titleBarChanged();
  if (ready_) {
    agent_->setTitleBar(item);
  }
}

QQuickItem* WindowAgent::MinimizeButton() const {
  return minimize_button_;
}

void WindowAgent::SetMinimizeButton(QQuickItem* item) {
  if (minimize_button_ == item) {
    return;
  }
  minimize_button_ = item;
  emit minimizeButtonChanged();
  ApplyButton(QWK::WindowAgentBase::Minimize, item);
}

QQuickItem* WindowAgent::MaximizeButton() const {
  return maximize_button_;
}

void WindowAgent::SetMaximizeButton(QQuickItem* item) {
  if (maximize_button_ == item) {
    return;
  }
  maximize_button_ = item;
  emit maximizeButtonChanged();
  ApplyButton(QWK::WindowAgentBase::Maximize, item);
}

QQuickItem* WindowAgent::CloseButton() const {
  return close_button_;
}

void WindowAgent::SetCloseButton(QQuickItem* item) {
  if (close_button_ == item) {
    return;
  }
  close_button_ = item;
  emit closeButtonChanged();
  ApplyButton(QWK::WindowAgentBase::Close, item);
}

bool WindowAgent::IsReady() const {
  return ready_;
}

void WindowAgent::setHitTestVisible(  // NOLINT(readability-identifier-naming)
    QQuickItem* item, bool visible) {
  if (item == nullptr) {
    return;
  }
  if (ready_) {
    agent_->setHitTestVisible(item, visible);
  } else {
    pending_hit_test_.append({item, visible});
  }
}

void WindowAgent::showSystemMenu(const QPoint& pos) {  // NOLINT(readability-identifier-naming)
  if (ready_) {
    agent_->showSystemMenu(pos);
  }
}

void WindowAgent::classBegin() {}

void WindowAgent::componentComplete() {
  complete_ = true;
  TrySetup();
}

void WindowAgent::TrySetup() {
  if (ready_ || !complete_ || window_ == nullptr) {
    return;
  }
  if (!agent_->setup(window_)) {
    qWarning("GXWindowAgent: QWindowKit could not set the window up");
    return;
  }
  ready_ = true;
  ApplyItems();
  emit readyChanged();
}

void WindowAgent::ApplyItems() {
  agent_->setTitleBar(title_bar_);
  agent_->setSystemButton(QWK::WindowAgentBase::Minimize, minimize_button_);
  agent_->setSystemButton(QWK::WindowAgentBase::Maximize, maximize_button_);
  agent_->setSystemButton(QWK::WindowAgentBase::Close, close_button_);
  for (const auto& [item, visible] : std::as_const(pending_hit_test_)) {
    if (item != nullptr) {
      agent_->setHitTestVisible(item, visible);
    }
  }
  pending_hit_test_.clear();
}

void WindowAgent::ApplyButton(int button, QQuickItem* item) {
  if (ready_) {
    agent_->setSystemButton(static_cast<QWK::WindowAgentBase::SystemButton>(button), item);
  }
}

}  // namespace gxde
