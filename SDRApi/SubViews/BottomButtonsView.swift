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
  BottomButtonsView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
  
  .frame(minWidth: 1250, maxWidth: .infinity)
}
