//
//  dbv_nfc_gamesApp.swift
//  dbv-nfc-games
//
//  Created by David Batista on 26/08/2025.
//

import SwiftUI

@main
struct dbv_nfc_gamesApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var appState = AppState()
    @StateObject var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationService)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Inject backend posting into location service
                    locationService.onPing = { [weak appState] location in
                        guard let appState = appState, let token = appState.authToken else { return }
                        let client = APIClient(baseURL: appState.apiBaseURL)
                        let event = APIClient.AppEvent(type: "locationPing",
                                                       details: [
                                                        "lat": String(location.coordinate.latitude),
                                                        "lon": String(location.coordinate.longitude)
                                                       ],
                                                       timestamp: Date())
                        Task { try? await client.postEvent(event, token: token) }
                    }
                }
        }
    }
}
