import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum PresetField: String, Codable {
    case micDI
    case stand
}

struct PresetDragPayload: Codable, Transferable {
    var field: PresetField
    var value: String
    var sourceID: UUID
    var selectionCount: Int

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .data) { payload in
            try JSONEncoder().encode(payload)
        } importing: { data in
            try JSONDecoder().decode(PresetDragPayload.self, from: data)
        }
    }
}

@MainActor
final class InputListViewModel: ObservableObject {

    @Published var channels: [InputChannel] = []
    @Published var selection: Set<InputChannel.ID> = []

    @Published private(set) var lastMultiSelection: [UUID] = []

    private let customToken = "Custom…"

    private let micDIBase: [String] = [
        "mic/di",
        "SM58", "SM57", "Beta 52", "e906", "C414",
        "DI Box", "Radial JDI", "Countryman DI",
        "Custom…"
    ]

    private let standBase: [String] = [
        "None",
        "Boom",
        "Straight",
        "Short boom",
        "Straight, round base",
        "Desk",
        "Table",
        "Clip on",
        "Custom…"
    ]

    @Published private(set) var micDICustom: [String] = []
    @Published private(set) var standCustom: [String] = []

    var micDIOptions: [String] {
        makeOptions(base: micDIBase, custom: micDICustom)
    }

    var standOptions: [String] {
        makeOptions(base: standBase, custom: standCustom)
    }

    func captureMultiSelectionSnapshot(_ newSelection: Set<InputChannel.ID>) {
        guard newSelection.count > 1 else { return }
        lastMultiSelection = Array(newSelection)
    }

    func setMicDI(_ value: String, sourceID: UUID) {
        setPreset(field: .micDI, value: value, sourceID: sourceID)
    }

    func setStand(_ value: String, sourceID: UUID) {
        setPreset(field: .stand, value: value, sourceID: sourceID)
    }

    func commitCustomMicDI(sourceID: UUID, value: String) {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !v.isEmpty else { return }
        guard v != customToken else { return }

        registerCustomIfNeeded(field: .micDI, value: v)
        setMicDI(v, sourceID: sourceID)
    }

    func commitCustomStand(sourceID: UUID, value: String) {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !v.isEmpty else { return }
        guard v != customToken else { return }

        registerCustomIfNeeded(field: .stand, value: v)
        setStand(v, sourceID: sourceID)
    }

    func add() {
        channels.append(InputChannel())
        if let last = channels.last { selection = [last.id] }
    }

    func deleteSelected() {
        let ids = selection
        channels.removeAll { ids.contains($0.id) }
        selection.removeAll()
    }

    func clearAll() {
        channels.removeAll()
        selection.removeAll()
    }

    func moveUp() {
        guard !selection.isEmpty else { return }
        let selectedIndices = channels.indices.filter { selection.contains(channels[$0].id) }
        guard let first = selectedIndices.first, first > 0 else { return }

        var newChannels = channels
        for i in selectedIndices {
            newChannels.swapAt(i, i - 1)
        }
        channels = newChannels
    }

    func moveDown() {
        guard !selection.isEmpty else { return }
        let selectedIndices = channels.indices.filter { selection.contains(channels[$0].id) }
        guard let last = selectedIndices.last, last < channels.count - 1 else { return }

        var newChannels = channels
        for i in selectedIndices.reversed() {
            newChannels.swapAt(i, i + 1)
        }
        channels = newChannels
    }

    func index(of ch: InputChannel) -> Int {
        channels.firstIndex(where: { $0.id == ch.id }) ?? 0
    }

    func applyDropFill(payload: PresetDragPayload, targetID: UUID) {
        let cleaned = payload.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        guard let startIndex = channels.firstIndex(where: { $0.id == targetID }) else { return }

        registerCustomIfNeeded(field: payload.field, value: cleaned)

        var remaining = max(1, payload.selectionCount)
        var i = startIndex

        while i < channels.count, remaining > 0 {
            switch payload.field {
            case .micDI:
                if isMicDIEmpty(channels[i].micDI) {
                    channels[i].micDI = cleaned
                    remaining -= 1
                }
            case .stand:
                if isStandEmpty(channels[i].stand) {
                    channels[i].stand = cleaned
                    remaining -= 1
                }
            }
            i += 1
        }

        selection = [targetID]
    }

    private func setPreset(field: PresetField, value: String, sourceID: UUID) {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        registerCustomIfNeeded(field: field, value: cleaned)

        let ids = resolvedBatchIDs(sourceID: sourceID)
        for id in ids {
            guard let i = channels.firstIndex(where: { $0.id == id }) else { continue }
            switch field {
            case .micDI:
                channels[i].micDI = cleaned
            case .stand:
                channels[i].stand = cleaned
            }
        }
    }

    private func resolvedBatchIDs(sourceID: UUID) -> [UUID] {
        if selection.count > 1, selection.contains(sourceID) {
            return Array(selection)
        }
        if lastMultiSelection.count > 1, lastMultiSelection.contains(sourceID) {
            return lastMultiSelection
        }
        return [sourceID]
    }

    private func registerCustomIfNeeded(field: PresetField, value: String) {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !v.isEmpty else { return }
        guard v != customToken else { return }

        switch field {
        case .micDI:
            if !micDIBase.contains(v), !micDICustom.contains(v) {
                micDICustom.append(v)
            }
        case .stand:
            if !standBase.contains(v), !standCustom.contains(v) {
                standCustom.append(v)
            }
        }
    }

    private func makeOptions(base: [String], custom: [String]) -> [String] {
        let baseWithoutCustom = base.filter { $0 != customToken }
        let merged = baseWithoutCustom + custom
        let unique = uniquePreservingOrder(merged)
        return unique + [customToken]
    }

    private func uniquePreservingOrder(_ items: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        out.reserveCapacity(items.count)

        for s in items {
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty { continue }
            if seen.insert(t).inserted { out.append(t) }
        }
        return out
    }

    private func isMicDIEmpty(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return true }
        if t.lowercased() == "mic/di" { return true }
        return false
    }

    private func isStandEmpty(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return true }
        if t.lowercased() == "none" { return true }
        return false
    }
}
