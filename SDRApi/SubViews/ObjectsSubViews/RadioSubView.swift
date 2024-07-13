//
//  RadioSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct RadioSubView: View {
  let store: StoreOf<SDRApi>

  @Environment(ObjectModel.self) var objectModel

  @State var showSubView = true
  
  @MainActor private var sourceColor: Color {
    objectModel.radio?.packet.source == .local ? .blue : .red
  }
  
  var body: some View {
    
    ScrollView([.vertical, .horizontal]) {
      VStack(alignment: .leading) {
        HStack(spacing: 0) {
          Label("Radio", systemImage: showSubView ? "chevron.down" : "chevron.right")
            .frame(width: 125, alignment: .leading)
            .font(.title)
            .foregroundColor(sourceColor)
            .onTapGesture{ showSubView.toggle() }
            .help("          Tap to toggle details")
          
          Text(objectModel.radio?.packet.nickname ?? "" )
            .foregroundColor(sourceColor)
            .frame(width: 120, alignment: .leading)
          
          Line1View()
        }
        
        if showSubView {  DetailView(store: store, sourceColor: sourceColor) }
      }
    }
  }
}

private struct Line1View: View {

  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    
    if let radio = objectModel.radio {
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

        HStack(spacing: 5) {
          Text("HW")
          Text(objectModel.hardwareVersion ?? "").foregroundColor(.green)
        }
        
        HStack(spacing: 5) {
          Text("Uptime")
          Text("\(radio.uptime)").foregroundColor(.green)
          Text("(seconds)")
        }

        Toggle("TNF's Enabled", isOn: Binding(get: {radio.tnfsEnabled}, set: {radio.set(.tnfsEnabled, $0.as1or0)} ))

        Toggle("MF Enabled", isOn: Binding(get: {radio.multiflexEnabled}, set: {radio.set(.multiflexEnabled, $0.as1or0)} ))

        .frame(alignment: .leading)
      }.padding(.leading, 20)
    }
  }
}

private struct DetailView: View {
  var store: StoreOf<SDRApi>
  var sourceColor: Color
  var body: some View {
    
    VStack(alignment: .leading) {
      switch store.appSettings.radioObjectFilter {
      case .all:
        AtuSubView(sourceColor: sourceColor)
        BandSettingSubView(store: store, sourceColor: sourceColor)
        EqualizerSubView(sourceColor: sourceColor)
        GpsSubView(sourceColor: sourceColor)
        //    MeterStreamSubView(streamModel: streamModel)
        ListsView(sourceColor: sourceColor)
        TnfSubView(sourceColor: sourceColor)
        TransmitSubView(sourceColor: sourceColor)
      case .atu:          AtuSubView(sourceColor: sourceColor)
      case .bandSettings: BandSettingSubView(store: store, sourceColor: sourceColor)
      case .equalizers:   EqualizerSubView(sourceColor: sourceColor)
      case .gps:          GpsSubView(sourceColor: sourceColor)
      case .lists:        ListsView(sourceColor: sourceColor)
      case .tnf:          TnfSubView(sourceColor: sourceColor)
      case .transmit:     TransmitSubView(sourceColor: sourceColor)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  RadioSubView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
    
  .environment(ObjectModel.shared)

  .frame(minWidth: 1250)
}
