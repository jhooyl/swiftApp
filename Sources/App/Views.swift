import Hummingbird
import Foundation

struct Views {
    // 1. The Main Page (Read & Create Operations)
// 1. Updated Main Page with Search Bar
    static func renderIndex(missions: [SpaceMission], searchQuery: String? = nil) -> HTML {
        let rows = missions.map { mission in
            """
            <tr>
                <td>\(mission.name)</td>
                <td>\(mission.agency)</td>
                <td>\(mission.destination)</td>
                <td>\(mission.launchYear)</td>
                <td>
                    <div style="display: flex; gap: 5px;">
                        <a href="/edit/\(mission.id ?? 0)" role="button" class="outline" style="padding: 4px 8px; font-size: 0.8rem;">Edit</a>
                        <form action="/delete/\(mission.id ?? 0)" method="post" style="margin: 0;">
                            <button type="submit" class="secondary" style="padding: 4px 8px; font-size: 0.8rem;">Delete</button>
                        </form>
                    </div>
                </td>
            </tr>
            """
        }.joined()

        let searchVal = searchQuery ?? ""

        return HTML(content: """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
            <title>Space Mission Control</title>
        </head>
        <body class="container" style="padding-top: 2rem;">
            <header>
                <nav>
                  <ul><li><strong>🚀 Mission Control</strong></li></ul>
                  <ul>
                    <li><a href="/" class="secondary">View All</a></li>
                  </ul>
                </nav>
                <h1>Interstellar Registry</h1>
            </header>
            
            <main>
                <section>
                    <form action="/" method="get" style="display: flex; gap: 10px;">
                        <input type="search" name="search" placeholder="Search by mission or destination..." value="\(searchVal)" style="flex-grow: 1;">
                        <button type="submit" class="outline">Search</button>
                    </form>

                    <table role="grid">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Agency</th>
                                <th>Destination</th>
                                <th>Year</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            \(missions.isEmpty ? "<tr><td colspan='5'>No missions found.</td></tr>" : rows)
                        </tbody>
                    </table>
                </section>

                <hr>

                <section>
                    <h2>Add New Mission</h2>
                    <form action="/add" method="post">
                        <div class="grid">
                            <input type="text" name="name" placeholder="Mission Name" required>
                            <input type="text" name="agency" placeholder="Agency" required>
                        </div>
                        <div class="grid">
                            <input type="text" name="destination" placeholder="Destination" required>
                            <input type="number" name="launchYear" placeholder="Year (e.g. 2024)" required>
                        </div>
                        <button type="submit">Log Mission</button>
                    </form>
                </section>
            </main>
        </body>
        </html>
        """)
    }

    // 2. The Edit Page (Update Operation)
    static func renderEdit(mission: SpaceMission) -> HTML {
        return HTML(content: """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
            <title>Edit Mission</title>
        </head>
        <body class="container" style="padding-top: 2rem;">
            <h1>Modify Mission Parameters</h1>
            <form action="/update/\(mission.id ?? 0)" method="post">
                <label>Mission Name
                    <input type="text" name="name" value="\(mission.name)" required>
                </label>
                <label>Agency
                    <input type="text" name="agency" value="\(mission.agency)" required>
                </label>
                <label>Destination
                    <input type="text" name="destination" value="\(mission.destination)" required>
                </label>
                <label>Launch Year
                    <input type="number" name="launchYear" value="\(mission.launchYear)" required>
                </label>
                <button type="submit">Confirm Changes</button>
                <a href="/" class="secondary" role="button">Cancel</a>
            </form>
        </body>
        </html>
        """)
    }
}

// Helper to make Hummingbird accept our HTML strings [cite: 51]
struct HTML: ResponseGenerator {
    let content: String
    func response(from request: Request, context: some RequestContext) throws -> Response {
        return Response(
            status: .ok,
            headers: [.contentType: "text/html"],
            body: .init(byteBuffer: .init(string: content))
        )
    }
}