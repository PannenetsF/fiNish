//
//  fishtimeApp.swift
//  fishtime
//
//  Created by Yunqian Fan on 2023/4/1.
//

import SwiftUI

@main
struct fishtimeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
