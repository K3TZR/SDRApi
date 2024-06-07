//
//  SendView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

public struct SendView: View {
  @Bindable var store: StoreOf<SDRApi>

//  @State var commandToSend = ""

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
        TextField("Command to send", text: $store.commandToSend)
      }
      .disabled(store.connectionState != .connected)
      
      Toggle("Clear on Send", isOn: $store.clearOnSend)
        .toggleStyle(.button)
        .help("Clear the field after sending a command")
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

