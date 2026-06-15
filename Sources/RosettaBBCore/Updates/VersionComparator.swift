/// Сравнивает строки точечно-числовых версий ("2.4.1").
public enum VersionComparator {
    /// Возвращает true, если `candidate` строго новее `current`.
    public static func isNewer(_ candidate: String, than current: String) -> Bool {
        let a = components(candidate)
        let b = components(current)
        guard !a.isEmpty, !b.isEmpty else { return false }
        let count = max(a.count, b.count)
        for i in 0..<count {
            let x = i < a.count ? a[i] : 0
            let y = i < b.count ? b[i] : 0
            if x != y { return x > y }
        }
        return false
    }

    /// "2.4.1-beta" → [2, 4, 1]. Берёт у каждого компонента числовой префикс.
    private static func components(_ version: String) -> [Int] {
        version.split(separator: ".").compactMap { part in
            let digits = part.prefix { $0.isNumber }
            return digits.isEmpty ? nil : Int(digits)
        }
    }
}
