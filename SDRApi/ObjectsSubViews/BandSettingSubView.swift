//
//  BandSettingsSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct BandSettingSubView: View {
  
  @Environment(ObjectModel.self) private var objectModel
  
  var body: some View {
    
    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 5) {
      HeadingView()
      if objectModel.bandSettings.count > 0 {
        ForEach(objectModel.bandSettings.sorted(by: {$0.name < $1.name})) { setting in
          DetailView(setting: setting)
        }
      } else {
        GridRow {
          Text("----- NONE PRESENT -----").foregroundColor(.red)
        }
      }
    }
  }
}

private struct HeadingView: View {
  
  var body: some View {
    
    GridRow {
      Text("BAND SETTINGS")              
        .monospaced()
        .gridColumnAlignment(.leading)
        .foregroundColor(.yellow)

      Text("Band")
      Text("Rf Power")
      Text("Tune Power")
      Text("Tx1")
      Text("Tx2")
      Text("Tx3")
      Text("Acc Tx")
      Text("Acc Tx Req")
      Text("Rca Tx Req")
      Text("HW Alc")
      Text("Inhibit")
    }
    Divider()
  }
}

private struct DetailView: View {
  var setting: BandSetting
  
  var body: some View {
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(setting.name == 999 ? " GEN" : String(format: "%#4d", setting.name))
      Text(setting.rfPower.formatted(.number))
      Text(setting.tunePower.formatted(.number))
      Text(setting.tx1Enabled ? "Y" : "N").foregroundColor(setting.tx1Enabled  ? .green : nil)
      Text(setting.tx2Enabled ? "Y" : "N").foregroundColor(setting.tx2Enabled  ? .green : nil)
      Text(setting.tx3Enabled ? "Y" : "N").foregroundColor(setting.tx3Enabled  ? .green : nil)
      Text(setting.accTxEnabled ? "Y" : "N").foregroundColor(setting.accTxEnabled  ? .green : nil)
      Text(setting.accTxReqEnabled ? "Y" : "N").foregroundColor(setting.accTxReqEnabled ? .green : nil)
      Text(setting.rcaTxReqEnabled ? "Y" : "N").foregroundColor(setting.rcaTxReqEnabled ? .green : nil)
      Text(setting.hwAlcEnabled ? "Y" : "N").foregroundColor(setting.hwAlcEnabled ? .green : nil)
      Text(setting.inhibit ? "Y" : "N").foregroundColor(setting.inhibit ? .green : nil)
    }
    .lineLimit(1)
    .truncationMode(.middle)
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  BandSettingSubView()
    .environment(ApiModel.shared)
}
