//
//  ObjectsView.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 1/29/24.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - View

public struct ObjectsView: View {
  @Bindable var store: StoreOf<SDRApi>

  public init(store: StoreOf<SDRApi>) {
    self.store = store
  }
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      HStack(spacing: 40) {
        FilterRadioObjectsView(store: store)
        FilterStationObjectsView(store: store)
      }
      
      if store.connectionState != .connected {
        VSplitView {
          VStack(alignment: .center) {
            Spacer()
            Text("RADIO Objects will be displayed here").frame(maxWidth: .infinity)
            Spacer()
          }
          VStack(alignment: .center) {
            Spacer()
            Text("STATION Objects will be displayed here").frame(maxWidth: .infinity)
            Spacer()
          }
          if store.appSettings.isGui == false { 
            VStack(alignment: .center) {
              Spacer()
              Text("SDRApi Objects will be displayed here").frame(maxWidth: .infinity)
              Spacer()
            }.frame(height: 50)
          }
        }
        
      } else {
        VSplitView {
          RadioSubView(store: store)
          GuiClientSubView(store: store)
          if store.appSettings.isGui == false { TesterSubView() }
        }
        .textSelection(.enabled)
        .font(.system(size: CGFloat(store.appSettings.fontSize), weight: .regular, design: .monospaced))
        .padding(.horizontal, 10)
      }
    }
  }
}
  
private struct FilterRadioObjectsView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  var body: some View {
    
    Picker("Show RADIO Objects of type", selection: $store.appSettings.radioObjectFilter) {
      ForEach(RadioObjectFilter.allCases, id: \.self) {
        Text($0.rawValue).tag($0.rawValue)
      }
    }
    .pickerStyle(MenuPickerStyle())
    .frame(width: 300)
  }
}

private struct FilterStationObjectsView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  var body: some View {
    
    Picker("Show STATION Objects of type", selection: $store.appSettings.stationObjectFilter) {
      ForEach(StationObjectFilter.allCases, id: \.self) {
        Text($0.rawValue).tag($0.rawValue)
      }
    }
    .pickerStyle(MenuPickerStyle())
    .frame(width: 300)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ObjectsView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
  
  .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
  .padding()
}
