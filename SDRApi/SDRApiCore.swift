//
//  SDRApi.swift
//  SDRApi
//
//  Created by Douglas Adams on 12/27/23.
//

import AVFoundation
import Cocoa
import ComposableArchitecture
import Foundation

import AudioFeature
import ClientFeature
import DirectFeature
import FlexApiFeature
import ListenerFeature
import LoginFeature
import PickerFeature
import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - Persistence properties

public struct AppSettings: Codable, Equatable {
  public var alertOnError = true
  public var clearOnSend = false
  public var clearOnStart = true
  public var clearOnStop = true
  public var commandsArray = [String]()
  public var commandsIndex = 0
  public var commandToSend = ""
  public var daxSelection = -1
  public var directEnabled = false
  public var directGuiIp = ""
  public var directNonGuiIp = ""
  public var fontSize = 12
  public var gotoBottom = false
  public var guiDefault: String = ""
  public var isGui = true
  public var localEnabled = true
  public var lowBandwidthConnect = false              // FIXME: no provision for setting this
  public var lowBandwidthDax = false
  public var messageFilter: MessageFilter = .all
  public var messageFilterText = ""
  public var mtuValue = 1_300
  public var newLineBetweenMessages = false
  public var nonGuiDefault: String = ""
  public var previousCommand = ""
  public var previousIdToken: String = ""
  public var radioObjectFilter: RadioObjectFilter = .all
  public var refreshToken: String = ""
  public var remoteRxAudioCompressed = false
  public var remoteRxAudioEnabled = false
  public var remoteTxAudioEnabled = false
  public var showPings = false
  public var showTimes = true
  public var smartlinkEnabled = false
  public var smartlinkLoginRequired = false
  public var smartlinkUser = ""
  public var station = "SDRApi"
  public var stationObjectFilter: StationObjectFilter = .noMeters
  public var useDefaultEnabled = false
}

// ----------------------------------------------------------------------------
// MARK: - Persistence Extensions

extension URL {
  static let appSettings = Self
    .applicationSupportDirectory
    .appending(path: "appSettings.json")
}

extension PersistenceKey
where Self == PersistenceKeyDefault<FileStorageKey<AppSettings>> {
  public static var appSettings: Self {
    PersistenceKeyDefault(
      .fileStorage(.appSettings),
      AppSettings()
    )
  }
}

// ----------------------------------------------------------------------------
// MARK: - Reducer

@Reducer
public struct SDRApi {
  
  public init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - State
  
  @ObservableState
  public struct State {    
    // persistent
    @Shared(.appSettings) var appSettings: AppSettings

    // non-persistent
    var objectModel: ObjectModel?
    var initialized = false
    var connectionState: ConnectionState = .disconnected
    
    @Presents var showAlert: AlertState<Action.Alert>?
    @Presents var showClient: ClientFeature.State?
    @Presents var showDirect: DirectFeature.State?
    @Presents var showLogin: LoginFeature.State?
    @Presents var showPicker: PickerFeature.State?
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Actions
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    
    case onAppear(ObjectModel)
    
    // UI control actions
    case connectButtonTapped
    case clearButtonTapped
    case clearFilterTextTapped
    case clearSendTextButtonTapped
    case commandNextTapped
    case commandPreviousTapped
    case daxSelectionChanged(Int,Int)
    case directEnabledChanged
    case localEnabledChanged
    case messagesFilterChanged
    case remoteRxAudioEnabledChanged
    case remoteRxAudioCompressedChanged
    case remoteTxAudioEnabledChanged
    case saveButtonTapped
    case sendButtonTapped
    case showPingsChanged
    case smartlinkEnabledChanged
    case tnfsEnabledClicked
    
    // secondary actions
    case multiflexStatus(String)
    case connect(String, UInt32?)
    case connectionStatus(ConnectionState)
    case saveTokens(Tokens)
    case showAlert(Alert,String)
    case showClientSheet(String, IdentifiedArrayOf<GuiClient>)
    case showDirectSheet
//    case showLogAlert(LogEntry)
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
  // MARK: - Reducer builder
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
        
        // ----------------------------------------------------------------------------
        // MARK: - Root Actions
        
      case let .onAppear(objectModel):
        state.objectModel = objectModel
        // perform initialization
        return  initState(&state)
        
      case .clearButtonTapped:
        MessagesModel.shared.clear(state.appSettings.messageFilter, state.appSettings.messageFilterText)
        return .none

      case .clearFilterTextTapped:
        state.appSettings.messageFilterText = ""
        MessagesModel.shared.reFilter(state.appSettings.messageFilter, "")
        return .none
        
      case .clearSendTextButtonTapped:
        // clear the command field
        state.appSettings.commandToSend = ""
        return .none
        
      case .connectButtonTapped:
        // start/stop the connection
        if state.connectionState == .connected {
          return connectionStop(state)
        } else {
          return connectionStart(state)
        }
        
      case .commandNextTapped:
        // populate the command field with the next command in the stack (if any)
        commandNext(&state)
        return .none
        
      case .commandPreviousTapped:
        // populate the command field with the previously command in the stack (if any)
        commandPrevious(&state)
        return .none
        
      case let .daxSelectionChanged(previousChannel, newChannel):
        guard newChannel != previousChannel else { return .none }
        if newChannel == -1 {
          // stopping
          return daxRxAudioStop(&state, previousChannel)
          
        } else if previousChannel == -1 {
          // starting
          return daxRxAudioStart(&state, newChannel)
          
        } else {
          // switching
          return .concatenate(daxRxAudioStop(&state, previousChannel), daxRxAudioStart(&state, newChannel))
        }
        
      case .directEnabledChanged:
        if state.appSettings.directEnabled {
          state.appSettings.localEnabled = false
          state.appSettings.smartlinkEnabled = false
          return .run {
            await $0(.showDirectSheet)
          }
        } else {
          return .none
        }

      case .localEnabledChanged:
        state.appSettings.directEnabled = false
        return listenerStartStop(&state)

      case .messagesFilterChanged:
        MessagesModel.shared.reFilter(state.appSettings.messageFilter, state.appSettings.messageFilterText)
        return .none
        
      case .remoteRxAudioEnabledChanged:
        if state.appSettings.remoteRxAudioEnabled {
          return remoteRxAudioStart(&state)
        } else {
          return remoteRxAudioStop(&state)
        }

      case .remoteRxAudioCompressedChanged:
        if state.connectionState == .connected && state.appSettings.remoteRxAudioEnabled {
          state.appSettings.remoteRxAudioEnabled = false
          return remoteRxAudioStop(&state)
        }
        return .none

      case .remoteTxAudioEnabledChanged:
        if state.appSettings.remoteTxAudioEnabled {
          return remoteTxAudioStart(&state)
        } else {
          return remoteTxAudioStop(&state)
        }

      case .saveButtonTapped:
        return saveMessages(state)
        
      case .sendButtonTapped:
        // send a command to the radio
        return commandSend(&state)
        
      case .showPingsChanged:
        MessagesModel.shared.showPings(state.appSettings.showPings)
        return .none
        
      case .smartlinkEnabledChanged:
        state.appSettings.directEnabled = false
        return listenerStartStop(&state)

      case .tnfsEnabledClicked:
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Root Binding Actions
        
      case .binding(_):
        // appSettings are updated by bindings causing them to be persisted
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Effect Actions
        
      case let .connect(selection, disconnectHandle):
        // connect and optionally disconnect another client
        return connect(state, selection, disconnectHandle)
        
      case let .connectionStatus(status):
        // identify new state and take appropriate action(s)
        return connectionStatus(&state, status)
        
      case let .multiflexStatus(selection):
        // check for need to show Client view
        return multiflexStatus(state, selection)
        
      case let .saveTokens(tokens):
        if !tokens.idToken.isEmpty {
          // success
          state.appSettings.previousIdToken = tokens.idToken
          state.appSettings.refreshToken = tokens.refreshToken
        } else {
          // failure
          state.appSettings.previousIdToken = ""
          state.appSettings.refreshToken = ""
        }
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Presented Views
        
      case let .showAlert(alertType, message):
        switch alertType {
        case .connectFailed, .disconnectFailed, .unknownError:
          break
        case .remoteRxAudioFailed:
          state.appSettings.remoteRxAudioEnabled = false
        case .smartlinkLoginFailed:
          state.appSettings.smartlinkEnabled = false
        }
        state.showAlert = AlertState(title: TextState(alertType.rawValue), message: TextState(message))
        return .none
        
      case let .showClientSheet(selection, guiClients):
        state.showClient = ClientFeature.State(selection: selection, guiClients: guiClients)
        return .none
        
      case .showDirectSheet:
        state.showDirect = DirectFeature.State(ip: state.appSettings.isGui ? state.appSettings.directGuiIp : state.appSettings.directNonGuiIp)
        return .none
        
//      case let .showLogAlert(logEntry):
//        state.showAlert = AlertState(title: TextState("\(logEntry.level == .warning ? "A Warning" : "An Error") was logged:"), message: TextState(logEntry.msg))
//        return .none
        
      case .showLoginSheet:
        state.showLogin = LoginFeature.State(user: state.appSettings.smartlinkUser)
        return .none
        
      case .showPickerSheet:
        state.showPicker = PickerFeature.State(isGui: state.appSettings.isGui, defaultValue: state.appSettings.isGui ? state.appSettings.guiDefault : state.appSettings.nonGuiDefault)
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
        state.appSettings.directEnabled = false
        return .none
        
      case let .direct(.presented(.saveButtonTapped(ip))):
        // Direct is mutually exclusive of the other modes
        state.appSettings.localEnabled = false
        state.appSettings.smartlinkEnabled = false
        if state.appSettings.isGui {
          state.appSettings.directGuiIp = ip
        } else {
          state.appSettings.directNonGuiIp = ip
        }
        return .none
        
      case .direct(_):
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Login Actions
        
      case .login(.presented(.cancelButtonTapped)):
        state.appSettings.smartlinkEnabled = false
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
        
      case let .picker(.presented(.defaultButtonTapped(selection))):
        if state.appSettings.isGui {
          state.appSettings.guiDefault = state.appSettings.guiDefault == selection ? "" : selection
        } else {
          state.appSettings.nonGuiDefault = state.appSettings.nonGuiDefault == selection ? "" : selection
        }
        return .none
        
      case .picker(_):
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
  // MARK: - Private effect methods
  
  private func commandNext(_ state: inout State) {
    if state.appSettings.commandsIndex == state.appSettings.commandsArray.count - 1{
      state.appSettings.commandsIndex = 0
    } else {
      state.appSettings.commandsIndex += 1
    }
    state.appSettings.commandToSend = state.appSettings.commandsArray[state.appSettings.commandsIndex]
  }
  
  private func commandPrevious(_ state: inout State) {
    if state.appSettings.commandsIndex == 0 {
      state.appSettings.commandsIndex = state.appSettings.commandsArray.count - 1
    } else {
      state.appSettings.commandsIndex -= 1
    }
    state.appSettings.commandToSend = state.appSettings.commandsArray[state.appSettings.commandsIndex]
  }
  
  private func commandSend(_ state: inout State) -> Effect<SDRApi.Action> {
    state.appSettings.commandsArray.append(state.appSettings.commandToSend)
    return .run { [state] in
      // send command to the radio
      await state.objectModel!.sendTcp(state.appSettings.commandToSend)
      if state.appSettings.clearOnSend { await $0(.clearSendTextButtonTapped)}
    }
  }
  
  private func connect(_ state: State, _ selection: String, _ disconnectHandle: UInt32?) -> Effect<SDRApi.Action> {
//    ListenerModel.shared.setActive(state.isGui, selection, state.directEnabled)
    return .run {
      var activePacket: Packet?
      var activeStation: String?
      
      if state.appSettings.isGui {
        activePacket = await ListenerModel.shared.packets[id: selection]
        activeStation = "SDRApi"
      } else {
        activePacket = await ListenerModel.shared.stations[id: selection]?.packet
        activeStation = await ListenerModel.shared.stations[id: selection]?.station
      }
      MessagesModel.shared.resetStartTime()

      // attempt to connect to the selected Radio / Station
      do {
        // try to connect
        try await state.objectModel!.connect(packet: activePacket,
                                          station: activeStation,
                                          isGui: state.appSettings.isGui,
                                          disconnectHandle: disconnectHandle,
                                          programName: "SDRApiViewer",
                                          mtuValue: state.appSettings.mtuValue,
                                          lowBandwidthDax: state.appSettings.lowBandwidthDax,
                                          lowBandwidthConnect: state.appSettings.lowBandwidthConnect,
                                          testDelegate: MessagesModel.shared)
        await $0(.connectionStatus(.connected))
        
      } catch {
        // connection attempt failed
        await $0(.connectionStatus(.errorOnConnect))
      }
    }
  }
  
  private func connectionStart(_ state: State)  -> Effect<SDRApi.Action> {
    if state.appSettings.clearOnStart { MessagesModel.shared.clear(state.appSettings.messageFilter, state.appSettings.messageFilterText)}
    if state.appSettings.directEnabled {
      // DIRECT Mode
      return .run {
        if state.appSettings.isGui && !state.appSettings.directGuiIp.isEmpty {
          let selection = "9999-9999-9999-9999" + state.appSettings.directGuiIp
          await $0(.connect(selection, nil))
          
        } else if !state.appSettings.directNonGuiIp.isEmpty {
          let selection = "9999-9999-9999-9999" + state.appSettings.directNonGuiIp
          await $0(.connect(selection, nil))
          
        } else {
          // no Ip Address for the current connection type
          await $0(.showDirectSheet)
        }
      }
      
    } else {
      return .run {
        if state.appSettings.useDefaultEnabled {
          // LOCAL/SMARTLINK mode connection using the Default, is there a valid? Default
          if await ListenerModel.shared.isValidDefault(for: state.appSettings.guiDefault, state.appSettings.nonGuiDefault, state.appSettings.isGui) {
            // YES, valid default
            if state.appSettings.isGui {
              await $0(.multiflexStatus(state.appSettings.guiDefault))
            } else {
              await $0(.multiflexStatus(state.appSettings.nonGuiDefault))
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
  
  private func connectionStop(_ state: State)  -> Effect<SDRApi.Action> {
    if state.appSettings.clearOnStop { MessagesModel.shared.clear(state.appSettings.messageFilter, state.appSettings.messageFilterText) }
    return .run {
      await ObjectModel.shared.clientInitialized(false)
      await state.objectModel!.disconnect()
      await $0(.connectionStatus(.disconnected))
    }
  }
  
  private func connectionStatus(_ state: inout State, _ status: ConnectionState) -> Effect<SDRApi.Action> {
    switch status {
    case .connected:
      state.connectionState = .connected
      
    case .errorOnConnect:
      state.connectionState = .disconnected
      return .run {
        await $0(.showAlert(.connectFailed, ""))
      }
    case .disconnected:
      state.connectionState = .disconnected
      
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
    
    if state.connectionState == .connected && state.appSettings.remoteRxAudioEnabled {
      return remoteRxAudioStart(&state)
    }
    
    if state.connectionState != .connected && state.appSettings.remoteRxAudioEnabled {
      return remoteRxAudioStop(&state)
    }
    return .none
  }
  
  private func daxRxAudioStart(_ state: inout State, _ channel: Int) -> Effect<SDRApi.Action> {
    return .run { [state] _ in
      // request a stream
      if channel == 0 {
        await state.objectModel!.requestStream(.daxMicAudioStream, replyTo: daxRxReplyHandler)
      } else {
        await state.objectModel!.requestStream(.daxRxAudioStream, daxChannel: channel, isCompressed: state.appSettings.lowBandwidthDax, replyTo: daxRxReplyHandler)
      }
    }
  }
  
  private func daxRxReplyHandler(_ command: String, _ seqNumber: Int, _ responseValue: String, _ reply: String) {
    // parse the command to get the type and channel number
    let properties = command.keyValuesArray()
    
    if let streamId = reply.streamId {
      Task {
        if properties[2].value == StreamType.daxMicAudioStream.rawValue {
          await StreamModel.shared.daxRxAudioStart(streamId, 0)
        } else {
          await StreamModel.shared.daxRxAudioStart(streamId, properties[3].value.iValue)
        }
      }
    }
  }

  private func daxRxAudioStop(_ state: inout State, _ channel: Int) -> Effect<SDRApi.Action> {
    Task {
      await StreamModel.shared.daxRxAudioStop(channel)
    }
    return .none
  }

  private func initState(_ state: inout State) -> Effect<SDRApi.Action> {
    if state.initialized == false {
            
      // pass Tcp messages to the Tester
//      state.objectModel!.testDelegate = MessagesModel.shared
      
      // instantiate the Logger, use the group defaults (not the Standard)
//      XCGWrapper.shared.setup(logLevel: .debug, group: "group.net.k3tzr.flexapps")
      
      // mark as initialized
      state.initialized = true
            
      return listenerStartStop(&state)
    }
    return .none
  }

  // start/stop listener, as needed
  private func listenerStartStop(_ state: inout State) -> Effect<SDRApi.Action> {
    // start/stop local mode
    ListenerModel.shared.localMode(state.appSettings.localEnabled)
    
    // start smartlink mode?
    if state.appSettings.smartlinkEnabled {
      
      if state.appSettings.smartlinkLoginRequired || state.appSettings.smartlinkUser.isEmpty {
        // YES but login required or no user
        state.appSettings.previousIdToken = ""
        state.appSettings.refreshToken = ""
        return .run {
          await $0(.showLoginSheet)
        }
        
      } else {
        // YES, try
        return .run { [state] in
          let tokens = await ListenerModel.shared.smartlinkMode(state.appSettings.smartlinkUser,
                                                                state.appSettings.smartlinkLoginRequired,
                                                                state.appSettings.previousIdToken,
                                                                state.appSettings.refreshToken)
          await $0(.saveTokens(tokens))
        }
      }
    } else {
      Task { await ListenerModel.shared.removePackets(condition: {$0.source == .smartlink}) }
      return .none
    }
  }
  
  private func multiflexStatus(_ state: State, _ selection: String) -> Effect<SDRApi.Action> {
    return .run {
      if state.appSettings.isGui {
        // GUI selection
        if let selectedPacket = await ListenerModel.shared.packets[id: selection] {
          
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
  
  private func remoteRxAudioStart(_ state: inout State) -> Effect<SDRApi.Action> {
    return .run { [state] _ in
      // request a stream
      await state.objectModel!.requestStream(.remoteRxAudioStream, isCompressed: state.appSettings.remoteRxAudioCompressed, replyTo: remoteRxReplyHandler)
    }
  }
  
  private func remoteRxReplyHandler(_ command: String, _ seqNumber: Int, _ responseValue: String, _ reply: String) {
    if let streamId = reply.streamId {
      Task {
        await StreamModel.shared.remoteRxAudioStart(streamId)
      }
    }
  }

  private func remoteRxAudioStop(_ state: inout State) -> Effect<SDRApi.Action> {
    Task {
      await StreamModel.shared.remoteRxAudioStop()
    }
    return .none
  }
  
  private func remoteTxAudioStart(_ state: inout State)  -> Effect<SDRApi.Action> {
    print("TODO: remoteTxAudioStart") // TODO
    return .none
  }
  
  private func remoteTxAudioStop(_ state: inout State)  -> Effect<SDRApi.Action> {
    print("TODO: remoteTxAudioStop") // TODO
    return .none
  }
  
  private func saveMessages(_ state: State) -> Effect<SDRApi.Action> {
    let savePanel = NSSavePanel()
    savePanel.nameFieldStringValue = "SDRApi.messages"
    savePanel.canCreateDirectories = true
    savePanel.isExtensionHidden = false
    savePanel.allowsOtherFileTypes = false
    savePanel.title = "Save TCP Messages"
    
    let response = savePanel.runModal()
    if response == .OK {
      return .run { _ in
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 6
        formatter.positiveFormat = " * ##0.000000"
        
        let textArray = await MessagesModel.shared.filteredMessages.map { formatter.string(from: NSNumber(value: $0.interval))! + " " + $0.text }
        let fileTextArray = textArray.joined(separator: "\n")
        try? await fileTextArray.write(to: savePanel.url!, atomically: true, encoding: .utf8)
      }
    } else {
      return .none
    }
  }
  
  private func smartlinkUserLogin(_ state: inout State, _ user: String, _ password: String) -> Effect<SDRApi.Action> {
    state.appSettings.smartlinkUser = user
    return .run {
      let tokens = await ListenerModel.shared.smartlinkStart(user, password)
      await $0(.saveTokens(tokens))
    }
  }
}
