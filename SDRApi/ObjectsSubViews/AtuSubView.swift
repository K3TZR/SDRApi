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
  var sourceColor: Color

  @Environment(ObjectModel.self) private var objectModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 5) {
      if let radio = objectModel.radio {
        if radio.atuPresent {
          DetailView(atu: objectModel.atu, sourceColor: sourceColor)
          
        } else {
          GridRow {
            Text("ATU".padRight(13))
              .monospaced()
              .foregroundColor(sourceColor)

            Text("----- NONE -----").foregroundColor(.red)
          }
        }
      }
    }
  }
}

private struct DetailView: View {
  var atu: Atu
  var sourceColor: Color

  var body: some View {
    GridRow {
      Text("ATU".padRight(13))
        .monospaced()
        .foregroundColor(sourceColor)

      HStack(spacing: 5){
        Text("Atu Enabled")
        Text(atu.enabled ? "Y" : "N").foregroundColor(atu.enabled ? .green : nil)
      }
      HStack(spacing: 5){
        Text("Memory enabled")
        Text(atu.memoriesEnabled ? "Y" : "N").foregroundColor(atu.memoriesEnabled ? .green : nil)
      }
      HStack(spacing: 5){
        Text("Using Memories")
        Text(atu.usingMemory ? "Y" : "N").foregroundColor(atu.usingMemory ? .green : nil)
      }
      HStack(spacing: 5){
        Text("Tune Status")
        Text(atu.status.rawValue).foregroundColor(.secondary)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AtuSubView(sourceColor: .blue)
    .environment(ObjectModel.shared)
}
