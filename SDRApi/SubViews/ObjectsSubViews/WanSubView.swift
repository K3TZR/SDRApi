//
//  WanSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/10/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct WanSubView: View {

  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Text("WAN")
          .frame(width: 100, alignment: .leading)
          .foregroundColor(.yellow)
        
        Group {
          HStack(spacing: 5) {
            Text("Radio Authenticated")
            Text(objectModel.wan.radioAuthenticated ? "Y" : "N").foregroundColor(objectModel.wan.radioAuthenticated ? .green : .red)
          }
          HStack(spacing: 5) {
            Text("Server Connected")
            Text(objectModel.wan.serverConnected ? "Y" : "N").foregroundColor(objectModel.wan.serverConnected ? .green : .red)
          }
        }.frame(width: 210, alignment: .leading)
      }
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  WanSubView()
    
    .environment(ObjectModel.shared)

    .frame(minWidth: 1250)
}
