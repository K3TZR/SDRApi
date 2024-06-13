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
      if objectModel.radio?.atuPresent != nil {
        DetailView(atu: objectModel.atu, sourceColor: sourceColor)
        
      } else {
        GridRow {
          Text("ATU")
            .frame(width: 100, alignment: .leading)
            .foregroundColor(sourceColor)
          
          Text("----- NONE -----").foregroundColor(.red)
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
      Text("ATU")
        .frame(width: 100, alignment: .leading)
        .foregroundColor(sourceColor)

      Toggle("Atu Enabled", isOn: Binding(get: {atu.enabled}, set: {atu.setProperty(.enabled, $0.as1or0)} ))

      Toggle("Memories Enabled", isOn: Binding(get: {atu.memoriesEnabled}, set: {atu.setProperty(.memoriesEnabled, $0.as1or0)} ))

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
  
    .frame(width: 1250)
}
