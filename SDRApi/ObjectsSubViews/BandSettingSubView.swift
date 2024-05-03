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
  var sourceColor: Color

  @Environment(ObjectModel.self) private var objectModel
  
  var body: some View {

    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 0) {
      HeadingView(sourceColor: sourceColor)
      if objectModel.bandSettings.count > 0 {
        ForEach(objectModel.bandSettings.sorted(by: {$0.name > $1.name})) { setting in
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
  var sourceColor: Color

  var body: some View {
    
    GridRow {
      Text("BAND SETTINGS".padRight(13))
        .monospaced()
        .gridColumnAlignment(.leading)
        .foregroundColor(sourceColor)

      Text("Band")
      Text("Rf Power")
      Text("Tune Power")
      Text("PTT Inhibit")
      Text("ACC TX")
      Text("RCA TX Request")
      Text("ACC TX Request")
      Text("RCA TX1")
      Text("RCA TX2")
      Text("RCA TX3")
      Text("HW ALC")
    }
  }
}

private struct DetailView: View {
  @Bindable var setting: BandSetting

  var body: some View {
        
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(setting.name == 999 ? " GEN" : String(format: "%#4d", setting.name))
      TextField("", value: $setting.rfPower, formatter: NumberFormatter()).frame(width: 50).multilineTextAlignment(.trailing)
      TextField("", value: $setting.tunePower, formatter: NumberFormatter()).frame(width: 50).multilineTextAlignment(.trailing)
      Toggle("", isOn: $setting.inhibit)
      Toggle("", isOn: $setting.accTxEnabled)
      Toggle("", isOn: $setting.rcaTxReqEnabled)
      Toggle("", isOn: $setting.accTxReqEnabled)
      Toggle("", isOn: $setting.tx1Enabled)
      Toggle("", isOn: $setting.tx2Enabled)
      Toggle("", isOn: $setting.tx3Enabled)
      Toggle("", isOn: $setting.hwAlcEnabled)
    }
    .controlSize(.small)
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  BandSettingSubView(sourceColor: .blue)
    .environment(ApiModel.shared)
}
