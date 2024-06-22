//
//  MeterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/24/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct MeterSubView: View {
  let sliceId: UInt32?
  let sliceClientHandle: UInt32?
  let handle: UInt32
  
  @Environment(ObjectModel.self) private var objectModel

  func showMeter(_ id: UInt32?, _ clientHandle: UInt32?, _ source: String, _ group: String) -> Bool {
    if id == nil { return true }
    if clientHandle != handle { return false }
    if source != "slc" { return false }
    if UInt32(group) != id { return false }
    return true
  }
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 20) {
      HeadingView(sliceId: sliceId)
      ForEach(objectModel.meters ) { meter in
        if showMeter(sliceId, sliceClientHandle, meter.source, meter.group) {
          DetailView(meter: meter, sliceId: sliceId)
        }
      }
      .foregroundColor(.secondary)
    }
  }
}

private struct HeadingView: View {
  let sliceId: UInt32?
  
  var body: some View {
    GridRow {
      Text("METER")
        .frame(width: 100)
        .foregroundColor(.yellow)
      
      Text("Group")
        .gridColumnAlignment(.trailing)

      Text("Source")
      Text("Name")
      Text("Value")
        .gridColumnAlignment(.trailing)

      Text("Units")
      Text("Fps")
        .gridColumnAlignment(.trailing)
      Text("Description")
    }
  }
}

private struct DetailView: View {
  @ObservedObject var meter: Meter
  let sliceId: UInt32?
  
  func valueColor(_ value: Float, _ low: Float, _ high: Float) -> Color {
    if value > high { return .red }
    if value < low { return .yellow }
    return .secondary
  }
  
  @State var throttledValue: CGFloat = 0.0
  
  var body: some View {
    
    GridRow {
      Text(meter.id, format: .number)
        .frame(width: 100)
        .foregroundColor(.yellow)
      
      Text(meter.group)
      Text(meter.source)
      Text(meter.name)
      Text(String(format: "%-4.2f", throttledValue))
        .help("        range: \(String(format: "%-4.2f", meter.low)) to \(String(format: "%-4.2f", meter.high))")
        .foregroundColor(valueColor(meter.value, meter.low, meter.high))
        .onReceive(meter.$value.throttle(for: 1, scheduler: RunLoop.main, latest: true)) { throttledValue = CGFloat($0) }
      
      Text(meter.units)
      Text(String(format: "% 2d", meter.fps))
      Text(meter.desc).foregroundColor(.secondary)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MeterSubView(sliceId: 1, sliceClientHandle: nil, handle: 1)
    
    .environment(ObjectModel.shared)
  
    .frame(width: 1250)
}
