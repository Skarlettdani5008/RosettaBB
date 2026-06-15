import Foundation

/// Откуда пришла информация об обновлении.
public enum UpdateSource: Sendable, Hashable {
    case appStore
    case sparkle
    case homebrew
}

/// Статус проверки обновления для одного приложения.
public enum UpdateStatus: Sendable, Hashable {
    case notChecked
    case checking
    case updateAvailable(latestVersion: String, source: UpdateSource, url: URL?)
    case upToDate(source: UpdateSource)
    case unknownSource
    case failed(reason: String)
}

/// Что нашёл провайдер: последняя версия + источник + ссылка.
public struct UpdateCheckResult: Sendable, Hashable {
    public let latestVersion: String
    public let source: UpdateSource
    public let url: URL?

    public init(latestVersion: String, source: UpdateSource, url: URL?) {
        self.latestVersion = latestVersion
        self.source = source
        self.url = url
    }
}

/// Исход одного провайдера.
public enum ProviderOutcome: Sendable {
    case notApplicable                  // провайдер не про это приложение
    case success(UpdateCheckResult)     // нашёл последнюю версию
    case failure(reason: String)        // применим, но сеть/парсинг упали
}
