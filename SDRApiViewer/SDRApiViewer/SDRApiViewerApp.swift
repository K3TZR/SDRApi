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
import MessagesFeature
import SettingsFeature
import SharedFeature

final class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ notification: Notification) {
    // disable tab view
    NSWindow.allowsAutomaticWindowTabbing = false
    // disable restoring windows
    UserDefaults.standard.register(defaults: ["NSQuitAlwaysKeepsWindows" : false])
  }
    
  func applicationWillTerminate(_ notification: Notification) {
    SettingsModel.shared.save()
    ApiModel.shared.disconnect()
    log("SDRApiViewer: application terminated", .debug, #function, #file, #line)
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

@main
struct SDRApiViewerApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  @State var apiModel = ApiModel.shared
  @State var listener = Listener.shared
  @State var messagesModel = MessagesModel.shared
  @State var settingsModel = SettingsModel.shared

  var body: some Scene {
    WindowGroup("SDRApiViewer  (v" + Version().string + ")") {
      SDRApiView(store: Store(initialState: SDRApi.State()) {
        SDRApi()
      })
      .environment(apiModel)
      .environment(listener)
      .environment(messagesModel)
      .environment(settingsModel)
    }
  }
}
