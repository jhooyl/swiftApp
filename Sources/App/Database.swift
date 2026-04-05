import SQLite
import Foundation

extension Connection: @unchecked @retroactive Sendable {}

struct Database {
    static let missions = Table("missions")
    static let id = Expression<Int64>("id") 
    static let name = Expression<String>("name")
    static let agency = Expression<String>("agency")
    static let destination = Expression<String>("destination")
    static let launchYear = Expression<Int>("launchYear")

    // setup the table 
    static func setup() throws -> Connection {
        let db = try Connection("db.sqlite3")
        try db.run(missions.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(name)
            t.column(agency)
            t.column(destination)
            t.column(launchYear)
        })
        return db
    }

    // fetch all missions 
    static func fetchAll(db: Connection) throws -> [SpaceMission] {
        return try db.prepare(missions).map { row in
            SpaceMission(
                id: Int(row[id]), 
                name: row[name], 
                agency: row[agency], 
                destination: row[destination], 
                launchYear: row[launchYear]
            )
        }
    }

    // add a mission 
    static func addMission(db: Connection, mission: SpaceMission) throws {
        try db.run(missions.insert(
            name <- mission.name,
            agency <- mission.agency,
            destination <- mission.destination,
            launchYear <- mission.launchYear
        ))
    }

    // modify an existing mission 
    static func updateMission(db: Connection, mission: SpaceMission) throws {
        guard let missionId = mission.id else { return }
        let query = missions.filter(id == Int64(missionId))
        try db.run(query.update(
            name <- mission.name,
            agency <- mission.agency,
            destination <- mission.destination,
            launchYear <- mission.launchYear
        ))
    }

    // remove a mission 
    static func deleteMission(db: Connection, missionId: Int) throws {
        let query = missions.filter(id == Int64(missionId))
        try db.run(query.delete())
    }
}