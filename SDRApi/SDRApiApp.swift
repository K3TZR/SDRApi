//
//  SDRApiApp.swift
//  SDRApi
//
//  Created by Douglas Adams on 12/20/23.
//

import Foundation
import SwiftUI

import FlexApi
import Listener
import RxAVAudioPlayer
import SettingsModel
import SettingsPanel
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
    SettingsModel.shared.save()
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

  @State var api = ApiModel.shared
  @State var settings = SettingsModel.shared
  @State var listener = Listener.shared
  @State var messages = MessagesModel.shared
  @State var rxAVAudioPlayer = RxAVAudioPlayer.shared

  var body: some Scene {

    // Main window
    WindowGroup("SDRApi  (v" + Version().string + ")") {
      ApiView()
        .environment(api)
        .environment(listener)
        .environment(messages)
        .environment(settings)
        .environment(SDRModel(api, listener, messages, settings, rxAVAudioPlayer))
        .environment(rxAVAudioPlayer)
      .frame(minWidth: 975)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
    }

    // Settings window
    Settings {
      SettingsView()
        .environment(api)
        .environment(settings)
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
