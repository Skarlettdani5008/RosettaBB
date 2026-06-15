/// Источник проверки обновлений для приложения.
public protocol UpdateProvider: Sendable {
    func check(_ app: AppEntry) async -> ProviderOutcome
}
