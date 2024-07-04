//
//  MiscSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 10/20/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct MiscSubView: View {

  @Environment(ObjectModel.self) private var objectModel

  @MainActor func list(_ array: [String]) -> String {
    array.formatted(.list(type: .and)).replacingOccurrences(of: ", and ", with: ", ")
  }

  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 30) {
      GridRow {
        Text("Software Version").foregroundColor(.yellow)
        Text(objectModel.radio?.softwareVersion ?? "---").foregroundColor(.secondary)
      }
      GridRow {
        Text("Hardware Version").foregroundColor(.yellow)
        Text(objectModel.hardwareVersion ?? "---").foregroundColor(.secondary)
      }
      GridRow {
        Text("Antenna List").foregroundColor(.yellow)
        Text(list(objectModel.radio?.antList ?? [])).foregroundColor(.secondary)
      }
      GridRow {
        Text("Microphone List").foregroundColor(.yellow)
        Text(list(objectModel.radio?.micList ?? [])).foregroundColor(.secondary)
      }
      GridRow {
        Text("Radio Uptime").foregroundColor(.yellow)
        Text(objectModel.radio?.uptime ?? 0, format: .number).foregroundColor(.secondary)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MiscSubView()
    
    .environment(ObjectModel.shared)
  
    .frame(width: 1250)
}
