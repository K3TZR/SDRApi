//
//  SDRApi.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//

import AVFoundation
import Cocoa
import ComposableArchitecture
import Foundation

import ClientFeature
import DirectFeature
import FlexApiFeature
import ListenerFeature
import LoginFeature
import MessagesFeature
import ObjectsFeature
import PickerFeature
import RxAudioFeature
import SettingsFeature
import SharedFeature
import XCGLogFeature

@Reducer
public struct SDRApi {
  
  public init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - State
  
  @ObservableState
  public struct State {
    // non-persistent
    var initialized = false
    var connectionState: ConnectionState = .disconnected
    var rxAVAudioPlayer = RxAVAudioPlayer()

    var objects = ObjectsFeature.State()
        
    @Presents var showAlert: AlertState<Action.Alert>?
    @Presents var showClient: ClientFeature.State?
    @Presents var showDirect: DirectFeature.State?
    @Presents var showLogin: LoginFeature.State?
    @Presents var showPicker: PickerFeature.State?
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Actions
  
  public enum Action {
    case onAppear
    
    // UI control actions
    case connectButtonTapped
    case clearSendTextButtonTapped
    case commandNextTapped
    case commandPreviousTapped
    case directEnabledChanged
    case localEnabledChanged
    case remoteRxAudioEnabledChanged
    case remoteTxAudioEnabledChanged
    case sendButtonTapped
    case smartlinkEnabledChanged

    case objects(ObjectsFeature.Action)

    // secondary actions
    case multiflexStatus(String)
    case connect(String, UInt32?)
    case connectionStatus(ConnectionState)
    case showAlert(Alert,String)
    case showClientSheet(String, IdentifiedArrayOf<GuiClient>)
    case showDirectSheet
    case showLoginSheet
    case showPickerSheet
    
    // navigation actions
    case alert(PresentationAction<Alert>)
    case client(PresentationAction<ClientFeature.Action>)
    case direct(PresentationAction<DirectFeature.Action>)
    case login(PresentationAction<LoginFeature.Action>)
    case picker(PresentationAction<PickerFeature.Action>)
    
    // alert sub-actions
    public enum Alert : String {
      case connectFailed = "Connect FAILED"
      case disconnectFailed = "Disconnect FAILED"
      case remoteRxAudioFailed = "RemoteRxAudio FAILED"
      case smartlinkLoginFailed = "Smartlink login FAILED"
      case unknownError = "Unknown error logged"
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Reducer
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.objects, action: \.objects) {
      ObjectsFeature()
    }

    Reduce { state, action in
      switch action {
        
        // ----------------------------------------------------------------------------
        // MARK: - Root Actions
        
      case .onAppear:
        // perform initialization
        return initState(&state)
        
      case .clearSendTextButtonTapped:
        // clear the command field
        SettingsModel.shared.commandToSend = ""
        return .none
        
      case .connectButtonTapped:
        // attempt to connect to the selected radio
        return connectionStartStop(state)
        
      case .commandNextTapped:
        // populate the command field with the next command in the stack (if any)
        commandNext(&state)
        return .none
        
      case .commandPreviousTapped:
        // populate the command field with the previously command in the stack (if any)
        commandPrevious(&state)
        return .none
        
      case .directEnabledChanged:
        if SettingsModel.shared.directEnabled {
          return .run { send in
            await send(.showDirectSheet)
          }
        }
        return .none
                
      case .localEnabledChanged:
        // start listening for local broadcasts
        return listenerStartStop(state)
        
      case .remoteRxAudioEnabledChanged:
        // attempt to start a remoteRxAudio connection
        return remoteRxAudioStartStop(state)

      case .remoteTxAudioEnabledChanged:
        // attempt to start a remoteTxAudio connection
        return remoteTxAudioStartStop(state)

      case .sendButtonTapped:
        // send a command to the radio
        return commandSend(&state)

      case .smartlinkEnabledChanged:
        // start listening to Smartlink radio lists
        return listenerStartStop(state)
        
        // ----------------------------------------------------------------------------
        // MARK: - Effect Actions
        
      case let .multiflexStatus(selection):
        // check for need to show Client view
        return multiflexStatus(state, selection)
        
      case let .connect(selection, disconnectHandle):
        // connect and optionally disconnect another client
        return connect(state, selection, disconnectHandle)
        
      case let .connectionStatus(status):
        // identify new state and take appropriate action(s)
        return connectionStatus(&state, status)
        
        // ----------------------------------------------------------------------------
        // MARK: - Presented Views
        
      case let .showAlert(alertType, message):
        switch alertType {
        case .connectFailed, .disconnectFailed, .unknownError:
          break
        case .remoteRxAudioFailed:
          SettingsModel.shared.remoteRxAudioEnabled = false
        case .smartlinkLoginFailed:
          SettingsModel.shared.smartlinkEnabled = false
        }
        state.showAlert = AlertState(title: TextState(alertType.rawValue), message: TextState(message))
        return .none
        
      case let .showClientSheet(selection, guiClients):
        state.showClient = ClientFeature.State(selection: selection, guiClients: guiClients)
        return .none
        
      case .showDirectSheet:
        state.showDirect = DirectFeature.State(ip: SettingsModel.shared.isGui ? SettingsModel.shared.directGuiIp : SettingsModel.shared.directNonGuiIp)
        return .none
        
      case .showLoginSheet:
        state.showLogin = LoginFeature.State()
        return .none
        
      case .showPickerSheet:
        state.showPicker = PickerFeature.State()
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Alert Actions
        
      case .alert(_):
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Client Actions
        
      case let .client(.presented(.connect(selection, disconnectHandle))):
        // connect in the chosen manner
        return .run { await $0(.connect(selection, disconnectHandle)) }
        
      case .client(_):
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Direct Actions
        
      case .direct(.presented(.cancelButtonTapped)):
        SettingsModel.shared.directEnabled = false
        return .none
        
      case let .direct(.presented(.saveButtonTapped(directIp))):
        if SettingsModel.shared.isGui {
          SettingsModel.shared.directGuiIp = directIp
        } else {
          SettingsModel.shared.directNonGuiIp = directIp
        }
        // Direct is mutually exclusive of the other modes
        SettingsModel.shared.localEnabled = false
        SettingsModel.shared.smartlinkEnabled = false

        return .none
        
      case .direct(_):
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Login Actions
        
      case .login(.presented(.cancelButtonTapped)):
        SettingsModel.shared.smartlinkEnabled = false
        return .none
        
      case let .login(.presented(.loginButtonTapped(user, password))):
        // attempt to login to Smartlink
        return smartlinkUserLogin(&state, user, password)
        
      case .login(_):
        return .none

        // ----------------------------------------------------------------------------
        // MARK: - Picker Actions
        
      case let .picker(.presented(.connectButtonTapped(selection))):
        // check the status of the selection
        return .run {await $0(.multiflexStatus(selection)) }
        
      case .picker(_):
        return .none
               
        // ----------------------------------------------------------------------------
        // MARK: - Objects Actions (cause values to be persisted)
        
      case .objects(_):
        return .none
      }
    }

    // ----------------------------------------------------------------------------
    // MARK: - Sheet / Alert reducer integration
    
    .ifLet(\.$showAlert, action: /Action.alert)
    .ifLet(\.$showClient, action: /Action.client) { ClientFeature() }
    .ifLet(\.$showDirect, action: /Action.direct) { DirectFeature() }
    .ifLet(\.$showLogin, action: /Action.login) { LoginFeature() }
    .ifLet(\.$showPicker, action: /Action.picker) { PickerFeature() }
  }
  
  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------
  // MARK: - Private effect methods
  
  private func commandNext(_ state: inout State) {
    if SettingsModel.shared.commandsIndex == SettingsModel.shared.commandsArray.count - 1{
      SettingsModel.shared.commandsIndex = 0
    } else {
      SettingsModel.shared.commandsIndex += 1
    }
    SettingsModel.shared.commandToSend = SettingsModel.shared.commandsArray[SettingsModel.shared.commandsIndex]
  }
  
  private func commandPrevious(_ state: inout State) {
    if SettingsModel.shared.commandsIndex == 0 {
      SettingsModel.shared.commandsIndex = SettingsModel.shared.commandsArray.count - 1
    } else {
      SettingsModel.shared.commandsIndex -= 1
    }
    SettingsModel.shared.commandToSend = SettingsModel.shared.commandsArray[SettingsModel.shared.commandsIndex]
  }
  
  private func commandSend(_ state: inout State) -> Effect<SDRApi.Action> {
    SettingsModel.shared.commandsArray.append(SettingsModel.shared.commandToSend)
    return .run {
      // send command to the radio
      await ApiModel.shared.sendCommand(SettingsModel.shared.commandToSend)
      if SettingsModel.shared.clearOnSend { await $0(.clearSendTextButtonTapped)}
    }
  }
  
  private func connect(_ state: State, _ selection: String, _ disconnectHandle: UInt32?) -> Effect<SDRApi.Action> {
    Listener.shared.setActive(SettingsModel.shared.isGui, selection)
    return .run {
      // attempt to connect to the selected Radio / Station
      do {
        // try to connect
        try await ApiModel.shared.connect(selection: selection,
                                          isGui: SettingsModel.shared.isGui,
                                          disconnectHandle: disconnectHandle,
                                          programName: "SDRApiViewer",
                                          mtuValue: SettingsModel.shared.mtuValue,
                                          lowBandwidthDax: SettingsModel.shared.lowBandwidthDax)
        await $0(.connectionStatus(.connected))
        
      } catch {
        // connection attempt failed
        await $0(.connectionStatus(.errorOnConnect))
      }
    }
  }
  
  private func connectionStartStop(_ state: State)  -> Effect<SDRApi.Action> {
    if state.connectionState == .connected {
      // ----- STOPPING -----
      MessagesModel.shared.stop()
      return .run { 
        if SettingsModel.shared.remoteRxAudioEnabled { await remoteRxAudioStop(state) }
        await ApiModel.shared.disconnect()
        await $0(.connectionStatus(.disconnected))
      }
      
    } else {
      // ----- STARTING -----
      MessagesModel.shared.start()
      if SettingsModel.shared.directEnabled && ((SettingsModel.shared.isGui && !SettingsModel.shared.directGuiIp.isEmpty) || (!SettingsModel.shared.isGui && !SettingsModel.shared.directNonGuiIp.isEmpty)) {
        // DIRECT mode connection
        return .run {
          if SettingsModel.shared.isGui && !SettingsModel.shared.directGuiIp.isEmpty {
            await $0(.multiflexStatus(SettingsModel.shared.directGuiIp))
          } else if !SettingsModel.shared.directNonGuiIp.isEmpty {
            await $0(.multiflexStatus(SettingsModel.shared.directNonGuiIp))
          }
        }
        
      } else {
        return .run { 
          if SettingsModel.shared.useDefault {
            // LOCAL/SMARTLINK mode connection using the Default, is there a valid? Default
            if Listener.shared.isValidDefault(for: SettingsModel.shared.guiDefault, SettingsModel.shared.nonGuiDefault, SettingsModel.shared.isGui) {
              // YES, valid default
              if SettingsModel.shared.isGui {
                await $0(.multiflexStatus(SettingsModel.shared.guiDefault!))
              } else {
                await $0(.multiflexStatus(SettingsModel.shared.nonGuiDefault!))
              }
            } else {
              // NO, invalid default
              await $0(.showPickerSheet)
            }
          } else {
            // default not in use, open the Picker
            await $0(.showPickerSheet)
          }
        }
      }
    }
  }
      
  private func connectionStatus(_ state: inout State, _ status: ConnectionState) -> Effect<SDRApi.Action> {
    
    switch status {
    case .connected:
      state.connectionState = .connected
      state.objects.connectionState = .connected
      
    case .errorOnConnect:
      state.connectionState = .disconnected
      return .run {
        await $0(.showAlert(.connectFailed, ""))
      }
    case .disconnected:
      state.connectionState = .disconnected
      state.objects.connectionState = .disconnected

    case .errorOnDisconnect:
      state.connectionState = .disconnected
      return .run {
        await $0(.showAlert(.disconnectFailed, ""))
      }
    case .connecting:
      state.connectionState = .connecting
      return .none

    case .disconnecting:
      state.connectionState = .disconnecting
      return .none
    }

    if state.connectionState == .connected && SettingsModel.shared.remoteRxAudioEnabled {
      return .run { [state] send in
        await remoteRxAudioStart(state, send)
      }
    }
    return .none
  }
  
  private func initState(_ state: inout State) -> Effect<SDRApi.Action> {
    if state.initialized == false {
            
      // instantiate the Logger, use the group defaults (not the Standard)
      _ = XCGWrapper(logLevel: .debug, group: "group.net.k3tzr.flexapps")
      
      state.objects = ObjectsFeature.State(connectionState: state.connectionState)
      
      // mark as initialized
      state.initialized = true
      
      return listenerStartStop(state)
    }
    return .none
  }
  
  // start/stop listener, as needed
  private func listenerStartStop(_ state: State) -> Effect<SDRApi.Action> {
    return .run {
      Listener.shared.previousIdToken = SettingsModel.shared.smartlinkIdToken
      Listener.shared.localMode(SettingsModel.shared.localEnabled)
      if await !Listener.shared.smartlinkMode(SettingsModel.shared.smartlinkEnabled , SettingsModel.shared.smartlinkUser, SettingsModel.shared.loginRequired) {
        await $0(.showLoginSheet)
      }
    }
  }
  
  private func multiflexStatus(_ state: State, _ selection: String) -> Effect<SDRApi.Action> {
    return .run {
      if SettingsModel.shared.isGui {
        // GUI selection
        if let selectedPacket = Listener.shared.packets[id: selection] {
          
          // Gui connection with other stations?
          if selectedPacket.guiClients.count > 0 {
            // show the client chooser, let the user choose
            await $0(.showClientSheet(selection, selectedPacket.guiClients))
          } else {
            // Gui without other stations, attempt to connect
            await $0(.connect(selection, nil))
          }
        } else {
          // packet not found, should be impossible
          fatalError("ConnectionStatus: Packet not found")
        }
      } else {
        // NON-GUI selection
        await $0(.connect(selection, nil))
      }
    }
  }
    
  private func remoteRxAudioStartStop(_ state: State)  -> Effect<SDRApi.Action> {
    if state.connectionState == .connected {
      return .run { [state] send in
        if SettingsModel.shared.remoteRxAudioEnabled {
          await remoteRxAudioStart(state, send)
        } else {
          await remoteRxAudioStop(state)
        }
      }
    }
    return .none
  }
  
  private func remoteRxAudioStart(_ state: State, _ send: Send<SDRApi.Action>) async {
    let isCompressed = SettingsModel.shared.remoteRxAudioCompressed
    
    // request a stream
    if let streamId = try! await ApiModel.shared.requestRemoteRxAudioStream(isCompressed: isCompressed).streamId {
      // start player
      state.rxAVAudioPlayer.setup(outputDeviceID: nil, volume: nil, isCompressed: isCompressed)
      // finish audio setup
      state.rxAVAudioPlayer.start(streamId)
      await ApiModel.shared.remoteRxAudioStreams[id: streamId]?.delegate = state.rxAVAudioPlayer
      
    } else {
      state.rxAVAudioPlayer.stop()
      await send(.showAlert(.remoteRxAudioFailed, ""))
    }
  }
  
  private func remoteRxAudioStop(_ state: State) async {
    // remove player and stream
    state.rxAVAudioPlayer.stop()
    await ApiModel.shared.sendRemoveStream(state.rxAVAudioPlayer.streamId)
  }
  
  private func remoteTxAudioStartStop(_ state: State)  -> Effect<SDRApi.Action> {
    // TODO
    return .none
  }
  
  private func smartlinkUserLogin(_ state: inout State, _ user: String, _ password: String) -> Effect<SDRApi.Action> {
    SettingsModel.shared.smartlinkUser = user
    return .run {
      if await !Listener.shared.startSmartlink(user, password) {
        await $0(.showAlert(.smartlinkLoginFailed, "for user \(user)"))
      }
    }
  }
  
//  private func testButton(_ selection: String) -> Effect<SDRApi.Action> {
//    return .run {
//      Listener.shared.smartlinkTest(selection)
//      await $0(.showPickerSheet)
//    }
//  }
}
