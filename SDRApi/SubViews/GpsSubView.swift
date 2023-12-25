//
//  GpsSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import FlexApi
import SharedModel

// ----------------------------------------------------------------------------
// MARK: - View

struct GpsSubView: View {

  @Environment(ApiModel.self) private var api

  let post = String(repeating: " ", count: 8)
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Group {
          Text("GPS")
          if let radio = api.radio {
            if radio.gpsPresent {
              Text("Not implemented").foregroundColor(.red)
            } else {
              Text("Not installed").foregroundColor(.red)
            }
          }
        }
        .frame(width: 100, alignment: .leading)
      }
    }
    .padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  GpsSubView()
    .environment(ApiModel.shared)
}
