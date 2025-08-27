//
//  EnigmaView.swift
//  dbv-nfc-games
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct EnigmaView: View {
    @EnvironmentObject private var appState: AppState
    let enigma: Enigma

    @State private var answerText: String = ""
    @State private var showBlockedOverlay: Bool = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let text = enigma.instructions.text {
                        Text(text)
                    }
                    if let images = enigma.instructions.imageURLs, images.isEmpty == false {
                        ForEach(images, id: \.self) { url in
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }

                    TextField("Your answer", text: $answerText)
                        .textFieldStyle(.roundedBorder)
                    Button("Submit") { submitAnswer() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }

            if showBlockedOverlay {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .overlay(
                        VStack { Text("Screenshots blocked").foregroundColor(.white).bold() }
                    )
            }
        }
        .navigationTitle("Enigma")
#if canImport(UIKit)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            showBlockedOverlay = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showBlockedOverlay = false }
        }
#endif
    }

    private func submitAnswer() {
        let ok = appState.validateAndMarkSolved(answer: answerText)
        if !ok {
            // Could show an inline error; keep it simple for now
        }
    }
}

#Preview {
    let e = Enigma(id: "e1", baseId: nil, instructions: EnigmaInstructions(text: "Riddle...", imageURLs: nil), answerRule: .appendTeamID)
    return EnigmaView(enigma: e).environmentObject(AppState())
}


