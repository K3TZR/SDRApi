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
    
  @Environment(ApiModel.self) private var apiModel
  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    
    if objectModel.activePacket != nil {
      ForEach(objectModel.activePacket!.guiClients, id: \.id) { guiClient in
        DetailView(store: store, guiClient: guiClient)
//          .frame(minWidth: 1250, maxWidth: .infinity)
      }
    } else {
      Text("No active packet")
    }
  }
}

private struct DetailView: View {
  let store: StoreOf<SDRApi>
  let guiClient: GuiClient
  
  @State var showSubView = true
  
  var body: some View {
    VStack(alignment: .leading) {
      ScrollView([.vertical, .horizontal]) {
        VStack(alignment: .leading) {
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
            
            //      Toggle("Local PTT", isOn: Binding(get: {guiClient.isLocalPtt}, set: {guiClient.setProperty(.isLocalPtt, $0.as1or0)} ))
            
            HStack(spacing: 5) {
              Text("LocalPtt")
              Text(guiClient.isLocalPtt ? "Y" : "N").foregroundColor(guiClient.isLocalPtt ? .green : .red)
            }
            Spacer()
          }
          .frame(minWidth: 1250, maxWidth: .infinity)
          
          if showSubView {
            GuiClientDetailView(stationObjectFilter: store.appSettings.stationObjectFilter, handle: guiClient.handle)
          }
        }
      }
    }
  }
}




/*
 ScrollView([.vertical, .horizontal]) {
   VStack(alignment: .leading) {
     HStack(spacing: 0) {
       Label("Radio", systemImage: showSubView ? "chevron.down" : "chevron.right")
         .foregroundColor(sourceColor)
         .font(.title)
         .frame(width: 120, alignment: .leading)
         .onTapGesture{ showSubView.toggle() }
         .help("          Tap to toggle details")
       
       Text(objectModel.radio?.packet.nickname ?? "" )
         .foregroundColor(sourceColor)
         .frame(width: 120, alignment: .leading)
       
       Line1View()
     }
     
     if showSubView {  DetailView(store: store, sourceColor: sourceColor) }
   }.frame(maxWidth: .infinity, minHeight: 200)
 }

 */








struct GuiClientDetailView: View {
  var stationObjectFilter: StationObjectFilter
  let handle: UInt32

  var body: some View {
    
    VStack(alignment: .leading) {
      switch stationObjectFilter {
        
      case .all:
        PanadapterSubView(handle: handle, showMeters: true)
        
      case .noMeters:
        PanadapterSubView(handle: handle, showMeters: false)
        
      case .amplifiers:        AmplifierSubView()
      case .cwx:               CwxSubView()
      case .interlock:         InterlockSubView()
      case .memories:          MemorySubView()
      case .meters:            MeterSubView(sliceId: nil, sliceClientHandle: nil, handle: handle)
      case .misc:              MiscSubView()
      case .network:           NetworkSubView()
      case .profiles:          ProfileSubView()
      case .streams:           StreamSubView(handle: handle)
      case .usbCable:          UsbCableSubView()
      case .wan:               WanSubView()
      case .waveforms:         WaveformSubView()
      case .xvtrs:             XvtrSubView()
      }
    }      
//    .frame(minWidth: 1250, maxWidth: .infinity)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  GuiClientSubView(store: Store(initialState: SDRApi.State()) {
    SDRApi()
  })
  .environment(ApiModel.shared)
  .environment(ListenerModel.shared)
  .environment(ObjectModel.shared)
}
