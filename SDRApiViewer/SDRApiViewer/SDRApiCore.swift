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
import PickerFeature
import RxAudioFeature
import SharedFeature
import XCGLogFeature

@Reducer
public struct SDRApi {
  
  public init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - State
  
  @ObservableState
  public struct State {
    let AppDefaults = UserDefaults.standard
    
    // persistent
    var alertOnError = true                         {didSet { AppDefaults.set(alertOnError, forKey: "alertOnError")}}
    var clearOnSend = false                         {didSet { AppDefaults.set(clearOnSend, forKey: "clearOnSend")}}
    var clearOnStart = true                         {didSet { AppDefaults.set(clearOnStart, forKey: "clearOnStart")}}
    var clearOnStop = false                         {didSet { AppDefaults.set(clearOnStop, forKey: "clearOnStop")}}
    var commandToSend = ""                          {didSet { AppDefaults.set(commandToSend, forKey: "commandToSend")}}
    var commandsArray = [String]()                  {didSet { AppDefaults.set(commandsArray, forKey: "commandsArray")}}
    var commandsIndex = 0                           {didSet { AppDefaults.set(commandsIndex, forKey: "commandsIndex")}}
    var directEnabled = false                       {didSet { AppDefaults.set(directEnabled, forKey: "directEnabled")}}
    var directGuiIp = ""                            {didSet { AppDefaults.set(directGuiIp, forKey: "directGuiIp")}}
    var directNonGuiIp = ""                         {didSet { AppDefaults.set(directNonGuiIp, forKey: "directNonGuiIp")}}
    var fontSize = 12                               {didSet { AppDefaults.set(fontSize, forKey: "fontSize")}}
    var gotoTop = false                             {didSet { AppDefaults.set(gotoTop, forKey: "gotoTop")}}
    var guiDefault: String?                         {didSet { AppDefaults.set(guiDefault, forKey: "guiDefault")}}
    var isGui = true                                {didSet { AppDefaults.set(isGui, forKey: "isGui")}}
    var localEnabled = true                         {didSet { AppDefaults.set(localEnabled, forKey: "localEnabled")}}
    var lowBandwidthDax = false                     {didSet { AppDefaults.set(lowBandwidthDax, forKey: "lowBandwidthDax")}}
    var messageFilter: MessageFilter = .all         {didSet { AppDefaults.set(messageFilter.rawValue, forKey: "messageFilter")}}
    var messageFilterText = ""                      {didSet { AppDefaults.set(messageFilterText, forKey: "messageFilterText")}}
    var mtuValue = 1_300                            {didSet { AppDefaults.set(mtuValue, forKey: "mtuValue")}}
    var nonGuiDefault: String?                      {didSet { AppDefaults.set(nonGuiDefault, forKey: "nonGuiDefault")}}
    var objectFilter: ObjectFilter = .coreNoMeters  {didSet { AppDefaults.set(objectFilter.rawValue, forKey: "objectFilter")}}
    var previousCommand = ""                        {didSet { AppDefaults.set(previousCommand, forKey: "previousCommand")}}
    var previousIdToken: String?                    {didSet { AppDefaults.set(previousIdToken, forKey: "previousIdToken")}}
    var refreshToken: String?                       {didSet { AppDefaults.set(refreshToken, forKey: "refreshToken")}}
    var remoteRxAudioCompressed = true              {didSet { AppDefaults.set(remoteRxAudioCompressed, forKey: "remoteRxAudioCompressed")}}
    var remoteRxAudioEnabled = false                {didSet { AppDefaults.set(remoteRxAudioEnabled, forKey: "remoteRxAudioEnabled")}}
    var remoteTxAudioEnabled = false                {didSet { AppDefaults.set(remoteTxAudioEnabled, forKey: "remoteTxAudioEnabled")}}
    var showPings = false                           {didSet { AppDefaults.set(showPings, forKey: "showPings")}}
    var showTimes = true                            {didSet { AppDefaults.set(showTimes, forKey: "showTimes")}}
    var smartlinkEnabled = false                    {didSet { AppDefaults.set(smartlinkEnabled, forKey: "smartlinkEnabled")}}
    var smartlinkLoginRequired = false              {didSet { AppDefaults.set(smartlinkLoginRequired, forKey: "smartlinkLoginRequired")}}
    var smartlinkUser = ""                          {didSet { AppDefaults.set(smartlinkUser, forKey: "smartlinkUser")}}
    var station = "SDRApi"                          {didSet { AppDefaults.set(station, forKey: "station")}}
    var useDefaultEnabled = false                   {didSet { AppDefaults.set(useDefaultEnabled, forKey: "useDefaultEnabled")}}
    
    // non-persistent
    var initialized = false
    var connectionState: ConnectionState = .disconnected
    var audioOutput: RxAudioPlayer?

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
    case saveButtonTapped
    case sendButtonTapped

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
        return .merge(
          initState(&state),
          subscribeToLogAlerts()
        )
        
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
        
      case .sendButtonTapped:
        // send a command to the radio
        return commandSend(&state)
        
      case .clearButtonTapped:
        MessagesModel.shared.clearAll()
        return .none
        
      case .clearFilterTextTapped:
        state.messageFilterText = ""
        MessagesModel.shared.reFilter(filterText: state.messageFilterText)
        return .none

      case .saveButtonTapped:
        return saveMessages()

        // ----------------------------------------------------------------------------
        // MARK: - Root Binding Actions
        
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
        MessagesModel.shared.reFilter(filter: state.messageFilter)
        return .none
        
      case .binding(\.messageFilterText):
        MessagesModel.shared.reFilter(filterText: state.messageFilterText)
        return .none
        
      case .binding(\.remoteRxAudioEnabled):
        if state.remoteRxAudioEnabled {
          return remoteRxAudioStart(&state)
        } else {
          return remoteRxAudioStop(&state)
        }
        
      case .binding(\.remoteTxAudioEnabled):
        return remoteTxAudioStartStop(state)
        
      case .binding(\.showPings):
        MessagesModel.shared.showPings = state.showPings
        return .none

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
        if tokens.idToken != nil {
          // success
          state.previousIdToken = tokens.idToken
          state.refreshToken = tokens.refreshToken
        } else {
          // failure
          state.previousIdToken = nil
          state.refreshToken = nil
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
          state.guiDefault = state.guiDefault == selection ? nil : selection
        } else {
          state.nonGuiDefault = state.nonGuiDefault == selection ? nil : selection
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
      await ApiModel.shared.sendCommand(state.commandToSend)
      if state.clearOnSend { await $0(.clearSendTextButtonTapped)}
    }
  }
  
  private func connect(_ state: State, _ selection: String, _ disconnectHandle: UInt32?) -> Effect<SDRApi.Action> {
    ListenerModel.shared.setActive(state.isGui, selection, state.directEnabled)
    return .run {
      // attempt to connect to the selected Radio / Station
      do {
        // try to connect
        try await ApiModel.shared.connect(selection: selection,
                                          isGui: state.isGui,
                                          disconnectHandle: disconnectHandle,
                                          programName: "SDRApiViewer",
                                          mtuValue: state.mtuValue,
                                          lowBandwidthDax: state.lowBandwidthDax)
        await $0(.connectionStatus(.connected))
        
      } catch {
        // connection attempt failed
        await $0(.connectionStatus(.errorOnConnect))
      }
    }
  }
  
  private func connectionStart(_ state: State)  -> Effect<SDRApi.Action> {
    MessagesModel.shared.start(state.clearOnStart)
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
          if ListenerModel.shared.isValidDefault(for: state.guiDefault, state.nonGuiDefault, state.isGui) {
            // YES, valid default
            if state.isGui {
              await $0(.multiflexStatus(state.guiDefault!))
            } else {
              await $0(.multiflexStatus(state.nonGuiDefault!))
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
    MessagesModel.shared.stop(state.clearOnStop)
    return .run {
      await ApiModel.shared.disconnect()
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
  
  private func initState(_ state: inout State) -> Effect<SDRApi.Action> {
    if state.initialized == false {
            
      state.alertOnError = UserDefaults.standard.bool(forKey: "alertOnError")
      state.clearOnSend = UserDefaults.standard.bool(forKey: "clearOnSend")
      state.clearOnStart = UserDefaults.standard.bool(forKey: "clearOnStart")
      state.clearOnStop = UserDefaults.standard.bool(forKey: "clearOnStop")
      state.commandToSend = UserDefaults.standard.string(forKey: "commandToSend") ?? ""
      state.commandsArray = UserDefaults.standard.object(forKey: "commandsArray") as? [String] ?? [String]()
      state.commandsIndex = UserDefaults.standard.integer(forKey: "commandsIndex")
      state.fontSize = UserDefaults.standard.integer(forKey: "fontSize")
      state.gotoTop = UserDefaults.standard.bool(forKey: "gotoTop")
      state.guiDefault = UserDefaults.standard.string(forKey: "guiDefault") ?? nil
      state.isGui = UserDefaults.standard.bool(forKey: "isGui")
      state.directEnabled = UserDefaults.standard.bool(forKey: "directEnabled")
      state.directGuiIp = UserDefaults.standard.string(forKey: "directGuiIp") ?? ""
      state.directNonGuiIp = UserDefaults.standard.string(forKey: "directNonGuiIp") ?? ""
      state.localEnabled = UserDefaults.standard.bool(forKey: "localEnabled")
      state.lowBandwidthDax = UserDefaults.standard.bool(forKey: "lowBandwidthDax")
      state.messageFilter = MessageFilter(rawValue: UserDefaults.standard.string(forKey: "messageFilter") ?? "all") ?? .all
      state.messageFilterText = UserDefaults.standard.string(forKey: "messageFilterText") ?? ""
      state.mtuValue = UserDefaults.standard.integer(forKey: "mtuValue")
      state.nonGuiDefault = UserDefaults.standard.string(forKey: "nonGuiDefault") ?? nil
      state.objectFilter = ObjectFilter(rawValue: UserDefaults.standard.string(forKey: "objectFilter") ?? "coreNoMeters") ?? .coreNoMeters
      state.previousCommand = UserDefaults.standard.string(forKey: "previousCommand") ?? ""
      state.previousIdToken = UserDefaults.standard.string(forKey: "previousIdToken")
      state.refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
      state.remoteRxAudioCompressed = UserDefaults.standard.bool(forKey: "remoteRxAudioCompressed")
      state.remoteRxAudioEnabled = UserDefaults.standard.bool(forKey: "remoteRxAudioEnabled")
      state.remoteTxAudioEnabled = UserDefaults.standard.bool(forKey: "remoteTxAudioEnabled")
      state.showPings = UserDefaults.standard.bool(forKey: "showPings")
      state.showTimes = UserDefaults.standard.bool(forKey: "showTimes")
      state.smartlinkEnabled = UserDefaults.standard.bool(forKey: "smartlinkEnabled")
      state.smartlinkLoginRequired = UserDefaults.standard.bool(forKey: "smartlinkLoginRequired")
      state.smartlinkUser = UserDefaults.standard.string(forKey: "smartlinkUser") ?? ""
      state.useDefaultEnabled = UserDefaults.standard.bool(forKey: "useDefaultEnabled")
      
      // instantiate the Logger, use the group defaults (not the Standard)
      _ = XCGWrapper(logLevel: .debug, group: "group.net.k3tzr.flexapps")
      
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
        state.previousIdToken = nil
        state.refreshToken = nil
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
      ListenerModel.shared.removePackets(condition: {$0.source == .smartlink})
      return .none
    }
  }
  
  private func multiflexStatus(_ state: State, _ selection: String) -> Effect<SDRApi.Action> {
    return .run {
      if state.isGui {
        // GUI selection
        if let selectedPacket = ListenerModel.shared.packets[id: selection] {
          
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
    state.audioOutput = RxAudioPlayer()
    return .run { [state] _ in
      // request a stream, reply to handler
      await ApiModel.shared.requestRemoteRxAudioStream(isCompressed: state.remoteRxAudioCompressed, replyTo: state.audioOutput!.streamReplyHandler)
      log("SdrApiCore: remote rx audio stream REQUESTED", .debug, #function, #file, #line)
    }
  }

  private func remoteRxAudioStop(_ state: inout State) -> Effect<SDRApi.Action> {
    if state.audioOutput != nil, let streamId = state.audioOutput!.streamId {
      state.audioOutput!.stop()
      state.audioOutput = nil
      return .run { [streamId] _ in
        // remove stream(s)
        await ApiModel.shared.sendRemoveStreams([streamId])
        log("SdrApiCore: remote rx audiostream STOPPED", .debug, #function, #file, #line)
      }
    }
    return .none
  }
  
  private func remoteTxAudioStartStop(_ state: State)  -> Effect<SDRApi.Action> {
    // TODO
    return .none
  }
  
  private func saveMessages() -> Effect<SDRApi.Action> {
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
        
        let textArray = MessagesModel.shared.filteredMessages.map { formatter.string(from: NSNumber(value: $0.interval))! + " " + $0.text }
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
  
  private func subscribeToLogAlerts() ->  Effect<SDRApi.Action>  {
    return .run {
      for await logEntry in logAlerts {
        // a Warning or Error has been logged.
        await $0(.showLogAlert(logEntry))
      }
    }
  }
}
