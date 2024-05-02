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
    
    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 5) {
      if let radio = objectModel.radio {
        if radio.atuPresent {
          DetailView(atu: objectModel.atu)
          
        } else {
          GridRow {
            Text("ATU          ")
              .monospaced()
              .foregroundColor(.yellow)

            Text("----- NONE -----").foregroundColor(.red)
          }
        }
      }
    }
  }
}

private struct DetailView: View {
  var atu: Atu
  
  var body: some View {
    GridRow {
      Text("ATU          ")
        .monospaced()
        .foregroundColor(.yellow)

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
  AtuSubView()
    .environment(ObjectModel.shared)
}
