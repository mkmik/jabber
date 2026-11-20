import AppKit
import FoundationModels
import os

/// Whether the on-device Apple Intelligence model can clean up transcripts
/// right now, and if not, why, in words the Post-Processing page can show.
enum AppleIntelligenceStatus: Equatable {
    case available
    case deviceNotEligible
    case notEnabled
    case modelNotReady
    case unavailable
    case needsNewerMacOS

    private static let logger = Logger(subsystem: "com.rselbach.jabber", category: "AppleIntelligenceStatus")
    private static let settingsURL = "x-apple.systempreferences:com.apple.Siri-Settings.extension"

    @available(macOS 26, *)
    init(_ availability: SystemLanguageModel.Availability) {
        switch availability {
        case .available:
            self = .available
        case .unavailable(.deviceNotEligible):
            self = .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            self = .notEnabled
        case .unavailable(.modelNotReady):
            self = .modelNotReady
        case .unavailable:
            self = .unavailable
        }
    }

    static func current() -> AppleIntelligenceStatus {
        guard #available(macOS 26, *) else { return .needsNewerMacOS }
        return AppleIntelligenceStatus(SystemLanguageModel.default.availability)
    }

    /// Opens the Apple Intelligence & Siri settings pane.
    static func openSettings() {
        guard let url = URL(string: settingsURL), NSWorkspace.shared.open(url) else {
            logger.error("Failed to open Apple Intelligence settings")
            return
        }
    }

    var isAvailable: Bool {
        self == .available
    }

    /// Only a setting the user can change is worth a button.
    var canFixInSettings: Bool {
        self == .notEnabled
    }

    var message: String {
        switch self {
        case .available:
            return "Apple Intelligence is ready."
        case .deviceNotEligible:
            return "This Mac doesn't support Apple Intelligence, so Jabber uses the raw transcript."
        case .notEnabled:
            return "Apple Intelligence is turned off, so Jabber uses the raw transcript."
        case .modelNotReady:
            return "Apple Intelligence is still getting ready, so Jabber uses the raw transcript until it's done."
        case .unavailable:
            return "Apple Intelligence isn't available right now, so Jabber uses the raw transcript."
        case .needsNewerMacOS:
            return "Apple Intelligence cleanup needs macOS 26, so Jabber uses the raw transcript."
        }
    }
}
