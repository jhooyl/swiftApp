import Foundation

struct SpaceMission: Codable, Sendable {
    var id: Int?
    var name: String
    var agency: String
    var destination: String
    var launchYear: Int
}