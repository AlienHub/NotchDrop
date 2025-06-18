//
//  NotchHeaderView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import ColorfulX
import SwiftUI

struct NotchHeaderView: View {
    @StateObject var vm: NotchViewModel
    @State private var showSwipeIndicator = false
    @State private var swipeDirection: String = ""

    private let mainViewTypes: [NotchViewModel.ContentType] = [.normal, .directory, .menu]
    
    private func localizedTitle(for type: NotchViewModel.ContentType) -> String {
        switch type {
        case .normal: return "临时"
        case .directory: return "目录"
        case .menu: return "菜单"
        }
    }

    private var displayTitle: String {
        return "Notch Drop"
    }
    
    private var titleWithHint: some View {
        VStack(spacing: 2) {
            Text(displayTitle)
                .contentTransition(.numericText())
                .lineLimit(1)
                .truncationMode(.middle)
                .font(.system(.headline, design: .rounded))
            
            Text(NSLocalizedString("Two-finger swipe to switch", comment: "Swipe tip"))
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .opacity(vm.status == .opened ? 1 : 0)
        }
    }

    var body: some View {
        HStack {
            titleWithHint
            
            Spacer()
            
            // 滑动指示器
            if showSwipeIndicator {
                Text(swipeDirection)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .transition(.opacity)
            }
            
            viewSwitcherButtons 
        }
        .frame(height: 32)
        .animation(vm.animation, value: vm.contentType)
        .onReceive(NotificationCenter.default.publisher(for: .init("SwipeGesture"))) { notification in
            if let direction = notification.object as? String {
                swipeDirection = direction
                showSwipeIndicator = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showSwipeIndicator = false
                }
            }
        }
    }
    
    private var viewSwitcherButtons: some View {
        HStack(spacing: 4) {
            ForEach(mainViewTypes, id: \.self) { type in
                Button(action: {
                    handleButtonTap(for: type)
                }) {
                    buttonContent(for: type)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.3))
        )
    }
    
    private func buttonContent(for type: NotchViewModel.ContentType) -> some View {
        let isSelected = vm.contentType == type
        return Text(localizedTitle(for: type))
            .font(.caption)
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.white : Color.clear)
            )
    }
    
    private func handleButtonTap(for type: NotchViewModel.ContentType) {
        // 统一处理，只改变内容类型，不重新打开notch
        vm.contentType = type
    }
}

// MARK: - Previews

#Preview("Normal State") {
    NotchHeaderView(vm: {
        let vm = NotchViewModel()
        vm.contentType = .normal
        return vm
    }())
    .padding()
    .frame(width: 600, height: 50)
    .background(.black)
    .preferredColorScheme(.dark)
}

#Preview("Directory State") {
    NotchHeaderView(vm: {
        let vm = NotchViewModel()
        vm.contentType = .directory
        return vm
    }())
    .padding()
    .frame(width: 600, height: 50)
    .background(.black)
    .preferredColorScheme(.dark)
}

#Preview("Menu State") {
    NotchHeaderView(vm: {
        let vm = NotchViewModel()
        vm.contentType = .menu
        return vm
    }())
    .padding()
    .frame(width: 600, height: 50)
    .background(.black)
    .preferredColorScheme(.dark)
}
