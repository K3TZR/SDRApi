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
//import TcpFeature
import XCGLogFeature

//extension URL {
//  static let appSettings = Self
//    .applicationSupportDirectory
//    .appending(path: "appSettings.json")
//}
//
//extension PersistenceKey
//where Self == FileStorageKey<AppSettings> {
//  public static var appSettings: Self {
//    fileStorage(.appSettings)
//  }
//}
//
//extension PersistenceKey
//where Self == PersistenceKeyDefault<
//  FileStorageKey<AppSettings>
//> {
//  public static var appSettings: Self {
//    PersistenceKeyDefault(
//      .fileStorage(.appSettings),
//      AppSettings()
//    )
//  }
//}
//
//public struct AppSettings: Codable, Equatable {
//  public var clearOnStart = true
//  public var clearOnStop = true
//  public var gotoTop = false
//  public var messageFilter: MessageFilter = .all
//  public var messageFilterText = ""
//  public var showPings = false
//  public var showTimes = true
//  public var newLineBetweenMessages = false
//}

@Reducer
public struct SDRApi {
  
  public init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - State
  
  @ObservableState
  public struct State {
    
    // persistent
    @Shared(.appStorage("clearOnStart")) var clearOnStart = true
    @Shared(.appStorage("clearOnStop")) var clearOnStop = true
    @Shared(.appStorage("gotoBottom")) var gotoBottom = false
    @Shared(.appStorage("messageFilter")) var messageFilter: MessageFilter = .all
    @Shared(.appStorage("messageFilterText")) var messageFilterText = ""
    @Shared(.appStorage("showPings")) var showPings = false
    @Shared(.appStorage("showTimes")) var showTimes = true
    @Shared(.appStorage("newLineBetweenMessages")) var newLineBetweenMessages = false
    
    
    
    @Shared(.appStorage("alertOnError")) var alertOnError = false
    @Shared(.appStorage("clearOnSend")) var clearOnSend = false
    @Shared(.appStorage("commandToSend")) var commandToSend = ""
    @Shared(.appStorage("commandsArray")) var commandsArray = [String]()
    @Shared(.appStorage("commandsIndex")) var commandsIndex = 0
    @Shared(.appStorage("daxSelection")) var daxSelection = -1
    @Shared(.appStorage("directEnabled")) var directEnabled = false
    @Shared(.appStorage("directGuiIp")) var directGuiIp = ""
    @Shared(.appStorage("directNonGuiIp")) var directNonGuiIp = ""
    @Shared(.appStorage("fontSize")) var fontSize = 12
    @Shared(.appStorage("guiDefault")) var guiDefault: String = ""
    @Shared(.appStorage("isGui")) var isGui = true
    @Shared(.appStorage("localEnabled")) var localEnabled = true
    @Shared(.appStorage("lowBandwidthConnect")) var lowBandwidthConnect = false
    @Shared(.appStorage("lowBandwidthDax")) var lowBandwidthDax = false
    @Shared(.appStorage("mtuValue")) var mtuValue = 1_300
    @Shared(.appStorage("nonGuiDefault")) var nonGuiDefault: String = ""
    @Shared(.appStorage("radioObjectFilter")) var radioObjectFilter: RadioObjectFilter = .all
    @Shared(.appStorage("stationObjectFilter")) var stationObjectFilter: StationObjectFilter = .noMeters
    @Shared(.appStorage("previousCommand")) var previousCommand = ""
    @Shared(.appStorage("previousIdToken")) var previousIdToken: String = ""
    @Shared(.appStorage("refreshToken")) var refreshToken: String = ""
    @Shared(.appStorage("remoteRxAudioCompressed")) var remoteRxAudioCompressed = false
    @Shared(.appStorage("remoteRxAudioEnabled")) var remoteRxAudioEnabled = false
    @Shared(.appStorage("remoteTxAudioEnabled")) var remoteTxAudioEnabled = false
    @Shared(.appStorage("smartlinkEnabled")) var smartlinkEnabled = false
    @Shared(.appStorage("smartlinkLoginRequired")) var smartlinkLoginRequired = false
    @Shared(.appStorage("smartlinkUser")) var smartlinkUser = ""
    @Shared(.appStorage("station")) var station = "SDRApi"
    @Shared(.appStorage("useDefaultEnabled")) var useDefaultEnabled = false
    
    // non-persistent
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
    case onAppear
    
    // UI control actions
    case connectButtonTapped
    case clearButtonTapped
    case clearFilterTextTapped
    case clearSendTextButtonTapped
    case commandNextTapped
    case commandPreviousTapped
    case daxSelectionChanged(Int,Int)
    case saveButtonTapped
    case sendButtonTapped
    case tnfsEnabledClicked
    
    // secondary actions
    case multiflexStatus(String)
    case connect(String, UInt32?)
    case connectionStatus(ConnectionState)
    case saveTokens(Tokens)
    case showAlert(Alert,String)
    case showClientSheet(String, IdentifiedArrayOf<GuiClient>)
    case showDirectSheet
    case showLogAlert(LogEntry)
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
    BindingReducer()
    
    Reduce { state, action in
      switch action {
        
        // ----------------------------------------------------------------------------
        // MARK: - Root Actions
        
      case .onAppear:
        // perform initialization
        return  initState(&state)
        
      case .clearSendTextButtonTapped:
        // clear the command field
        state.commandToSend = ""
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
        
      case .sendButtonTapped:
        // send a command to the radio
        return commandSend(&state)
        
      case .clearButtonTapped:
        return .run { _ in await MessagesModel.shared.clear() }
        
      case .clearFilterTextTapped:
        state.messageFilterText = ""
        return .run {[filter = state.messageFilter] _ in await MessagesModel.shared.reFilter(filter, "") }
        
      case .saveButtonTapped:
        return saveMessages(state)
        
      case .tnfsEnabledClicked:
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Root Binding Actions
        
//      case .binding(\.daxSelection):
//        if state.daxSelection == none {
//          return daxAudioStop(&state)
//        } else {
//          return daxAudioStart(&state)
//        }
        
      case .binding(\.directEnabled):
        state.localEnabled = false
        state.smartlinkEnabled = false
        if state.directEnabled {
          return .run {
            await $0(.showDirectSheet)
          }
        } else {
          return .none
        }
        
      case .binding(\.localEnabled):
        state.directEnabled = false
        return listenerStartStop(&state)
        
      case .binding(\.messageFilter):
        return .run { [filter = state.messageFilter, text = state.messageFilterText] _ in await MessagesModel.shared.reFilter(filter, text) }
        
      case .binding(\.messageFilterText):
        return .run { [filter = state.messageFilter, text = state.messageFilterText] _ in await MessagesModel.shared.reFilter(filter, text) }
        
      case .binding(\.remoteRxAudioCompressed):
        if state.connectionState == .connected && state.remoteRxAudioEnabled {
          state.remoteRxAudioEnabled = false
          return remoteRxAudioStop(&state)
        }
        return .none
        
      case .binding(\.remoteRxAudioEnabled):
        if state.remoteRxAudioEnabled {
          return remoteRxAudioStart(&state)
        } else {
          return remoteRxAudioStop(&state)
        }
        
      case .binding(\.remoteTxAudioEnabled):
        if state.remoteTxAudioEnabled {
          return remoteTxAudioStart(&state)
        } else {
          return remoteTxAudioStop(&state)
        }
        
      case .binding(\.showPings):
        state.showPings = state.showPings
        return .run {[showPings = state.showPings] _ in
          await MessagesModel.shared.showPings(showPings)
        }
        
      case .binding(\.smartlinkEnabled):
        state.directEnabled = false
        return listenerStartStop(&state)
        
      case .binding(_):
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
          state.previousIdToken = tokens.idToken
          state.refreshToken = tokens.refreshToken
        } else {
          // failure
          state.previousIdToken = ""
          state.refreshToken = ""
        }
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Presented Views
        
      case let .showAlert(alertType, message):
        switch alertType {
        case .connectFailed, .disconnectFailed, .unknownError:
          break
        case .remoteRxAudioFailed:
          state.remoteRxAudioEnabled = false
        case .smartlinkLoginFailed:
          state.smartlinkEnabled = false
        }
        state.showAlert = AlertState(title: TextState(alertType.rawValue), message: TextState(message))
        return .none
        
      case let .showClientSheet(selection, guiClients):
        state.showClient = ClientFeature.State(selection: selection, guiClients: guiClients)
        return .none
        
      case .showDirectSheet:
        state.showDirect = DirectFeature.State(ip: state.isGui ? state.directGuiIp : state.directNonGuiIp)
        return .none
        
      case let .showLogAlert(logEntry):
        state.showAlert = AlertState(title: TextState("\(logEntry.level == .warning ? "A Warning" : "An Error") was logged:"), message: TextState(logEntry.msg))
        return .none
        
      case .showLoginSheet:
        state.showLogin = LoginFeature.State(user: state.smartlinkUser)
        return .none
        
      case .showPickerSheet:
        state.showPicker = PickerFeature.State(isGui: state.isGui, defaultValue: state.isGui ? state.guiDefault : state.nonGuiDefault)
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
        state.directEnabled = false
        return .none
        
      case let .direct(.presented(.saveButtonTapped(ip))):
        // Direct is mutually exclusive of the other modes
        state.localEnabled = false
        state.smartlinkEnabled = false
        if state.isGui {
          state.directGuiIp = ip
        } else {
          state.directNonGuiIp = ip
        }
        return .none
        
      case .direct(_):
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Login Actions
        
      case .login(.presented(.cancelButtonTapped)):
        state.smartlinkEnabled = false
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
        if state.isGui {
          state.guiDefault = state.guiDefault == selection ? "" : selection
        } else {
          state.nonGuiDefault = state.nonGuiDefault == selection ? "" : selection
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
    if state.commandsIndex == state.commandsArray.count - 1{
      state.commandsIndex = 0
    } else {
      state.commandsIndex += 1
    }
    state.commandToSend = state.commandsArray[state.commandsIndex]
  }
  
  private func commandPrevious(_ state: inout State) {
    if state.commandsIndex == 0 {
      state.commandsIndex = state.commandsArray.count - 1
    } else {
      state.commandsIndex -= 1
    }
    state.commandToSend = state.commandsArray[state.commandsIndex]
  }
  
  private func commandSend(_ state: inout State) -> Effect<SDRApi.Action> {
    state.commandsArray.append(state.commandToSend)
    return .run { [state] in
      // send command to the radio
      await ObjectModel.shared.sendTcp(state.commandToSend)
      if state.clearOnSend { await $0(.clearSendTextButtonTapped)}
    }
  }
  
  private func connect(_ state: State, _ selection: String, _ disconnectHandle: UInt32?) -> Effect<SDRApi.Action> {
//    ListenerModel.shared.setActive(state.isGui, selection, state.directEnabled)
    return .run {
      var activePacket: Packet?
      var activeStation: String?
      if state.isGui {
        activePacket = await ListenerModel.shared.packets[id: selection]
        activeStation = "SDRApi"
      } else {
        activePacket = await ListenerModel.shared.stations[id: selection]?.packet
        activeStation = await ListenerModel.shared.stations[id: selection]?.station
      }

      // attempt to connect to the selected Radio / Station
      do {
        // try to connect
        try await ApiModel.shared.connect(packet: activePacket,
                                          station: activeStation,
                                          isGui: state.isGui,
                                          disconnectHandle: disconnectHandle,
                                          programName: "SDRApiViewer",
                                          mtuValue: state.mtuValue,
                                          lowBandwidthDax: state.lowBandwidthDax,
                                          lowBandwidthConnect: state.lowBandwidthConnect)
        await $0(.connectionStatus(.connected))
        
      } catch {
        // connection attempt failed
        await $0(.connectionStatus(.errorOnConnect))
      }
    }
  }
  
  
//  private func parseSelection(_ selection: String, state: State) -> (Packet, String) {
//    if state.directEnabled {
//      
//      let components = selection.components(separatedBy: "|")
//      let serial = components[0]
//      let publicIp = components[1]
//      
//      if state.isGui {
//       return ( Packet(nickname: "DIRECT", serial: serial, publicIp: publicIp, port: 4_992), "SDRApi")
//      } else {
//        fatalError()
//      }
//      
//    } else {
//      Task {
//        if state.isGui {
//          return ( await _listenerModel.packets[id: selection]!, "SDRApi" )
//        } else {
//          return ( await _listenerModel.stations[id: selection]!.packet, await _listenerModel.stations[id: selection]!.station )
//        }
//      }
//    }
//
//  }
  
  
  
  
  
  
  
  
  
  private func connectionStart(_ state: State)  -> Effect<SDRApi.Action> {
    if state.clearOnStart { Task { await MessagesModel.shared.clear() } }
    if state.directEnabled {
      // DIRECT Mode
      return .run {
        if state.isGui && !state.directGuiIp.isEmpty {
          let selection = "9999-9999-9999-9999" + state.directGuiIp
          await $0(.connect(selection, nil))
          
        } else if !state.directNonGuiIp.isEmpty {
          let selection = "9999-9999-9999-9999" + state.directNonGuiIp
          await $0(.connect(selection, nil))
          
        } else {
          // no Ip Address for the current connection type
          await $0(.showDirectSheet)
        }
      }
      
    } else {
      return .run {
        if state.useDefaultEnabled {
          // LOCAL/SMARTLINK mode connection using the Default, is there a valid? Default
          if await ListenerModel.shared.isValidDefault(for: state.guiDefault, state.nonGuiDefault, state.isGui) {
            // YES, valid default
            if state.isGui {
              await $0(.multiflexStatus(state.guiDefault))
            } else {
              await $0(.multiflexStatus(state.nonGuiDefault))
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
    if state.clearOnStop { Task { await MessagesModel.shared.clear() } }
    return .run {
      await ObjectModel.shared.clientInitialized(false)
      ApiModel.shared.disconnect()
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
    
    if state.connectionState == .connected && state.remoteRxAudioEnabled {
      return remoteRxAudioStart(&state)
    }
    
    if state.connectionState != .connected && state.remoteRxAudioEnabled {
      return remoteRxAudioStop(&state)
    }
    return .none
  }
  
  private func daxRxAudioStart(_ state: inout State, _ channel: Int) -> Effect<SDRApi.Action> {
    return .run { [state] _ in
      // request a stream
      if channel == 0 {
        ApiModel.shared.requestStream(.daxMicAudioStream, replyTo: daxRxReplyHandler)
      } else {
        ApiModel.shared.requestStream(.daxRxAudioStream, daxChannel: channel, isCompressed: state.lowBandwidthDax, replyTo: daxRxReplyHandler)
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
            
      // instantiate the Logger, use the group defaults (not the Standard)
      XCGWrapper.shared.setup(logLevel: .debug, group: "group.net.k3tzr.flexapps")

      // mark as initialized
      state.initialized = true
            
      return listenerStartStop(&state)
    }
    return .none
  }

  // start/stop listener, as needed
  private func listenerStartStop(_ state: inout State) -> Effect<SDRApi.Action> {
    // start/stop local mode
    ListenerModel.shared.localMode(state.localEnabled)
    
    // start smartlink mode?
    if state.smartlinkEnabled {
      
      if state.smartlinkLoginRequired || state.smartlinkUser.isEmpty {
        // YES but login required or no user
        state.previousIdToken = ""
        state.refreshToken = ""
        return .run {
          await $0(.showLoginSheet)
        }
        
      } else {
        // YES, try
        return .run { [state] in
          let tokens = await ListenerModel.shared.smartlinkMode(state.smartlinkUser,
                                                                state.smartlinkLoginRequired,
                                                                state.previousIdToken,
                                                                state.refreshToken)
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
      if state.isGui {
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
//    state.audioOutput = RxAudioPlayer()
    return .run { [state] _ in
      // request a stream
      ApiModel.shared.requestStream(.remoteRxAudioStream, isCompressed: state.remoteRxAudioCompressed, replyTo: remoteRxReplyHandler)
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
    // TODO
    return .none
  }
  
  private func remoteTxAudioStop(_ state: inout State)  -> Effect<SDRApi.Action> {
    // TODO
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
    state.smartlinkUser = user
    return .run {
      let tokens = await ListenerModel.shared.smartlinkStart(user, password)
      await $0(.saveTokens(tokens))
    }
  }
}
