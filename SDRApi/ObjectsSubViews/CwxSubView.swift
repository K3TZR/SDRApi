//
//  CwxSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 8/10/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct CwxSubView: View {
  
  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    
    let cwx = objectModel.cwx
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("CWX")
            .frame(width: 100, alignment: .leading)
            .foregroundColor(.yellow)

          HStack(spacing: 5) {
            Text("Delay")
            Text(cwx.breakInDelay, format: .number).foregroundColor(.secondary)
            Stepper("", value: Binding(get: {cwx.breakInDelay}, set: {cwx.setProperty(.breakInDelay, String($0))} ), in: 40...2000, step: 10)
          }

          Toggle("QSK", isOn: Binding(get: {cwx.qskEnabled }, set: {cwx.setProperty(.qskEnabled, $0.as1or0)} ))

          HStack(spacing: 5) {
            Text("Speed")
            Text(cwx.wpm, format: .number).foregroundColor(.secondary)
            Stepper("", value: Binding(get: {cwx.wpm}, set: {cwx.setProperty(.wpm, String($0))} ), in: 5...60, step: 1)
          }
        }
      }
      .frame(width: 100, alignment: .leading)
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  CwxSubView()
  
    .environment(ObjectModel.shared)
  
    .frame(width: 1250)
  
}
