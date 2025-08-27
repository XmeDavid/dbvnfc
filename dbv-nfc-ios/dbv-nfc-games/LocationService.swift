//
//  LocationService.swift
//  dbv-nfc-games
//

import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastLocation: CLLocation?
    @Published var isPinging: Bool = false

    private let manager: CLLocationManager
    private var timer: Timer?

    // Dependency-injected poster to send events to backend
    var onPing: ((CLLocation) -> Void)?

    override init() {
        self.manager = CLLocationManager()
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdates() {
        manager.startUpdatingLocation()
        startPingTimer()
        isPinging = true
    }

    func stopUpdates() {
        manager.stopUpdatingLocation()
        stopPingTimer()
        isPinging = false
    }

    private func startPingTimer() {
        stopPingTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self = self, let location = self.lastLocation else { return }
            self.onPing?(location)
        }
    }

    private func stopPingTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.lastLocation = locations.last
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
}


