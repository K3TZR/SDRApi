//
//  SDRApiApp.swift
//  SDRApi
//
//  Created by Douglas Adams on 12/27/23.
//
import ComposableArchitecture
import SwiftUI

import FlexApiFeature
import ListenerFeature
import SettingsFeature
import XCGLogFeature

// ----------------------------------------------------------------------------
// MARK: - Main

@main
struct SDRApiApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  @State var apiModel = ApiModel.shared
  @State var listenerModel = ListenerModel.shared
  @State var messagesModel = MessagesModel.shared
  @State var objectModel = ObjectModel.shared

  private var testApiModel: ApiModel { apiModel.testDelegate = MessagesModel.shared ; return apiModel }

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
      .environment(testApiModel)
      .environment(listenerModel)
      .environment(messagesModel)
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
    log("SDRApi: application terminated", .debug, #function, #file, #line)
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

// ----------------------------------------------------------------------------
// MARK: - Persistence URL Extension

extension URL {
  static let appSettings = Self
    .applicationSupportDirectory
    .appending(path: "appSettings.json")
}

// ----------------------------------------------------------------------------
// MARK: - PersistenceKey Extension

//extension PersistenceKey
//where Self == PersistenceKeyDefault<FileStorageKey<AppSettings>> {
//  public static var appSettings: Self {
//    PersistenceKeyDefault(
//      .fileStorage(),
//      AppSettings()
//    )
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - Persistence properties

//public struct AppSettings: Codable, Equatable {
//  public var alertOnError = true
//  public var clearOnSend = false
//  public var clearOnStart = true
//  public var clearOnStop = true
//  public var commandsArray = [String]()
//  public var commandsIndex = 0
//  public var commandToSend = ""
//  public var daxSelection = -1
//  public var directEnabled = false
//  public var directGuiIp = ""
//  public var directNonGuiIp = ""
//  public var fontSize = 12
//  public var gotoBottom = false
//  public var guiDefault: String = ""
//  public var isGui = true
//  public var localEnabled = true
//  public var lowBandwidthConnect = false
//  public var lowBandwidthDax = false
//  public var messageFilter: MessageFilter = .all
//  public var messageFilterText = ""
//  public var mtuValue = 1_300
//  public var newLineBetweenMessages = false
//  public var nonGuiDefault: String = ""
//  public var previousCommand = ""
//  public var previousIdToken: String = ""
//  public var radioObjectFilter: RadioObjectFilter = .all
//  public var refreshToken: String = ""
//  public var remoteRxAudioCompressed = false
//  public var remoteRxAudioEnabled = false
//  public var remoteTxAudioEnabled = false
//  public var showPings = false
//  public var showTimes = true
//  public var smartlinkEnabled = false
//  public var smartlinkLoginRequired = false
//  public var smartlinkUser = ""
//  public var station = "SDRApi"
//  public var stationObjectFilter: StationObjectFilter = .noMeters  
//  public var useDefaultEnabled = false
//}
