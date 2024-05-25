//
//  TopButtonsView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

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
      
      Group {
        Toggle("Smartlink Login", isOn: $store.smartlinkLoginRequired)
          .disabled( store.connectionState != .disconnected)
          .help("User must enter Login credentials")
        
        Spacer()
        
        ControlGroup {
          Toggle("Rx Audio", isOn: $store.remoteRxAudioEnabled)
            .disabled(store.isGui == false)
            .help("Enable audio from the Radio to this Mac")
          Toggle("Compression", isOn: $store.remoteRxAudioCompressed)
            .disabled(store.isGui == false)
            .help("Enable Rx Audio compression")
        }

        Toggle("Tx Audio", isOn: $store.remoteTxAudioEnabled)
          .disabled(true)
          .help("Enable audio from this Mac to the Radio")

        Toggle("Use Default", isOn: $store.useDefaultEnabled)
          .disabled( store.connectionState != .disconnected )
          .help("Skip the Radio Picker")

        Toggle("Alert on Error", isOn: $store.alertOnError)
          .help("Display a sheet when an Error / Warning occurs")
        
        HStack(spacing: 5) {
          Stepper("Font Size", value: $store.fontSize, in: 8...14)
          Text(store.fontSize, format: .number).frame(alignment: .leading)
        }
      }
      .toggleStyle(.button)
    }
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
