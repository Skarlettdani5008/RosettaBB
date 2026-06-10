/// Классификация приложения по поддерживаемым архитектурам.
public enum Verdict: String, Sendable, Hashable {
    case intel          // только x86_64 — требует Rosetta
    case universal      // x86_64 + arm64
    case appleSilicon   // только arm64
    case unknown        // не удалось определить
}
