import Foundation
import SwiftUI

struct InputListView: View {
    @StateObject private var vm = InputListViewModel()

    private func resolvedSelectionCount(dragging sourceID: UUID) -> Int {
        if vm.selection.count > 1, vm.selection.contains(sourceID) {
            return vm.selection.count
        }
        if vm.lastMultiSelection.count > 1, vm.lastMultiSelection.contains(sourceID) {
            return vm.lastMultiSelection.count
        }
        return 1
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button { vm.add() } label: { Label("Add", systemImage: "plus") }

                Button(role: .destructive) { vm.deleteSelected() } label: {
                    Label("Delete", systemImage: "trash")
                }

                Button { vm.clearAll() } label: {
                    Label("Clear all", systemImage: "trash.slash")
                }

                Divider().frame(height: 22)

                Button { vm.moveUp() } label: { Label("Up", systemImage: "arrow.up") }
                Button { vm.moveDown() } label: { Label("Down", systemImage: "arrow.down") }

                Spacer()
            }
            .padding(.horizontal)

            Table(of: InputChannel.self, selection: $vm.selection) {
                TableColumn("") { ch in
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.secondary)
                        .help("Drag whole channel")
                        .frame(width: 18)
                        .contentShape(Rectangle())
                        .draggable(vm.makeChannelDragPayload(sourceID: ch.id))
                        .dropDestination(for: ChannelDragPayload.self) { items, _ in
                            guard let payload = items.first else { return false }
                            vm.applyChannelDrop(payload: payload, targetID: ch.id)
                            return true
                        }
                }
                .width(min: 28, ideal: 32, max: 36)

                TableColumn("#") { ch in
                    Text("\(vm.index(of: ch) + 1)")
                        .frame(width: 34, alignment: .trailing)
                }

                TableColumn("Source") { ch in
                    TextField("Source", text: binding(for: ch).source)
                        .textFieldStyle(.roundedBorder)
                }

                TableColumn("Mic,DI") { ch in
                    let micBinding = Binding<String>(
                        get: { binding(for: ch).micDI.wrappedValue },
                        set: { vm.setMicDI($0, sourceID: ch.id) }
                    )

                    let dragPayload = PresetDragPayload(
                        field: .micDI,
                        value: micBinding.wrappedValue,
                        sourceID: ch.id,
                        selectionCount: resolvedSelectionCount(dragging: ch.id)
                    )

                    PresetPickerCell(
                        id: ch.id,
                        value: micBinding,
                        options: vm.micDIOptions,
                        customToken: "Custom…",
                        customPlaceholder: "Type custom model",
                        dragHelp: "Drag Mic,DI to another channel",
                        commitCustom: { id, text in
                            vm.commitCustomMicDI(sourceID: id, value: text)
                        }
                    )
                    .frame(minWidth: 220)
                    .draggable(dragPayload)
                    .dropDestination(for: PresetDragPayload.self) { items, _ in
                        guard let payload = items.first else { return false }
                        vm.applyDropFill(payload: payload, targetID: ch.id)
                        return true
                    }
                }

                TableColumn("Stand") { ch in
                    let standBinding = Binding<String>(
                        get: { binding(for: ch).stand.wrappedValue },
                        set: { vm.setStand($0, sourceID: ch.id) }
                    )

                    let dragPayload = PresetDragPayload(
                        field: .stand,
                        value: standBinding.wrappedValue,
                        sourceID: ch.id,
                        selectionCount: resolvedSelectionCount(dragging: ch.id)
                    )

                    PresetPickerCell(
                        id: ch.id,
                        value: standBinding,
                        options: vm.standOptions,
                        customToken: "Custom…",
                        customPlaceholder: "Type custom stand",
                        dragHelp: "Drag Stand to another channel",
                        commitCustom: { id, text in
                            vm.commitCustomStand(sourceID: id, value: text)
                        }
                    )
                    .frame(minWidth: 180)
                    .draggable(dragPayload)
                    .dropDestination(for: PresetDragPayload.self) { items, _ in
                        guard let payload = items.first else { return false }
                        vm.applyDropFill(payload: payload, targetID: ch.id)
                        return true
                    }
                }

                TableColumn("48V") { ch in
                    Toggle("", isOn: binding(for: ch).phantom)
                        .labelsHidden()
                        .frame(width: 46)
                }

                TableColumn("Comments") { ch in
                    TextField("Comments", text: binding(for: ch).comments)
                        .textFieldStyle(.roundedBorder)
                }
            } rows: {
                ForEach(vm.channels) { ch in
                    TableRow(ch)
                }
            }
            .onChange(of: vm.selection) { _, newValue in
                vm.captureMultiSelectionSnapshot(newValue)
            }
            .onDeleteCommand { vm.deleteSelected() }
            .focusedValue(\.inputListCommands, InputListCommandHandler(
                add: { vm.add() },
                deleteSelected: { vm.deleteSelected() },
                clearAll: { vm.clearAll() },
                moveUp: { vm.moveUp() },
                moveDown: { vm.moveDown() }
            ))
        }
        .padding(.vertical)
        .navigationTitle("Input List")
    }

    private func binding(for item: InputChannel) -> Binding<InputChannel> {
        Binding(
            get: { vm.channels.first(where: { $0.id == item.id }) ?? item },
            set: { newValue in
                if let i = vm.channels.firstIndex(where: { $0.id == item.id }) {
                    vm.channels[i] = newValue
                }
            }
        )
    }
}
