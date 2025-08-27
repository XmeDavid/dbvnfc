//
//  AdminNFCWriterView.swift
//  dbv-nfc-games
//

import SwiftUI

struct AdminNFCWriterView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var writer = AdminNFCWriterService()

    @State private var username: String = ""
    @State private var password: String = ""

    @State private var gameId: String = ""
    @State private var baseId: String = ""
    @State private var tagUUID: String = ""
    @State private var status: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Admin Login")) {
                    if appState.isAdmin == false {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                        SecureField("Password", text: $password)
                        Button("Login", action: adminLogin)
                    } else {
                        Text("Logged in")
                    }
                }

                Section(header: Text("Write Tag")) {
                    TextField("Game ID", text: $gameId)
                    TextField("Base ID", text: $baseId)
                    TextField("Tag UUID", text: $tagUUID)
                    Button("Write to Tag") { writer.beginWrite(baseId: baseId, uuid: tagUUID) }
                        .disabled(!appState.isAdmin || baseId.isEmpty || tagUUID.isEmpty)
                }

                if let status = status { Text(status) }
                if let writerStatus = writer.statusMessage { Text(writerStatus) }
            }
            .navigationTitle("Admin NFC Writer")
        }
    }

    private func adminLogin() {
        Task {
            do {
                let token = try await APIClient(baseURL: appState.apiBaseURL).adminLogin(username: username, password: password)
                await MainActor.run { appState.adminToken = token }
            } catch {
                await MainActor.run { status = String(describing: error) }
            }
        }
    }
}

#Preview {
    AdminNFCWriterView().environmentObject(AppState())
}


