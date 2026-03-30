import SwiftUI

@main
struct PLoT1App: App {
    @FocusedValue(\.inputListCommands) private var inputListCommands

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandMenu("Input List") {
                Button("Add Channel") { inputListCommands?.add() }
                    .keyboardShortcut("n", modifiers: [.command])

                Button("Delete Selected") { inputListCommands?.deleteSelected() }
                    .keyboardShortcut(.delete, modifiers: [.command])

                Button("Clear All") { inputListCommands?.clearAll() }
                    .keyboardShortcut("k", modifiers: [.command, .shift])

                Divider()

                Button("Move Up") { inputListCommands?.moveUp() }
                    .keyboardShortcut(.upArrow, modifiers: [.command])

                Button("Move Down") { inputListCommands?.moveDown() }
                    .keyboardShortcut(.downArrow, modifiers: [.command])
            }
        }
    }
}
