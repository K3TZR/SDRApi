//
//  StreamSubView.swift
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

struct StreamSubView: View {
  let handle: UInt32

  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 10) {
      
      // Meter
      MeterStreamView()
      
      // Panadapter
      ForEach(objectModel.panadapters) { panadapter in
        if handle == panadapter.clientHandle { PanadapterStreamView(panadapter: panadapter) }
      }
      
      // Waterfall
      ForEach(objectModel.waterfalls) { waterfall in
        if handle == waterfall.clientHandle { WaterfallStreamView(waterfall: waterfall) }
      }
      
      // RemoteRxAudio
      if let rxAudio = objectModel.remoteRxAudio {
        if handle == rxAudio.clientHandle { RemoteRxStreamView(remoteRxAudio: rxAudio) }
      }
      
      // RemoteTxAudio
      if let remoteTxAudio = objectModel.remoteTxAudio {
        if handle == remoteTxAudio.clientHandle { RemoteTxStreamView(remoteTxAudio: remoteTxAudio) }
      }
      
      // DaxMicAudio
      if let daxMicAudio = objectModel.daxMicAudio {
        if handle == daxMicAudio.clientHandle { DaxMicStreamView(daxMicAudio: daxMicAudio) }
      }
      
      // DaxRxAudio
      ForEach(objectModel.daxRxAudios) { daxRxAudio in
        if handle == daxRxAudio.clientHandle { DaxRxStreamView(daxRxAudio: daxRxAudio) }
      }
      
      // DaxTxAudio
      if let daxTxAudio = objectModel.daxTxAudio {
        if handle == daxTxAudio.clientHandle { DaxTxStreamView(daxTxAudio: daxTxAudio) }
      }
      
      // DaxIq
      ForEach(objectModel.daxIqs) { daxIq in
        if handle == daxIq.clientHandle { DaxIqStreamView(daxIq: daxIq) }
      }
    }
    .frame(minWidth: 1250, maxWidth: .infinity)
//    .padding(.leading, 20)
  }
}

private struct MeterStreamView: View {
  
  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    
    GridRow {
      Text("METER").frame(width: 100, alignment: .leading)
      Text(ObjectModel.shared.meterStream?.id.hex ?? "0x0").foregroundColor(.green)
      Spacer()
    }
  }
}

private struct PanadapterStreamView: View {
  var panadapter: Panadapter
  
  var body: some View {
    
    GridRow {
      Text("PANADAPTER").frame(width: 100, alignment: .leading)
      Text(panadapter.id.hex).foregroundColor(.secondary)
    }
  }
}

private struct WaterfallStreamView: View {
  var waterfall: Waterfall
  
  var body: some View {
    
    GridRow {
      Text("WATERFALL").frame(width: 100, alignment: .leading)
      Text(waterfall.id.hex).foregroundColor(.secondary)
    }
  }
}

private struct RemoteRxStreamView: View {
  var remoteRxAudio: RemoteRxAudio
  
  var body: some View {
    
    GridRow {
      Text("REMOTE Rx").frame(width: 100, alignment: .leading)
      Text(remoteRxAudio.id.hex).foregroundColor(.secondary)
      HStack(spacing: 5) {
        Text("Handle")
        Text("\(remoteRxAudio.clientHandle.hex)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Compression")
        Text("\(remoteRxAudio.compression)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Ip")
        Text("\(remoteRxAudio.ip)").foregroundColor(.secondary)
      }
    }
  }
}

private struct RemoteTxStreamView: View {
  var remoteTxAudio: RemoteTxAudio
  
  var body: some View {
    
    GridRow {
      Text("REMOTE Tx").frame(width: 100, alignment: .leading)
      Text(remoteTxAudio.id.hex).foregroundColor(.secondary)
      HStack(spacing: 5) {
        Text("Handle")
        Text("\(remoteTxAudio.clientHandle.hex)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Compression")
        Text("\(remoteTxAudio.compression)").foregroundColor(.secondary)
      }
    }
  }
}

private struct DaxMicStreamView: View {
  var daxMicAudio: DaxMicAudio
  
  var body: some View {
    
    GridRow {
      Text("DAX Mic").frame(width: 100, alignment: .leading)
      Text(daxMicAudio.id.hex).foregroundColor(.secondary)
      HStack(spacing: 5) {
        Text("Handle")
        Text("\(daxMicAudio.clientHandle.hex)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Ip")
        Text("\(daxMicAudio.ip)").foregroundColor(.secondary)
      }
    }
  }
}

private struct DaxRxStreamView: View {
  var daxRxAudio: DaxRxAudio
  
  var body: some View {
    
    GridRow {
      Text("DAX Rx").frame(width: 100, alignment: .leading)
      Text(daxRxAudio.id.hex).foregroundColor(.secondary)
      HStack(spacing: 5) {
        Text("Handle")
        Text("\(daxRxAudio.clientHandle.hex)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Channel")
        Text("\(daxRxAudio.daxChannel)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Ip")
        Text("\(daxRxAudio.ip)").foregroundColor(.secondary)
      }
    }
  }
}

private struct DaxTxStreamView: View {
  var daxTxAudio: DaxTxAudio
  
  var body: some View {
    
    GridRow {
      Text("DAX Tx").frame(width: 100, alignment: .leading)
      Text(daxTxAudio.id.hex).foregroundColor(.secondary)
      HStack(spacing: 5) {
        Text("Handle")
        Text("\(daxTxAudio.clientHandle.hex)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Ip")
        Text("\(daxTxAudio.ip)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Transmit")
        Text("\(daxTxAudio.isTransmitChannel ? "Y" : "N")").foregroundColor(daxTxAudio.isTransmitChannel ? .green : .red)
      }
    }
  }
}

private struct DaxIqStreamView: View {
  var daxIq: DaxIq
  
  var body: some View {
    
    GridRow {
      Text("DAX IQ").frame(width: 100, alignment: .leading)
      Text(daxIq.id.hex).foregroundColor(.secondary)
      HStack(spacing: 5) {
        Text("Handle")
        Text("\(daxIq.clientHandle.hex)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Ip")
        Text("\(daxIq.ip)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Channel")
        Text("\(daxIq.channel)").foregroundColor(.secondary)
      }
      HStack(spacing: 5) {
        Text("Pan")
        Text(daxIq.pan.hex).foregroundColor(.secondary)
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  StreamSubView(handle: 1)
    .environment(ObjectModel.shared)
//    .environment(StreamModel.shared)
}
