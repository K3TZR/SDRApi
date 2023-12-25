//
//  ApiView.swift
//  SDRApi
//
//  Created by Douglas Adams on 12/1/21.
//

import SwiftUI

import ClientSheet
import FlexApi
import Listener
import LoginSheet
import MonitorControl
import PickerSheet
import RxAVAudioPlayer
import SettingsModel
import SharedModel
import XCGWrapper

// ----------------------------------------------------------------------------
// MARK: - View

public struct ApiView: View {
  
  @State private var loginPassword: String = ""
  //  @State private var disconnectHandle: UInt32? = nil
  //  @State private var selectedPacket: Packet?
  
  @Environment(\.openWindow) private var openWindow
  
  @Environment(ApiModel.self) private var api
  @Environment(Listener.self) private var listener
  @Environment(RxAVAudioPlayer.self) private var rxAVAudioPlayer
  @Environment(SDRModel.self) private var sdr
  @Environment(SettingsModel.self) private var settings
  
  public var body: some View {
    @Bindable var sdrBindable = sdr
    @Bindable var settingsBindable = settings
    
    VStack(alignment: .leading) {
      TopButtonsView()
      SendView()
      
      Divider()
        .frame(height: 3)
        .background(Color(.gray))
      
      VSplitView {
        VStack(spacing: 0) {
          ObjectsView()
          Spacer()
          Divider()
            .frame(height: 3)
            .background(Color(.gray))
        }.frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        
        MessagesView()
          .frame(maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
          .padding(.top, 5)
      }
    }
    .padding(.horizontal, 10)
    
    // ---------- Initialization ----------
    .onAppear {
      sdr.onAppear()
    }
    
    // ---------- Sheets ----------
    // Alert
    .alert(isPresented: $sdrBindable.showAlert) {
      Alert(title: Text(sdr.alertText))
    }
    
    // Client sheet
    .sheet(isPresented: $sdrBindable.showClientSheet, onDismiss: {
      sdr.clientDismissed()
    }) {
      ClientView(stations: listener.stations, idToDisconnect: $sdrBindable.idToDisconnect, pickerSelection: $sdrBindable.pickerSelection)
    }
    
    // Picker sheet
    .sheet(isPresented: $sdrBindable.showPickerSheet, onDismiss: {
      sdr.pickerDismissed()
    }) {
      PickerView(selection: $sdrBindable.pickerSelection, defaultMethod: { sdr.setDefault($0) }, testMethod: { sdr.test($0) })
    }
    
    // Smartlink Login  sheet
    .sheet(isPresented: $sdrBindable.showLoginSheet, onDismiss: {
      sdr.loginDismissed(loginPassword)
    }) {
      LoginView(user: $settingsBindable.smartlinkUser, pwd: $loginPassword)
    }
    
    
    //      .onDisappear {
    //        viewStore.send(.closeAllWindows)
    //      }
    //    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - SubView(s)

private struct TopButtonsView: View {
  
  @Environment(ApiModel.self) private var api
  @Environment(Listener.self) private var listener
  @Environment(RxAVAudioPlayer.self) private var rxAVAudioPlayer
  @Environment(SDRModel.self) private var sdr
  @Environment(SettingsModel.self) private var settings
  
  @State private var isOptionPressed = false
  
  public  var body: some View {
    @Bindable var settingsBindable = settings
    
    HStack(spacing: 20) {
      // Connection initiation
      Button(sdr.connectionStatus == .connected ? "Disconnect" : "Connect") {
        sdr.connectDisconnect(isOptionPressed)
      }
      .background(Color(.green).opacity(0.3))
      .cornerRadius(10)
      .frame(width: 100)
      .disabled((!settings.directEnabled && !settings.localEnabled && !settings.smartlinkEnabled) )
      
      HStack(spacing: 10) {
        Toggle("Gui", isOn: $settingsBindable.isGui)
          .frame(width: 60)
          .disabled( sdr.connectionStatus == .connected )
        Group {
          Toggle("Show Times", isOn: $settingsBindable.showTimes)
          Toggle("Show Pings", isOn: $settingsBindable.showPings)
        }
        .frame(width: 100)
      }
      
      Spacer()
      ControlGroup {
        Toggle(isOn: $settingsBindable.remoteRxAudioEnabled) {
          Text("Rx Audio") }
        Toggle(isOn: $settingsBindable.remoteTxAudioEnabled) {
          Text("Tx Audio") }
      }
      .frame(width: 130)
      
      Spacer()
      // Connection types
      if api.radio == nil {
        ControlGroup {
          Toggle(isOn: $settingsBindable.directEnabled) {
            Text("Direct") }
          Toggle(isOn: $settingsBindable.localEnabled) {
            Text("Local") }
          Toggle(isOn: $settingsBindable.smartlinkEnabled) {
            Text("Smartlink") }
        }.controlGroupStyle(.navigation)
          .frame(width: 180)
          .padding(.horizontal, 10)
          .disabled(sdr.connectionStatus != .disconnected)
      }
      
      Spacer()
      Group {
        Toggle("Smartlink Login", isOn: $settingsBindable.loginRequired)
          .disabled( sdr.connectionStatus == .connected || settings.smartlinkEnabled == false )
        Toggle("Use Default", isOn: $settingsBindable.useDefault)
          .disabled( sdr.connectionStatus == .connected )
      }.frame(width: 130, alignment: .leading)
    }
    
    .onAppear() {
      // setup left mouse down tracking
      NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) {
        if $0.modifierFlags.contains(.option) {
          isOptionPressed = true
        } else {
          isOptionPressed = false
        }
        return $0
      }
    }
    
    .onChange(of: settings.isGui) {
      print("----->>>>> isGui = \($1)")
    }
    
  }
}

private struct SendView: View {
  
  @Environment(ApiModel.self) private var api
  @Environment(Listener.self) private var listener
  @Environment(RxAVAudioPlayer.self) private var rxAVAudioPlayer
  @Environment(SDRModel.self) private var sdr
  @Environment(SettingsModel.self) private var settings
  
  @State var commandToSend = ""
  
  var body: some View {
    @Bindable var settingsBindable = settings
    
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
      .disabled(sdr.connectionStatus == .disconnected)
      
      Spacer()
      Group {
        Toggle("Clear on Send", isOn: $settingsBindable.clearOnSend)
        Toggle("Alert on Error", isOn: $settingsBindable.alertOnError)
        HStack(spacing: 5) {
          Stepper("Font Size",
                  value: $settingsBindable.fontSize,
                  in: 8...12)
          Text(String(format: "%2.0f", settings.fontSize)).frame(alignment: .leading)
        }
      }.frame(width: 130, alignment: .leading)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  
  ApiView()
    .environment(ApiModel.shared)
    .environment(Listener.shared)
    .environment(MessagesModel.shared)
    .environment(RxAVAudioPlayer.shared)
    .environment(SettingsModel.shared)
}
