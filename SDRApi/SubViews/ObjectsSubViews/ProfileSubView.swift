//
//  ProfileSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 8/9/22.
//

import ComposableArchitecture
import SwiftUI

import FlexApiFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct ProfileSubView: View {

  @Environment(ObjectModel.self) private var objectModel

  var body: some View {
    
    if objectModel.profiles.count == 0 {
      Grid(alignment: .leading, horizontalSpacing: 10) {
        GridRow {
          Text("PROFILE")
            .frame(width: 100, alignment: .leading)
            .foregroundColor(.yellow)
          Text("----- NONE -----").foregroundColor(.red)
        }
      }
      
    } else {
      Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
        HeadingView()
        ForEach(objectModel.profiles) { profile in
          DetailView(profile: profile)
        }
      }
    }
  }
}

private struct HeadingView: View {
  
  var body: some View {
    GridRow {
      Text("PROFILE")
        .frame(width: 100, alignment: .leading)
        .foregroundColor(.yellow)
      
      Text("Current")
      Text("List")
      Spacer()
    }
  }
}

private struct DetailView: View {
  var profile: Profile
  
  @MainActor var list: String {
    profile.list.formatted(.list(type: .and)).replacingOccurrences(of: ", and ", with: ", ")
  }
  
  var body: some View {
    GridRow {
      Text(profile.id.uppercased())
        .frame(width: 100, alignment: .leading)
        .foregroundColor(.yellow)

      Text(profile.current)
      
      Text(list)
    }.foregroundColor(.secondary)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  ProfileSubView()

    .environment(ObjectModel.shared)

    .frame(width: 1250)
}
