//
//  BandSettingsSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct BandSettingSubView: View {
  var store: StoreOf<SDRApi>
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
      Text("BAND SETTINGS")
        .frame(width: 100)
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
      HStack(spacing: 5) {
        Text(setting.rfPower, format: .number)
        Stepper("", value: Binding(get: {setting.rfPower}, set: {setting.setProperty(.rfPower, String($0))} ), in: 0...100, step: 1)
      }
      HStack(spacing: 5) {
        Text(setting.tunePower, format: .number)
        Stepper("", value: Binding(get: {setting.tunePower}, set: {setting.setProperty(.tunePower, String($0))} ), in: 0...100, step: 1)
      }
      Toggle("", isOn: Binding(get: {setting.inhibit}, set: {setting.setProperty(.inhibit, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {setting.accTxEnabled}, set: {setting.setProperty(.accTxEnabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {setting.rcaTxReqEnabled}, set: {setting.setProperty(.rcaTxReqEnabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {setting.accTxReqEnabled}, set: {setting.setProperty(.accTxReqEnabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {setting.tx1Enabled}, set: {setting.setProperty(.tx1Enabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {setting.tx2Enabled}, set: {setting.setProperty(.tx2Enabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {setting.tx3Enabled}, set: {setting.setProperty(.tx3Enabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {setting.hwAlcEnabled}, set: {setting.setProperty(.hwAlcEnabled, $0.as1or0)} ))
    }
    .controlSize(.small)
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  BandSettingSubView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  }, sourceColor: .blue)
  
  .environment(ObjectModel.shared)
  
  .frame(width: 1250)
}
