import Foundation
import Testing
@testable import RosettaBBCore

/// Мок сети с заранее заданными данными или ошибкой.
struct StubFetcher: DataFetching {
    var data: Data = Data()
    var error: Error? = nil
    func data(from url: URL) async throws -> Data {
        if let error { throw error }
        return data
    }
}

@Suite("AppStoreUpdateProvider")
struct AppStoreUpdateProviderTests {
    private func makeMASBundle(version installed: String) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rbb-mas-\(UUID().uuidString)")
        let receiptDir = root.appendingPathComponent("Mas.app")
            .appendingPathComponent("Contents")
            .appendingPathComponent("_MASReceipt")
        try FileManager.default.createDirectory(at: receiptDir, withIntermediateDirectories: true)
        try Data("receipt".utf8).write(to: receiptDir.appendingPathComponent("receipt"))
        return root.appendingPathComponent("Mas.app")
    }

    @Test("есть чек MAS и более новая версия → success")
    func success() async throws {
        let bundle = try makeMASBundle(version: "5.0.0")
        defer { try? FileManager.default.removeItem(at: bundle.deletingLastPathComponent()) }
        let app = AppEntry(bundleURL: bundle, name: "Mas",
                           architectures: [.x86_64], verdict: .intel,
                           version: "5.0.0", bundleIdentifier: "com.example.mas")
        let json = #"{"resultCount":1,"results":[{"version":"5.2.0","trackViewUrl":"https://apps.apple.com/app/id1"}]}"#
        let provider = AppStoreUpdateProvider(fetcher: StubFetcher(data: Data(json.utf8)))

        let outcome = await provider.check(app)
        guard case let .success(result) = outcome else {
            Issue.record("ожидался .success, получено \(outcome)")
            return
        }
        #expect(result.latestVersion == "5.2.0")
        #expect(result.source == .appStore)
        #expect(result.url?.absoluteString == "https://apps.apple.com/app/id1")
    }

    @Test("нет чека _MASReceipt → notApplicable")
    func notApplicable() async throws {
        let bundle = FileManager.default.temporaryDirectory
            .appendingPathComponent("NoReceipt-\(UUID().uuidString).app")
        let app = AppEntry(bundleURL: bundle, name: "X",
                           architectures: [.x86_64], verdict: .intel,
                           version: "1.0", bundleIdentifier: "com.example.x")
        let provider = AppStoreUpdateProvider(fetcher: StubFetcher(data: Data()))

        let outcome = await provider.check(app)
        guard case .notApplicable = outcome else {
            Issue.record("ожидался .notApplicable, получено \(outcome)")
            return
        }
    }
}
