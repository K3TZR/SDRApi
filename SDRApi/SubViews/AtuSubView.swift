//
//  AtuSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import FlexApi
import SharedModel

// ----------------------------------------------------------------------------
// MARK: - View

struct AtuSubView: View {

  @Environment(ApiModel.self) private var api

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        if api.atuPresent {
          Group {
            Text("ATU")
            HStack(spacing: 5) {
              Text("Enabled")
              Text(api.atu.enabled ? "Y" : "N").foregroundColor(api.atu.enabled ? .green : .red)
            }
            HStack(spacing: 5) {
              Text("Mem enabled")
              Text(api.atu.memoriesEnabled ? "Y" : "N").foregroundColor(api.atu.memoriesEnabled ? .green : .red)
            }
            HStack(spacing: 5) {
              Text("Using Mem")
              Text(api.atu.usingMemory ? "Y" : "N").foregroundColor(api.atu.usingMemory ? .green : .red)
            }
          }
          .frame(width: 100, alignment: .leading)
          HStack(spacing: 5) {
            Text("Status")
            Text(api.atu.status.rawValue).foregroundColor(.green)
          }
        } else {
          Group {
            Text("ATU")
            Text("Not installed").foregroundColor(.red)
          }
          .frame(width: 100, alignment: .leading)
        }
      }
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AtuSubView()
    .environment(ApiModel.shared)
}
