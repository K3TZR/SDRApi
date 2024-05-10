//
//  TesterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/25/22.
//

import ComposableArchitecture
import SwiftUI

import ListenerFeature
import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct TesterSubView: View {
  
  @Environment(ApiModel.self) private var apiModel
  @Environment(ListenerModel.self) private var listenerModel
  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    if objectModel.radio != nil {
      VStack(alignment: .leading) {
//        Divider().background(Color(.green))
        HStack(spacing: 10) {
          
          Text("SDRApi").foregroundColor(.green)
            .font(.title)
          
          HStack(spacing: 5) {
            Text("Bound to Station")
            Text("\(listenerModel.activeStation ?? "none")").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Handle")
            Text(apiModel.connectionHandle?.hex ?? "").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Client Id")
            Text("\(objectModel.boundClientId ?? "none")").foregroundColor(.secondary)
          }
        }
      }.frame(maxWidth: .infinity, minHeight: 50)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TesterSubView()
    .environment(ApiModel.shared)
    .environment(ListenerModel.shared)
}
