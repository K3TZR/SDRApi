//
//  WaveformSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/4/22.
//

import SwiftUI

import FlexApi

struct WaveformSubView: View {
  var waveform: Waveform
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      if waveform.list.isEmpty {
        GridRow {
          Group {
            Text("WAVEFORMs")
            Text("None present").foregroundColor(.red)
          }.frame(width: 100, alignment: .leading)
        }
        
      } else {
        GridRow {
          Group {
            Text("WAVEFORMS").frame(width: 100, alignment: .leading)
            Text(waveform.list)
          }
        }
      }
    }.padding(.leading, 20)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  WaveformSubView(waveform: Waveform())
}
