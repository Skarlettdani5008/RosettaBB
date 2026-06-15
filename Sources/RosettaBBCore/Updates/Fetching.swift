import Foundation

/// Абстракция загрузки данных по URL — чтобы подменять сеть в тестах.
public protocol DataFetching: Sendable {
    func data(from url: URL) async throws -> Data
}

/// Прод-реализация на URLSession с таймаутом.
public struct URLSessionDataFetcher: DataFetching {
    private let timeout: TimeInterval

    public init(timeout: TimeInterval = 10) {
        self.timeout = timeout
    }

    public func data(from url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.timeoutInterval = timeout
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
