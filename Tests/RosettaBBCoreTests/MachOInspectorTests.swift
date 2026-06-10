import Foundation
import Testing
@testable import RosettaBBCore

@Suite("MachOInspector")
struct MachOInspectorTests {
    // Thin x86_64: magic CF FA ED FE (LE), cputype 0x01000007 (LE) = 07 00 00 01
    @Test("thin x86_64")
    func thinIntel() {
        let data = Data([0xCF, 0xFA, 0xED, 0xFE, 0x07, 0x00, 0x00, 0x01])
        #expect(MachOInspector.architectures(in: data) == [.x86_64])
    }

    // Thin arm64: cputype 0x0100000C (LE) = 0C 00 00 01
    @Test("thin arm64")
    func thinArm() {
        let data = Data([0xCF, 0xFA, 0xED, 0xFE, 0x0C, 0x00, 0x00, 0x01])
        #expect(MachOInspector.architectures(in: data) == [.arm64])
    }

    // Fat universal: CA FE BA BE, nfat_arch=2, два fat_arch по 20 байт.
    @Test("fat universal x86_64 + arm64")
    func fatUniversal() {
        var bytes: [UInt8] = [0xCA, 0xFE, 0xBA, 0xBE, 0x00, 0x00, 0x00, 0x02]
        // fat_arch[0]: cputype 0x01000007 (BE) + 16 байт хвоста
        bytes += [0x01, 0x00, 0x00, 0x07] + [UInt8](repeating: 0, count: 16)
        // fat_arch[1]: cputype 0x0100000C (BE) + 16 байт хвоста
        bytes += [0x01, 0x00, 0x00, 0x0C] + [UInt8](repeating: 0, count: 16)
        #expect(MachOInspector.architectures(in: Data(bytes)) == [.x86_64, .arm64])
    }

    @Test("мусор → пусто")
    func garbage() {
        let data = Data([0x7F, 0x45, 0x4C, 0x46, 0x00, 0x00, 0x00, 0x00]) // ELF
        #expect(MachOInspector.architectures(in: data) == [])
    }

    @Test("слишком короткий → пусто")
    func tooShort() {
        #expect(MachOInspector.architectures(in: Data([0xCF, 0xFA])) == [])
    }
}
