//
//  SDRApiApp.swift
//  SDRApi
//
//  Created by Douglas Adams on 12/20/23.
//

import Foundation
import SwiftUI

import SettingsModel
import SharedModel

final class AppDelegate: NSObject, NSApplicationDelegate {
  public var isClosing = false
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    // disable tab view
    NSWindow.allowsAutomaticWindowTabbing = false
    // disable restoring windows
    UserDefaults.standard.register(defaults: ["NSQuitAlwaysKeepsWindows" : false])
  }
    
  func applicationWillTerminate(_ notification: Notification) {
    isClosing = true
    log("SDRApi: application terminated", .debug, #function, #file, #line)
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

@main
struct SDRApiApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  @State var messagesModel = MessagesModel.shared
  @State var settingsModel = SettingsModel.shared

  var body: some Scene {

    // Main window
    WindowGroup("Api6000  (v" + Version().string + ")") {
      ApiView()
        .environment(messagesModel)
        .environment(settingsModel)
      .frame(minWidth: 975)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
    }

    // Settings window
    Settings {
      SettingsView()
    }
    .windowStyle(.hiddenTitleBar)
    .windowResizability(WindowResizability.contentSize)
    .defaultPosition(.bottomLeading)

    .commands {
      //remove the "New" menu item
      CommandGroup(replacing: CommandGroupPlacement.newItem) {}
    }
  }
}
