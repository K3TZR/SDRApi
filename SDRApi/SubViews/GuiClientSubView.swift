//
//  GuiClientSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//


import SwiftUI

import Listener
import FlexApi
import SettingsModel
import SharedModel

// ----------------------------------------------------------------------------
// MARK: - View

struct GuiClientSubView: View {
  
  @Environment(ApiModel.self) private var api
  @Environment(Listener.self) private var listener

  var body: some View {
    VStack(alignment: .leading) {
      //      if apiModel.activePacket == nil {
      //        Text("No active packet")
      //      } else {
//      if let radio = api.radio {
        ForEach(listener.guiClients, id: \.id) { guiClient in
          DetailView(guiClient: guiClient)
        }
//      }
      //      }
    }
  }
}

private struct DetailView: View {
  let guiClient: GuiClient
  
  @State var showSubView = true
  
  var body: some View {
    Divider().background(Color(.yellow))
    HStack(spacing: 20) {
      
      HStack(spacing: 0) {
        Image(systemName: showSubView ? "chevron.down" : "chevron.right")
          .help("          Tap to toggle details")
          .onTapGesture(perform: { showSubView.toggle() })
        Text(" Gui   ").foregroundColor(.yellow)
          .font(.title)
          .help("          Tap to toggle details")
          .onTapGesture(perform: { showSubView.toggle() })
        
        Text("\(guiClient.station)").foregroundColor(.yellow)
      }
      
      HStack(spacing: 5) {
        Text("Program")
        Text("\(guiClient.program)").foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Handle")
        Text(guiClient.handle.hex).foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("ClientId")
        Text(guiClient.clientId ?? "Unknown").foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("LocalPtt")
        Text(guiClient.isLocalPtt ? "Y" : "N").foregroundColor(guiClient.isLocalPtt ? .green : .red)
      }
    }
    if showSubView { GuiClientDetailView(handle: guiClient.handle) }
  }
}

struct GuiClientDetailView: View {
  let handle: UInt32

  @Environment(ApiModel.self) private var api
  @Environment(SettingsModel.self) private var settings
    
  var body: some View {
    
    switch settings.objectFilter {
      
    case ObjectFilter.core:
      PanadapterSubView(handle: handle, showMeters: true)
      
    case ObjectFilter.coreNoMeters:
      PanadapterSubView(handle: handle, showMeters: false)
      
    case ObjectFilter.amplifiers:        AmplifierSubView()
    case ObjectFilter.bandSettings:      BandSettingSubView()
    case ObjectFilter.cwx:               CwxSubView()
    case ObjectFilter.equalizers:        EqualizerSubView()
    case ObjectFilter.interlock:         InterlockSubView()
    case ObjectFilter.memories:          MemorySubView()
    case ObjectFilter.meters:            MeterSubView(sliceId: nil, sliceClientHandle: nil, handle: handle)
    case ObjectFilter.misc:              MiscSubView()
    case ObjectFilter.network:           NetworkSubView()
    case ObjectFilter.profiles:          ProfileSubView()
    case ObjectFilter.streams:           StreamSubView(handle: handle)
    case ObjectFilter.usbCable:          UsbCableSubView()
    case ObjectFilter.wan:               WanSubView(wan: api.wan)
    case ObjectFilter.waveforms:         WaveformSubView(waveform: api.waveform)
    case ObjectFilter.xvtrs:             XvtrSubView()
//    default: EmptyView()
//      PanadapterSubView(objectModel: objectModel, streamModel: streamModel, handle: handle, showMeters: true)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  GuiClientSubView()
    .environment(ApiModel.shared)
}
