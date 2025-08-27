//
//  AdminNFCWriterService.swift
//  dbv-nfc-games
//

import Foundation

#if canImport(CoreNFC)
import CoreNFC

@MainActor
final class AdminNFCWriterService: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var isWriting: Bool = false
    @Published var statusMessage: String?
    private var session: NFCNDEFReaderSession?
    private var payloadToWrite: Data?

    func beginWrite(baseId: BaseID, uuid: String) {
        guard NFCNDEFReaderSession.readingAvailable else {
            statusMessage = "NFC not available"
            return
        }
        let json = ["baseId": baseId, "uuid": uuid]
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
            payloadToWrite = data
        } else {
            statusMessage = "Invalid payload"
            return
        }
        isWriting = true
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "Hold near tag to write"
        session.begin()
        self.session = session
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            self.statusMessage = error.localizedDescription
            self.isWriting = false
            self.session = nil
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) { }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        session.connect(to: tag) { [weak self] error in
            guard error == nil, let self = self, let payload = self.payloadToWrite else {
                session.invalidate(errorMessage: error?.localizedDescription ?? "Connection error")
                return
            }
            let ndefPayload = NFCNDEFPayload(format: .unknown, type: Data(), identifier: Data(), payload: payload)
            let message = NFCNDEFMessage(records: [ndefPayload])
            tag.writeNDEF(message) { writeError in
                if let writeError = writeError {
                    session.invalidate(errorMessage: writeError.localizedDescription)
                } else {
                    session.alertMessage = "Write successful"
                    session.invalidate()
                    Task { @MainActor in
                        self.statusMessage = "Tag written"
                        self.isWriting = false
                        self.session = nil
                    }
                }
            }
        }
    }
}
#else
@MainActor
final class AdminNFCWriterService: NSObject, ObservableObject {
    @Published var isWriting: Bool = false
    @Published var statusMessage: String?
    func beginWrite(baseId: BaseID, uuid: String) {
        statusMessage = "NFC not available"
    }
}
#endif


