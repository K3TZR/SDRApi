//
//  ContentView.swift
//  SDRApi
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

import ClientFeature
import DirectFeature
import FlexApiFeature
import LoginFeature
import PickerFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct SDRApiView: View {
  @Bindable var store: StoreOf<SDRApi>
      
  var body: some View {
    VStack(alignment: .leading) {
      TopButtonsView(store: store)
      SendView(store: store)
      Divider().background(Color(.gray))
      
      VSplitView {
        ObjectsView(store: store)
          .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)

        Divider().background(Color(.cyan))
        MessagesView(store: store)
          .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
      }
      Spacer()
      Divider().background(Color(.gray))
      BottomButtonsView(store: store)
    }
    
    // initialize on first appearance
    .onAppear() {
      store.send(.onAppear)
    }

    // LogAlert Warning
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlertWarning)
      .receive(on: RunLoop.main)) { note in
        if store.appSettings.alertOnError {
          store.send(.showAlert("A WARNING was logged", note.object! as! String))
        }
    }

    // LogAlert Error
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlertError)
      .receive(on: RunLoop.main)) { note in
        if store.appSettings.alertOnError {
          store.send(.showAlert("An ERROR was logged", note.object! as! String))
        }
    }

    // Sheets
    .alert($store.scope(state: \.alert, action: \.alert))

    .sheet(item: $store.scope(state: \.destination?.clientItem, action: \.destination.clientItem))
    { store in ClientView(store: store) }

      .sheet(item: $store.scope(state: \.destination?.directItem, action: \.destination.directItem))
    { store in DirectView(store: store) }

    .sheet(item: $store.scope(state: \.destination?.loginItem, action: \.destination.loginItem))
    { store in LoginView(store: store) }

      .sheet(item: $store.scope(state: \.destination?.pickerItem, action: \.destination.pickerItem))
    { store in PickerView(store: store) }
    
    .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
    .padding()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  SDRApiView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
  
  .environment(ObjectModel.shared)
  
  .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
  .padding()
}
