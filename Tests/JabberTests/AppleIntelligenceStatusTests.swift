import FoundationModels
import XCTest
@testable import Jabber

final class AppleIntelligenceStatusTests: XCTestCase {
    func testStatusForAvailability() throws {
        guard #available(macOS 26, *) else { throw XCTSkip("Apple Intelligence needs macOS 26") }
        let tests: [String: (
            availability: SystemLanguageModel.Availability,
            want: AppleIntelligenceStatus,
            wantSettingsButton: Bool
        )] = [
            "available": (.available, .available, false),
            "unsupported Mac": (.unavailable(.deviceNotEligible), .deviceNotEligible, false),
            "turned off": (.unavailable(.appleIntelligenceNotEnabled), .notEnabled, true),
            "model still downloading": (.unavailable(.modelNotReady), .modelNotReady, false)
        ]

        for (name, tc) in tests {
            let got = AppleIntelligenceStatus(tc.availability)
            XCTAssertEqual(got, tc.want, name)
            XCTAssertEqual(got.isAvailable, tc.want == .available, name)
            XCTAssertEqual(got.canFixInSettings, tc.wantSettingsButton, name)
        }
    }
}
