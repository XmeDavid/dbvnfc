//
//  ProgressViewScreen.swift
//  dbv-nfc-games
//

import SwiftUI

struct ProgressViewScreen: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationView {
            List(appState.teamProgress) { row in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Base: \(row.baseId)")
                    HStack(spacing: 12) {
                        Text(row.arrivedAt != nil ? "Arrived" : "-")
                        Text(row.solvedAt != nil ? "Solved" : "-")
                        Text(row.completedAt != nil ? "Completed" : "-")
                        Text("Score: \(row.score)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressViewScreen().environmentObject(AppState())
}


