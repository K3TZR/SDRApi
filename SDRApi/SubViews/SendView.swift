//
//  SendView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

public struct SendView: View {
  @State var store: StoreOf<SDRApi>
  
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
        
        Stepper("", onIncrement: {
          store.send(.commandPreviousTapped)
        }, onDecrement: {
          store.send(.commandNextTapped)
        })
        TextField("Command to send", text: $store.commandToSend)
      }
      .disabled(store.connectionState != .connected)
      
      Toggle("Clear on Send", isOn: $store.clearOnSend)
        .toggleStyle(.button)
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

