//
//  SDRApiApp.swift
//  SDRApi
//
//  Created by Douglas Adams on 12/27/23.
//
import ComposableArchitecture
import os
import SwiftUI

import FlexApiFeature
import ListenerFeature

public let appLog = Logger(subsystem: "net.k3tzr.sdrApi", category: "Application")

// ----------------------------------------------------------------------------
// MARK: - Main

@main
struct SDRApiApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  @State var apiModel = ApiModel.shared
  @State var listenerModel = ListenerModel.shared
  @State var objectModel = ObjectModel.shared

//  private var testApiModel: ApiModel { apiModel.testDelegate = MessagesModel.shared ; return apiModel }

  /// Struct to hold a Semantic Version number
  private struct Version {
    var major: Int = 1
    var minor: Int = 0
    var build: Int = 0
    
    // can be used directly in packages
    init(_ versionString: String = "1.0.0") {
      let components = versionString.components(separatedBy: ".")
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      build = Int(components[2]) ?? 0
    }
    
    // only useful for Apps & Frameworks (which have a Bundle), not Packages
    init() {
      let versions = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "?"
      let build   = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as? String ?? "?"
      self.init(versions + ".\(build)")
    }
    
    var string: String { "\(major).\(minor).\(build)" }
  }

  var body: some Scene {
    
    // Main window
    WindowGroup("SDRApi  (v" + Version().string + ")") {
      SDRApiView(store: Store(initialState: SDRApi.State()) {
        SDRApi()
      })
      .environment(apiModel)
      .environment(listenerModel)
      .environment(objectModel)
    }
    
    // Settings window
//    Settings {
//      SettingsView(store: Store(initialState: SettingsCore.State()) {
//        SettingsCore()
//      })
//        .environment(apiModel)
//        .environment(objectModel)
//    }
//    .windowStyle(.hiddenTitleBar)
//    .windowResizability(WindowResizability.contentSize)
//    .defaultPosition(.bottomLeading)
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
    appLog.debug("SDRApi: application terminated")
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}
