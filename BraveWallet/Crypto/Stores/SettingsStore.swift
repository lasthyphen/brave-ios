// Copyright 2022 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BraveCore

public class SettingsStore: ObservableObject {
  /// The number of minutes to wait until the Brave Wallet is automatically locked
  @Published var autoLockInterval: AutoLockInterval = .minute {
    didSet {
      keyringService.setAutoLockMinutes(autoLockInterval.value) { _ in }
    }
  }

  private let keyringService: BraveWalletKeyringService
  private let walletService: BraveWalletBraveWalletService
  private let txService: BraveWalletTxService

  public init(
    keyringService: BraveWalletKeyringService,
    walletService: BraveWalletBraveWalletService,
    txService: BraveWalletTxService
  ) {
    self.keyringService = keyringService
    self.walletService = walletService
    self.txService = txService

    self.keyringService.autoLockMinutes { minutes in
      self.autoLockInterval = .init(value: minutes)
    }
  }

  func reset() {
    walletService.reset()
    KeyringStore.resetKeychainStoredPassword()
  }

  func resetTransaction() {
    txService.reset()
  }

  public func isDefaultKeyringCreated(_ completion: @escaping (Bool) -> Void) {
    keyringService.defaultKeyringInfo { keyring in
      completion(keyring.isKeyringCreated)
    }
  }

  public func addKeyringServiceObserver(_ observer: BraveWalletKeyringServiceObserver) {
    keyringService.add(observer)
  }
}
