import Foundation

struct InputChannel: Identifiable, Equatable, Codable {
    var id = UUID()
    var source: String = ""
    var micDI: String = "mic/di"
    var stand: String = "None"
    var phantom: Bool = false
    var comments: String = ""
}
