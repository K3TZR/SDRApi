//
//  GuiClientSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import ListenerFeature
import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct GuiClientSubView: View {
  let store: StoreOf<SDRApi>
    
  @Environment(ListenerModel.self) private var listenerModel

  var body: some View {
    VStack(alignment: .leading) {
      if listenerModel.activePacket != nil {
        ForEach(listenerModel.activePacket!.guiClients, id: \.id) { guiClient in
          DetailView(store: store, guiClient: guiClient)
        }
      } else {
        Text("No active packet")
      }
    }
  }
}

private struct DetailView: View {
  let store: StoreOf<SDRApi>
  let guiClient: GuiClient
  
  @State var showSubView = true
  
  var body: some View {
    Divider().background(Color(.yellow))
    HStack(spacing: 20) {
      
      HStack(spacing: 0) {
        Label("Gui", systemImage: showSubView ? "chevron.down" : "chevron.right")
          .foregroundColor(.yellow)
          .font(.title)
          .frame(width: 120, alignment: .leading)
          .onTapGesture{ showSubView.toggle() }
          .help("          Tap to toggle details")

        Text("\(guiClient.station)").foregroundColor(.yellow)
          .frame(width: 120, alignment: .leading)
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
    if showSubView { GuiClientDetailView(store: store, handle: guiClient.handle) }
  }
}

struct GuiClientDetailView: View {
  let store: StoreOf<SDRApi>
  let handle: UInt32

  var body: some View {
    
    switch store.objectFilter {
      
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
    case ObjectFilter.wan:               WanSubView()
    case ObjectFilter.waveforms:         WaveformSubView()
    case ObjectFilter.xvtrs:             XvtrSubView()
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  GuiClientSubView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
  .environment(ListenerModel.shared)
}
