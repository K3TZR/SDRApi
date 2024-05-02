//
//  TnfSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct TnfSubView: View {
  
  @Environment(ObjectModel.self) private var objectModel
  
  var body: some View {
    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 5) {
      if objectModel.tnfs.count > 0 {
        HeaderView()
        ForEach(objectModel.tnfs.sorted(by: <)) { tnf in
          DetailView(tnf: tnf)
        }
        
      } else {
        GridRow {
          Text("TNF          ")
            .monospaced()
            .gridColumnAlignment(.leading)
            .foregroundColor(.yellow)

          Text("----- NONE -----").foregroundColor(.red)
        }
      }
    }
  }
}

private struct HeaderView: View {
  
  var body: some View {
    GridRow {
      Text("TNF          ")
        .monospaced()
        .gridColumnAlignment(.leading)
        .foregroundColor(.yellow)

      Text("ID")
      Text("Frequency")
      Text("Width")
      Text("Depth")
      Text("Permanent")
    }
  }
}

private struct DetailView: View {
  var tnf: Tnf
  
  func depthName(_ depth: UInt) -> String {
    switch depth {
    case 1: return "Normal"
    case 2: return "Deep"
    case 3: return "Very Deep"
    default:  return "Invalid"
    }
  }
  
  var body: some View {
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(tnf.id.formatted(.number))
      Text(tnf.frequency.formatted(.number))
      Text(tnf.width.formatted(.number))
      Text(depthName(tnf.depth))
      Text(tnf.permanent ? "Y" : "N").foregroundColor(tnf.permanent ? .green : nil)
    }
    .lineLimit(1)
    .truncationMode(.middle)
    .foregroundColor(.secondary)    
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TnfSubView()
    .environment(ApiModel.shared)
}
