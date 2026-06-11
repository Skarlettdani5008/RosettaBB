import SwiftUI
import AppKit
import RosettaBBCore

struct ContentView: View {
    @State private var model = ScanViewModel()

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            content
        }
    }

    private var toolbar: some View {
        HStack {
            Button {
                Task { await model.scan() }
            } label: {
                Label("Сканировать", systemImage: "magnifyingglass")
            }
            .disabled(model.isScanning)

            Toggle("Только Intel", isOn: $model.showIntelOnly)
                .toggleStyle(.checkbox)

            Spacer()

            if model.isScanning {
                ProgressView().controlSize(.small)
            } else if !model.entries.isEmpty {
                Text("Intel: \(model.intelCount)  ·  Universal: \(model.universalCount)  ·  Apple: \(model.appleCount)")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
        .padding()
    }

    @ViewBuilder
    private var content: some View {
        if model.entries.isEmpty && !model.isScanning {
            ContentUnavailableView(
                "Нажмите «Сканировать»",
                systemImage: "macwindow.on.rectangle",
                description: Text("Найдём приложения и покажем, какие из них Intel-only.")
            )
            .frame(maxHeight: .infinity)
        } else {
            List(model.visibleEntries) { entry in
                AppRow(entry: entry)
            }
        }
    }
}

private struct AppRow: View {
    let entry: AppEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: entry.bundleURL.path))
                .resizable()
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name).font(.body)
                Text(entry.bundleURL.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()
            badge
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([entry.bundleURL])
            } label: {
                Image(systemName: "arrow.right.circle")
            }
            .buttonStyle(.borderless)
            .help("Показать в Finder")
        }
        .padding(.vertical, 2)
    }

    private var badge: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.18), in: Capsule())
            .foregroundStyle(color)
    }

    private var label: String {
        switch entry.verdict {
        case .intel:        return "Intel"
        case .universal:    return "Universal"
        case .appleSilicon: return "Apple"
        case .unknown:      return "—"
        }
    }

    private var color: Color {
        switch entry.verdict {
        case .intel:        return .orange
        case .universal:    return .blue
        case .appleSilicon: return .green
        case .unknown:      return .gray
        }
    }
}
