import SwiftUI

struct InputListCommandHandler {
    let add: () -> Void
    let deleteSelected: () -> Void
    let clearAll: () -> Void
    let moveUp: () -> Void
    let moveDown: () -> Void
}

private struct InputListCommandHandlerKey: FocusedValueKey {
    typealias Value = InputListCommandHandler
}

extension FocusedValues {
    var inputListCommands: InputListCommandHandler? {
        get { self[InputListCommandHandlerKey.self] }
        set { self[InputListCommandHandlerKey.self] = newValue }
    }
}
