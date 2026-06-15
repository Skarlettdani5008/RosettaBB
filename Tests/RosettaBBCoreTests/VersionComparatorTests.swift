import Testing
@testable import RosettaBBCore

@Suite("VersionComparator")
struct VersionComparatorTests {
    @Test("равные версии не новее (1.0 vs 1.0.0)")
    func equalNotNewer() {
        #expect(VersionComparator.isNewer("1.0", than: "1.0.0") == false)
    }

    @Test("патч новее")
    func patchNewer() {
        #expect(VersionComparator.isNewer("2.4.2", than: "2.4.1"))
    }

    @Test("числовое сравнение, не лексическое (2.10 > 2.9)")
    func numericNotLexical() {
        #expect(VersionComparator.isNewer("2.10", than: "2.9"))
    }

    @Test("старее — не новее")
    func olderNotNewer() {
        #expect(VersionComparator.isNewer("2.4.1", than: "2.4.2") == false)
    }

    @Test("нечисловой хвост отбрасывается (3.0-beta > 2.9)")
    func suffixIgnored() {
        #expect(VersionComparator.isNewer("3.0-beta", than: "2.9"))
    }

    @Test("мусор → false")
    func garbageFalse() {
        #expect(VersionComparator.isNewer("abc", than: "1.0") == false)
        #expect(VersionComparator.isNewer("1.0", than: "") == false)
    }
}
