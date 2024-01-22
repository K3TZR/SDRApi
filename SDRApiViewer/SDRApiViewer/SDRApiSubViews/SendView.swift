//
//  SendView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

import SettingsFeature

public struct SendView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  @Environment(SettingsModel.self) var settingsModel
  
  public var body: some View {
    @Bindable var settings = settingsModel
    
    GridRow {
        Button("Send") { store.send(.sendButtonTapped) }
          .frame(width: 100)
          .keyboardShortcut(.defaultAction)
          .disabled(store.connectionState != .connected)
        
        HStack(spacing: 0) {
          Image(systemName: "x.circle").font(.title2)
            .onTapGesture { store.send(.clearSendTextButtonTapped) }
          
          Stepper("", onIncrement: {
            store.send(.commandPreviousTapped)
          }, onDecrement: {
            store.send(.commandNextTapped)
          })
          TextField("Command to send", text: $settings.commandToSend)
        }
        .gridCellColumns(2)
        .disabled(store.connectionState != .connected)

      Group {
        Toggle("Clear on Send", isOn: $settings.clearOnSend)
        Toggle("Alert on Error", isOn: $settings.alertOnError)
        HStack(spacing: 5) {
          Stepper("Font Size", value: $settings.fontSize, in: 8...14)
          Text(settingsModel.fontSize, format: .number).frame(alignment: .leading)
        }
      }
      .toggleStyle(.button)
      .frame(width: 120, alignment: .leading)
    }
  }
}

#Preview {
  Grid(alignment: .leading, horizontalSpacing: 20) {
    SendView(store: Store(initialState: SDRApi.State()) {
      SDRApi()
    })
  }
  .frame(minWidth: 1250, maxWidth: .infinity)
}

