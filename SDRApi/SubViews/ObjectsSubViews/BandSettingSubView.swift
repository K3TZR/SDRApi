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
          DetailView(bandSetting: setting)
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
  @Bindable var bandSetting: BandSetting

  var body: some View {
        
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(bandSetting.name == 999 ? " GEN" : String(format: "%#4d", bandSetting.name))
      HStack(spacing: 5) {
        Text(bandSetting.rfPower, format: .number)
        Stepper("", value: Binding(get: {bandSetting.rfPower}, set: {bandSetting.set(.rfPower, String($0))} ), in: 0...100, step: 1)
      }
      HStack(spacing: 5) {
        Text(bandSetting.tunePower, format: .number)
        Stepper("", value: Binding(get: {bandSetting.tunePower}, set: {bandSetting.set(.tunePower, String($0))} ), in: 0...100, step: 1)
      }
      Toggle("", isOn: Binding(get: {bandSetting.inhibit}, set: {bandSetting.set(.inhibit, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {bandSetting.accTxEnabled}, set: {bandSetting.set(.accTxEnabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {bandSetting.rcaTxReqEnabled}, set: {bandSetting.set(.rcaTxReqEnabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {bandSetting.accTxReqEnabled}, set: {bandSetting.set(.accTxReqEnabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {bandSetting.tx1Enabled}, set: {bandSetting.set(.tx1Enabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {bandSetting.tx2Enabled}, set: {bandSetting.set(.tx2Enabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {bandSetting.tx3Enabled}, set: {bandSetting.set(.tx3Enabled, $0.as1or0)} ))
      Toggle("", isOn: Binding(get: {bandSetting.hwAlcEnabled}, set: {bandSetting.set(.hwAlcEnabled, $0.as1or0)} ))
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
  
  .environment(ObjectModel())
  
  .frame(width: 1250)
}
