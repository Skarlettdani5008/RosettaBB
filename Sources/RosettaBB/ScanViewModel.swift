import Foundation
import Observation
import RosettaBBCore

@MainActor
@Observable
final class ScanViewModel {
    private(set) var entries: [AppEntry] = []
    private(set) var isScanning = false
    var showIntelOnly = true

    var visibleEntries: [AppEntry] {
        showIntelOnly ? entries.filter { $0.verdict == .intel } : entries
    }

    var intelCount: Int { entries.filter { $0.verdict == .intel }.count }
    var universalCount: Int { entries.filter { $0.verdict == .universal }.count }
    var appleCount: Int { entries.filter { $0.verdict == .appleSilicon }.count }

    func scan() async {
        isScanning = true
        entries = []
        let roots = AppScanner.defaultRoots
        entries = await Task.detached(priority: .userInitiated) {
            AppScanner().scan(roots: roots)
        }.value
        isScanning = false
    }
}
