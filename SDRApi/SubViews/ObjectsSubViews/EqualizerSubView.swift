//
//  EqualizerSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 8/8/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct EqualizerSubView: View {
  var sourceColor: Color

  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 5) {
      HeadingView(sourceColor: sourceColor)
      ForEach(objectModel.equalizers) { eq in
        DetailView(eq: eq)
      }
    }
  }
}

private struct HeadingView: View {
  var sourceColor: Color

  var body: some View {
    GridRow {
      Text("EQUALIZER")
        .frame(width: 100, alignment: .leading)
        .gridColumnAlignment(.leading)
        .foregroundColor(sourceColor)
      
      Text("ID")
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
    .frame(width: 80)
  }
}

private struct DetailView: View {
  var eq: Equalizer
  
  var body: some View {
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])

      Text(eq.id)
      
      Toggle("", isOn: Binding(get: {eq.eqEnabled}, set: {eq.setProperty(.eqEnabled, $0.as1or0)} ))

      HStack(spacing: 5) {
        Text(eq.hz63.formatted(.number))
        Stepper("", value: Binding(get: {eq.hz63}, set: {eq.setProperty(.hz63, String($0))} ), in: -10...10)
      }
      HStack(spacing: 5) {
        Text(eq.hz125.formatted(.number))
        Stepper("", value: Binding(get: {eq.hz125}, set: {eq.setProperty(.hz125, String($0))} ), in: -10...10)
      }
      HStack(spacing: 5) {
        Text(eq.hz250.formatted(.number))
        Stepper("", value: Binding(get: {eq.hz250}, set: {eq.setProperty(.hz250, String($0))} ), in: -10...10)
      }
      HStack(spacing: 5) {
        Text(eq.hz500.formatted(.number))
        Stepper("", value: Binding(get: {eq.hz500}, set: {eq.setProperty(.hz500, String($0))} ), in: -10...10)
      }
      HStack(spacing: 5) {
        Text(eq.hz1000.formatted(.number))
        Stepper("", value: Binding(get: {eq.hz1000}, set: {eq.setProperty(.hz1000, String($0))} ), in: -10...10)
      }
      HStack(spacing: 5) {
        Text(eq.hz2000.formatted(.number))
        Stepper("", value: Binding(get: {eq.hz2000}, set: {eq.setProperty(.hz2000, String($0))} ), in: -10...10)
      }
      HStack(spacing: 5) {
        Text(eq.hz4000.formatted(.number))
        Stepper("", value: Binding(get: {eq.hz4000}, set: {eq.setProperty(.hz4000, String($0))} ), in: -10...10)
      }
      HStack(spacing: 5) {
        Text(eq.hz8000.formatted(.number))
        Stepper("", value: Binding(get: {eq.hz8000}, set: {eq.setProperty(.hz8000, String($0))} ), in: -10...10)
      }
    }
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  EqualizerSubView(sourceColor: .blue)

    .environment(ObjectModel.shared)
}
