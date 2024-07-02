//
//  TopButtonsView.swift
//  SDRApi/Subviews
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

public struct TopButtonsView: View {
  @Bindable var store: StoreOf<SDRApi>
    
  @MainActor var buttonText: String {
    switch store.connectionState {
    case .disconnected: "Connect"
    case .connected: "Disconnect"
    default: "waiting"
    }
  }

  @MainActor var buttonDisable: Bool {
    guard store.appSettings.directEnabled || store.appSettings.localEnabled || store.appSettings.smartlinkEnabled else { return true }
    switch store.connectionState {
    case .disconnected: return false
    case .connected:  return false
    default: return true
    }
  }

  @State var daxChoices = [-1, 1, 2, 3, 4, 0]

  public var body: some View {
    
    HStack(spacing: 30) {
      // Connection initiation
      Button(buttonText) {
        store.send(.connectButtonTapped)
      }
      .background(Color(.green).opacity(0.2))
      .frame(width: 100)
      .disabled(buttonDisable)
      .help("At least one connection type must be selected")
      
      Toggle("Gui", isOn: $store.appSettings.isGui)
 
      // Connection types
      ControlGroup {
        Toggle("Direct", isOn: $store.appSettings.directEnabled)
          .onChange(of: store.appSettings.directEnabled) { _, _ in
            store.send(.directEnabledChanged)
          }
        Toggle("Local", isOn: $store.appSettings.localEnabled)
          .onChange(of: store.appSettings.localEnabled) { _, _ in
            store.send(.localEnabledChanged)
          }
        Toggle("Smartlink", isOn: $store.appSettings.smartlinkEnabled)
          .onChange(of: store.appSettings.smartlinkEnabled) { _, _ in
            store.send(.smartlinkEnabledChanged)
          }
      }
      .frame(width: 180)
      .disabled(store.connectionState != .disconnected)
      .help("At least one connection type must be selected")
      
      Toggle("Use Default", isOn: $store.appSettings.useDefaultEnabled)
        .disabled( store.connectionState != .disconnected )
        .help("Skip the Radio Picker")
      
      Toggle("Smartlink Login", isOn: $store.appSettings.smartlinkLoginRequired)
        .disabled( store.connectionState != .disconnected)
        .help("User must enter Login credentials")
      
      Spacer()
      
      HStack(spacing: 0) {
        Picker("Dax", selection: $store.appSettings.daxSelection) {
          ForEach(daxChoices, id: \.self) {
            Text($0 == -1 ? "none" : $0 == 0 ? "Mic" : "Rx\($0)").tag($0)
          }
        }
        
        .onChange(of: store.appSettings.daxSelection) {
          store.send(.daxSelectionChanged($0, $1))
        }
        
        Toggle("Low BW", isOn: $store.appSettings.lowBandwidthDax)
          .disabled( store.connectionState != .disconnected)
          .help("Enable Low Bandwidth Dax")
      }
      .frame(width: 180)
      .disabled(store.appSettings.isGui == false)


      HStack(spacing: 0) {
        Toggle("Rx Audio", isOn: $store.appSettings.remoteRxAudioEnabled)
          .disabled(store.appSettings.isGui == false)
          .help("Enable audio from the Radio to this Mac")
          .onChange(of: store.appSettings.remoteRxAudioEnabled) { _, _ in
            store.send(.remoteRxAudioEnabledChanged)
          }

        Toggle("Compress", isOn: $store.appSettings.remoteRxAudioCompressed)
          .help("Enable Rx Audio compression")
          .onChange(of: store.appSettings.remoteRxAudioCompressed) { _, _ in
            store.send(.remoteRxAudioCompressedChanged)
          }
      }
      .disabled(store.appSettings.isGui == false)
      .frame(width: 180)
      
      Toggle("Tx Audio", isOn: $store.appSettings.remoteTxAudioEnabled)
        .disabled(true)
        .help("Enable audio from this Mac to the Radio")
        .onChange(of: store.appSettings.remoteTxAudioEnabled) { _, _ in
          store.send(.remoteTxAudioEnabledChanged)
        }
    }.toggleStyle(.button)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  Grid(alignment: .leading, horizontalSpacing: 20) {
    TopButtonsView(store: Store(initialState: SDRApi.State()) {
      SDRApi()
    })
  }
  .frame(minWidth: 1250, maxWidth: .infinity)
}
