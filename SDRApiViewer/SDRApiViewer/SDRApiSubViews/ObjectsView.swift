//
//  ObjectsView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 1/29/24.
//

import ComposableArchitecture
import SwiftUI

import SharedFeature

public struct ObjectsView: View {
  @Bindable var store: StoreOf<SDRApi>

  public init(store: StoreOf<SDRApi>) {
    self.store = store
  }
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      FilterObjectsView(store: store)
      
      if store.connectionState != .connected {
        VStack(alignment: .leading) {
          Spacer()
          HStack {
            Spacer()
            Text("API Objects will be displayed here")
            Spacer()
          }
          Spacer()
        }
        
      } else {
        ScrollView([.vertical]) {
          VStack(alignment: .leading) {
            RadioSubView()
            
            GuiClientSubView(store: store)

            if store.isGui == false {
              TesterSubView()
            }
          }
          .textSelection(.enabled)
          .font(.system(size: CGFloat(store.fontSize), weight: .regular, design: .monospaced))
          .padding(.horizontal, 10)
        }
      }
    }
  }
}
  
private struct FilterObjectsView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  var body: some View {

    HStack {
      Picker("Show Objects of type", selection: $store.objectFilter) {
        ForEach(ObjectFilter.allCases, id: \.self) {
          Text($0.rawValue).tag($0.rawValue)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .frame(width: 300)
    }
  }
}

#Preview {
  ObjectsView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
}
