import Foundation

/// Проверяет обновления через Sparkle appcast (SUFeedURL в Info.plist).
public struct SparkleUpdateProvider: UpdateProvider {
    private let fetcher: DataFetching

    public init(fetcher: DataFetching) {
        self.fetcher = fetcher
    }

    public func check(_ app: AppEntry) async -> ProviderOutcome {
        let infoPlist = app.bundleURL
            .appendingPathComponent("Contents")
            .appendingPathComponent("Info.plist")
        guard let dict = NSDictionary(contentsOf: infoPlist),
              let feed = dict["SUFeedURL"] as? String,
              let feedURL = URL(string: feed) else {
            return .notApplicable
        }

        do {
            let data = try await fetcher.data(from: feedURL)
            let items = AppcastParser().parse(data)
            let versions: [(version: String, url: String?)] = items.compactMap { item in
                if let s = item.shortVersion { return (s, item.url) }
                if let v = item.version { return (v, item.url) }
                return nil
            }
            guard let latest = versions.max(by: { VersionComparator.isNewer($1.version, than: $0.version) }) else {
                return .failure(reason: "Appcast без версий")
            }
            let url = latest.url.flatMap { URL(string: $0) }
            return .success(UpdateCheckResult(latestVersion: latest.version, source: .sparkle, url: url))
        } catch {
            return .failure(reason: "Сеть: \(error.localizedDescription)")
        }
    }
}

/// Разбирает Sparkle appcast XML, собирая версии из элементов <item>.
private final class AppcastParser: NSObject, XMLParserDelegate {
    struct Item {
        var shortVersion: String?
        var version: String?
        var url: String?
    }

    private var items: [Item] = []
    private var current: Item?
    private var textBuffer = ""

    func parse(_ data: Data) -> [Item] {
        items = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {
        textBuffer = ""
        if elementName == "item" { current = Item() }
        if elementName == "enclosure" {
            current?.url = attributeDict["url"]
            if let s = attributeDict["sparkle:shortVersionString"] { current?.shortVersion = s }
            if let v = attributeDict["sparkle:version"] { current?.version = v }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        textBuffer += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        let text = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
        switch elementName {
        case "sparkle:shortVersionString":
            if !text.isEmpty { current?.shortVersion = text }
        case "sparkle:version":
            if !text.isEmpty { current?.version = text }
        case "item":
            if let item = current { items.append(item) }
            current = nil
        default:
            break
        }
        textBuffer = ""
    }
}
