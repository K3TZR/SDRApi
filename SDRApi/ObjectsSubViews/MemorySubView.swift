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
  
  @Environment(ApiModel.self) private var apiModel
  @Environment(ObjectModel.self) var objectModel

  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      if objectModel.memories.count == 0 {
        GridRow {
          Text("MEMORYs")
          Text("None present").foregroundColor(.red)
        }
        
      } else {
        HeadingView()
        ForEach(objectModel.memories) { memory in
          Group {
            DetailView(memory: memory)
//            Row2View(memory: memory)
          }
        }
      }
    }
  }
}

private struct HeadingView: View {
  var body: some View {
    GridRow {
      Text("MEMORY").border(.red)
      Text("Name")
      Text("Group")
      Text("Owner")
      Text("Frequency")
      Text("Mode")
      Text("Step")
      Text("Power")
      Text("Low")
      Text("High")
    }
    Divider()
  }
}

private struct DetailView: View {
  var memory: Memory
  
  var body: some View {
    
    GridRow {
      Text("\(memory.id)").gridColumnAlignment(.trailing)
      Text(memory.name).help(memory.name)
      Text(memory.group.isEmpty ? "none" : memory.group).help(memory.group)
      Text(memory.owner).help(memory.owner)
      Text("\(memory.frequency)").gridColumnAlignment(.trailing)
      Text(memory.mode)
      Text("\(memory.step)").gridColumnAlignment(.trailing)
      Text("\(memory.rfPower)").gridColumnAlignment(.trailing)
      Text("\(memory.filterLow)").gridColumnAlignment(.trailing)
      Text("\(memory.filterHigh)").gridColumnAlignment(.trailing)
    }
    .lineLimit(1)
    .truncationMode(.middle)
    .foregroundColor(.secondary)
  }
}

//private struct Row2View: View {
//  var memory: Memory
//  
//  var body: some View {
//    GridRow {
//      Group {
//        HStack(spacing: 5) {
//          Text("")
//          Text("")
//        }
//        HStack(spacing: 5) {
//          Text("Squelch")
//          Text(memory.squelchEnabled ? "Y" : "N").foregroundColor(memory.squelchEnabled ? .green : .red)
//        }
//        HStack(spacing: 5) {
//          Text("Sq Level")
//          Text("\(memory.squelchLevel)").foregroundColor(.green)
//        }
//        HStack(spacing: 5) {
//          Text("Rep")
//          Text(memory.offsetDirection).foregroundColor(.green)
//        }
//        HStack(spacing: 5) {
//          Text("Rep Off")
//          Text("\(memory.offset)").foregroundColor(.green)
//        }
//      }
//      Group {
//        HStack(spacing: 5) {
//          Text("Tone")
//          Text(memory.toneMode).foregroundColor(.green)
//        }
//        HStack(spacing: 5) {
//          Text("T Value")
//          Text("\(String(format: "%3.0f", memory.toneValue))").foregroundColor(.green)
//        }
//        HStack(spacing: 5) {
//          Text("Mark")
//          Text("\(memory.rttyMark)").foregroundColor(.green)
//        }
//        HStack(spacing: 5) {
//          Text("Shift")
//          Text("\(memory.rttyShift)").foregroundColor(.green)
//        }
//        HStack(spacing: 5) {
//          Text("DIGL")
//          Text("\(memory.digitalLowerOffset)").foregroundColor(.green)
//        }
//        HStack(spacing: 5) {
//          Text("DIGU")
//          Text("\(memory.digitalUpperOffset)").foregroundColor(.green)
//        }
//      }
//    }
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MemorySubView()
    .environment(ApiModel.shared)
}
