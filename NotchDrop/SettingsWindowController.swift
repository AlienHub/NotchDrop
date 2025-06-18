//
//  SettingsWindowController.swift
//  NotchDrop
//
//  Created by alien on 2025/6/17.
//

import Cocoa
import SwiftUI

class SettingsWindowController: NSWindowController {
    var vm: NotchViewModel?
    
    init(vm: NotchViewModel) {
        self.vm = vm
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: window)
        
        window.title = NSLocalizedString("Settings", comment: "Settings window title")
        window.center()
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.hidesOnDeactivate = false
        window.minSize = NSSize(width: 600, height: 350)
        
        // 创建SwiftUI视图控制器
        let settingsView = NotchSettingsView(vm: vm)
        let hostingController = NSHostingController(rootView: settingsView)
        window.contentViewController = hostingController
        
        // 设置窗口属性
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWindow() {
        if let window = window {
            if window.isVisible {
                window.orderFront(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
            }
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func hideWindow() {
        window?.orderOut(nil)
    }
} 