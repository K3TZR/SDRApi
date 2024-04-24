//
//  AtuSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct AtuSubView: View {
  
  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        if let radio = objectModel.radio {
          if radio.atuPresent {
            Group {
              Text("ATU")
              HStack(spacing: 5) {
                Text("Enabled")
                Text(objectModel.atu.enabled ? "Y" : "N").foregroundColor(objectModel.atu.enabled ? .green : .red)
              }
              HStack(spacing: 5) {
                Text("Mem enabled")
                Text(objectModel.atu.memoriesEnabled ? "Y" : "N").foregroundColor(objectModel.atu.memoriesEnabled ? .green : .red)
              }
              HStack(spacing: 5) {
                Text("Using Mem")
                Text(objectModel.atu.usingMemory ? "Y" : "N").foregroundColor(objectModel.atu.usingMemory ? .green : .red)
              }
            }
            .frame(width: 100, alignment: .leading)
            HStack(spacing: 5) {
              Text("Status")
              Text(objectModel.atu.status.rawValue).foregroundColor(.green)
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
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AtuSubView()
    .environment(ObjectModel.shared)
}
