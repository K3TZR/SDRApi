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

  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    
    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 5) {
      TransmitView(transmit: objectModel.transmit)
      CwView(transmit: objectModel.transmit)
    }
  }
}

private struct TransmitView: View {
  var transmit: Transmit
  
  var body: some View {
    
    GridRow {
      Text("TRANSMIT     ")
        .monospaced()
        .gridColumnAlignment(.leading)
        .foregroundColor(.yellow)

      HStack(spacing: 5) {
        Text("Processor")
        Text(transmit.speechProcessorEnabled ? "Y" : "N")
          .foregroundColor(transmit.speechProcessorEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Compander")
        Text(transmit.companderEnabled ? "Y" : "N")
          .foregroundColor(transmit.companderEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Monitor")
        Text(transmit.txMonitorEnabled ? "Y" : "N")
          .foregroundColor(transmit.txMonitorEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Mic Acc")
        Text(transmit.micAccEnabled ? "Y" : "N")
          .foregroundColor(transmit.micAccEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Dax")
        Text(transmit.daxEnabled ? "Y" : "N")
          .foregroundColor(transmit.daxEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Vox")
        Text(transmit.voxEnabled ? "Y" : "N")
          .foregroundColor(transmit.voxEnabled ? .green : .red)
      }
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
  
  var body: some View {
    
    GridRow {
      Text("CW           ")
        .monospaced()
        .gridColumnAlignment(.leading)
        .foregroundColor(.yellow)
      
      HStack(spacing: 5) {
        Text("Sidetone")
        Text(transmit.cwSidetoneEnabled ? "Y" : "N").foregroundColor(transmit.cwSidetoneEnabled ? .green : .red)
      }
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
  TransmitSubView()
    .environment(ObjectModel.shared)
}
