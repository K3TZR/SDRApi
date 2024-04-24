//
//  CwxSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/10/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct CwxSubView: View {
  
  @Environment(ApiModel.self) private var apiModel
  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("CWX")
          HStack(spacing: 5) {
            Text("Bkin_Delay")
            Text("\(objectModel.cwx.breakInDelay)").foregroundColor(.green)
          }
          HStack(spacing: 5) {
            Text("QSK")
            Text(objectModel.cwx.qskEnabled ? "Y" : "N").foregroundColor(objectModel.cwx.qskEnabled ? .green : .red)
          }
          HStack(spacing: 5) {
            Text("WPM")
            Text("\(objectModel.cwx.wpm)").foregroundColor(.green)
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
    .environment(ApiModel.shared)
    .environment(ObjectModel.shared)
}
