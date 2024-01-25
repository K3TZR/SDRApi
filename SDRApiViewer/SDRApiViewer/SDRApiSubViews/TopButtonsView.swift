//
//  TopButtonsView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

import SettingsFeature

public struct TopButtonsView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  @Environment(SettingsModel.self) var settingsModel
  
  var buttonText: String {
    switch store.connectionState {
    case .disconnected: "Connect"
    case .connected:  "Disconnect"
    default: "waiting"
    }
  }

  var buttonDisable: Bool {
    guard settingsModel.directEnabled || settingsModel.localEnabled || settingsModel.smartlinkEnabled else { return true }
    switch store.connectionState {
    case .disconnected: return false
    case .connected:  return false
    default: return true
    }
  }

  public var body: some View {
    @Bindable var settings = settingsModel
    
    GridRow {
      // Connection initiation
      Button(buttonText) {
        store.send(.connectButtonTapped)
      }
      .background(Color(.green).opacity(0.3))
      .frame(width: 100)
      .disabled(buttonDisable)
      
      ControlGroup {
        Toggle(isOn: Binding(get: { settingsModel.isGui}, set: {settingsModel.isGui = $0})) {
          Text("Gui") }
        Toggle(isOn: Binding(get: { !settingsModel.isGui}, set: {settingsModel.isGui = !$0})) {
          Text("Non-Gui") }
      }
      .frame(width: 130)
 
      ControlGroup {
        Toggle(isOn: $settings.remoteRxAudioEnabled) {
          Text("Rx Audio") }
        Toggle(isOn: $settings.remoteTxAudioEnabled) {
          Text("Tx Audio") }.disabled(true)
      }
      .frame(width: 130)
      
      // Connection types
      ControlGroup {
        Toggle(isOn: $settings.directEnabled) {
          Text("Direct") }.disabled(true)
        Toggle(isOn: $settings.localEnabled) {
          Text("Local") }
        Toggle(isOn: $settings.smartlinkEnabled) {
          Text("Smartlink") }
      }
      .frame(width: 180)
      .disabled(store.connectionState != .disconnected)
      
      Group {
        Toggle(isOn: $settings.smartlinkLoginRequired) {
          Text("Smartlink Login")
        }.disabled( store.connectionState != .disconnected)
        
        Toggle("Use Default", isOn: $settings.useDefault)
          .disabled( store.connectionState != .disconnected )
      }
      .toggleStyle(.button)
      .frame(width: 120, alignment: .leading)
    }
    .onChange(of: settingsModel.remoteRxAudioEnabled) { store.send(.remoteRxAudioEnabledChanged) }
    .onChange(of: settingsModel.remoteTxAudioEnabled) { store.send(.remoteTxAudioEnabledChanged) }
    .onChange(of: settingsModel.directEnabled) { store.send(.directEnabledChanged) }
    .onChange(of: settingsModel.localEnabled) { store.send(.localEnabledChanged) }
    .onChange(of: settingsModel.smartlinkEnabled) { store.send(.smartlinkEnabledChanged) }
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
