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
    
  var buttonText: String {
    switch store.connectionState {
    case .disconnected: "Connect"
    case .connected: "Disconnect"
    default: "waiting"
    }
  }

  var buttonDisable: Bool {
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
      
      Toggle("Gui", isOn: $store.isGui)
        .toggleStyle(.button)
 
      // Connection types
      ControlGroup {
        Toggle(isOn: $store.directEnabled) {
          Text("Direct") }
        Toggle(isOn: $store.localEnabled) {
          Text("Local") }
        Toggle(isOn: $store.smartlinkEnabled) {
          Text("Smartlink") }
      }
      .frame(width: 180)
      .disabled(store.connectionState != .disconnected)
      
      Group {
        Toggle("Smartlink Login", isOn: $store.smartlinkLoginRequired)
          .disabled( store.connectionState != .disconnected)
        
        Spacer()
        
        ControlGroup {
          Toggle(isOn: $store.remoteRxAudioEnabled) {
            Text("Rx Audio") }
          Toggle(isOn: $store.remoteTxAudioEnabled) {
            Text("Tx Audio") }.disabled(true)
        }
        .frame(width: 130)
        
        Toggle("Use Default", isOn: $store.useDefaultEnabled)
          .disabled( store.connectionState != .disconnected )

        Toggle("Alert on Error", isOn: $store.alertOnError)
        
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
