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

// alert sub-actions
//public enum AlertType {
//  case connectFailed(String)
//  case disconnectFailed
//  case logAlert(String)
//  case remoteRxAudioFailed
//  case smartlinkLoginFailed
//  case unknownError
//}

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

  @Reducer
  public enum Destination {
    case clientItem(ClientFeature)
    case directItem(DirectFeature)
    case loginItem(LoginFeature)
    case pickerItem(PickerFeature)
  }

  // ----------------------------------------------------------------------------
  // MARK: - State
  
  @ObservableState
  public struct State {    
    // persistent
    @Shared(.appSettings) var appSettings: AppSettings

    // non-persistent
    var streamModel: StreamModel?
    var initialized = false
    var connectionState: ConnectionState = .disconnected
    
    @Presents var destination: Destination.State?
    @Presents var alert: AlertState<Action.Alert>?
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Actions
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    
    case alert(PresentationAction<Alert>)
    case destination(PresentationAction<Destination.Action>)
    
    case onAppear
    
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
    
    // secondary actions
    case multiflexStatus(String)
    case connect(String, UInt32?)
    case connectionStatus(ConnectionState)
    case saveTokens(Tokens)
    case showAlert(String, String)
    case showClientSheet(String, IdentifiedArrayOf<GuiClient>)
    case showDirectSheet
    case showLoginSheet
    case showPickerSheet
    
    
    public enum Alert {
      case logAlert
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
        
      case .onAppear:
        if state.initialized == false {
          // mark as initialized
          state.initialized = true
          return listenerStartStop(&state)
        }
        return .none

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
        
      case let .showAlert(title, message):
        state.alert = AlertState {
            TextState(title)
          } actions: {
            /* ButtonState(role: .destructive, action: .send(.doSomething)) {
             TextState("Do Something")
           }
             */
          } message: {
            TextState(message)
          }
        return .none
        
      case let .showClientSheet(selection, guiClients):
        state.destination = .clientItem(ClientFeature.State(selection: selection, guiClients: guiClients))
        return .none
        
      case .showDirectSheet:
        state.destination = .directItem(DirectFeature.State(ip: state.appSettings.isGui ? state.appSettings.directGuiIp : state.appSettings.directNonGuiIp))
        return .none
        
      case .showLoginSheet:
        state.destination = .loginItem(LoginFeature.State(user: state.appSettings.smartlinkUser))
        return .none
        
      case .showPickerSheet:
        state.destination = .pickerItem(PickerFeature.State(isGui: state.appSettings.isGui, defaultValue: state.appSettings.isGui ? state.appSettings.guiDefault : state.appSettings.nonGuiDefault))
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Alert Actions
      case .alert:
        return .none

        // ----------------------------------------------------------------------------
        // MARK: - Client actions
      case let .destination(.presented(.clientItem(.connect(selection, disconnectHandle)))):
        // connect in the chosen manner
        return .run { await $0(.connect(selection, disconnectHandle)) }

        // ----------------------------------------------------------------------------
        // MARK: - Direct actions
      case .destination(.presented(.directItem(.cancelButtonTapped))):
        state.appSettings.directEnabled = false
        return .none

      case let .destination(.presented(.directItem(.saveButtonTapped(ip)))):
        // Direct is mutually exclusive of the other modes
        state.appSettings.localEnabled = false
        state.appSettings.smartlinkEnabled = false
        if state.appSettings.isGui {
          state.appSettings.directGuiIp = ip
        } else {
          state.appSettings.directNonGuiIp = ip
        }
        return .none

        // ----------------------------------------------------------------------------
        // MARK: - Login actions
      case .destination(.presented(.loginItem(.cancelButtonTapped))):
        state.appSettings.smartlinkEnabled = false
        return .none

      case let .destination(.presented(.loginItem(.loginButtonTapped(user, password)))):
        // attempt to login to Smartlink
        return smartlinkUserLogin(&state, user, password)
        
        // ----------------------------------------------------------------------------
        // MARK: - Picker actions
      case let .destination(.presented(.pickerItem(.connectButtonTapped(selection)))):
        // check the status of the selection
        return .run {await $0(.multiflexStatus(selection)) }

      case let .destination(.presented(.pickerItem(.defaultButtonTapped(selection)))):
        if state.appSettings.isGui {
          state.appSettings.guiDefault = state.appSettings.guiDefault == selection ? "" : selection
        } else {
          state.appSettings.nonGuiDefault = state.appSettings.nonGuiDefault == selection ? "" : selection
        }
        return .none

      case .destination(.presented(.pickerItem(.testButtonTapped(_, _)))):
        // FIXME: add code
        return .none
        
        // ----------------------------------------------------------------------------
        // MARK: - Destination actions
      case .destination(_):
        // ignore remaining cases
        return .none
      }
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Sheet / Alert reducer integration
    
    .ifLet(\.$destination, action: \.destination)
    .ifLet(\.$alert, action: \.alert)
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
      await ObjectModel.shared.sendTcp(state.appSettings.commandToSend)
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
        try await ObjectModel.shared.connect(packet: activePacket,
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
      return .run { [state] in
        // DIRECT Mode
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
      return .run { [state] in
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
            // invalid default, open the Picker
            await $0(.showPickerSheet)
          }
        }
        else {
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
      await ObjectModel.shared.disconnect()
      await $0(.connectionStatus(.disconnected))
    }
  }
  
  private func connectionStatus(_ state: inout State, _ status: ConnectionState) -> Effect<SDRApi.Action> {
    switch status {
    case .connected:
      state.connectionState = .connected
      
    case .errorOnConnect:
      state.connectionState = .disconnected
      log.error("Connect FAILED")
      return .none

    case .disconnected:
      state.connectionState = .disconnected
      
    case .errorOnDisconnect:
      state.connectionState = .disconnected
      log.warning("Disconnect FAILED")
      return .none

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
    return .run { _ in
      var tuple: (command:String, reply:String)
      // request a stream
      if channel == 0 {
        tuple = await ObjectModel.shared.sendTcpAwaitReply("stream create type=dax_mic")
      } else {
        tuple = await ObjectModel.shared.sendTcpAwaitReply("stream create type=dax_rx dax_channel=\(channel)")
      }
      let components = tuple.reply.components(separatedBy: "|")
      if components.count >= 3 {
        if let streamId = components[2].streamId {
          await StreamModel.shared.daxRxAudioStreams[id: streamId]?.start(channel)
        }
      }
    }
  }

  private func daxRxAudioStop(_ state: inout State, _ channel: Int) -> Effect<SDRApi.Action> {
    return .run { _ in
      await StreamModel.shared.daxRxAudioStop(channel)
    }
  }

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
    return .run { _ in
      // request a stream
      let _ = await ObjectModel.shared.sendTcpAwaitReply("stream create type=remote_audio_rx compression=opus")
      await  StreamModel.shared.remoteRxAudioStream?.start()
    }
  }
  
  private func remoteRxAudioStop(_ state: inout State) -> Effect<SDRApi.Action> {
    return .run { _ in
      await StreamModel.shared.remoteRxAudioStop()
    }
  }
  
  private func remoteTxAudioStart(_ state: inout State)  -> Effect<SDRApi.Action> {
    return .run { _ in
      // request a stream
      let _ = await ObjectModel.shared.sendTcpAwaitReply("stream create type=remote_audio_tx compression=opus")
      await  ObjectModel.shared.remoteTxAudio?.start()
    }
  }

  private func remoteTxAudioStop(_ state: inout State)  -> Effect<SDRApi.Action> {
    return .run { _ in
      if let streamId = await ObjectModel.shared.remoteTxAudio?.stop() {
        await ObjectModel.shared.sendTcp("stream remove \(streamId.hex)")
      }
    }
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
