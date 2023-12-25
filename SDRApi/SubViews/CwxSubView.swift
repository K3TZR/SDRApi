//
//  CwxSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/10/22.
//

import SwiftUI

import FlexApi

// ----------------------------------------------------------------------------
// MARK: - View

struct CwxSubView: View {
  
  @Environment(ApiModel.self) private var api

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("CWX")
          HStack(spacing: 5) {
            Text("Bkin_Delay")
            Text("\(api.cwx.breakInDelay)").foregroundColor(.green)
          }
          HStack(spacing: 5) {
            Text("QSK")
            Text(api.cwx.qskEnabled ? "Y" : "N").foregroundColor(api.cwx.qskEnabled ? .green : .red)
          }
          HStack(spacing: 5) {
            Text("WPM")
            Text("\(api.cwx.wpm)").foregroundColor(.green)
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
}
