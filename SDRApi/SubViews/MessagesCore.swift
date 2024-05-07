//
//  MessagesCore.swift
//  SDRApi
//
//  Created by Douglas Adams on 5/4/24.
//

import ComposableArchitecture
import Foundation

import SharedFeature
import TcpFeature
import XCGLogFeature

@Reducer
public struct MessagesCore {
  public init() {}
  
  @ObservableState
  public struct State {
    public init() {}
    
    @Shared(.appStorage("clearOnStart")) var clearOnStart = true
    @Shared(.appStorage("clearOnStop")) var clearOnStop = true
    @Shared(.appStorage("gotoTop")) var gotoTop = false
    @Shared(.appStorage("messageFilter")) var messageFilter: MessageFilter = .all
    @Shared(.appStorage("messageFilterText")) var messageFilterText = ""
    @Shared(.appStorage("showPings")) var showPings = false
    @Shared(.appStorage("showTimes")) var showTimes = true
    
    var newLineBetweenMessages = false
    var filteredMessages = IdentifiedArrayOf<TcpMessage>()
    var filter: MessageFilter = .all
    var filterText = ""
    var messages = IdentifiedArrayOf<TcpMessage>()
    var tcpMessageSubscription: Task<(), Never>?
    
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    
    case onAppear
    
    case clearButtonTapped
    case clearFilterTextTapped
    case saveButtonTapped
    
    case process(TcpMessage)
  }
  
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
        
      case .onAppear:
        return subscribeToTcpMessages(&state)
        
      case .clearButtonTapped:
        state.messages.removeAll()
        state.filteredMessages.removeAll()
        return .none
        
      case .clearFilterTextTapped:
        state.filterText = ""
        return .none
        
      case .saveButtonTapped:
        print("TODO: Save Button action")
        return .none
        
      case .binding(_):
        return .none
        
      case let .process(msg):
        return process(msg, &state)
      }
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private message processing methods
  
  private func subscribeToTcpMessages(_ state: inout State) -> Effect<MessagesCore.Action> {
    return .run { send in
      log("MessagesModel: TcpMessage subscription STARTED", .debug, #function, #file, #line)
      for await msg in Tcp.shared.testerStream {
        await send(.process(msg))
      }
    }
  }

  /// Process a TcpMessage
  /// - Parameter msg: a TcpMessage struct
  private func process(_ msg: TcpMessage, _ state: inout State) -> Effect<MessagesCore.Action> {
    
    // ignore routine replies (i.e. replies with no error or no attached data)
    func ignoreReply(_ text: String) -> Bool {
      if text.first != "R" { return false }     // not a Reply
      let parts = text.components(separatedBy: "|")
      if parts.count < 3 { return false }       // incomplete
      if parts[1] != kNoError { return false }  // error of some type
      if parts[2] != "" { return false }        // additional data present
      return true                               // otherwise, ignore it
    }

    // ignore received replies unless they are non-zero or contain additional data
    if msg.direction == .received && ignoreReply(msg.text) { return .none }
    // ignore sent "ping" messages unless showPings is true
    if msg.text.contains("ping") && state.showPings == false { return .none }
    // add it to the backing collection
    state.messages.append(msg)
    
    
    // add it to the published collection (if appropriate)
    switch (state.filter, state.filterText) {
      
    case (MessageFilter.all, _):        state.filteredMessages.append(msg)
    case (MessageFilter.prefix, ""):    state.filteredMessages.append(msg)
    case (MessageFilter.prefix, _):     if msg.text.localizedCaseInsensitiveContains("|" + state.filterText) { state.filteredMessages.append(msg) }
    case (MessageFilter.includes, _):   if msg.text.localizedCaseInsensitiveContains(state.filterText) { state.filteredMessages.append(msg) }
    case (MessageFilter.excludes, ""):  state.filteredMessages.append(msg)
    case (MessageFilter.excludes, _):   if !msg.text.localizedCaseInsensitiveContains(state.filterText) { state.filteredMessages.append(msg) }
    case (MessageFilter.command, _):    if msg.text.prefix(1) == "C" { state.filteredMessages.append(msg) }
    case (MessageFilter.S0, _):         if msg.text.prefix(3) == "S0|" { state.filteredMessages.append(msg) }
    case (MessageFilter.status, _):     if msg.text.prefix(1) == "S" && msg.text.prefix(3) != "S0|" { state.filteredMessages.append(msg) }
    case (MessageFilter.reply, _):      if msg.text.prefix(1) == "R" { state.filteredMessages.append(msg) }
    }
    return .none
  }
}

