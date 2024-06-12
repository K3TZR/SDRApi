//
//  MiscSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 10/20/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature


// ----------------------------------------------------------------------------
// MARK: - View

struct MiscSubView: View {

  @Environment(ApiModel.self) private var apiModel
  @Environment(ObjectModel.self) private var objectModel

  func stringArrayToString( _ list: [String]?) -> String? {
    guard list != nil else {return nil}
    let str = list!.reduce("") {$0 + $1 + ", "}
    return String(str.dropLast(2))
  }
  
  var body: some View {
      HStack {
        VStack(alignment: .leading) {
          Text("Software Version")
          Text("Hardware Version")
          Text("Antenna List")
          Text("Microphone List")
          Text("Radio Uptime")
        }.frame(width: 150)
        
        VStack(alignment: .leading) {
          Text(objectModel.radio?.softwareVersion ?? "---")
          Text(apiModel.hardwareVersion ?? "---")
          Text(stringArrayToString(objectModel.radio?.antList) ?? "---")
          Text(stringArrayToString(objectModel.radio?.micList) ?? "---")
          Text("\(objectModel.radio?.uptime ?? 0)")
        }.foregroundColor(.secondary)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  MiscSubView()
    .environment(ApiModel.shared)
    .environment(ObjectModel.shared)
  
    .frame(width: 1250)
}
