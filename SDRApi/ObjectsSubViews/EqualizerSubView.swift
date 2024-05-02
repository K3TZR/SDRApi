//
//  EqualizerSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/8/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct EqualizerSubView: View {

  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 5) {
      HeadingView()
      ForEach(objectModel.equalizers) { eq in
        DetailView(eq: eq)
      }
    }
  }
}

private struct HeadingView: View {
  
  var body: some View {
    GridRow {
      Text("EQUALIZER    ")
        .monospaced()
        .gridColumnAlignment(.leading)
        .foregroundColor(.yellow)
      Text("ID").gridColumnAlignment(.leading)
      Text("Enabled")
      Text("63 Hz")
      Text("125 Hz")
      Text("250 Hz")
      Text("500 Hz")
      Text("1000 Hz")
      Text("2000 Hz")
      Text("4000 Hz")
      Text("8000 Hz")
    }
  }
}

private struct DetailView: View {
  var eq: Equalizer
  
  var body: some View {
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(eq.id).gridColumnAlignment(.leading)
      Text(eq.eqEnabled ? "Y" : "N").foregroundColor(eq.eqEnabled ? .green : nil)
      Text(eq.hz63.formatted(.number))
      Text(eq.hz125.formatted(.number))
      Text(eq.hz250.formatted(.number))
      Text(eq.hz500.formatted(.number))
      Text(eq.hz1000.formatted(.number))
      Text(eq.hz2000.formatted(.number))
      Text(eq.hz4000.formatted(.number))
      Text(eq.hz8000.formatted(.number))
    }
    .lineLimit(1)
    .truncationMode(.middle)
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  EqualizerSubView()
    .environment(ObjectModel.shared)
}
