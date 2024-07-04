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
  var sourceColor: Color

  @Environment(ObjectModel.self) private var objectModel
  
  var body: some View {
    Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 5) {
      if objectModel.tnfs.count > 0 {
        HeaderView(sourceColor: sourceColor)
        ForEach(objectModel.tnfs.sorted(by: <)) { tnf in
          DetailView(tnf: tnf)
        }
        
      } else {
        GridRow {
          Text("TNF".padRight(13))
            .monospaced()
            .gridColumnAlignment(.leading)
            .foregroundColor(sourceColor)

          Text("----- NONE -----").foregroundColor(.red)
        }
      }
    }
  }
}

private struct HeaderView: View {
  var sourceColor: Color

  var body: some View {
    GridRow {
      Text("TNF".padRight(13))
        .monospaced()
        .gridColumnAlignment(.leading)
        .foregroundColor(sourceColor)

      Text("ID")
      Text("Frequency")
      Text("Width").frame(width: 100)
      Text("Depth").frame(width: 100)
      Text("Permanent").frame(width: 100)
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
      
      HStack(spacing: 5) {
        Text(tnf.frequency, format: .number)
        Stepper("", value: Binding(get: {tnf.frequency}, set: {tnf.set(.frequency, String(Double($0)/1_000_000))}), step: 100 )
      }

      HStack(spacing: 5) {
        Text(tnf.width, format: .number)
        Stepper("", value: Binding(get: {tnf.width}, set: {tnf.set(.width, String(Double($0)/1_000_000))}), in: 5...6000, step: 100 )
      }
      
      HStack(spacing: 5) {
        Text(depthName(tnf.depth))
        Stepper("", value: Binding(get: {tnf.depth}, set: {tnf.set(.depth, String($0) )}), in: 1...3, step: 1 )
      }
      
      Toggle("", isOn: Binding(get: {tnf.permanent}, set: {tnf.set(.permanent, $0.as1or0)} ))
        .gridColumnAlignment(.center)
    }
    .lineLimit(1)
    .truncationMode(.middle)
    .foregroundColor(.secondary)    
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TnfSubView(sourceColor: .blue)
    
    .environment(ObjectModel.shared)
  
    .frame(minWidth: 1250)
}
