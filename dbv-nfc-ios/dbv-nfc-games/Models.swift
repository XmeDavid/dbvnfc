//
//  Models.swift
//  dbv-nfc-games
//
//  Core domain models for the app and API integration.
//

import Foundation

// MARK: - Identifier Typealiases

public typealias GameID = String
public typealias TeamID = String
public typealias BaseID = String
public typealias EnigmaID = String

// MARK: - Game

public struct Game: Codable, Identifiable, Equatable {
    public let id: GameID
    public let name: String
    public let bases: [GameBase]
    public let enigmas: [Enigma]
}

public struct GameBase: Codable, Identifiable, Equatable {
    public let id: BaseID
    public let displayName: String
    public let nfcTagUUID: String
    public let latitude: Double
    public let longitude: Double
    public let isLocationDependent: Bool
}

// MARK: - Enigma

public struct Enigma: Codable, Identifiable, Equatable {
    public let id: EnigmaID
    public let baseId: BaseID? // nil if random from pool
    public let instructions: EnigmaInstructions
    public let answerRule: AnswerRule
}

public struct EnigmaInstructions: Codable, Equatable {
    public let text: String?
    public let imageURLs: [URL]?
}

public enum AnswerRule: String, Codable {
    case exact
    case appendTeamID // e.g., "answer + team42"
}

// MARK: - Team

public struct Team: Codable, Identifiable, Equatable {
    public let id: TeamID
    public let name: String
    public let members: [String]
    public let leaderDeviceID: String
    public var activeBaseId: BaseID?
}

// MARK: - Progress

public struct TeamBaseProgress: Codable, Identifiable, Equatable {
    // Use baseId as the stable identifier for per-base progress rows
    public var id: BaseID { baseId }
    public let baseId: BaseID
    public var arrivedAt: Date?
    public var solvedAt: Date?
    public var completedAt: Date?
    public var score: Int
}

// MARK: - Offline Queue

public struct QueuedAction: Codable, Identifiable, Equatable {
    public let id: UUID
    public let kind: String // e.g., "tapArrived", "tapCompleted", "solveEnigma", "locationPing"
    public let data: Data?
    public let createdAt: Date

    public init(id: UUID = UUID(), kind: String, data: Data?, createdAt: Date = Date()) {
        self.id = id
        self.kind = kind
        self.data = data
        self.createdAt = createdAt
    }
}


