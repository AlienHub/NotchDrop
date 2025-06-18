//
//  DirectoryMonitor.swift
//  NotchDrop
//
//  Created by Alien zhou on 2025/6/16.
//

import Foundation

final class DirectoryMonitor: ObservableObject {
    @Published var directoryDidChange = false

    private var directoryFileDescriptor: CInt = -1
    private var source: DispatchSourceFileSystemObject?
    private let url: URL

    init(directoryURL: URL) {
        self.url = directoryURL
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        guard source == nil else { return }

        directoryFileDescriptor = open(url.path, O_EVTONLY)
        guard directoryFileDescriptor != -1 else { return }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: directoryFileDescriptor,
            eventMask: .write,
            queue: DispatchQueue.global()
        )

        source?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.directoryDidChange.toggle()
            }
        }

        source?.setCancelHandler { [weak self] in
            if let fd = self?.directoryFileDescriptor, fd != -1 {
                close(fd)
            }
            self?.directoryFileDescriptor = -1
            self?.source = nil
        }

        source?.resume()
    }

    private func stopMonitoring() {
        source?.cancel()
    }
}
