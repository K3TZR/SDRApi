//
//  XvtrSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/5/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct XvtrSubView: View {

  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    
    if objectModel.xvtrs.count == 0 {
      HStack(spacing: 20) {
        Text("XVTR")
          .frame(width: 100, alignment: .leading)
          .foregroundColor(.yellow)
        
        Text("----- NONE -----t").foregroundColor(.red)
      }
      .padding(.leading, 40)
      
    } else {
      HStack(spacing: 20) {
        Text("XVTR")
          .frame(width: 100, alignment: .leading)
          .foregroundColor(.yellow)

        Text("----- NOT IMPLEMENTED -----").foregroundColor(.red)
      }
      .padding(.leading, 40)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  XvtrSubView()

    .environment(ObjectModel())
  
    .frame(minWidth: 1250)
}
