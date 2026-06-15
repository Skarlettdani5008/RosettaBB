import Foundation

/// Абстракция запуска внешней команды — чтобы подменять brew в тестах.
public protocol CommandRunning: Sendable {
    /// Запускает `executable` с аргументами, возвращает stdout.
    func run(_ executable: String, _ arguments: [String]) async throws -> String
}

/// Прод-реализация на Foundation.Process.
public struct ProcessCommandRunner: CommandRunning {
    public init() {}

    public func run(_ executable: String, _ arguments: [String]) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let outPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = Pipe()
        try process.run()
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(decoding: data, as: UTF8.self)
    }
}
