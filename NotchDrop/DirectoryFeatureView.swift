//
//  DirectoryFeatureView.swift
//  NotchDrop
//
//  Created by Alien zhou on 2025/6/17.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

// MARK: - File Sorting Utilities

/// Gets the date a file was added to a directory (macOS 11+).
func getDateAddedToDirectory(for url: URL) -> Date {
    do {
        let resourceValues = try url.resourceValues(forKeys: [.addedToDirectoryDateKey, .contentModificationDateKey])
        // 优先使用添加日期，如果不可用则使用修改日期
        return resourceValues.addedToDirectoryDate ?? resourceValues.contentModificationDate ?? .distantPast
    } catch {
        return .distantPast
    }
}

/// Gets the most recently added files from a directory.
func getRecentFiles(from directoryURL: URL, count: Int = 5) -> [URL] {
    let fileManager = FileManager.default
    let contents = (try? fileManager.contentsOfDirectory(
        at: directoryURL,
        includingPropertiesForKeys: [.addedToDirectoryDateKey, .contentModificationDateKey],
        options: [.skipsHiddenFiles]
    )) ?? []

    let sortedFiles = contents
        .sorted { getDateAddedToDirectory(for: $0) > getDateAddedToDirectory(for: $1) }
        .prefix(count)
        .map { $0 }
    
    return sortedFiles
}

// MARK: - Directory Content View

struct DirectoryContentView: View {
    @ObservedObject var vm: NotchViewModel
    
    var body: some View {
        VStack {
            if let directory = vm.directoryURL {
                RecentFilesView(directory: directory, count: 20)
            } else {
                VStack {
                    Spacer()
                    Text("Please select a directory in settings to see recent files.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


// MARK: - Recent Files List View

struct RecentFilesView: View {
    let directory: URL
    let count: Int
    @State private var recentFiles: [URL] = []
    @StateObject private var monitor: DirectoryMonitor

    init(directory: URL, count: Int) {
        self.directory = directory
        self.count = count
        _monitor = StateObject(wrappedValue: DirectoryMonitor(directoryURL: directory))
    }

    var body: some View {
        ScrollView {
            if recentFiles.isEmpty {
                VStack {
                    Spacer()
                    Text("No recent files found.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 60)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(recentFiles, id: \.self) { file in
                        FileItemView(file: file)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
        .onAppear(perform: loadFiles)
        .onChange(of: monitor.directoryDidChange) { _ in loadFiles() }
        .onChange(of: directory) { _ in loadFiles() }
    }

    private func loadFiles() {
        self.recentFiles = getRecentFiles(from: directory, count: count)
    }
}

// MARK: - File Item View

struct FileItemView: View {
    // 定义文件的URL和hover状态
    let file: URL
    @State private var hover = false

    var body: some View {
        // 水平栈布局，间距为8
        HStack(spacing: 4) {
            // 显示文件图标
            Image(nsImage: NSWorkspace.shared.icon(forFile: file.path))
                .resizable() // 可以调整大小
                .aspectRatio(contentMode: .fit) // 保持宽高比，适应容器
                .frame(width: 16, height: 16) // 设置宽度和高度为16

            // 显示文件名
            Text(file.lastPathComponent)
                .font(.footnote) // 设置字体为脚注字体
                .lineLimit(1) // 最多显示一行
                .truncationMode(.middle) // 如果超出两行，则中间截断

            Spacer() // 填充剩余空间
        }
        // 设置边距为2
        .padding(2)
        // 根据hover状态设置背景颜色
        .background(hover ? Color.white.opacity(0.3) : Color.clear)
        // 设置圆角为6
        .cornerRadius(4)
        // 监听hover事件
        .onHover { hover = $0 }
        // 根据hover状态设置缩放效果
        .scaleEffect(hover ? 1.02 : 1.0)
        // 设置动画效果
        .animation(.easeInOut(duration: 0.15), value: hover)
        // 设置点击事件，点击时打开文件
        .onTapGesture {
            NSWorkspace.shared.open(file)
        }
        // 使文件项可拖拽
        .draggable(file)
    }
} 


// MARK: - Previews

#Preview("DirectoryContentView") {
    DirectoryContentView(vm: {
        let vm = NotchViewModel()
        vm.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        return vm
    }())
    .frame(width: 600, height: 160)
    .background(Color.black.opacity(0.8))
    .preferredColorScheme(.dark)
}

#Preview("RecentFilesView") {
    RecentFilesView(
        directory: FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!,
        count: 10
    )
    .frame(width: 600, height: 160)
    .background(Color.black.opacity(0.8))
    .preferredColorScheme(.dark)
}

#Preview("FileItemView") {
    VStack(spacing: 4) {
        FileItemView(file: URL(fileURLWithPath: "/Applications/Safari.app"))
        FileItemView(file: URL(fileURLWithPath: "/System/Applications/Calculator.app"))
        FileItemView(file: URL(fileURLWithPath: "/Applications/Xcode.app"))
    }
    .padding()
    .frame(width: 400)
    .background(Color.black.opacity(0.8))
    .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    DirectoryContentView(vm: {
        let vm = NotchViewModel()
        vm.directoryURL = nil
        return vm
    }())
    .frame(width: 600, height: 160)
    .background(Color.black.opacity(0.8))
    .preferredColorScheme(.dark)
}
