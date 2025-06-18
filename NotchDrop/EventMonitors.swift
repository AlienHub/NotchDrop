//
//  EventMonitors.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import Cocoa
import Combine

class EventMonitors {
    static let shared = EventMonitors()

    private var mouseMoveEvent: EventMonitor!
    private var mouseDownEvent: EventMonitor!
    private var mouseDraggingFileEvent: EventMonitor!
    private var optionKeyPressEvent: EventMonitor!
    private var scrollWheelEvent: EventMonitor!

    let mouseLocation: CurrentValueSubject<NSPoint, Never> = .init(.zero)
    let mouseDown: PassthroughSubject<Void, Never> = .init()
    let mouseDraggingFile: PassthroughSubject<Void, Never> = .init()
    let optionKeyPress: CurrentValueSubject<Bool, Never> = .init(false)
    let scrollGesture: PassthroughSubject<ScrollDirection, Never> = .init()
    
    enum ScrollDirection {
        case left
        case right
    }
    
    private var accumulatedScrollX: CGFloat = 0
    private var lastScrollTime: TimeInterval = 0
    private var lastGestureTime: TimeInterval = 0
    private let scrollThreshold: CGFloat = 80 // 累积滑动阈值
    private let gestureInterval: TimeInterval = 1.5 // 手势间隔时间

    private init() {
        mouseMoveEvent = EventMonitor(mask: .mouseMoved) { [weak self] _ in
            guard let self else { return }
            let mouseLocation = NSEvent.mouseLocation
            self.mouseLocation.send(mouseLocation)
        }
        mouseMoveEvent.start()

        mouseDownEvent = EventMonitor(mask: .leftMouseDown) { [weak self] _ in
            guard let self else { return }
            mouseDown.send()
        }
        mouseDownEvent.start()

        mouseDraggingFileEvent = EventMonitor(mask: .leftMouseDragged) { [weak self] _ in
            guard let self else { return }
            mouseDraggingFile.send()
        }
        mouseDraggingFileEvent.start()

        optionKeyPressEvent = EventMonitor(mask: .flagsChanged) { [weak self] event in
            guard let self else { return }
            if event?.modifierFlags.contains(.option) == true {
                optionKeyPress.send(true)
            } else {
                optionKeyPress.send(false)
            }
        }
        optionKeyPressEvent.start()
        
        scrollWheelEvent = EventMonitor(mask: .scrollWheel) { [weak self] event in
            guard let self, let event else { return }
            
            let currentTime = Date().timeIntervalSince1970
            let deltaX = event.scrollingDeltaX
            let deltaY = event.scrollingDeltaY
            
            // 如果距离上次手势触发时间太短，直接忽略
            if currentTime - lastGestureTime < gestureInterval {
                return
            }
            
            // 如果超过1秒没有滑动，重置累积值
            if currentTime - lastScrollTime > 1.0 {
                accumulatedScrollX = 0
            }
            lastScrollTime = currentTime
            
            // 只累积主要是水平方向的滑动，且滑动幅度要足够大
            if abs(deltaX) > 3 && abs(deltaX) > abs(deltaY) * 2.0 {
                accumulatedScrollX += deltaX
                
                // 检查是否达到阈值
                if abs(accumulatedScrollX) > scrollThreshold {
                    // 记录手势触发时间
                    lastGestureTime = currentTime
                    
                    if accumulatedScrollX > 0 {
                        scrollGesture.send(.right)
                    } else {
                        scrollGesture.send(.left)
                    }
                    
                    // 重置累积值
                    accumulatedScrollX = 0
                }
            }
        }
        scrollWheelEvent.start()
    }
}
