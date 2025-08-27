//
//  NFCService.swift
//  dbv-nfc-games
//

import Foundation

#if canImport(CoreNFC)
import CoreNFC

@MainActor
final class NFCService: NSObject, ObservableObject {
    @Published var lastReadUUID: String?
    @Published var isScanning: Bool = false
    @Published var errorMessage: String?

    private var session: NFCTagReaderSession?

    func beginScan() {
        guard NFCTagReaderSession.readingAvailable else {
            errorMessage = "NFC not available on this device"
            return
        }
        isScanning = true
        errorMessage = nil
        session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self)
        session?.alertMessage = "Hold your iPhone near the NFC tag."
        session?.begin()
    }

    func stopScan() {
        session?.invalidate()
        session = nil
        isScanning = false
    }
}

extension NFCService: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = (error as NSError).localizedDescription
            self.isScanning = false
            self.session = nil
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let first = tags.first else { return }
        session.connect(to: first) { [weak self] connectError in
            guard connectError == nil, let self = self else {
                session.invalidate(errorMessage: connectError?.localizedDescription ?? "Connection error")
                return
            }
            Task { @MainActor in
                switch first {
                case .miFare(let mifare):
                    self.lastReadUUID = mifare.identifier.map { String(format: "%02hhx", $0) }.joined()
                case .iso7816(let iso):
                    self.lastReadUUID = iso.identifier.map { String(format: "%02hhx", $0) }.joined()
                case .iso15693(let iso):
                    self.lastReadUUID = iso.identifier.map { String(format: "%02hhx", $0) }.joined()
                case .feliCa(let felica):
                    self.lastReadUUID = felica.currentIDm.map { String(format: "%02hhx", $0) }.joined()
                @unknown default:
                    self.lastReadUUID = nil
                }
                self.isScanning = false
                session.alertMessage = "Tag read"
                session.invalidate()
            }
        }
    }
}
#else
@MainActor
final class NFCService: NSObject, ObservableObject {
    @Published var lastReadUUID: String?
    @Published var isScanning: Bool = false
    @Published var errorMessage: String?

    func beginScan() { errorMessage = "NFC not available on this platform" }
    func stopScan() { isScanning = false }
}
#endif


