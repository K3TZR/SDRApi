//
//  ApiView.swift
//  SDRApi
//
//  Created by Douglas Adams on 12/1/21.
//

import SwiftUI

import SettingsModel
import SharedModel

// ----------------------------------------------------------------------------
// MARK: - View

public struct ApiView: View {

  @State var isConnected = false
  
  public var body: some View {
      VStack(alignment: .leading) {
        TopButtonsView(isConnected: $isConnected)
        SendView(isConnected: isConnected)
        
        Divider()
          .frame(height: 4)
          .background(Color(.gray))
        
        VSplitView {
          ObjectsView()
          .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
          
          Divider()
            .frame(height: 4)
            .background(Color(.gray))
            .padding(.bottom, 5)

          MessagesView()
          .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        }
      }
      .padding(.horizontal, 10)
      
      // ---------- Initialization ----------
      // initialize on first appearance
      
      // ---------- Sheet Management ----------
      // alert dialogs
//      .alert(
//        self.store.scope(state: \.alertState),
//        dismiss: .alertDismissed
//      )
      
      // Picker sheet
//      .sheet(
//        isPresented: viewStore.binding(
//          get: { $0.pickerState != nil },
//          send: ApiModule.Action.picker(.cancelButton)),
//        content: {
//          IfLetStore(
//            store.scope(state: \.pickerState, action: ApiModule.Action.picker),
//            then: PickerView.init(store:)
//          )
//        }
//      )
      
      // Login sheet
//      .sheet(
//        isPresented: viewStore.binding(
//          get: { $0.loginState != nil },
//          send: ApiModule.Action.login(.cancelButton)),
//        content: {
//          IfLetStore(
//            store.scope(state: \.loginState, action: ApiModule.Action.login),
//            then: LoginView.init(store:)
//          )
//        }
//      )
      
      // Client connection sheet
//      .sheet(
//        isPresented: viewStore.binding(
//          get: { $0.clientState != nil },
//          send: ApiModule.Action.client(.cancelButton)),
//        content: {
//          IfLetStore(
//            store.scope(state: \.clientState, action: ApiModule.Action.client),
//            then: ClientView.init(store:)
//          )
//        }
//      )
      
//      .onDisappear {
//        viewStore.send(.closeAllWindows)
//      }
//    }
  }
}

private struct ObjectsView: View {
  
  var body: some View {
    Text("Objects view")
  }
}

// ----------------------------------------------------------------------------
// MARK: - SubView(s)

private struct TopButtonsView: View {
  var isConnected: Binding<Bool>

  @Environment(SettingsModel.self) var settingsModel
  
  public  var body: some View {
    @Bindable var bindableSettingsModel = settingsModel
    
    HStack(spacing: 20) {
      Button(isConnected .wrappedValue ? "Stop" : "Start") {
        isConnected.wrappedValue.toggle()
      }
      .frame(width: 60)
//      .disabled(viewStore.startStopDisabled)
      .keyboardShortcut(isConnected.wrappedValue ? .cancelAction : .defaultAction)
      
      HStack(spacing: 10) {
        Toggle("Gui", isOn: $bindableSettingsModel.isGui)
          .frame(width: 60)
          .disabled( isConnected.wrappedValue )
        Group {
          Toggle("Show Times", isOn: $bindableSettingsModel.showTimes)
          Toggle("Show Pings", isOn: $bindableSettingsModel.showPings)
        }
        .frame(width: 100)
      }
      
      Spacer()
      ControlGroup {
        Toggle(isOn: $bindableSettingsModel.remoteRxAudioEnabled) {
          Text("Rx Audio") }
        Toggle(isOn: $bindableSettingsModel.remoteTxAudioEnabled) {
          Text("Tx Audio") }
      }
      .frame(width: 130)
      
      Spacer()
      ControlGroup {
        Toggle(isOn: $bindableSettingsModel.localEnabled) {
          Text("Local") }
        Toggle(isOn: $bindableSettingsModel.smartlinkEnabled) {
          Text("Smartlink") }
      }
      .disabled( isConnected.wrappedValue )
      .frame(width: 130)
      
      Spacer()
      Group {
        Toggle("Smartlink Login", isOn: $bindableSettingsModel.loginRequired)
          .disabled( isConnected.wrappedValue || settingsModel.smartlinkEnabled == false )
        Toggle("Use Default", isOn: $bindableSettingsModel.useDefault)
          .disabled( isConnected.wrappedValue )
      }.frame(width: 130, alignment: .leading)
    }
  }
}

private struct SendView: View {
  let isConnected: Bool
  
  @Environment(SettingsModel.self) var settingsModel
  
  @State var commandToSend = ""
  
  var body: some View {
    @Bindable var bindableSettingsModel = settingsModel

    HStack(spacing: 20) {
      Group {
        Button("Send") { /* FIXME: */ }
          .keyboardShortcut(.defaultAction)
        
        HStack(spacing: 0) {
          Image(systemName: "x.circle").font(.title2)
            .onTapGesture {
             print("CLEAR send text")
            }
          
          Stepper("", onIncrement: {
            print("Previous Command")
          }, onDecrement: {
            print("Next Command")
          })
          
          TextField("Command to send", text: $commandToSend)
        }
      }
      .disabled(isConnected == false)
      
      Spacer()
      Group {
        Toggle("Clear on Send", isOn: $bindableSettingsModel.clearOnSend)
        Toggle("Alert on Error", isOn: $bindableSettingsModel.alertOnError)
        HStack(spacing: 5) {
          Stepper("Font Size",
                  value: $bindableSettingsModel.fontSize,
                  in: 8...12)
          Text(String(format: "%2.0f", settingsModel.fontSize)).frame(alignment: .leading)
        }
      }.frame(width: 130, alignment: .leading)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ApiView()
    .environment(MessagesModel.shared)
    .environment(SettingsModel.shared)
}
