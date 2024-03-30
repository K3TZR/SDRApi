//
//  NetworkSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 10/3/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import VitaFeature

// ----------------------------------------------------------------------------
// MARK: - View

public struct NetworkSubView: View {
  @ObservedObject var streamStatistics: StreamStatistics
  
  @Environment(ApiModel.self) private var apiModel

  public var body: some View {
    
    VStack(alignment: .leading) {
      HeadingView()
      ForEach(streamStatistics.streamStatus) { status in
        DetailView(status: status)
      }
    }.padding(.leading, 40)
  }
}

private struct HeadingView: View {
  
  var body: some View {
    HStack(spacing: 10) {
      Text("NETWORK").frame(width: 80, alignment: .leading)
      Text("Stream").frame(width: 130, alignment: .leading)
      Group {
        Text("Packets")
        Text("Errors")
      }.frame(width: 80, alignment: .trailing)
    }
    Text("")
  }
}

private struct DetailView: View {
  @ObservedObject var status: StreamStatus
  @State var throttledPackets: Int = 0
  
  var errorPerCent: Float {
    if status.errors == 0 { return 0 }
    return Float(status.errors) / Float(status.packets)
  }
  
  var body: some View {
    HStack(spacing: 10) {
      Text(status.type.description()).frame(width: 130, alignment: .leading)
      Group {
        Text(throttledPackets.formatted(.number))
        Text(status.errors.formatted(.number))
        Text(errorPerCent.formatted(.percent.precision(.fractionLength(4))))
      }.frame(width: 80, alignment: .trailing)
    }
    .padding(.leading, 90)
    
    .onReceive(status.$packets.throttle(for: 1, scheduler: RunLoop.main, latest: true) ) { 
      self.throttledPackets = $0
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  NetworkSubView(streamStatistics: StreamStatistics.shared)
    .environment(ApiModel.shared)
}
