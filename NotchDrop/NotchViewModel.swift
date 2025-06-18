import Cocoa
import Combine
import Foundation
import LaunchAtLogin
import SwiftUI

// MARK: - Main View Type
enum MainViewType: Int, CaseIterable, Identifiable, Codable {
    case temporary = 0
    case directory = 1
    
    var id: Int { rawValue }
    
    var localized: String {
        switch self {
        case .temporary:
            return NSLocalizedString("Temporary Files", comment: "")
        case .directory:
            return NSLocalizedString("Directory Files", comment: "")
        }
    }
}

class NotchViewModel: NSObject, ObservableObject {
    var cancellables: Set<AnyCancellable> = []
    let inset: CGFloat

    init(inset: CGFloat = -4) {
        self.inset = inset
        super.init()
        loadDirectoryURL()
        setupCancellables()
    }
    
    private func loadDirectoryURL() {
        if let url = UserDefaults.standard.url(forKey: "directoryURL") {
            directoryURL = url
        } else {
            // 默认设置为用户Downloads目录（有沙盒权限）
            directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        }
    }

    deinit {
        destroy()
    }

    let animation: Animation = .interactiveSpring(
        duration: 0.5,
        extraBounce: 0.25,
        blendDuration: 0.125
    )
    let notchOpenedSize: CGSize = .init(width: 600, height: 160)
    let dropDetectorRange: CGFloat = 32

    enum Status: String, Codable, Hashable, Equatable {
        case closed
        case opened
        case popping
    }

    enum OpenReason: String, Codable, Hashable, Equatable {
        case click
        case drag
        case boot
        case unknown
    }

    enum ContentType: Int, Codable, Hashable, Equatable {
        case normal = 0      // 临时文件模式
        case directory = 1   // 目录文件模式
        case menu = 2        // 菜单模式
    }

    var notchOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }

    var headlineOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - deviceNotchRect.height,
            width: notchOpenedSize.width,
            height: deviceNotchRect.height
        )
    }

    @Published private(set) var status: Status = .closed
    @Published var openReason: OpenReason = .unknown
    @Published var contentType: ContentType = .normal

    @Published var spacing: CGFloat = 16
    @Published var cornerRadius: CGFloat = 16
    @Published var deviceNotchRect: CGRect = .zero
    @Published var screenRect: CGRect = .zero
    @Published var optionKeyPressed: Bool = false
    @Published var notchVisible: Bool = true

    @PublishedPersist(key: "selectedLanguage", defaultValue: .system)
    var selectedLanguage: Language

    @PublishedPersist(key: "hapticFeedback", defaultValue: true)
    var hapticFeedback: Bool

    // MARK: - Share Settings
    @PublishedPersist(key: "showAirDrop", defaultValue: true)
    var showAirDrop: Bool
    
    @PublishedPersist(key: "showGenericShare", defaultValue: true)
    var showGenericShare: Bool

    // MARK: - Directory Settings
    @PublishedPersist(key: "defaultView", defaultValue: .temporary)
    var defaultView: MainViewType
    
    @Published var directoryURL: URL? {
        didSet {
            if let url = directoryURL {
                UserDefaults.standard.set(url, forKey: "directoryURL")
            } else {
                UserDefaults.standard.removeObject(forKey: "directoryURL")
            }
        }
    }

    let hapticSender = PassthroughSubject<Void, Never>()

    func notchOpen(_ reason: OpenReason) {
        openReason = reason
        status = .opened
        // 根据用户的默认视图设置来决定显示哪个视图
        contentType = defaultView == .directory ? .directory : .normal
        NSApp.activate(ignoringOtherApps: true)
    }

    func notchClose() {
        openReason = .unknown
        status = .closed
        contentType = .normal
    }

    func showDirectory() {
        contentType = .directory
    }



    func showMenu() {
        contentType = .menu
    }
    
    func switchToNextContentType() {
        let allTypes: [ContentType] = [.normal, .directory, .menu]
        if let currentIndex = allTypes.firstIndex(of: contentType) {
            let nextIndex = (currentIndex + 1) % allTypes.count
            contentType = allTypes[nextIndex]
        }
    }
    
    func switchToPreviousContentType() {
        let allTypes: [ContentType] = [.normal, .directory, .menu]
        if let currentIndex = allTypes.firstIndex(of: contentType) {
            let previousIndex = (currentIndex - 1 + allTypes.count) % allTypes.count
            contentType = allTypes[previousIndex]
        }
    }

    func notchPop() {
        openReason = .unknown
        status = .popping
    }
}
