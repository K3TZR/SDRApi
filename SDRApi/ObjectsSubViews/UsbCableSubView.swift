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

  @Environment(ApiModel.self) private var apiModel
  @Environment(ObjectModel.self) var objectModel

  let post = String(repeating: " ", count: 1)
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      Group {
        if objectModel.usbCables.count == 0 {
          GridRow {
            Group {
              Text("USBCABLEs")
              Text("None present").foregroundColor(.red)
            }
//            .frame(width: 100, alignment: .leading)
          }
          
        } else {
          HeadingView()
          ForEach(objectModel.usbCables) { cable in
            Group {
              Row1View(cable: cable)
//              Row2View(cable: cable)
            }
//            .frame(width: 100, alignment: .leading)
          }
        }
      }
    }.padding(.leading, 20)
  }
}

private struct HeadingView: View {
  var body: some View {
    GridRow {
      Text("USBCABLE")
      Text("Type")
      Text("Name").frame(width: 200)
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

private struct Row1View: View {
  var cable: UsbCable
  
  var body: some View {
    GridRow {
      Text(cable.id)
      Text(cable.cableType)
      Text(cable.name).help(cable.name)
      Text(cable.source).help(cable.source)
      Text(cable.enable ? "Y" : "N").foregroundColor(cable.enable ? .green : .red)
      Text(cable.band)
      Text(cable.polarity)
      Text(cable.flowControl)
      Text(String(format: "%2d", cable.dataBits))
      Text(String(format: "%2d", cable.stopBits))
      Text(cable.parity)
      Text("\(cable.speed)")
      Text(cable.sourceRxAnt)
      Text(cable.sourceTxAnt)
      Text(String(format: "%2d", cable.sourceSlice))
      Text(cable.preamp)
      Text(cable.usbLog ? "Y" : "N").foregroundColor(cable.usbLog ? .green : .red)
      Text(cable.autoReport ? "Y" : "N").foregroundColor(cable.autoReport ? .green : .red)
    }
    .lineLimit(1)
    .truncationMode(.middle)
    .foregroundColor(.secondary)
  }
}

//private struct Row2View: View {
//  var cable: UsbCable
//  
//  var body: some View {
//    
//    GridRow {
//      HStack(spacing: 5) {
//        Text(cable.parity).foregroundColor(.secondary)
//      }
//      
//      HStack(spacing: 5) {
//        Text("\(cable.speed)").foregroundColor(.secondary)
//      }
//      
//      HStack(spacing: 5) {
//        Text(cable.sourceRxAnt).foregroundColor(.secondary)
//      }
//      
//      HStack(spacing: 5) {
//        Text(cable.sourceTxAnt).foregroundColor(.secondary)
//      }
//      
//      HStack(spacing: 5) {
//        Text(String(format: "%2d", cable.sourceSlice)).foregroundColor(.secondary)
//      }
//      
//      HStack(spacing: 5) {
//        Text(cable.preamp).foregroundColor(.secondary)
//      }
//      
//      HStack(spacing: 5) {
//        Text(cable.usbLog ? "Y" : "N").foregroundColor(cable.usbLog ? .green : .red)
//      }
//      
//      HStack(spacing: 5) {
//        Text(cable.autoReport ? "Y" : "N").foregroundColor(cable.autoReport ? .green : .red)
//      }
//    }
//  }
//}


// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  UsbCableSubView()
    .environment(ApiModel.shared)
}
