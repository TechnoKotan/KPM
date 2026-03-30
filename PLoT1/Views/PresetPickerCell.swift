import Foundation
import SwiftUI

struct PresetPickerCell: View {
    let id: UUID
    @Binding var value: String
    let options: [String]
    let customToken: String
    let customPlaceholder: String
    let dragHelp: String
    let commitCustom: (UUID, String) -> Void

    @State private var customText: String = ""

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
                .help(dragHelp)
                .padding(.trailing, 2)

            Picker("", selection: $value) {
                ForEach(options, id: \.self) { opt in
                    Text(opt).tag(opt)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)

            if value == customToken {
                HStack(spacing: 6) {
                    TextField(customPlaceholder, text: $customText)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 140)

                    Button("Save") { saveCustom() }
                        .buttonStyle(.bordered)
                        .disabled(customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .onAppear { customText = "" }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .clipped()
    }

    private func saveCustom() {
        let v = customText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !v.isEmpty else { return }
        commitCustom(id, v)
        customText = ""
    }
}
