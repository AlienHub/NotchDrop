//
//  NotchSettingsView.swift
//  NotchDrop
//
//  Created by 曹丁杰 on 2024/7/29.
//

import LaunchAtLogin
import SwiftUI

struct NotchSettingsView: View {
    @StateObject var vm: NotchViewModel
    @StateObject var tvm: TrayDrop = .shared

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            // General Settings 部分
            VStack(alignment: .leading, spacing: 16) {
                Text(NSLocalizedString("General Settings", comment: "General settings section title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    // 语言设置
                    HStack {
                        Text(NSLocalizedString("Language:", comment: "Language label"))
                            .frame(width: 140, alignment: .leading)
                        Picker(NSLocalizedString("", comment: ""), selection: $vm.selectedLanguage) {
                            ForEach(Language.allCases) { language in
                                Text(language.localized).tag(language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 180)
                        Spacer()
                    }
                    
                    // 默认视图设置
                    HStack {
                        Text(NSLocalizedString("Default View:", comment: "Default view label"))
                            .frame(width: 140, alignment: .leading)
                        Picker(NSLocalizedString("", comment: ""), selection: $vm.defaultView) {
                            ForEach(MainViewType.allCases) { type in
                                Text(type.localized).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 180)
                        Spacer()
                    }
                    
                    // Launch at Login
                    HStack {
                        LaunchAtLogin.Toggle {
                            Text(NSLocalizedString("Launch at Login", comment: "Launch at login toggle"))
                        }
                        Spacer()
                    }
                    
                    // Haptic Feedback
                    HStack {
                        Toggle(NSLocalizedString("Haptic Feedback", comment: "Toggle for haptic feedback"), isOn: $vm.hapticFeedback)
                        Spacer()
                    }
                }
            }
            
            // Share Settings 部分
            VStack(alignment: .leading, spacing: 16) {
                Text(NSLocalizedString("Share Settings", comment: "Share settings section title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    // AirDrop 设置
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Toggle(NSLocalizedString("Show AirDrop", comment: "Toggle to show/hide AirDrop"), isOn: $vm.showAirDrop)
                            Spacer()
                        }
                        Text(NSLocalizedString("Send files directly to other Apple devices via AirDrop", comment: "AirDrop description"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                    }
                    
                    // 通用分享设置
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Toggle(NSLocalizedString("Show Generic Share", comment: "Toggle to show/hide generic share"), isOn: $vm.showGenericShare)
                            Spacer()
                        }
                        Text(NSLocalizedString("Show system share menu with email, messages, cloud storage and other sharing options", comment: "Generic share description"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                    }
                }
            }

            // File Management 部分
            VStack(alignment: .leading, spacing: 16) {
                Text(NSLocalizedString("File Management", comment: "File management section title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    // 文件保存时间
                    HStack {
                        Text(NSLocalizedString("File Storage Time:", comment: "File storage time label"))
                            .frame(width: 140, alignment: .leading)
                        
                        HStack(spacing: 8) {
                            Picker(NSLocalizedString("", comment: ""), selection: $tvm.selectedFileStorageTime) {
                                ForEach(TrayDrop.FileStorageTime.allCases) { time in
                                    Text(time.localized).tag(time)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                            
                            if tvm.selectedFileStorageTime == .custom {
                                TextField("", value: $tvm.customStorageTime, formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60)
                                
                                Picker(NSLocalizedString("", comment: ""), selection: $tvm.customStorageTimeUnit) {
                                    ForEach(TrayDrop.CustomstorageTimeUnit.allCases) { unit in
                                        Text(unit.localized).tag(unit)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 80)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // 目录设置
                    HStack {
                        Text(NSLocalizedString("Directory:", comment: "Directory label"))
                            .frame(width: 140, alignment: .leading)
                        
                        HStack(spacing: 8) {
                            if let url = vm.directoryURL {
                                Text(url.lastPathComponent)
                                    .font(.system(size: 12))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .frame(maxWidth: 200, alignment: .leading)
                            } else {
                                Text(NSLocalizedString("Downloads", comment: "Downloads label"))
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: 200, alignment: .leading)
                            }
                            
                            Button(NSLocalizedString("Select", comment: "Select button label")) {
                                let panel = NSOpenPanel()
                                panel.canChooseDirectories = true
                                panel.canChooseFiles = false
                                panel.allowsMultipleSelection = false
                                panel.prompt = NSLocalizedString("Select", comment: "Select button prompt")
                                if panel.runModal() == .OK {
                                    vm.directoryURL = panel.url
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            // 版本信息
            HStack {
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
                Text("NotchDrop v\(version) (\(build))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    NotchSettingsView(vm: .init())
        .frame(width: 700, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
}
