import Foundation

private struct ShortcutRecord: Codable {
    let id: String
    let title: String
    let value: String
    let description: String
    let category: String
    let kind: String
    let tags: [String]
    let confidence: String

    init(_ item: ReferenceItem) {
        id = item.id
        title = item.title
        value = item.value
        description = item.description
        category = item.category.rawValue
        kind = item.kind.rawValue
        tags = item.tags
        confidence = item.confidence.rawValue
    }
}

private struct CategorySummary: Codable {
    let category: String
    let count: Int
}

private struct ShortcutCatalog: Codable {
    let sourceRepository: String
    let sourceRevision: String
    let filter: String
    let totalShortcuts: Int
    let categories: [CategorySummary]
    let shortcuts: [ShortcutRecord]
}

private enum ExportError: LocalizedError {
    case missingArgument(String)
    case invalidRevision(String)
    case duplicateIDs([String])

    var errorDescription: String? {
        switch self {
        case let .missingArgument(name):
            "Missing required argument: \(name)"
        case let .invalidRevision(revision):
            "Source revision must be a 40-character Git SHA, got: \(revision)"
        case let .duplicateIDs(ids):
            "Duplicate shortcut IDs: \(ids.joined(separator: ", "))"
        }
    }
}

@main
private enum ShortcutExporter {
    private static let sourceRepository = "https://github.com/Saba-Burduli/keytome-macos"

    static func main() throws {
        let arguments = try parseArguments(Array(CommandLine.arguments.dropFirst()))
        let sourceRevision = try required("--source-revision", in: arguments)
        let jsonPath = try required("--json", in: arguments)
        let markdownPath = try required("--markdown", in: arguments)

        guard sourceRevision.range(of: #"^[0-9a-f]{40}$"#, options: .regularExpression) != nil else {
            throw ExportError.invalidRevision(sourceRevision)
        }

        let filteredItems: [ReferenceItem] = SeedData.items.filter { item in
            item.kind == ReferenceItem.Kind.shortcut
        }
        var shortcuts: [ShortcutRecord] = filteredItems.map { item in
            ShortcutRecord(item)
        }
        shortcuts.sort { left, right in
            if left.category == right.category {
                return left.id < right.id
            }
            return left.category.localizedCaseInsensitiveCompare(right.category) == .orderedAscending
        }

        let shortcutsByID: [String: [ShortcutRecord]] = Dictionary(grouping: shortcuts) { item in
            item.id
        }
        let duplicateIDs = shortcutsByID
            .filter { $0.value.count > 1 }
            .keys
            .sorted()
        guard duplicateIDs.isEmpty else {
            throw ExportError.duplicateIDs(duplicateIDs)
        }

        let shortcutsByCategory: [String: [ShortcutRecord]] = Dictionary(grouping: shortcuts) { item in
            item.category
        }
        let categories = shortcutsByCategory
            .map { CategorySummary(category: $0.key, count: $0.value.count) }
            .sorted { $0.category.localizedCaseInsensitiveCompare($1.category) == .orderedAscending }

        let catalog = ShortcutCatalog(
            sourceRepository: sourceRepository,
            sourceRevision: sourceRevision,
            filter: "kind == shortcut",
            totalShortcuts: shortcuts.count,
            categories: categories,
            shortcuts: shortcuts
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try write(encoder.encode(catalog) + Data("\n".utf8), to: jsonPath)
        try write(Data(markdown(catalog).utf8), to: markdownPath)
    }

    private static func parseArguments(_ values: [String]) throws -> [String: String] {
        var result: [String: String] = [:]
        var index = 0
        while index < values.count {
            let key = values[index]
            guard key.hasPrefix("--"), index + 1 < values.count else {
                throw ExportError.missingArgument("value after \(key)")
            }
            result[key] = values[index + 1]
            index += 2
        }
        return result
    }

    private static func required(_ name: String, in arguments: [String: String]) throws -> String {
        guard let value = arguments[name], !value.isEmpty else {
            throw ExportError.missingArgument(name)
        }
        return value
    }

    private static func write(_ data: Data, to path: String) throws {
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
    }

    private static func markdown(_ catalog: ShortcutCatalog) -> String {
        let grouped = Dictionary(grouping: catalog.shortcuts, by: \.category)
        var lines = [
            "# Keytome shortcut catalog",
            "",
            "Filtered from [Keytome for macOS](\(catalog.sourceRepository)) at revision `\(catalog.sourceRevision)`.",
            "",
            "This catalog contains **\(catalog.totalShortcuts) shortcuts**. Records typed as commands are excluded.",
            ""
        ]

        for summary in catalog.categories {
            lines.append("## \(summary.category) (\(summary.count))")
            lines.append("")
            lines.append("| Shortcut | Action | Description | Confidence |")
            lines.append("| --- | --- | --- | --- |")
            for item in grouped[summary.category, default: []] {
                lines.append("| `\(escape(item.value))` | \(escape(item.title)) | \(escape(item.description)) | \(item.confidence.uppercased()) |")
            }
            lines.append("")
        }

        while lines.last?.isEmpty == true {
            lines.removeLast()
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "|", with: "\\|")
            .replacingOccurrences(of: "\n", with: " ")
    }
}
