//
//  RadioSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct RadioSubView: View {
  @Environment(ApiModel.self) var apiModel
  
  @State var showSubView = true
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 0) {
        Label("Radio", systemImage: showSubView ? "chevron.down" : "chevron.right")
          .foregroundColor(apiModel.radio?.packet.source == .local ? .blue : .red)
          .font(.title)
          .frame(width: 120, alignment: .leading)
          .onTapGesture{ showSubView.toggle() }
          .help("          Tap to toggle details")

        Text(apiModel.radio?.packet.nickname ?? "" )
          .foregroundColor(apiModel.radio?.packet.source == .local ? .blue : .red)
          .frame(width: 120, alignment: .leading)
        
        Line1View()
      }
      
      Line2View()
      if showSubView {
        Divider().background(apiModel.radio?.packet.source == .local ? .blue : .red)
        DetailView()
      }
    }
  }
}

private struct Line1View: View {
  @Environment(ApiModel.self) var apiModel

  var body: some View {
    
    if let radio = apiModel.radio {
      HStack(spacing: 20) {
        HStack(spacing: 5) {
          Text("Connection")
          Text(radio.packet.source.rawValue)
            .foregroundColor(radio.packet.source == .local ? .green : .red)
        }
        HStack(spacing: 5) {
          Text("Ip")
          Text(radio.packet.publicIp).foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("FW")
          Text(radio.packet.version + "\(radio.alpha ? "(alpha)" : "")").foregroundColor(radio.alpha ? .red : .green)
        }
        HStack(spacing: 5) {
          Text("Model")
          Text(radio.packet.model).foregroundColor(.green)
        }
        HStack(spacing: 5) {
          Text("Serial")
          Text(radio.packet.serial).foregroundColor(.green)
        }
        .frame(alignment: .leading)
      }.padding(.leading, 20)
    }
  }
}

private struct Line2View: View {
  @Environment(ApiModel.self) var apiModel

  func stringArrayToString( _ list: [String]?) -> String {
    guard list != nil else { return "Unknown"}
    let str = list!.reduce("") {$0 + $1 + ", "}
    return String(str.dropLast(2))
  }
  
  func uint32ArrayToString( _ list: [UInt32]) -> String {
    let str = list.reduce("") {String($0) + String($1) + ", "}
    return String(str.dropLast(2))
  }
  
  var body: some View {
   
    if let radio = apiModel.radio {
      HStack(spacing: 20) {
        HStack(spacing: 5) {
          Text("Ant List")
          Text(stringArrayToString(apiModel.antList)).foregroundColor(.green)
        }
        
        HStack(spacing: 5) {
          Text("Mic List")
          Text(stringArrayToString(apiModel.micList)).foregroundColor(.green)
        }
        
        HStack(spacing: 5) {
          Text("Tnf Enabled")
          Text(radio.tnfsEnabled ? "Y" : "N").foregroundColor(radio.tnfsEnabled ? .green : .red)
        }
        
        HStack(spacing: 5) {
          Text("HW")
          Text(radio.hardwareVersion ?? "").foregroundColor(.green)
        }
        
        HStack(spacing: 5) {
          Text("Uptime")
          Text("\(apiModel.uptime)").foregroundColor(.green)
          Text("(seconds)")
        }
      }.padding(.leading, 130)
    }
  }
}

private struct DetailView: View {
  
  var body: some View {
    
    VStack(alignment: .leading) {
      AtuSubView()
      GpsSubView()
//    MeterStreamSubView(streamModel: streamModel)
      TransmitSubView()
      TnfSubView()
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  RadioSubView()
    .environment(ApiModel.shared)
    .frame(minWidth: 1250)
}
