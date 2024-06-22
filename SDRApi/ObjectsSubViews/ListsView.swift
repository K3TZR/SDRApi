//
//  ListsView.swift
//  SDRApi
//
//  Created by Douglas Adams on 5/2/24.
//

import SwiftUI

import FlexApiFeature

struct ListsView: View {
  var sourceColor: Color
  
  @Environment(ObjectModel.self) var objectModel

  func stringArrayToString( _ list: [String]?) -> String {
    guard list != nil else { return "Unknown"}
    let str = list!.reduce("") {$0 + $1 + ", "}
    return String(str.dropLast(2))
  }
  
  func uint32ArrayToString( _ list: [UInt32]) -> String {
    let str = list.reduce("") {String($0) + String($1) + ", "}
    return String(str.dropLast(2))
  }
  
  var body: some View {
   
    if let radio = objectModel.radio {
      Grid(alignment: .leading, horizontalSpacing: 30) {
        GridRow {
          Text("LISTS")
            .frame(width: 100, alignment: .leading)
            .foregroundColor(sourceColor)
          
          HStack(spacing: 5) {
            Text("Ant List")
            Text(stringArrayToString(radio.antList)).foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Mic List")
            Text(stringArrayToString(radio.micList)).foregroundColor(.secondary)
          }
        }
      }
    }
  }
}

#Preview {
  ListsView(sourceColor: .blue)
  
    .environment(ObjectModel.shared)
  
    .frame(width: 1250)
}
