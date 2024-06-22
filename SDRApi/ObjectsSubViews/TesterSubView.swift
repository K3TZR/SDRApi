//
//  TesterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/25/22.
//

import ComposableArchitecture
import SwiftUI

import ListenerFeature
import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct TesterSubView: View {
  
  @Environment(ApiModel.self) private var apiModel
  @Environment(ObjectModel.self) private var objectModel
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 20) {
        
        Text("SDRApi").foregroundColor(.green)
          .font(.title)
        
        HStack(spacing: 5) {
          Text("Bound to Station")
          Text("\(objectModel.activeStation ?? "???")").foregroundColor(.secondary)
        }
        
        HStack(spacing: 5) {
          Text("Handle")
          Text(apiModel.connectionHandle?.hex ?? "???").foregroundColor(.secondary)
        }
        
        HStack(spacing: 5) {
          Text("Client Id")
          Text("\(objectModel.boundClientId ?? "???")").foregroundColor(.secondary)
        }
      }
    }.frame(maxWidth: .infinity, minHeight: 50)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TesterSubView()
    
    .environment(ApiModel.shared)
    .environment(ObjectModel.shared)
  
    .frame(minWidth: 1250)
}
