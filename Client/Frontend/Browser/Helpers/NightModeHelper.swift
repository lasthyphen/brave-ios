// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import WebKit
import Shared
import BraveShared

class NightModeHelper: TabContentScript {
  fileprivate weak var tab: Tab?

  static var isActivated: Bool {
    return Preferences.General.nightModeEnabled.value
  }

  required init(tab: Tab) {
    self.tab = tab
  }

  static func name() -> String {
    return "NightMode"
  }

  func scriptMessageHandlerName() -> String? {
    return "NightMode"
  }

  func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
    // Do nothing.
  }

  static func setNightMode(tabManager: TabManager, enabled: Bool) {
    Preferences.General.nightModeEnabled.value = enabled

    for tab in tabManager.allTabs {
      tab.nightMode = enabled

      // For WKWebView background color to take effect, isOpaque must be false,
      // which is counter-intuitive. Default is true. The color is previously
      // set to black in the WKWebView init.
      tab.webView?.isOpaque = !enabled
      tab.webView?.scrollView.indicatorStyle = enabled ? .white : .default
    }
  }
}
