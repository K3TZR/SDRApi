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

    // LogAlert Notification
//    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlertNotification)
//      .receive(on: RunLoop.main)) { note in
//        if store.appSettings.alertOnError {
//          store.send(.showLogAlert(note.object! as! XCGLogFeature.LogEntry))
//        }
//    }
    
    // Sheets
    .alert($store.scope(state: \.showAlert, action: \.alert))
    .sheet( item: self.$store.scope(state: \.showClient, action: \.client)) {
      store in ClientView(store: store) }
    .sheet( item: self.$store.scope(state: \.showDirect, action: \.direct)) {
      store in DirectView(store: store) }
    .sheet( item: self.$store.scope(state: \.showLogin, action: \.login)) {
      store in LoginView(store: store) }
    .sheet( item: self.$store.scope(state: \.showPicker, action: \.picker)) {
      store in PickerView(store: store) }
    
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
