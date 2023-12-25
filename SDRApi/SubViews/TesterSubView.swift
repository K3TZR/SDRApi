//
//  TesterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/25/22.
//


import SwiftUI

import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct TesterSubView: View {
  
  @Environment(ApiModel.self) private var api
  
  var body: some View {
    if api.radio != nil {
      VStack(alignment: .leading) {
        Divider().background(Color(.green))
        HStack(spacing: 10) {
          
          Text("SDRApi").foregroundColor(.green)
            .font(.title)
          
          HStack(spacing: 5) {
            Text("Bound to Station")
            Text("\(api.activeStation ?? "none")").foregroundColor(.secondary)
          }
          TesterRadioViewView() }
      }
    }
  }
}

struct TesterRadioViewView: View {

  @Environment(ApiModel.self) private var api

  var body: some View {
      HStack(spacing: 5) {
        Text("Handle")
        Text(api.connectionHandle?.hex ?? "").foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Client Id")
        Text("\(api.boundClientId ?? "none")").foregroundColor(.secondary)
      }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TesterSubView()
    .environment(ApiModel.shared)
}
