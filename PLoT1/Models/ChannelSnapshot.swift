import Foundation

struct ChannelSnapshot: Codable, Equatable {
    var source: String
    var micDI: String
    var stand: String
    var phantom: Bool
    var comments: String
}
