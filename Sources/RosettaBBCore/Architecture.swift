/// Архитектура процессора, найденная в Mach-O бинарнике.
public enum Architecture: Sendable, Hashable {
    case x86_64
    case arm64
}
