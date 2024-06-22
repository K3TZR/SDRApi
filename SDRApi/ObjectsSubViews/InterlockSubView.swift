//
//  InterlockSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/1/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

struct InterlockSubView: View {
  
  @Environment(ObjectModel.self) var objectModel
  
  var body: some View {
    
    let interlock = objectModel.interlock
    HStack(spacing: 40) {
      Text("INTERLOCK")
        .frame(width: 100, alignment: .leading)
        .foregroundColor(.yellow)

      HStack(spacing: 5) {
        Text("Tx Allowed")
        Text(interlock.txAllowed ? "Y" : "N").foregroundColor(interlock.txAllowed ? .green : .red)
        Text(interlock.txDelay, format: .number).frame(width: 30)
      }
      HStack(spacing: 5) {
        Toggle("Tx1", isOn: Binding(get: {interlock.tx1Enabled}, set: {interlock.setProperty(.tx1Enabled, $0.as1or0)} ))
        Text(interlock.tx1Delay, format: .number).frame(width: 30).foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Toggle("Tx2", isOn: Binding(get: {interlock.tx2Enabled}, set: {interlock.setProperty(.tx2Enabled, $0.as1or0)} ))
        Text(interlock.tx2Delay, format: .number).frame(width: 30).foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Toggle("Tx3", isOn: Binding(get: {interlock.tx3Enabled}, set: {interlock.setProperty(.tx3Enabled, $0.as1or0)} ))
        Text(interlock.tx3Delay, format: .number).frame(width: 30).foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Toggle("ACC Tx", isOn: Binding(get: {interlock.accTxEnabled}, set: {interlock.setProperty(.accTxEnabled, $0.as1or0)} ))
        Text(interlock.accTxDelay, format: .number).frame(width: 30).foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Toggle("ACC Req", isOn: Binding(get: {interlock.accTxReqEnabled}, set: {interlock.setProperty(.accTxReqEnabled, $0.as1or0)} ))
        Toggle("", isOn: Binding(get: {interlock.accTxReqPolarity}, set: {interlock.setProperty(.accTxReqPolarity, $0.as1or0)} )).labelsHidden()
        Text(interlock.accTxReqPolarity ? "+" : "-").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Toggle("RCA Req", isOn: Binding(get: {interlock.rcaTxReqEnabled}, set: {interlock.setProperty(.rcaTxReqEnabled, $0.as1or0)} ))
        Toggle("", isOn: Binding(get: {interlock.rcaTxReqPolarity}, set: {interlock.setProperty(.rcaTxReqPolarity, $0.as1or0)} )).labelsHidden()
        Text(interlock.rcaTxReqPolarity ? "+" : "-").foregroundColor(.secondary)
      }
      Spacer()
    }
    .frame(minWidth: 1250, maxWidth: .infinity)
  }
}

#Preview {
  InterlockSubView()

    .environment(ObjectModel.shared)
  
    .frame(width: 1250)
}
