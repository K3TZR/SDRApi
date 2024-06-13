//
//  WaveformSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/4/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

struct WaveformSubView: View {

  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      if objectModel.waveform.list.isEmpty {
        GridRow {
          Text("WAVEFORM")
            .frame(width: 100, alignment: .leading)
            .foregroundColor(.yellow)
          
          Text("----- NONE -----").foregroundColor(.red)
        }
        
      } else {
        GridRow {
          Text("WAVEFORM")
            .frame(width: 100, alignment: .leading)
            .foregroundColor(.yellow)
          
          Text(objectModel.waveform.list)
        }
      }
    }.padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  WaveformSubView()
    .environment(ObjectModel.shared)
}
