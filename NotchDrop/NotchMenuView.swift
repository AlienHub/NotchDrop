//
//  NotchMenuView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/11.
//

import ColorfulX
import SwiftUI

struct NotchMenuView: View {
    @StateObject var vm: NotchViewModel
    @StateObject var tvm = TrayDrop.shared

    var body: some View {
        HStack(spacing: vm.spacing) {
            close
            github
            donate
            directory
            settings
            clear
        }
    }

    var github: some View {
        ColorButton(
            color: ColorfulPreset.colorful.colors,
            image: Image(.gitHub),
            title: "GitHub"
        )
        .onTapGesture {
            NSWorkspace.shared.open(productPage)
            vm.notchClose()
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }

    var donate: some View {
        ColorButton(
            color: ColorfulPreset.colorful.colors,
            image: Image(systemName: "heart.fill"),
            title: "Love Drop"
        )
        .onTapGesture {
            NSWorkspace.shared.open(sponsorPage)
            vm.notchClose()
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }

    var close: some View {
        ColorButton(
            color: [.red],
            image: Image(systemName: "xmark"),
            title: "Exit"
        )
        .onTapGesture {
            vm.notchClose()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                NSApp.terminate(nil)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }

    var clear: some View {
        ColorButton(
            color: [.red],
            image: Image(systemName: "trash"),
            title: "Clear"
        )
        .onTapGesture {
            tvm.removeAll()
            vm.notchClose()
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }

    var directory: some View {
        ColorButton(
            color: ColorfulPreset.colorful.colors,
            image: Image(systemName: "folder.fill"),
            title: "Directory"
        )
        .onTapGesture {
            vm.showDirectory()
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }

    var settings: some View {
        ColorButton(
            color: ColorfulPreset.colorful.colors,
            image: Image(systemName: "gear"),
            title: LocalizedStringKey("Settings")
        )
        .onTapGesture {
            // 关闭notch并打开独立设置窗口
            vm.notchClose()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.showSettings()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: vm.cornerRadius))
    }
}

private struct ColorButton: View {
    let color: [Color]
    let image: Image
    let title: LocalizedStringKey

    @State var hover: Bool = false

    var body: some View {
        Color.white
            .opacity(0.1)
            .overlay(
                ColorfulView(
                    color: .constant(color),
                    speed: .constant(0)
                )
                .mask {
                    VStack(spacing: 8) {
                        Text("888888")
                            .hidden()
                            .overlay {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        Text(title)
                    }
                    .font(.system(.headline, design: .rounded))
                }
                .contentShape(Rectangle())
                .scaleEffect(hover ? 1.05 : 1)
                .animation(.spring, value: hover)
                .onHover { hover = $0 }
            )
            .aspectRatio(1, contentMode: .fit)
            .contentShape(Rectangle())
    }
}

// MARK: - Previews

#Preview("NotchMenuView") {
    NotchMenuView(vm: .init())
        .padding()
        .frame(width: 600, height: 150)
        .background(.black)
        .preferredColorScheme(.dark)
}

#Preview("Individual Buttons") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ColorButton(
                color: [.red],
                image: Image(systemName: "xmark"),
                title: "Exit"
            )
            .frame(width: 80, height: 80)
            
            ColorButton(
                color: ColorfulPreset.colorful.colors,
                image: Image(systemName: "gear"),
                title: "Settings"
            )
            .frame(width: 80, height: 80)
        }
        
        HStack(spacing: 20) {
            ColorButton(
                color: ColorfulPreset.colorful.colors,
                image: Image(systemName: "folder.fill"),
                title: "Directory"
            )
            .frame(width: 80, height: 80)
            
            ColorButton(
                color: [.red],
                image: Image(systemName: "trash"),
                title: "Clear"
            )
            .frame(width: 80, height: 80)
        }
    }
    .padding()
    .background(.black)
    .preferredColorScheme(.dark)
}
