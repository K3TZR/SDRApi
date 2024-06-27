//
//  MessagesView.swift
//  SDRApi/Subviews
//
//  Created by Douglas Adams on 1/28/24.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import SharedFeature

public enum MessageFilter: String, Codable, CaseIterable {
  case all
  case prefix
  case includes
  case excludes
  case command
  case status
  case reply
  case S0
}

// ----------------------------------------------------------------------------
// MARK: - View

struct MessagesView: View {
  var store: StoreOf<SDRApi>
  
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
        attString[range].foregroundColor = .yellow
        attString[range].font = .boldSystemFont(ofSize: CGFloat(store.fontSize + 4))
      }
    }
    return attString
  }
  
  @State var id: UUID?
  
  var body: some View {
    
    VStack(alignment: .leading) {
      FilterMessagesView(store: store)
      
      if MessagesModel.shared.filteredMessages.count == 0 {
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
          // NOTE: can't make the gotoBottom function work using List
          //
          //          List(MessagesModel.shared.filteredMessages.reversed(), id: \.id) { tcpMessage in
          //            HStack(alignment: .top) {
          //              if store.showTimes { Text(tcpMessage.interval, format: .number.precision(.fractionLength(6))) }
          //              Text(textLine(tcpMessage.text + "\(store.newLineBetweenMessages ? "\n" : "")"))
          //            }
          //            .listRowSeparator(.hidden)
          //            .textSelection(.enabled)
          //            .font(.system(size: CGFloat(store.fontSize), weight: .regular, design: .monospaced))
          //          }
          
          ScrollView([.vertical]) {
            LazyVStack(alignment: .leading) {
              ForEach(MessagesModel.shared.filteredMessages.reversed(), id: \.id) { tcpMessage in
                HStack(alignment: .top) {
                  if store.showTimes { Text(tcpMessage.interval, format: .number.precision(.fractionLength(6))) }
                  Text(textLine(tcpMessage.text + "\(store.newLineBetweenMessages ? "\n" : "")"))
                }
                .textSelection(.enabled)
                .font(.system(size: CGFloat(store.fontSize), weight: .regular, design: .monospaced))
              }
            }
          }
          .scrollPosition(id: $id)
          
          .onChange(of: store.gotoBottom) {
            if $1 {
              self.id = MessagesModel.shared.filteredMessages.first?.id
            } else {
              self.id = MessagesModel.shared.filteredMessages.last?.id
            }
          }
        }
        
        .onAppear{
          store.send(.onAppear)
        }
       
        .frame(minWidth: 1250, maxWidth: .infinity)
      }
    }
  }
}

private struct FilterMessagesView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  var body: some View {
    
    HStack {
      Picker("Show Tcp Messages of type", selection: $store.messageFilter) {
        ForEach(MessageFilter.allCases, id: \.self) {
          Text($0.rawValue).tag($0.rawValue)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .frame(width: 300)
      .onChange(of: store.messageFilter) { _, _ in
        store.send(.messagesFilterChanged)
      }

      
      Image(systemName: "x.circle").font(.title2)
        .onTapGesture {
          store.send(.clearFilterTextTapped)
        }
      
      TextField("filter text", text: $store.messageFilterText)
        .onChange(of: store.messageFilterText) { _, _ in
          store.send(.messagesFilterChanged)
        }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MessagesView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
  
  .frame(minWidth: 1250, maxWidth: .infinity)
}
