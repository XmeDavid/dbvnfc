//
//  HomeView.swift
//  dbv-nfc-games
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var nfc = NFCService()

    @State private var joinCode: String = ""
    @State private var isJoining: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if let team = appState.currentTeam {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Team: \(team.name)").font(.headline)
                        Text("Leader device: \(team.leaderDeviceID == appState.deviceId ? "You" : "Other")")
                        if let game = appState.currentGame {
                            Text("Game: \(game.name)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        Button(action: { nfc.beginScan() }) {
                            Label("Scan NFC", systemImage: "dot.radiowaves.up.forward")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(nfc.isScanning)

                        if nfc.isScanning { ProgressView() }
                    }
                } else {
                    TextField("Join code", text: $joinCode)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button(action: joinTeam) {
                        if isJoining { ProgressView() } else { Text("Join Team") }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(joinCode.isEmpty || isJoining)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
        .onChange(of: nfc.lastReadUUID) { newValue in
            guard let uuid = newValue else { return }
            Task {
                let result = await appState.processTag(uuid: uuid)
                await MainActor.run {
                    switch result {
                    case .success:
                        errorMessage = nil
                    case .failure(let err):
                        errorMessage = err.localizedDescription
                    }
                }
            }
        }
        .sheet(item: $appState.enigmaSession) { session in
            NavigationView {
                EnigmaView(enigma: session.enigma)
                    .environmentObject(appState)
            }
        }
    }

    private func joinTeam() {
        guard isJoining == false else { return }
        isJoining = true
        errorMessage = nil
        Task {
            do {
                let client = APIClient(baseURL: appState.apiBaseURL)
                let (token, team) = try await client.joinTeam(joinCode: joinCode, deviceId: appState.deviceId)
                await MainActor.run {
                    appState.authToken = token
                    appState.currentTeam = team
                }
                // In a real app, fetch the game after join (omitted here)
            } catch {
                await MainActor.run { errorMessage = String(describing: error) }
            }
            await MainActor.run { isJoining = false }
        }
    }
}

#Preview {
    HomeView().environmentObject(AppState())
}


