/// Оркестратор: пробует провайдеры по приоритету, возвращает итоговый статус.
public struct UpdateChecker: Sendable {
    private let providers: [any UpdateProvider]

    public init(providers: [any UpdateProvider]) {
        self.providers = providers
    }

    public func check(_ app: AppEntry) async -> UpdateStatus {
        for provider in providers {
            switch await provider.check(app) {
            case .notApplicable:
                continue
            case .failure(let reason):
                return .failed(reason: reason)
            case .success(let result):
                if VersionComparator.isNewer(result.latestVersion, than: app.version ?? "") {
                    return .updateAvailable(latestVersion: result.latestVersion,
                                            source: result.source, url: result.url)
                } else {
                    return .upToDate(source: result.source)
                }
            }
        }
        return .unknownSource
    }
}
