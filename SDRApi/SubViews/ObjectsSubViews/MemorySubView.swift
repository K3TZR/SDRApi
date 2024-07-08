//
//  MemorySubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct MemorySubView: View {
  
  @Environment(ObjectModel.self) var objectModel
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      HeadingView()
      if objectModel.memories.count == 0 {
        GridRow {
          Text("None present").foregroundColor(.red)
        }
      } else {
        ForEach(objectModel.memories) { memory in
          DetailView(memory: memory)
        }
      }
    } 
    .frame(minWidth: 1250, maxWidth: .infinity)
  }
}

private struct HeadingView: View {
  var body: some View {
    GridRow {
      Text("MEMORY")
        .frame(width: 100, alignment: .leading)
        .foregroundColor(.yellow)
      Text("Name")
      Text("Group")
      Text("Owner")
      Text("Frequency")
      Text("Mode")
      Text("Step")
      Text("Power")
      Text("Low")
      Text("High")
      Text("Squelch")
      Text("Sq Level")
      Text("Rpt Mode")
      Text("Rpt Offset")
      Text("Tone")
      Text("Tone Value")
      Text("Mark")
      Text("Shift")
      Text("DIGL Upper")
      Text("DIGU Lower")
      Spacer()
    }
    Divider()
  }
}

private struct DetailView: View {
  var memory: Memory
  
  var body: some View {
    
    GridRow {
      Text("\(memory.id)")
        .frame(width: 100, alignment: .leading)
        .foregroundColor(.yellow)
      Text(memory.name).help(memory.name).gridColumnAlignment(.leading)
      Text(memory.group.isEmpty ? "none" : memory.group).gridColumnAlignment(.leading).help(memory.group)
      Text(memory.owner).help(memory.owner).gridColumnAlignment(.leading)
      Text("\(memory.frequency)")
      Text(memory.mode).gridColumnAlignment(.leading)
      Text("\(memory.step)")
      Text("\(memory.rfPower)")
      Text("\(memory.filterLow)")
      Text("\(memory.filterHigh)")
      Text(memory.squelchEnabled ? "Y" : "N").foregroundColor(memory.squelchEnabled ? .green : nil)
      Text("\(memory.squelchLevel)")
      Text(memory.offsetDirection).gridColumnAlignment(.leading)
      Text("\(memory.offset)")
      Text(memory.toneMode).gridColumnAlignment(.leading)
      Text("\(String(format: "%3.0f", memory.toneValue))")
      Text("\(memory.rttyMark)")
      Text("\(memory.rttyShift)")
      Text("\(memory.digitalLowerOffset)")
      Text("\(memory.digitalUpperOffset)")
    }
    .lineLimit(1)
    .truncationMode(.middle)
    .foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MemorySubView()
  
    .environment(ObjectModel())
  
    .frame(width: 1250)
}
