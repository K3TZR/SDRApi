//
//  MessagesModel.swift
//
//  Created by Douglas Adams on 10/15/22.
//

import Foundation
import SwiftUI
import IdentifiedCollections

import Tcp
import SettingsModel
import SharedModel

@Observable
public final class MessagesModel {
  // ----------------------------------------------------------------------------
  // MARK: - Singleton
  
  public static var shared = MessagesModel()
  private init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var filteredMessages = IdentifiedArrayOf<TcpMessage>()

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _settingsModel = SettingsModel.shared
  
  
  private var _messages = IdentifiedArrayOf<TcpMessage>()
  private var _task: Task<(), Never>?
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
//  public func start() {
//    if clearOnStart { clearAll() }
//  }
  
//  public func stop() {
//    if clearOnStop { clearAll() }
//  }
  
  /// Clear all messages
  public func clearAll(_ enabled: Bool = true) {
    if enabled {
      self._messages.removeAll()
      Task { await removeAllFilteredMessages() }
    }
  }

  /// Set the messages filter parameters and re-filter
  public func reFilter(filter: MessageFilter) {
    _settingsModel.messageFilter = filter
    Task { await self.filterMessages() }
  }

  /// Set the messages filter parameters and re-filter
  public func reFilter(filterText: String) {
    _settingsModel.messageFilterText = filterText
    Task { await self.filterMessages() }
  }

  /// Begin to process TcpMessages
  public func start() {
    subscribeToTcpMessages()
    if _settingsModel.clearOnStart { clearAll() }
  }
  
  /// Stop processing TcpMessages
  public func stop() {
    _task = nil
    if _settingsModel.clearOnStop { clearAll() }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Rebuild the entire filteredMessages array
  @MainActor private func filterMessages() {
    // re-filter the entire messages array
    switch (_settingsModel.messageFilter, _settingsModel.messageFilterText) {

    case (MessageFilter.all, _):        filteredMessages = _messages
    case (MessageFilter.prefix, ""):    filteredMessages = _messages
    case (MessageFilter.prefix, _):     filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains("|" + _settingsModel.messageFilterText) }
    case (MessageFilter.includes, _):   filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains(_settingsModel.messageFilterText) }
    case (MessageFilter.excludes, ""):  filteredMessages = _messages
    case (MessageFilter.excludes, _):   filteredMessages = _messages.filter { !$0.text.localizedCaseInsensitiveContains(_settingsModel.messageFilterText) }
    case (MessageFilter.command, _):    filteredMessages = _messages.filter { $0.text.prefix(1) == "C" }
    case (MessageFilter.S0, _):         filteredMessages = _messages.filter { $0.text.prefix(3) == "S0|" }
    case (MessageFilter.status, _):     filteredMessages = _messages.filter { $0.text.prefix(1) == "S" && $0.text.prefix(3) != "S0|"}
    case (MessageFilter.reply, _):      filteredMessages = _messages.filter { $0.text.prefix(1) == "R" }
    }
  }
  
  @MainActor private func removeAllFilteredMessages() {
    self.filteredMessages.removeAll()
  }
}

extension MessagesModel {
  // ----------------------------------------------------------------------------
  // MARK: - Subscription methods

  private func subscribeToTcpMessages()  {
    _task = Task(priority: .high) {
      log("MessagesModel: TcpMessage subscription STARTED", .debug, #function, #file, #line)
      for await msg in Tcp.shared.testerStream {
        process(msg)
      }
      log("MessagesModel: : TcpMessage subscription STOPPED", .debug, #function, #file, #line)
    }
  }

  /// Process a TcpMessage
  /// - Parameter msg: a TcpMessage struct
  private func process(_ msg: TcpMessage) {

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
    if msg.direction == .received && ignoreReply(msg.text) { return }
    // ignore sent "ping" messages unless showPings is true
    if msg.text.contains("ping") && _settingsModel.showPings == false { return }
    // add it to the backing collection
    _messages.append(msg)
    Task {
      await MainActor.run {
        // add it to the published collection (if appropriate)
        switch (_settingsModel.messageFilter, _settingsModel.messageFilterText) {

        case (MessageFilter.all, _):        filteredMessages.append(msg)
        case (MessageFilter.prefix, ""):    filteredMessages.append(msg)
        case (MessageFilter.prefix, _):     if msg.text.localizedCaseInsensitiveContains("|" + _settingsModel.messageFilterText) { filteredMessages.append(msg) }
        case (MessageFilter.includes, _):   if msg.text.localizedCaseInsensitiveContains(_settingsModel.messageFilterText) { filteredMessages.append(msg) }
        case (MessageFilter.excludes, ""):  filteredMessages.append(msg)
        case (MessageFilter.excludes, _):   if !msg.text.localizedCaseInsensitiveContains(_settingsModel.messageFilterText) { filteredMessages.append(msg) }
        case (MessageFilter.command, _):    if msg.text.prefix(1) == "C" { filteredMessages.append(msg) }
        case (MessageFilter.S0, _):         if msg.text.prefix(3) == "S0|" { filteredMessages.append(msg) }
        case (MessageFilter.status, _):     if msg.text.prefix(1) == "S" && msg.text.prefix(3) != "S0|" { filteredMessages.append(msg) }
        case (MessageFilter.reply, _):      if msg.text.prefix(1) == "R" { filteredMessages.append(msg) }
        }
      }
    }
  }
}
