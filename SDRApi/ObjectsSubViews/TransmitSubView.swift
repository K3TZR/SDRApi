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

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
      Group {
        Row1View()
        Row2View()
        Row3View()
      }.frame(width: 100, alignment: .leading)
    }
    .padding(.leading, 20)
  }
}

private struct Row1View: View {

  @Environment(ApiModel.self) var apiModel
  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    
    GridRow {
      Text("TRANSMIT")
      Group {
        HStack(spacing: 5) {
          Text("RF_Power")
          Text("\(objectModel.transmit.rfPower)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Tune_Power")
          Text("\(objectModel.transmit.tunePower)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Frequency")
          Text("\(objectModel.transmit.frequency)").foregroundColor(.secondary)
        }
        HStack(spacing: 5) {
          Text("Mon_Level")
          Text("\(objectModel.transmit.ssbMonitorGain)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Comp_Level")
          Text("\(objectModel.transmit.companderLevel)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Mic")
          Text("\(objectModel.transmit.micSelection)").foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Mic_Level")
          Text("\(objectModel.transmit.micLevel)").foregroundColor(.green)
        }
      }
    }
  }
}
  
private struct Row2View: View {

  @Environment(ApiModel.self) var apiModel
  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    GridRow {
      Text("")
      HStack(spacing: 5) {
        Text("Proc")
        Text(objectModel.transmit.speechProcessorEnabled ? "Y" : "N")
          .foregroundColor(objectModel.transmit.speechProcessorEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Comp")
        Text(objectModel.transmit.companderEnabled ? "Y" : "N")
          .foregroundColor(objectModel.transmit.companderEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Mon")
        Text(objectModel.transmit.txMonitorEnabled ? "Y" : "N")
          .foregroundColor(objectModel.transmit.txMonitorEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Acc")
        Text(objectModel.transmit.micAccEnabled ? "Y" : "N")
          .foregroundColor(objectModel.transmit.micAccEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Dax")
        Text(objectModel.transmit.daxEnabled ? "Y" : "N")
          .foregroundColor(objectModel.transmit.daxEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Vox")
        Text(objectModel.transmit.voxEnabled ? "Y" : "N")
          .foregroundColor(objectModel.transmit.voxEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Vox_Delay")
        Text("\(objectModel.transmit.voxDelay)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Vox_Level")
        Text("\(objectModel.transmit.voxLevel)").foregroundColor(.green)
      }
    }
  }
}
  
private struct Row3View: View {

  @Environment(ApiModel.self) var apiModel
  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    GridRow {
      Text("")
      HStack(spacing: 5) {
        Text("Sidetone")
        Text(objectModel.transmit.cwSidetoneEnabled ? "Y" : "N").foregroundColor(objectModel.transmit.cwSidetoneEnabled ? .green : .red)
      }
      HStack(spacing: 5) {
        Text("Level")
        Text("\(objectModel.transmit.cwMonitorGain)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Pan")
        Text("\(objectModel.transmit.cwMonitorPan)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Pitch")
        Text("\(objectModel.transmit.cwPitch)").foregroundColor(.green)
      }
      HStack(spacing: 5) {
        Text("Speed")
        Text("\(objectModel.transmit.cwSpeed)").foregroundColor(.green)
      }
    }
  }
}
  
  // ----------------------------------------------------------------------------
  // MARK: - Preview
  
#Preview {
  TransmitSubView()
    .environment(ApiModel.shared)
}
