import Foundation
import SwiftUI

struct ChannelDragPayload: Codable, Transferable {
    var snapshots: [ChannelSnapshot]
    var sourceIDs: [UUID]

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .data) { payload in
            try JSONEncoder().encode(payload)
        } importing: { data in
            try JSONDecoder().decode(ChannelDragPayload.self, from: data)
        }
    }
}
