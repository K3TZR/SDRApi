//
//  TransmitSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct TransmitSubView: View {
  var sourceColor: Color

  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 5) {
      TransmitView(transmit: objectModel.transmit, sourceColor: sourceColor)
      CwView(transmit: objectModel.transmit, sourceColor: sourceColor)
    }
  }
}

private struct TransmitView: View {
  var transmit: Transmit
  var sourceColor: Color

  var body: some View {
    
    GridRow {
      Text("TRANSMIT")
        .frame(width: 100, alignment: .leading)
        .foregroundColor(sourceColor)

      Toggle("Processor", isOn: Binding(get: {transmit.speechProcessorEnabled}, set: {transmit.set(.speechProcessorEnabled, $0.as1or0)} ))
      Toggle("Compander", isOn: Binding(get: {transmit.companderEnabled}, set: {transmit.set(.companderEnabled, $0.as1or0)} ))
      Toggle("Monitor", isOn: Binding(get: {transmit.txMonitorEnabled}, set: {transmit.set(.txMonitorEnabled, $0.as1or0)} ))
      Toggle("Mic Acc", isOn: Binding(get: {transmit.micAccEnabled}, set: {transmit.set(.micAccEnabled, $0.as1or0)} ))
      Toggle("Dax", isOn: Binding(get: {transmit.daxEnabled}, set: {transmit.set(.daxEnabled, $0.as1or0)} ))
      Toggle("Vox", isOn: Binding(get: {transmit.voxEnabled}, set: {transmit.set(.voxEnabled, $0.as1or0)} ))

      HStack(spacing: 5) {
        Text("Vox Delay")
        Text(transmit.voxDelay, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {transmit.voxDelay}, set: {transmit.set(.voxDelay, String($0))} ), in: 0...100, step: 1)
      }

      HStack(spacing: 5) {
        Text("Vox Level")
        Text(transmit.voxLevel, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {transmit.voxLevel}, set: {transmit.set(.voxLevel, String($0))} ), in: 0...100, step: 1)
      }
    }
  }
}

private struct CwView: View {
  var transmit: Transmit
  var sourceColor: Color

  var body: some View {
    
    GridRow {
      Text("CW")
        .frame(width: 100, alignment: .leading)
        .foregroundColor(sourceColor)
      
      Toggle("Sidetone", isOn: Binding(get: {transmit.cwSidetoneEnabled}, set: {transmit.set(.cwSidetoneEnabled, $0.as1or0)} ))

      HStack(spacing: 5) {
        Text("Level")
        Text(transmit.cwMonitorGain, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {transmit.cwMonitorGain}, set: {transmit.set(.cwMonitorGain, String($0))} ), in: 0...100, step: 1)
      }

      HStack(spacing: 5) {
        Text("Pan")
        Text(transmit.cwMonitorPan, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {transmit.cwMonitorPan}, set: {transmit.set(.cwMonitorPan, String($0))} ), in: 0...100, step: 1)
      }

      HStack(spacing: 5) {
        Text("Pitch")
        Text(transmit.cwPitch, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {transmit.cwPitch}, set: {transmit.set(.cwPitch, String($0))} ), in: 100...6000, step: 10)
      }

      HStack(spacing: 5) {
        Text("Speed")
        Text(transmit.cwSpeed, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {transmit.cwSpeed}, set: {transmit.set(.cwSpeed, String($0))} ), in: 5...100, step: 1)
      }
    }
  }
}
  
  // ----------------------------------------------------------------------------
  // MARK: - Preview
  
#Preview {
  TransmitSubView(sourceColor: .blue)
    
    .environment(ObjectModel.shared)

    .frame(minWidth: 1250)
}
