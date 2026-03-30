import Foundation

struct InputChannel: Identifiable, Equatable, Codable {
    var id = UUID()
    var source: String = ""
    var micDI: String = "mic/di"
    var stand: String = "None"
    var phantom: Bool = false
    var comments: String = ""
}

extension InputChannel {
    func snapshot() -> ChannelSnapshot {
        ChannelSnapshot(
            source: source,
            micDI: micDI,
            stand: stand,
            phantom: phantom,
            comments: comments
        )
    }

    mutating func apply(snapshot: ChannelSnapshot) {
        source = snapshot.source
        micDI = snapshot.micDI
        stand = snapshot.stand
        phantom = snapshot.phantom
        comments = snapshot.comments
    }
}
