//
//  MessagesView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 1/28/24.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import SharedFeature
//import TcpFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct MessagesView: View {
  var store: StoreOf<SDRApi>
  
  @Environment(MessagesModel.self) var messagesModel
  
  @Namespace var topID
  @Namespace var bottomID
  
  @MainActor func textLine( _ text: String) -> AttributedString {
    var attString = AttributedString(text)
    // color it appropriately
    if text.prefix(1) == "C" { attString.foregroundColor = .systemGreen }                        // Commands
    if text.prefix(1) == "R" && text.contains("|0|") { attString.foregroundColor = .systemGray } // Replies no error
    if text.prefix(1) == "R" && !text.contains("|0|") { attString.foregroundColor = .systemRed } // Replies w/error
    if text.prefix(2) == "S0" { attString.foregroundColor = .systemOrange }                      // S0
    
    // highlight any filterText value
    if !store.messageFilterText.isEmpty {
      if let range = attString.range(of: store.messageFilterText) {
        attString[range].underlineStyle = .single
        attString[range].font = .boldSystemFont(ofSize: 18)
      }
    }
    return attString
  }
  
  var body: some View {
    
    VStack(alignment: .leading) {
      FilterMessagesView(store: store)
      
      if store.connectionState != .connected {
        VStack(alignment: .leading) {
          Spacer()
          HStack {
            Spacer()
            Text("TCP Messages will be displayed here")
            Spacer()
          }
          Spacer()
        }
      } else {
        VStack {
          ScrollView([.vertical]) {
            LazyVStack(alignment: .leading) {
              ForEach(messagesModel.filteredMessages.reversed(), id: \.id) { tcpMessage in
                HStack(alignment: .top) {
                  if store.showTimes { Text(tcpMessage.interval, format: .number.precision(.fractionLength(6))) }
                  Text(textLine(tcpMessage.text + "\(store.newLineBetweenMessages ? "\n" : "")"))
                }
                .textSelection(.enabled)
                .font(.system(size: CGFloat(store.fontSize), weight: .regular, design: .monospaced))
              }
            }
          }
          
          Spacer()
          Divider().background(Color(.gray))
          BottomButtonsView(store: store)
        }
      }
    }
    .onAppear{
      store.send(.onAppear)
    }
    .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
  }
}

private struct FilterMessagesView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  @State var messageFilterText = ""
  
  var body: some View {
    
    HStack {
      Picker("Show Tcp Messages of type", selection: $store.messageFilter) {
        ForEach(MessageFilter.allCases, id: \.self) {
          Text($0.rawValue).tag($0.rawValue)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .frame(width: 300)
      
      Image(systemName: "x.circle").font(.title2)
        .onTapGesture {
          store.send(.clearFilterTextTapped)
        }
      TextField("filter text", text: $messageFilterText)
    }
  }
}

private struct BottomButtonsView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  var body: some View {
    
    HStack {
      Toggle(isOn: $store.gotoBottom) {
        Image(systemName: "arrow.down.square").font(.title)
      }
      
      Spacer()
      
      HStack(spacing: 5) {
        Stepper("Font Size", value: $store.fontSize, in: 8...14)
        Text(store.fontSize, format: .number).frame(alignment: .leading)
      }
      Toggle("Line Spacing", isOn: $store.newLineBetweenMessages)
      
      Spacer()
      HStack {
        Toggle("Show Times", isOn: $store.showTimes)
        Toggle("Show Pings", isOn: $store.showPings)
        Toggle("Show Alerts", isOn: $store.alertOnError)
          .help("Display a sheet when an Error / Warning occurs")
      }
      
      Spacer()
      Button("Save") { store.send(.saveButtonTapped) }
      
      Spacer()
      HStack {
        Toggle("Clear on Start", isOn: $store.clearOnStart)
        Toggle("Clear on Stop", isOn: $store.clearOnStop)
      }
      
      Button("Clear") { store.send(.clearButtonTapped) }
    }
    .toggleStyle(.button)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MessagesView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
  //  .environment(MessagesModel.shared)
  
  .frame(minWidth: 1250, maxWidth: .infinity)
}
