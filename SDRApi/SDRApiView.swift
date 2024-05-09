//
//  ContentView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//

import ComposableArchitecture
import SwiftUI

import ClientFeature
import DirectFeature
import LoginFeature
import PickerFeature
import XCGLogFeature

struct SDRApiView: View {
  @Bindable var store: StoreOf<SDRApi>
      
  var body: some View {
    VStack(alignment: .leading) {
      TopButtonsView(store: store)
      SendView(store: store)
      Divider().background(Color(.gray))
      
      VSplitView {
        ObjectsView(store: store)
        Divider().background(Color(.cyan))
          .padding(.vertical, 10)
        MessagesView(store: store)
      }
    }
    
    // LogAlert
    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logAlertNotification)
      .receive(on: RunLoop.main)) { note in
        print("----->>>>> LogAlert: \(note.object!)")
        store.send(.showLogAlert(note.object! as! XCGLogFeature.LogEntry))
    }
    
    // Alert
    .alert($store.scope(state: \.showAlert, action: \.alert))
    
    // Client sheet
    .sheet( item: self.$store.scope(state: \.showClient, action: \.client)) {
      store in ClientView(store: store) }
    
    // Direct sheet
    .sheet( item: self.$store.scope(state: \.showDirect, action: \.direct)) {
      store in DirectView(store: store) }
    
    // Login sheet
    .sheet( item: self.$store.scope(state: \.showLogin, action: \.login)) {
      store in LoginView(store: store) }
    
    // Picker sheet
    .sheet( item: self.$store.scope(state: \.showPicker, action: \.picker)) {
      store in PickerView(store: store) }
    
    // initialize on first appearance
    .onAppear() {
      store.send(.onAppear)
    }
    .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
    .padding()
  }
}

#Preview {
  SDRApiView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
}
