import Foundation
import Hummingbird
import SQLite

let db = try Database.setup()

let router = Router()

// ROUTES:

// READ: display all missions (includes search logic)
router.get("/") { request, _ -> HTML in
    let allMissions = try Database.fetchAll(db: db)
    
    // check for search parameter in URL: /?search=Mars
    let query = request.uri.queryParameters.get("search")?.lowercased()
    
    if let searchTerm = query, !searchTerm.isEmpty {
        // filter logic: matches mission name/destination
        let filtered = allMissions.filter { 
            $0.name.lowercased().contains(searchTerm) || 
            $0.destination.lowercased().contains(searchTerm) 
        }
        return Views.renderIndex(missions: filtered, searchQuery: searchTerm)
    }
    
    return Views.renderIndex(missions: allMissions)
}

// CREATE: add a new mission from the form
router.post("/add") { request, _ -> Response in
    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)
    
    // parse the form-url-encoded body
    var components = URLComponents()
    components.percentEncodedQuery = bodyString
    let queryItems = components.queryItems ?? []
    
    let name = queryItems.first(where: { $0.name == "name" })?.value ?? ""
    let agency = queryItems.first(where: { $0.name == "agency" })?.value ?? ""
    let destination = queryItems.first(where: { $0.name == "destination" })?.value ?? ""
    let yearStr = queryItems.first(where: { $0.name == "launchYear" })?.value ?? ""
    
    // ensures fields aren't empty + the year is realistic number
    guard !name.isEmpty, !agency.isEmpty, let yearInt = Int(yearStr), yearInt > 1950 else {
        return Response(status: .badRequest) 
    }
    
    let mission = SpaceMission(id: nil, name: name, agency: agency, destination: destination, launchYear: yearInt)
    try Database.addMission(db: db, mission: mission)
    
    // redirect back to home
    return Response(status: .seeOther, headers: [.location: "/"])
}

// UPDATE (the view): show the edit form for a specific mission
router.get("/edit/:id") { _, context -> HTML in
    guard let idStr = context.parameters.get("id"), let idInt = Int(idStr) else {
        throw HTTPError(.badRequest)
    }
    
    let allMissions = try Database.fetchAll(db: db)
    guard let mission = allMissions.first(where: { $0.id == idInt }) else {
        throw HTTPError(.notFound)
    }
    
    return Views.renderEdit(mission: mission)
}

// UPDATE (the action): process the changes from the edit form
router.post("/update/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"), let idInt = Int(idStr) else {
        return Response(status: .badRequest)
    }
    
    let buffer = try await request.body.collect(upTo: 1024 * 16)
    let bodyString = String(buffer: buffer)
    
    var components = URLComponents()
    components.percentEncodedQuery = bodyString
    let queryItems = components.queryItems ?? []
    
    let name = queryItems.first(where: { $0.name == "name" })?.value ?? ""
    let agency = queryItems.first(where: { $0.name == "agency" })?.value ?? ""
    let destination = queryItems.first(where: { $0.name == "destination" })?.value ?? ""
    let yearStr = queryItems.first(where: { $0.name == "launchYear" })?.value ?? ""
    
    let updatedMission = SpaceMission(
        id: idInt,
        name: name,
        agency: agency,
        destination: destination,
        launchYear: Int(yearStr) ?? 0
    )
    
    try Database.updateMission(db: db, mission: updatedMission)
    return Response(status: .seeOther, headers: [.location: "/"])
}

// DELETE: remove a mission from the DB
router.post("/delete/:id") { _, context -> Response in
    guard let idStr = context.parameters.get("id"), let idInt = Int(idStr) else {
        return Response(status: .badRequest)
    }
    
    try Database.deleteMission(db: db, missionId: idInt)
    return Response(status: .seeOther, headers: [.location: "/"])
}

// start the Server
let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

print("Space Mission Control active at http://localhost:8080")
try await app.runService()