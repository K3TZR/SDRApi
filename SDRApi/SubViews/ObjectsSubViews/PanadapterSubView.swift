//
//  PanadapterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/24/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct PanadapterSubView: View {
  let handle: UInt32
  let showMeters: Bool

  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    
    if objectModel.panadapters.count == 0 {
      HStack(spacing: 20) {
        Text("PANADAPTER").frame(width: 80, alignment: .leading)
        Text("None present").foregroundColor(.red)
      }
      
    } else {
      ForEach(objectModel.panadapters.filter { $0.clientHandle == handle }) { panadapter in
        VStack(alignment: .leading) {
          // Panadapter
          PanadapterDetailView(panadapter: panadapter)
          
          // corresponding Waterfall
          ForEach(objectModel.waterfalls.filter { $0.panadapterId == panadapter.id} ) { waterfall in
            WaterfallDetailView(waterfall: waterfall)
          }
          
          // corresponding Slice(s)
          ForEach(objectModel.slices.filter { $0.panadapterId == panadapter.id}) { slice in
            SliceDetailView(slice: slice)
            
            // slice meter(s)
            if showMeters { MeterSubView(sliceId: slice.id, sliceClientHandle: slice.clientHandle, handle: handle) }
          }
        }
      }
    }
  }
}

private struct PanadapterDetailView: View {
  var panadapter: Panadapter
  
  var body: some View {
    HStack(spacing: 20) {
      
      Text("PANADAPTER").frame(width: 80, alignment: .leading)
      
      HStack(spacing: 5) {
        Text("Id")
        Text(panadapter.id.hex).padding(.leading, 5).foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Bandwidth")
        Text(panadapter.bandwidth, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {panadapter.bandwidth}, set: {panadapter.set(.bandwidth, String(Double($0)/1_000_000))} ), step: 100)
      }
      
      HStack(spacing: 5) {
        Text("Center")
        Text(panadapter.center, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {panadapter.center}, set: {panadapter.set(.center, String(Double($0)/1_000_000))} ), step: 100)
      }
      Spacer()
    }
  }
}

private struct WaterfallDetailView: View {
  var waterfall: Waterfall
  
  var body: some View {
    HStack(spacing: 20) {
      Text("WATERFALL").frame(width: 80, alignment: .leading)
      
      HStack(spacing: 5) {
        Text("Id")
        Text(waterfall.id.hex).padding(.leading, 5).foregroundColor(.secondary)
      }
      
      Toggle("Auto Black", isOn: Binding(get: {waterfall.autoBlackEnabled}, set: {waterfall.set(.autoBlackEnabled, $0.as1or0)} ))
      
      HStack(spacing: 5) {
        Text("Color Gain")
        Text(waterfall.colorGain, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {waterfall.colorGain}, set: {waterfall.set(.colorGain, String($0))} ), in: 0...100, step: 1)
      }
      
      HStack(spacing: 5) {
        Text("Black Level")
        Text(waterfall.blackLevel, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {waterfall.blackLevel}, set: {waterfall.set(.blackLevel, String($0))} ), in: 0...100, step: 1)
      }
      
      HStack(spacing: 5) {
        Text("Duration")
        Text(waterfall.lineDuration, format: .number).foregroundColor(.secondary)
        Stepper("", value: Binding(get: {waterfall.lineDuration}, set: {waterfall.set(.lineDuration, String($0))} ), in: 0...100, step: 1)
      }
      Spacer()
    }
  }
}

private struct SliceDetailView: View {
  var slice: Slice
  
  func stringArrayToString( _ list: [String]?) -> String {
    
    guard list != nil else { return "Unknown"}
    let str = list!.reduce("") {$0 + $1 + ", "}
    return String(str.dropLast(2))
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 20) {
        HStack(spacing: 5) {
          Text("SLICE")
        }.frame(width: 80, alignment: .leading)
        
        Text(String(format: "%02d", slice.id)).foregroundColor(.secondary)
        
        Text("\(slice.frequency)").foregroundColor(.secondary).frame(width: 105, alignment: .trailing)
        
        Group {
          HStack(spacing: 5) {
            Text("Mode")
            Text("\(slice.mode)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Rx Ant")
            Text("\(slice.rxAnt)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Tx Ant")
            Text("\(slice.txAnt)").foregroundColor(.secondary)
          }
        }.frame(width: 100, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("Low")
            Text("\(slice.filterLow)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("High")
            Text("\(slice.filterHigh)").foregroundColor(.secondary)
          }
          
          Toggle("Active", isOn: Binding(get: {slice.active}, set: {slice.set(.active, $0.as1or0)} ))

          Toggle("Locked", isOn: Binding(get: {slice.locked}, set: {slice.set(.locked, $0.as1or0)} ))

        }.frame(width: 100, alignment: .leading)
      }
      HStack(spacing: 20) {
        Text("").frame(width: 80, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("DAX_channel")
            Text("\(slice.daxChannel)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("DAX_clients")
            Text("\(slice.daxClients)").foregroundColor(.secondary)
          }
        }.frame(width: 100, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("Rx Ant List")
            Text(stringArrayToString(slice.rxAntList)).foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Tx Ant List")
            Text(stringArrayToString(slice.txAntList)).foregroundColor(.secondary)
          }
        }.frame(width: 340, alignment: .leading)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  PanadapterSubView(handle: 1, showMeters: true)
    
    .environment(ObjectModel.shared)
  
    .frame(minWidth: 1250)
}
