//
//  SendView.swift
//  SDRApi/Subviews
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

public struct SendView: View {
  @Bindable var store: StoreOf<SDRApi>

  public var body: some View {
    
    HStack {
      Button("Send") {
        store.send(.sendButtonTapped)
      }
      .frame(width: 100)
      .keyboardShortcut(.defaultAction)
      .disabled(store.connectionState != .connected)
      
      HStack(spacing: 0) {
        Image(systemName: "x.circle").font(.title2)
          .onTapGesture { store.send(.clearSendTextButtonTapped) }
          .help("Clear the command field")
        
        Stepper("", onIncrement: {
          store.send(.commandPreviousTapped)
        }, onDecrement: {
          store.send(.commandNextTapped)
        })
        .help("Load previously sent commands")
        
        TextField("Command to send", text: $store.appSettings.commandToSend)
      }
      
      Toggle("Clear on Send", isOn: $store.appSettings.clearOnSend)
        .toggleStyle(.button)
        .help("Clear the field after sending a command")
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  Grid(alignment: .leading, horizontalSpacing: 20) {
    SendView(store: Store(initialState: SDRApi.State()) {
      SDRApi()
    })
  }
  .frame(minWidth: 1250, maxWidth: .infinity)
}

