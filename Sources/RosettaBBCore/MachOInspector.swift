import Foundation

/// Определяет архитектуры Mach-O бинарника, читая его заголовок.
public enum MachOInspector {
    private static let cpuTypeX86_64: UInt32 = 0x0100_0007
    private static let cpuTypeArm64: UInt32  = 0x0100_000C

    /// Читает заголовок файла и возвращает найденные архитектуры.
    public static func architectures(ofFileAt url: URL) throws -> Set<Architecture> {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        let data = (try handle.read(upToCount: 4096)) ?? Data()
        return architectures(in: data)
    }

    /// Разбирает заголовок Mach-O из готовых данных.
    public static func architectures(in data: Data) -> Set<Architecture> {
        guard data.count >= 8 else { return [] }
        // Magic читаем как big-endian-композицию байтов файла.
        let magic = readUInt32(data, at: 0, bigEndian: true)
        switch magic {
        case 0xCAFE_BABE:                    // fat 32-бит (BE на диске)
            return parseFat(data, archSize: 20)
        case 0xCAFE_BABF:                    // fat 64-бит (BE на диске)
            return parseFat(data, archSize: 32)
        case 0xCFFA_EDFE, 0xCEFA_EDFE:       // thin little-endian (обычный Mac)
            return cpuArchitecture(readUInt32(data, at: 4, bigEndian: false))
        case 0xFEED_FACF, 0xFEED_FACE:       // thin big-endian (редко)
            return cpuArchitecture(readUInt32(data, at: 4, bigEndian: true))
        default:
            return []
        }
    }

    private static func parseFat(_ data: Data, archSize: Int) -> Set<Architecture> {
        let count = Int(readUInt32(data, at: 4, bigEndian: true))
        var result: Set<Architecture> = []
        var offset = 8
        for _ in 0..<count {
            guard offset + 4 <= data.count else { break }
            let cputype = readUInt32(data, at: offset, bigEndian: true)
            result.formUnion(cpuArchitecture(cputype))
            offset += archSize
        }
        return result
    }

    private static func cpuArchitecture(_ cputype: UInt32) -> Set<Architecture> {
        switch cputype {
        case cpuTypeX86_64: return [.x86_64]
        case cpuTypeArm64:  return [.arm64]
        default:            return []
        }
    }

    /// Читает 4 байта по смещению как UInt32 в указанном порядке.
    private static func readUInt32(_ data: Data, at offset: Int, bigEndian: Bool) -> UInt32 {
        let base = data.startIndex + offset
        let b0 = UInt32(data[base])
        let b1 = UInt32(data[base + 1])
        let b2 = UInt32(data[base + 2])
        let b3 = UInt32(data[base + 3])
        return bigEndian
            ? (b0 << 24 | b1 << 16 | b2 << 8 | b3)
            : (b3 << 24 | b2 << 16 | b1 << 8 | b0)
    }
}
