//
//  UsbCableSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/10/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct UsbCableSubView: View {
  
  @Environment(ObjectModel.self) var objectModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 30, verticalSpacing: 5) {
      HeadingView()
      if objectModel.usbCables.count == 0 {
        GridRow {
          Text("----- NONE -----").foregroundColor(.red)
        }
      } else {
        ForEach(objectModel.usbCables) { cable in
          DetailView(cable: cable)
        }
      }
    }
  }
}

private struct HeadingView: View {
  var body: some View {
    GridRow {
      Text("USB CABLE    ")
        .monospaced()
        .foregroundColor(.yellow)
      
      Text("Type")
      Text("Name")
      Text("Source")
      Text("Enabled")
      Text("Band")
      Text("Polarity")
      Text("Flow_Control")
      Text("Data_Bits")
      Text("Stop_Bits")
      Text("Parity")
      Text("Speed")
      Text("Source_Rx_Ant")
      Text("Source_Tx_Ant")
      Text("Source_Slice")
      Text("Preamp")
      Text("UsbLog")
      Text("Auto_Report")
    }
    Divider()
  }
}

private struct DetailView: View {
  var cable: UsbCable
  
  var body: some View {
    GridRow {
      Text(cable.id)
      Text(cable.cableType)
      Text(cable.name).help(cable.name)
      Text(cable.source).help(cable.source)
      Text(cable.enable ? "Y" : "N").foregroundColor(cable.enable ? .green : nil).gridColumnAlignment(.trailing)
      Text(cable.band)
      Text(cable.polarity)
      Text(cable.flowControl)
      Text(cable.dataBits.formatted(.number)).gridColumnAlignment(.trailing)
      Text(cable.stopBits.formatted(.number)).gridColumnAlignment(.trailing)
      Text(cable.parity)
      Text("\(cable.speed)").gridColumnAlignment(.trailing)
      Text(cable.sourceRxAnt)
      Text(cable.sourceTxAnt)
      Text(cable.sourceSlice.formatted(.number)).gridColumnAlignment(.trailing)
      Text(cable.preamp).gridColumnAlignment(.trailing)
      Text(cable.usbLog ? "Y" : "N").foregroundColor(cable.usbLog ? .green : nil).gridColumnAlignment(.trailing)
      Text(cable.autoReport ? "Y" : "N").foregroundColor(cable.autoReport ? .green : nil).gridColumnAlignment(.trailing)
    }
    .lineLimit(1)
    .truncationMode(.middle)
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  UsbCableSubView()
    .environment(ApiModel.shared)
}
