//
//  SDRApiViewerApp.swift
//  SDRApiViewer
//
//  Created by Douglas Adams on 12/27/23.
//
import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import ListenerFeature
import XCGLogFeature

// ----------------------------------------------------------------------------
// MARK: - Main

@main
struct SDRApiViewerApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  @State var apiModel = ApiModel.shared
  @State var listenerModel = ListenerModel.shared
  @State var objectModel = ObjectModel.shared
  @State var streamModel = StreamModel.shared

  var body: some Scene {
    WindowGroup("SDRApi  (v" + Version().string + ")") {
      SDRApiView(store: Store(initialState: SDRApi.State()) {
        SDRApi()
      })
      .environment(apiModel)
      .environment(listenerModel)
      .environment(objectModel)
      .environment(streamModel)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - App Delegate

final class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ notification: Notification) {
    // disable tab view
    NSWindow.allowsAutomaticWindowTabbing = false
    // disable restoring windows
    UserDefaults.standard.register(defaults: ["NSQuitAlwaysKeepsWindows" : false])
  }
    
  func applicationWillTerminate(_ notification: Notification) {
    ApiModel.shared.disconnect()
    log("SDRApiViewer: application terminated", .debug, #function, #file, #line)
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

// ----------------------------------------------------------------------------
// MARK: - Global struct

/// Struct to hold a Semantic Version number
public struct Version {
  public var major: Int = 1
  public var minor: Int = 0
  public var build: Int = 0
  
  // can be used directly in packages
  public init(_ versionString: String = "1.0.0") {
    let components = versionString.components(separatedBy: ".")
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      build = Int(components[2]) ?? 0
  }
  
  // only useful for Apps & Frameworks (which have a Bundle), not Packages
  public init() {
    let versions = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "?"
    let build   = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as? String ?? "?"
    self.init(versions + ".\(build)")
  }
  
  public var string: String { "\(major).\(minor).\(build)" }
}
