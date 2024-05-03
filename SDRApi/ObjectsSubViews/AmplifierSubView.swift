//
//  AmplifierSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/24/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct AmplifierSubView: View {
  
  @Environment(ObjectModel.self) private var objectModel
  
  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 5) {
      if objectModel.amplifiers.count > 0 {
        HeadingView()
        ForEach(objectModel.amplifiers) { amplifier in
          DetailView(amplifier: amplifier)
        }
        
      } else {
        GridRow {
          Text("AMPLIFIER".padRight(13))
            .monospaced()
            .foregroundColor(.yellow)
          
          Text("----- NONE PRESENT -----").foregroundColor(.red)
        }
      }
    }
  }
}

private struct HeadingView: View {
  
  var body: some View {
    GridRow {
      Text("AMPLIFIER".padRight(13))
        .monospaced()
        .foregroundColor(.yellow)
      
      Text("ID")
      Text("Model")
      Text("Address")
      Text("Port")
      Text("State")
    }
  }
}

private struct DetailView: View {
  var amplifier: Amplifier
  
  var body: some View {
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(amplifier.id.hex)
      Text(amplifier.model)
      Text(amplifier.ip)
      Text("\(amplifier.port)")
      Text(amplifier.state)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  AmplifierSubView()
    .environment(ObjectModel.shared)
}
