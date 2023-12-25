//
//  MessagesView.swift
//
//  Created by Douglas Adams on 1/8/22.
//

import SwiftUI

import SettingsModel
import SharedModel

// ----------------------------------------------------------------------------
// MARK: - View

public struct MessagesView: View {
  
  public init() {}
  
  @Environment(MessagesModel.self) var messagesModel
  @Environment(SettingsModel.self) var settingsModel

  @Namespace var topID
  @Namespace var bottomID
  
  func messageColor(_ text: String) -> Color {
    if text.prefix(1) == "C" { return Color(.systemGreen) }                         // Commands
    if text.prefix(1) == "R" && text.contains("|0|") { return Color(.systemGray) }  // Replies no error
    if text.prefix(1) == "R" && !text.contains("|0|") { return Color(.systemRed) }  // Replies w/error
    if text.prefix(2) == "S0" { return Color(.systemOrange) }                       // S0
    
    return Color(.textColor)
  }
  
  func intervalFormat(_ interval: Double) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 6
    formatter.positiveFormat = " * ##0.000000"
    return formatter.string(from: NSNumber(value: interval))!
  }
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      FilterMessagesView()
      
      ScrollViewReader { proxy in
        ScrollView([.vertical, .horizontal]) {
          VStack(alignment: .leading) {
            if messagesModel.filteredMessages.count == 0 {
              Text("TCP Messages will be displayed here")
            } else {
              Text("Top").hidden()
                .id(topID)
              ForEach(messagesModel.filteredMessages.reversed(), id: \.id) { message in
                HStack {
                  if settingsModel.showTimes { Text(intervalFormat(message.interval)) }
                  Text(message.text)
                }
                .foregroundColor( messageColor(message.text) )
              }
              Text("Bottom").hidden()
                .id(bottomID)
            }
          }
          .textSelection(.enabled)
          .font(.system(size: settingsModel.fontSize, weight: .regular, design: .monospaced))
          
          .onChange(of: settingsModel.gotoLast) {
            let id = $1 ? bottomID : topID
            proxy.scrollTo(id, anchor: $1 ? .bottomLeading : .topLeading)
          }
          .onChange(of: messagesModel.filteredMessages.count) {
            let id = settingsModel.gotoLast ? bottomID : topID
            proxy.scrollTo(id, anchor: settingsModel.gotoLast ? .bottomLeading : .topLeading)
          }
        }
      }
      Spacer()
      Divider()
        .frame(height: 3)
        .background(Color(.gray))
      BottomButtonsView()
    }
  }
}

private struct FilterMessagesView: View {
  
  @Environment(MessagesModel.self) var messagesModel
  @Environment(SettingsModel.self) var settingsModel

  var body: some View {
    @Bindable var bindableSettingsModel = settingsModel
    
    HStack {
      Picker("Show Tcp Messages of type", selection: $bindableSettingsModel.messageFilter) {
        ForEach(MessageFilter.allCases, id: \.self) {
          Text($0.rawValue).tag($0.rawValue)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .frame(width: 300)
      
      Image(systemName: "x.circle")
        .onTapGesture {
          settingsModel.messageFilterText = ""
        }
      
      TextField("filter text", text: $bindableSettingsModel.messageFilterText)
    }
    .onChange(of: settingsModel.messageFilter) {
      messagesModel.reFilter(filter: $1)
    }
    .onChange(of: settingsModel.messageFilterText) {
      messagesModel.reFilter(filterText: $1)
    }
  }
}

private struct BottomButtonsView: View {
  
//  @AppStorage("clearOnStart", store: DefaultValues.flexStore) var clearOnStart = false
//  @AppStorage("clearOnStop", store: DefaultValues.flexStore) var clearOnStop = false
//  @AppStorage("fontSize", store: DefaultValues.flexStore) var fontSize: Double = 12
//  @AppStorage("gotoLast", store: DefaultValues.flexStore) public var gotoLast = true

  @Environment(MessagesModel.self) var messagesModel
  @Environment(SettingsModel.self) var settingsModel

  var body: some View {
    @Bindable var bindableSettingsModel = settingsModel

    HStack {
      HStack {
        Text("Go to \(settingsModel.gotoLast ? "Last" : "First")")
        Image(systemName: settingsModel.gotoLast ? "arrow.up.square" : "arrow.down.square").font(.title)
          .onTapGesture { settingsModel.gotoLast.toggle() }
      }
      Spacer()
      
      HStack {
        Button("Save") { print("Save messages") }
      }
      Spacer()
      
      HStack(spacing: 30) {
        Toggle("Clear on Start", isOn: $bindableSettingsModel.clearOnStart)
        Toggle("Clear on Stop", isOn: $bindableSettingsModel.clearOnStop)
        Button("Clear Now") {  messagesModel.clearAll() }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MessagesView()
}
