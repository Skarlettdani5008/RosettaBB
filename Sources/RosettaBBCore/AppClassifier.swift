/// Превращает набор архитектур в вердикт.
public enum AppClassifier {
    public static func verdict(for architectures: Set<Architecture>) -> Verdict {
        let hasIntel = architectures.contains(.x86_64)
        let hasArm = architectures.contains(.arm64)
        switch (hasIntel, hasArm) {
        case (true, true):   return .universal
        case (true, false):  return .intel
        case (false, true):  return .appleSilicon
        case (false, false): return .unknown
        }
    }
}
