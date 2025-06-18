//
//  NotchContentView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//  Last Modified by 冷月 on 2025/5/5.
//

import ColorfulX
import SwiftUI
import UniformTypeIdentifiers

struct NotchContentView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        ZStack {
            switch vm.contentType {
            case .normal:
                HStack(spacing: vm.spacing) {
                    if vm.showAirDrop {
                        ShareView(vm: vm, type: .airdrop)
                    }
                    if vm.showGenericShare {
                        ShareView(vm: vm, type: .generic)
                    }
                    TrayView(vm: vm)
                        .frame(maxWidth: .infinity) // 当分享功能被隐藏时，让TrayView占据更多空间
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            case .directory:
                DirectoryContentView(vm: vm)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            case .menu:
                NotchMenuView(vm: vm)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(vm.animation, value: vm.contentType)
    }
}

// MARK: - Previews

#Preview("Normal Mode") {
    NotchContentView(vm: {
        let vm = NotchViewModel()
        vm.contentType = .normal
        return vm
    }())
    .padding()
    .frame(width: 600, height: 150)
    .background(.black)
    .preferredColorScheme(.dark)
}

#Preview("Directory Mode") {
    NotchContentView(vm: {
        let vm = NotchViewModel()
        vm.contentType = .directory
        vm.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        return vm
    }())
    .padding()
    .frame(width: 600, height: 150)
    .background(.black)
    .preferredColorScheme(.dark)
}

#Preview("Menu Mode") {
    NotchContentView(vm: {
        let vm = NotchViewModel()
        vm.contentType = .menu
        return vm
    }())
    .padding()
    .frame(width: 600, height: 150)
    .background(.black)
    .preferredColorScheme(.dark)
}

#Preview("Normal Mode - Only TrayView") {
    NotchContentView(vm: {
        let vm = NotchViewModel()
        vm.contentType = .normal
        vm.showAirDrop = false
        vm.showGenericShare = false
        return vm
    }())
    .padding()
    .frame(width: 600, height: 150)
    .background(.black)
    .preferredColorScheme(.dark)
}

#Preview("Normal Mode - Only AirDrop") {
    NotchContentView(vm: {
        let vm = NotchViewModel()
        vm.contentType = .normal
        vm.showAirDrop = true
        vm.showGenericShare = false
        return vm
    }())
    .padding()
    .frame(width: 600, height: 150)
    .background(.black)
    .preferredColorScheme(.dark)
}
