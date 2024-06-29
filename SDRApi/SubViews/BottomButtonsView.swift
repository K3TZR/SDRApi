//
//  BottomButtonsView.swift
//  SDRApi/Subviews
//
//  Created by Douglas Adams on 6/19/24.
//

import ComposableArchitecture
import SwiftUI

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

public struct BottomButtonsView: View {
  @Bindable var store: StoreOf<SDRApi>
  
  public var body: some View {
    
    HStack {
      Toggle(isOn: $store.appSettings.gotoBottom) {
        Image(systemName: "arrow.down.square").font(.title)
      }
      
      Spacer()
      
      HStack(spacing: 5) {
        Stepper("Font Size", value: $store.appSettings.fontSize, in: 8...14)
        Text(store.appSettings.fontSize, format: .number).frame(alignment: .leading)
      }
      Toggle("Line Spacing", isOn: $store.appSettings.newLineBetweenMessages)
      
      Spacer()
      HStack {
        Toggle("Show Times", isOn: $store.appSettings.showTimes)
        Toggle("Show Pings", isOn: $store.appSettings.showPings)
          .onChange(of: store.appSettings.showPings) { _, _ in
            store.send(.showPingsChanged)
          }

        Toggle("Show Alerts", isOn: $store.appSettings.alertOnError)
          .help("Display a sheet when an Error / Warning occurs")
      }
      
      Spacer()
      Button("Save") { store.send(.saveButtonTapped) }
      
      Spacer()
      HStack {
        Toggle("Clear on Start", isOn: $store.appSettings.clearOnStart)
        Toggle("Clear on Stop", isOn: $store.appSettings.clearOnStop)
      }
      
      Button("Clear") { store.send(.clearButtonTapped) }
    }
    .toggleStyle(.button)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  BottomButtonsView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
  
  .frame(minWidth: 1250, maxWidth: .infinity)
}
