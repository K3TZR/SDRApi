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
    // persistent
    @Shared(.appStorage("alertOnError")) var alertOnError = false
    @Shared(.appStorage("clearOnSend")) var clearOnSend = false
    @Shared(.appStorage("clearOnStart")) var clearOnStart = true
    @Shared(.appStorage("clearOnStop")) var clearOnStop = true
    @Shared(.appStorage("commandToSend")) var commandToSend = ""
    @Shared(.appStorage("commandsArray")) var commandsArray = [String]()
    @Shared(.appStorage("commandsIndex")) var commandsIndex = 0
    @Shared(.appStorage("directEnabled")) var directEnabled = false
    @Shared(.appStorage("directGuiIp")) var directGuiIp = ""
    @Shared(.appStorage("directNonGuiIp")) var directNonGuiIp = ""
    @Shared(.appStorage("fontSize")) var fontSize = 12
    @Shared(.appStorage("gotoTop")) var gotoTop = false
    @Shared(.appStorage("guiDefault")) var guiDefault: String? = nil
    @Shared(.appStorage("isGui")) var isGui = true
    @Shared(.appStorage("localEnabled")) var localEnabled = true
    @Shared(.appStorage("lowBandwidthDax")) var lowBandwidthDax = false
    @Shared(.appStorage("messageFilter")) var messageFilter: MessageFilter = .all
    @Shared(.appStorage("messageFilterText")) var messageFilterText = ""
    @Shared(.appStorage("mtuValue")) var mtuValue = 1_300
    @Shared(.appStorage("nonGuiDefault")) var nonGuiDefault: String? = nil
    @Shared(.appStorage("objectFilter")) var objectFilter: ObjectFilter = .coreNoMeters
    @Shared(.appStorage("previousCommand")) var previousCommand = ""
    @Shared(.appStorage("previousIdToken")) var previousIdToken: String? = nil
    @Shared(.appStorage("refreshToken")) var refreshToken: String? = nil
    @Shared(.appStorage("remoteRxAudioCompressed")) var remoteRxAudioCompressed = true
    @Shared(.appStorage("remoteRxAudioEnabled")) var remoteRxAudioEnabled = false
    @Shared(.appStorage("remoteTxAudioEnabled")) var remoteTxAudioEnabled = false
    @Shared(.appStorage("showPings")) var showPings = false
    @Shared(.appStorage("showTimes")) var showTimes = true
    @Shared(.appStorage("smartlinkEnabled")) var smartlinkEnabled = false
    @Shared(.appStorage("smartlinkLoginRequired")) var smartlinkLoginRequired = false
    @Shared(.appStorage("smartlinkUser")) var smartlinkUser = ""
    @Shared(.appStorage("station")) var station = "SDRApi"
    @Shared(.appStorage("useDefaultEnabled")) var useDefaultEnabled = false
    
    // non-persistent
    var initialized = false
    var connectionState: ConnectionState = .disconnected
    var audioOutput: RxAudioPlayer?
    var newLineBetweenMessages = false

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
        if state.remoteTxAudioEnabled {
          return remoteTxAudioStart(&state)
        } else {
          return remoteTxAudioStop(&state)
        }

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
      await ApiModel.shared.requestStream(.remoteRxAudioStream, isCompressed: state.remoteRxAudioCompressed, replyTo: state.audioOutput!.streamReplyHandler)
      log("SdrApiCore: remote rx audio stream REQUESTED", .debug, #function, #file, #line)
    }
  }

  private func remoteRxAudioStop(_ state: inout State) -> Effect<SDRApi.Action> {
    if state.audioOutput != nil, let streamId = state.audioOutput!.streamId {
      state.audioOutput!.stop()
      state.audioOutput = nil
      return .run { [streamId] _ in
        // remove stream(s)
        await StreamModel.shared.sendRemoveStreams([streamId])
        log("SdrApiCore: remote rx audiostream STOPPED", .debug, #function, #file, #line)
      }
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
