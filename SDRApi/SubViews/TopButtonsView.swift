//
//  TopButtonsView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

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
    guard store.directEnabled || store.localEnabled || store.smartlinkEnabled else { return true }
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
      
      Toggle("Gui", isOn: $store.isGui)
 
      // Connection types
      ControlGroup {
        Toggle("Direct", isOn: $store.directEnabled)
        Toggle("Local", isOn: $store.localEnabled)
        Toggle("Smartlink", isOn: $store.smartlinkEnabled)
      }
      .frame(width: 180)
      .disabled(store.connectionState != .disconnected)
      .help("At least one connection type must be selected")
      
      Toggle("Use Default", isOn: $store.useDefaultEnabled)
        .disabled( store.connectionState != .disconnected )
        .help("Skip the Radio Picker")
      
      Toggle("Smartlink Login", isOn: $store.smartlinkLoginRequired)
        .disabled( store.connectionState != .disconnected)
        .help("User must enter Login credentials")
      
      Spacer()
      
      HStack(spacing: 0) {
        Picker("Dax", selection: $store.daxSelection) {
          ForEach(daxChoices, id: \.self) {
            Text($0 == -1 ? "none" : $0 == 0 ? "Mic" : "Rx\($0)").tag($0)
          }
        }
        .onChange(of: store.daxSelection) {
          store.send(.daxSelectionChanged($0, $1))
        }
        Toggle("Low BW", isOn: $store.lowBandwidthDax)
          .disabled( store.connectionState != .disconnected)
          .help("Enable Low Bandwidth Dax")
      }
      .frame(width: 180)
      .disabled(store.isGui == false)


      HStack(spacing: 0) {
        Toggle("Rx Audio", isOn: $store.remoteRxAudioEnabled)
          .disabled(store.isGui == false)
          .help("Enable audio from the Radio to this Mac")
        Toggle("Compress", isOn: $store.remoteRxAudioCompressed)
          .help("Enable Rx Audio compression")
      }
      .disabled(store.isGui == false)
      .frame(width: 180)
      
      Toggle("Tx Audio", isOn: $store.remoteTxAudioEnabled)
        .disabled(true)
        .help("Enable audio from this Mac to the Radio")
    }.toggleStyle(.button)
  }
}

#Preview {
  Grid(alignment: .leading, horizontalSpacing: 20) {
    TopButtonsView(store: Store(initialState: SDRApi.State()) {
      SDRApi()
    })
  }
  .frame(minWidth: 1250, maxWidth: .infinity)
}
