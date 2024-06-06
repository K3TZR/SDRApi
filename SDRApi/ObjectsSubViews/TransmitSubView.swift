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
      Text("TRANSMIT".padRight(13))
        .monospaced()
        .foregroundColor(sourceColor)

//      HStack(spacing: 5) {
//        Text("Processor")
//        Text(transmit.speechProcessorEnabled ? "Y" : "N")
//          .foregroundColor(transmit.speechProcessorEnabled ? .green : .red)
//      }

      Toggle("Processor", isOn: Binding(get: {transmit.speechProcessorEnabled}, set: {transmit.setProperty(.speechProcessorEnabled, $0.as1or0)} ))
      Toggle("Compander", isOn: Binding(get: {transmit.companderEnabled}, set: {transmit.setProperty(.companderEnabled, $0.as1or0)} ))
      Toggle("Monitor", isOn: Binding(get: {transmit.txMonitorEnabled}, set: {transmit.setProperty(.txMonitorEnabled, $0.as1or0)} ))
      Toggle("Mic Acc", isOn: Binding(get: {transmit.micAccEnabled}, set: {transmit.setProperty(.micAccEnabled, $0.as1or0)} ))
      Toggle("Dax", isOn: Binding(get: {transmit.daxEnabled}, set: {transmit.setProperty(.daxEnabled, $0.as1or0)} ))
      Toggle("Vox", isOn: Binding(get: {transmit.voxEnabled}, set: {transmit.setProperty(.voxEnabled, $0.as1or0)} ))

//      HStack(spacing: 5) {
//        Text("Compander")
//        Text(transmit.companderEnabled ? "Y" : "N")
//          .foregroundColor(transmit.companderEnabled ? .green : .red)
//      }
//      HStack(spacing: 5) {
//        Text("Monitor")
//        Text(transmit.txMonitorEnabled ? "Y" : "N")
//          .foregroundColor(transmit.txMonitorEnabled ? .green : .red)
//      }
//      HStack(spacing: 5) {
//        Text("Mic Acc")
//        Text(transmit.micAccEnabled ? "Y" : "N")
//          .foregroundColor(transmit.micAccEnabled ? .green : .red)
//      }
//      HStack(spacing: 5) {
//        Text("Dax")
//        Text(transmit.daxEnabled ? "Y" : "N")
//          .foregroundColor(transmit.daxEnabled ? .green : .red)
//      }
//      HStack(spacing: 5) {
//        Text("Vox")
//        Text(transmit.voxEnabled ? "Y" : "N")
//          .foregroundColor(transmit.voxEnabled ? .green : .red)
//      }
      HStack(spacing: 5) {
        Text("Vox Delay")
        Text("\(transmit.voxDelay)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Vox Level")
        Text("\(transmit.voxLevel)").foregroundColor(.green)
      }
    }
  }
}

private struct CwView: View {
  var transmit: Transmit
  var sourceColor: Color

  var body: some View {
    
    GridRow {
      Text("".padRight(13))
        .monospaced()
        .foregroundColor(sourceColor)
      
//      HStack(spacing: 5) {
//        Text("Sidetone")
//        Text(transmit.cwSidetoneEnabled ? "Y" : "N").foregroundColor(transmit.cwSidetoneEnabled ? .green : .red)
//      }

      Toggle("Sidetone", isOn: Binding(get: {transmit.cwSidetoneEnabled}, set: {transmit.setProperty(.cwSidetoneEnabled, $0.as1or0)} ))

      HStack(spacing: 5) {
        Text("Level")
        Text("\(transmit.cwMonitorGain)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Pan")
        Text("\(transmit.cwMonitorPan)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Pitch")
        Text("\(transmit.cwPitch)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Speed")
        Text("\(transmit.cwSpeed)").foregroundColor(.green)
      }
    }
  }
}
  
  // ----------------------------------------------------------------------------
  // MARK: - Preview
  
#Preview {
  TransmitSubView(sourceColor: .blue)
    .environment(ObjectModel.shared)
}
