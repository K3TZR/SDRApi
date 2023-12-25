//
//  ObjectsView.swift
//
//
//  Created by Douglas Adams on 5/29/23.
//

import SwiftUI

import FlexApi
import Listener
import SettingsModel
import SharedModel


// ----------------------------------------------------------------------------
// MARK: - View

public struct ObjectsView: View {
  
  @Environment(ApiModel.self) private var api
  @Environment(Listener.self) private var listener
  @Environment(SDRModel.self) private var sdr
  @Environment(SettingsModel.self) private var settings
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      FilterObjectsView()
      
      if api.radio == nil {
        Spacer()
        HStack {
          Spacer()
          Text("Objects will be displayed here")
          Spacer()
        }
        Spacer()
      } else {
        
        ScrollView([.horizontal, .vertical]) {
          VStack(alignment: .leading) {
            RadioSubView()
            
            GuiClientSubView()
            if settings.isGui == false { TesterSubView() }
          }
          .padding(.horizontal, 10)
        }
        .font(.system(size: settings.fontSize, weight: .regular, design: .monospaced))
      }
    }
//    .background(Color(.blue).opacity(0.1))
  }
}

private struct FilterObjectsView: View {
  
  @Environment(SettingsModel.self) private var settings

  var body: some View {
    @Bindable var bindableSettings = settings
      
    HStack {
        Picker("Show Radio Objects of type", selection: $bindableSettings.objectFilter ) {
          ForEach(ObjectFilter.allCases, id: \.self) {
            Text($0.rawValue).tag($0)
          }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 300)
      }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ObjectsView()
    .frame(minWidth: 975)
    .padding()
}
