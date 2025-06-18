//
//  NotchViewModel+Events.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Cocoa
import Combine
import Foundation
import SwiftUI

extension NotchViewModel {
    func setupCancellables() {
        let events = EventMonitors.shared
        events.mouseDown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation
                switch status {
                case .opened:
                    // touch outside, close
                    if !notchOpenedRect.contains(mouseLocation) {
                        notchClose()
                        // click where user open the panel
                    } else if deviceNotchRect.insetBy(dx: inset, dy: inset).contains(mouseLocation) {
                        notchClose()
                        // for the same height as device notch, open the url of project
                    }
                    else if headlineOpenedRect.contains(mouseLocation) {
                        // 点击标题栏区域时关闭notch
                        // notchClose()
                        // for clicking headline which mouse event may handled by another app
                        // open the menu
                        // if let nextValue = ContentType(rawValue: contentType.rawValue + 1) {
                        //     contentType = nextValue
                        // } else {
                        //     contentType = ContentType(rawValue: 0)!
                        // }
                    }
                case .closed, .popping:
                    // touch inside, open
                    if deviceNotchRect.insetBy(dx: inset, dy: inset).contains(mouseLocation) {
                        notchOpen(.click)
                    }
                }
            }
            .store(in: &cancellables)

        events.optionKeyPress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] input in
                guard let self else { return }
                optionKeyPressed = input
            }
            .store(in: &cancellables)
        
        events.scrollGesture
            .receive(on: DispatchQueue.main)
            .sink { [weak self] direction in
                guard let self else { return }
                // 只在notch打开时响应滑动手势
                guard status == .opened else { return }
                
                // 检查鼠标是否在notch区域内
                let mouseLocation = NSEvent.mouseLocation
                guard notchOpenedRect.contains(mouseLocation) else { return }
                
                let currentType = contentType
                switch direction {
                case .left:
                    switchToPreviousContentType()
                    NotificationCenter.default.post(name: .init("SwipeGesture"), object: "← \(localizedTitle(for: contentType))")
                case .right:
                    switchToNextContentType()
                    NotificationCenter.default.post(name: .init("SwipeGesture"), object: "\(localizedTitle(for: contentType)) →")
                }
                
                print("滑动切换: \(localizedTitle(for: currentType)) → \(localizedTitle(for: contentType))")
                
                // 触发触觉反馈
                hapticSender.send()
            }
            .store(in: &cancellables)

        events.mouseLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mouseLocation in
                guard let self else { return }
                let mouseLocation: NSPoint = NSEvent.mouseLocation
                let aboutToOpen = deviceNotchRect.insetBy(dx: inset, dy: inset).contains(mouseLocation)
                if status == .closed, aboutToOpen { notchPop() }
                if status == .popping, !aboutToOpen { notchClose() }
            }
            .store(in: &cancellables)

        $status
            .filter { $0 != .closed }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                withAnimation { self?.notchVisible = true }
            }
            .store(in: &cancellables)

        $status
            .filter { $0 == .popping }
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard NSEvent.pressedMouseButtons == 0 else { return }
                self?.hapticSender.send()
            }
            .store(in: &cancellables)

        hapticSender
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard self?.hapticFeedback ?? false else { return }
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .levelChange,
                    performanceTime: .now
                )
            }
            .store(in: &cancellables)

        $status
            .debounce(for: 0.5, scheduler: DispatchQueue.global())
            .filter { $0 == .closed }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                withAnimation {
                    self?.notchVisible = false
                }
            }
            .store(in: &cancellables)

        $selectedLanguage
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                self?.notchClose()
                output.apply()
            }
            .store(in: &cancellables)
    }

    func destroy() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    private func localizedTitle(for type: ContentType) -> String {
        switch type {
        case .normal: return "临时"
        case .directory: return "目录"
        case .menu: return "菜单"
        }
    }
}
