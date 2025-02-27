// Copyright 2022 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import BraveCore
import Shared

struct NetworkInputItem: Identifiable {
  var input: String
  var error: String?
  var id = UUID()
}

struct NetworkTextField: View {
  var placeholder: String
  @Binding var item: NetworkInputItem

  var body: some View {
    VStack(alignment: .leading) {
      TextField(placeholder, text: $item.input)
        .autocapitalization(.none)
        .disableAutocorrection(true)
      if let error = item.error {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Image(systemName: "exclamationmark.circle.fill")
          Text(error)
            .fixedSize(horizontal: false, vertical: true)
            .animation(nil, value: error)
        }
        .accessibilityElement(children: .combine)
        .transition(
          .asymmetric(
            insertion: .opacity.animation(.default),
            removal: .identity
          )
        )
        .font(.footnote)
        .foregroundColor(Color(.braveErrorLabel))
      }
    }
  }
}

class CustomNetworkModel: ObservableObject, Identifiable {
  var isEditMode: Bool = false
  var id: String {
    "\(isEditMode)"
  }

  @Published var networkId = NetworkInputItem(input: "") {
    didSet {
      if networkId.input != oldValue.input {
        if let intValue = Int(networkId.input), intValue > 0 {
          networkId.error = nil
        } else {
          networkId.error = Strings.Wallet.customNetworkChainIdErrMsg
        }
      }
    }
  }
  @Published var networkName = NetworkInputItem(input: "") {
    didSet {
      if networkName.input != oldValue.input {
        if networkName.input.isEmpty {
          networkName.error = Strings.Wallet.customNetworkEmptyErrMsg
        } else {
          networkName.error = nil
        }
      }
    }
  }
  @Published var networkSymbolName = NetworkInputItem(input: "") {
    didSet {
      if networkSymbolName.input != oldValue.input {
        if networkSymbolName.input.isEmpty {
          networkSymbolName.error = Strings.Wallet.customNetworkEmptyErrMsg
        } else {
          networkSymbolName.error = nil
        }
      }
    }
  }
  @Published var networkSymbol = NetworkInputItem(input: "") {
    didSet {
      if networkSymbol.input != oldValue.input {
        if networkSymbol.input.isEmpty {
          networkSymbol.error = Strings.Wallet.customNetworkEmptyErrMsg
        } else {
          networkSymbol.error = nil
        }
      }
    }
  }
  @Published var networkDecimals = NetworkInputItem(input: "") {
    didSet {
      if networkDecimals.input != oldValue.input {
        if networkDecimals.input.isEmpty {
          networkDecimals.error = Strings.Wallet.customNetworkEmptyErrMsg
        } else if let intValue = Int(networkDecimals.input), intValue > 0 {
          networkDecimals.error = nil
        } else {
          networkDecimals.error = Strings.Wallet.customNetworkCurrencyDecimalErrMsg
        }
      }
    }
  }

  @Published var rpcUrls: [NetworkInputItem] = [NetworkInputItem(input: "")] {
    didSet {
      // we only care the set on each item's `input`
      if rpcUrls.reduce("", { $0 + $1.input }) != oldValue.reduce("", { $0 + $1.input }) {
        // validate every entry except the last new entry if there is one
        var hasNewEntry = false
        for (index, item) in rpcUrls.enumerated() {
          if item.input.isEmpty && item.error == nil {  // no validation on new entry
            hasNewEntry = true
          } else {
            if URIFixup.getURL(item.input) == nil {
              rpcUrls[index].error = Strings.Wallet.customNetworkInvalidAddressErrMsg
            } else {
              rpcUrls[index].error = nil
            }
          }
        }
        // Only insert a new entry when all existed entries pass validation
        if rpcUrls.compactMap({ $0.error }).isEmpty && !hasNewEntry {
          rpcUrls.append(NetworkInputItem(input: ""))
        }
      }
    }
  }
  @Published var iconUrls = [NetworkInputItem(input: "")] {
    didSet {
      // we only care the set on each item's `input`
      if iconUrls.reduce("", { $0 + $1.input }) != oldValue.reduce("", { $0 + $1.input }) {
        // validate every entry except the last new entry if there is one
        var hasNewEntry = false
        for (index, item) in iconUrls.enumerated() {
          if item.input.isEmpty && item.error == nil {  // no validation on new entry
            hasNewEntry = true
          } else {
            if URIFixup.getURL(item.input) == nil {
              iconUrls[index].error = Strings.Wallet.customNetworkInvalidAddressErrMsg
            } else {
              iconUrls[index].error = nil
            }
          }
        }
        // Only insert a new entry when all existed entries pass validation and there is no new entry
        if iconUrls.compactMap({ $0.error }).isEmpty && !hasNewEntry {
          iconUrls.append(NetworkInputItem(input: ""))
        }
      }
    }
  }
  @Published var blockUrls = [NetworkInputItem(input: "")] {
    didSet {
      // we only care the set on each item's `input`
      if blockUrls.reduce("", { $0 + $1.input }) != oldValue.reduce("", { $0 + $1.input }) {
        // validate every entry except the last new entry if there is one
        var hasNewEntry = false
        for (index, item) in blockUrls.enumerated() {
          if item.input.isEmpty && item.error == nil {  // no validation on new entry
            hasNewEntry = true
          } else {
            if URIFixup.getURL(item.input) == nil {
              blockUrls[index].error = Strings.Wallet.customNetworkInvalidAddressErrMsg
            } else {
              blockUrls[index].error = nil
            }
          }
        }
        // Only insert a new entry when all existed entries pass validation and there is no new entry
        if blockUrls.compactMap({ $0.error }).isEmpty && !hasNewEntry {
          blockUrls.append(NetworkInputItem(input: ""))
        }
      }
    }
  }

  /// Updates the details of this class based on a custom network
  func populateDetails(from network: BraveWallet.EthereumChain) {
    self.isEditMode = true

    let chainIdInDecimal: String
    if let intValue = Int(network.chainId.removingHexPrefix, radix: 16) {  // BraveWallet.EthereumChain.chainId should always in hex
      chainIdInDecimal = "\(intValue)"
    } else {
      chainIdInDecimal = network.chainId
    }
    self.networkId.input = chainIdInDecimal
    self.networkName.input = network.chainName
    self.networkSymbolName.input = network.symbolName
    self.networkSymbol.input = network.symbol
    self.networkDecimals.input = String(network.decimals)
    if !network.rpcUrls.isEmpty {
      self.rpcUrls = network.rpcUrls.compactMap({ NetworkInputItem(input: $0) })
    }
    if !network.iconUrls.isEmpty {
      self.iconUrls = network.iconUrls.compactMap({ NetworkInputItem(input: $0) })
    }
    if !network.blockExplorerUrls.isEmpty {
      self.blockUrls = network.blockExplorerUrls.compactMap({ NetworkInputItem(input: $0) })
    }
  }
}

struct CustomNetworkDetailsView: View {
  @ObservedObject var networkStore: NetworkStore
  @ObservedObject var model: CustomNetworkModel

  @Environment(\.presentationMode) @Binding private var presentationMode

  @State private var customNetworkError: CustomNetworkError?

  enum CustomNetworkError: LocalizedError, Identifiable {
    case failed(errMsg: String)
    case duplicateId

    var id: String {
      errorDescription
    }

    var errorTitle: String {
      switch self {
      case .failed:
        return Strings.Wallet.failedToAddCustomNetworkErrorTitle
      case .duplicateId:
        return ""
      }
    }

    var errorDescription: String {
      switch self {
      case .failed(let errMsg):
        return errMsg
      case .duplicateId:
        return Strings.Wallet.networkIdDuplicationErrMsg
      }
    }
  }

  init(
    networkStore: NetworkStore,
    model: CustomNetworkModel
  ) {
    self.networkStore = networkStore
    self.model = model
  }

  var body: some View {
    Form {
      Section(
        header: WalletListHeaderView(title: Text(Strings.Wallet.customNetworkChainIdTitle))
          .osAvailabilityModifiers { content in
            if #available(iOS 15.0, *) {
              content  // padding already exists in 15
            } else {
              content.padding(.top)
            }
          }
      ) {
        NetworkTextField(
          placeholder: Strings.Wallet.customNetworkChainIdPlaceholder,
          item: $model.networkId
        )
        .keyboardType(.numberPad)
        .disabled(model.isEditMode)
      }
      .listRowBackground(Color(.secondaryBraveGroupedBackground))
      Section(
        header: WalletListHeaderView(title: Text(Strings.Wallet.customNetworkChainNameTitle))
      ) {
        NetworkTextField(
          placeholder: Strings.Wallet.customNetworkChainNamePlaceholder,
          item: $model.networkName
        )
      }
      .listRowBackground(Color(.secondaryBraveGroupedBackground))
      Section(
        header: WalletListHeaderView(title: Text(Strings.Wallet.customNetworkSymbolNameTitle))
      ) {
        NetworkTextField(
          placeholder: Strings.Wallet.customNetworkSymbolNamePlaceholder,
          item: $model.networkSymbolName
        )
      }
      .listRowBackground(Color(.secondaryBraveGroupedBackground))
      Section(
        header: WalletListHeaderView(title: Text(Strings.Wallet.customNetworkSymbolTitle))
      ) {
        NetworkTextField(
          placeholder: Strings.Wallet.customNetworkSymbolPlaceholder,
          item: $model.networkSymbol
        )
      }
      .listRowBackground(Color(.secondaryBraveGroupedBackground))
      Section(
        header: WalletListHeaderView(title: Text(Strings.Wallet.customNetworkCurrencyDecimalTitle))
      ) {
        NetworkTextField(
          placeholder: Strings.Wallet.customNetworkCurrencyDecimalPlaceholder,
          item: $model.networkDecimals
        )
        .keyboardType(.numberPad)
      }
      .listRowBackground(Color(.secondaryBraveGroupedBackground))
      Section(
        header: WalletListHeaderView(title: Text(Strings.Wallet.customNetworkRpcUrlsTitle))
      ) {
        ForEach($model.rpcUrls) { $url in
          NetworkTextField(
            placeholder: Strings.Wallet.customNetworkUrlsPlaceholder,
            item: $url
          )
        }
      }
      .listRowBackground(Color(.secondaryBraveGroupedBackground))
      Section(
        header: WalletListHeaderView(title: Text(Strings.Wallet.customNetworkIconUrlsTitle))
      ) {
        ForEach($model.iconUrls) { $url in
          NetworkTextField(
            placeholder: Strings.Wallet.customNetworkUrlsPlaceholder,
            item: $url
          )
        }
      }
      .listRowBackground(Color(.secondaryBraveGroupedBackground))
      Section(
        header: WalletListHeaderView(title: Text(Strings.Wallet.customNetworkBlockExplorerUrlsTitle))
      ) {
        ForEach($model.blockUrls) { $url in
          NetworkTextField(
            placeholder: Strings.Wallet.customNetworkUrlsPlaceholder,
            item: $url
          )
        }
      }
      .listRowBackground(Color(.secondaryBraveGroupedBackground))
    }
    .navigationBarTitle(model.isEditMode ? Strings.Wallet.editfCustomNetworkTitle : Strings.Wallet.customNetworkDetailsTitle)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .confirmationAction) {
        if networkStore.isAddingNewNetwork {
          ProgressView()
        } else {
          Button(action: {
            addCustomNetwork()
          }) {
            Text(Strings.Wallet.saveButtonTitle)
              .foregroundColor(Color(.braveOrange))
          }
        }
      }
      ToolbarItemGroup(placement: .cancellationAction) {
        Button(action: {
          presentationMode.dismiss()
        }) {
          Text(Strings.cancelButtonTitle)
            .foregroundColor(Color(.braveOrange))
        }
      }
    }
    .background(
      Color.clear
        .alert(
          item: $customNetworkError,
          content: { error in
            Alert(
              title: Text(error.errorTitle),
              message: Text(error.errorDescription),
              dismissButton: .default(Text(Strings.OKString))
            )
          })
    )
  }

  private func validateAllFields() -> Bool {
    if model.networkId.input.isEmpty {
      model.networkId.error = Strings.Wallet.customNetworkEmptyErrMsg
    }
    model.networkName.error = model.networkName.input.isEmpty ? Strings.Wallet.customNetworkEmptyErrMsg : nil
    model.networkSymbolName.error = model.networkSymbolName.input.isEmpty ? Strings.Wallet.customNetworkEmptyErrMsg : nil
    model.networkSymbol.error = model.networkSymbol.input.isEmpty ? Strings.Wallet.customNetworkEmptyErrMsg : nil
    if model.networkDecimals.input.isEmpty {
      model.networkDecimals.error = Strings.Wallet.customNetworkEmptyErrMsg
    }
    if model.rpcUrls.first(where: { !$0.input.isEmpty && $0.error == nil }) == nil {  // has no valid url
      if let index = model.rpcUrls.firstIndex(where: { $0.input.isEmpty }) {  // find the first empty entry
        model.rpcUrls[index].error = Strings.Wallet.customNetworkEmptyErrMsg  // set the empty err msg
      }
    }

    if model.networkId.error != nil
      || model.networkName.error != nil
      || model.networkSymbolName.error != nil
      || model.networkSymbol.error != nil
      || model.networkDecimals.error != nil
      || model.rpcUrls.filter({ !$0.input.isEmpty && $0.error == nil }).isEmpty {
      return false
    }

    return true
  }

  private func addCustomNetwork() {
    guard validateAllFields() else { return }

    var chainIdInHex = ""
    if let idValue = Int(model.networkId.input) {
      chainIdInHex = "0x\(String(format: "%02x", idValue))"
    }
    // Check if input chain id already existed for non-edit mode
    if !model.isEditMode,
      networkStore.ethereumChains.contains(where: { $0.id == chainIdInHex }) {
      customNetworkError = .duplicateId
      return
    }

    let blockExplorerUrls: [String] = model.blockUrls.compactMap({
      if !$0.input.isEmpty && $0.error == nil {
        return $0.input
      } else {
        return nil
      }
    })
    let iconUrls: [String] = model.iconUrls.compactMap({
      if !$0.input.isEmpty && $0.error == nil {
        return $0.input
      } else {
        return nil
      }
    })
    let rpcUrls: [String] = model.rpcUrls.compactMap({
      if !$0.input.isEmpty && $0.error == nil {
        return $0.input
      } else {
        return nil
      }
    })
    let network: BraveWallet.EthereumChain = .init(
      chainId: chainIdInHex,
      chainName: model.networkName.input,
      blockExplorerUrls: blockExplorerUrls,
      iconUrls: iconUrls,
      rpcUrls: rpcUrls,
      symbol: model.networkSymbol.input,
      symbolName: model.networkSymbol.input,
      decimals: Int32(model.networkDecimals.input) ?? 18,
      isEip1559: false)
    networkStore.addCustomNetwork(network) { accepted, errMsg in
      guard accepted else {
        customNetworkError = .failed(errMsg: errMsg)
        return
      }

      presentationMode.dismiss()
    }
  }
}

#if DEBUG
struct CustomNetworkDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CustomNetworkDetailsView(
        networkStore: .previewStore,
        model: .init()
      )
    }
  }
}
#endif
