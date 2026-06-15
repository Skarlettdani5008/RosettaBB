import Foundation
import Testing
@testable import RosettaBBCore

/// Мок-провайдер с фиксированным исходом.
struct StubProvider: UpdateProvider {
    let outcome: ProviderOutcome
    func check(_ app: AppEntry) async -> ProviderOutcome { outcome }
}

@Suite("UpdateChecker")
struct UpdateCheckerTests {
    private func sampleApp(version: String) -> AppEntry {
        AppEntry(bundleURL: URL(fileURLWithPath: "/Applications/Sample.app"),
                 name: "Sample", architectures: [.x86_64], verdict: .intel,
                 version: version, bundleIdentifier: "com.example.sample")
    }

    @Test("первый применимый побеждает, более новая версия → updateAvailable")
    func updateAvailable() async {
        let result = UpdateCheckResult(latestVersion: "2.0", source: .sparkle, url: nil)
        let checker = UpdateChecker(providers: [
            StubProvider(outcome: .notApplicable),
            StubProvider(outcome: .success(result)),
        ])
        let status = await checker.check(sampleApp(version: "1.0"))
        guard case let .updateAvailable(version, source, _) = status else {
            Issue.record("ожидался .updateAvailable, получено \(status)")
            return
        }
        #expect(version == "2.0")
        #expect(source == .sparkle)
    }

    @Test("версия не новее → upToDate")
    func upToDate() async {
        let result = UpdateCheckResult(latestVersion: "1.0", source: .appStore, url: nil)
        let checker = UpdateChecker(providers: [StubProvider(outcome: .success(result))])
        let status = await checker.check(sampleApp(version: "1.0"))
        guard case let .upToDate(source) = status else {
            Issue.record("ожидался .upToDate, получено \(status)")
            return
        }
        #expect(source == .appStore)
    }

    @Test("все notApplicable → unknownSource")
    func unknownSource() async {
        let checker = UpdateChecker(providers: [
            StubProvider(outcome: .notApplicable),
            StubProvider(outcome: .notApplicable),
        ])
        let status = await checker.check(sampleApp(version: "1.0"))
        guard case .unknownSource = status else {
            Issue.record("ожидался .unknownSource, получено \(status)")
            return
        }
    }

    @Test("failure применимого провайдера → failed")
    func failed() async {
        let checker = UpdateChecker(providers: [
            StubProvider(outcome: .failure(reason: "boom")),
            StubProvider(outcome: .success(UpdateCheckResult(latestVersion: "9.0", source: .sparkle, url: nil))),
        ])
        let status = await checker.check(sampleApp(version: "1.0"))
        guard case let .failed(reason) = status else {
            Issue.record("ожидался .failed, получено \(status)")
            return
        }
        #expect(reason == "boom")
    }
}
