import Testing
@testable import RosettaBBCore

@Suite("AppClassifier")
struct AppClassifierTests {
    @Test("только x86_64 → .intel")
    func intelOnly() {
        #expect(AppClassifier.verdict(for: [.x86_64]) == .intel)
    }

    @Test("только arm64 → .appleSilicon")
    func armOnly() {
        #expect(AppClassifier.verdict(for: [.arm64]) == .appleSilicon)
    }

    @Test("обе → .universal")
    func universal() {
        #expect(AppClassifier.verdict(for: [.x86_64, .arm64]) == .universal)
    }

    @Test("пусто → .unknown")
    func empty() {
        #expect(AppClassifier.verdict(for: []) == .unknown)
    }
}
