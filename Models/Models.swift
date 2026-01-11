//
//  Models.swift
//  mobile
//
//  Data models for dashboard and box data
//

import Foundation

// MARK: - Box Model

struct Box: Codable, Identifiable, Hashable {
    let id: UUID
    let high: Double
    let low: Double
    let value: Double
    
    init(high: Double, low: Double, value: Double) {
        self.id = UUID()
        self.high = high
        self.low = low
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.high = try container.decode(Double.self, forKey: .high)
        self.low = try container.decode(Double.self, forKey: .low)
        self.value = try container.decode(Double.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(high, forKey: .high)
        try container.encode(low, forKey: .low)
        try container.encode(value, forKey: .value)
    }
    
    enum CodingKeys: String, CodingKey {
        case high, low, value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Box, rhs: Box) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Box Slice

struct BoxSlice: Codable, Identifiable, Hashable {
    let id: UUID
    let timestamp: String
    let boxes: [Box]
    
    init(timestamp: String, boxes: [Box]) {
        self.id = UUID()
        self.timestamp = timestamp
        self.boxes = boxes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.timestamp = try container.decode(String.self, forKey: .timestamp)
        self.boxes = try container.decode([Box].self, forKey: .boxes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(boxes, forKey: .boxes)
    }
    
    enum CodingKeys: String, CodingKey {
        case timestamp, boxes
    }
    
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: timestamp) ?? ISO8601DateFormatter().date(from: timestamp)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BoxSlice, rhs: BoxSlice) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Pair Data

struct PairData: Codable {
    let boxes: [BoxSlice]
    let initialBoxData: BoxSlice?
    
    init(boxes: [BoxSlice] = [], initialBoxData: BoxSlice? = nil) {
        self.boxes = boxes
        self.initialBoxData = initialBoxData
    }
}

// MARK: - Price Data

struct PriceData: Codable {
    let price: Double
    let timestamp: String
    let volume: Double
    
    var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: timestamp) ?? ISO8601DateFormatter().date(from: timestamp)
    }
}

// MARK: - Box Snapshot (for Ryver mode)

struct BoxSnapshot: Codable, Identifiable {
    let id = UUID()
    let timestamp: String
    let boxes: [Box]
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case timestamp, boxes, price
    }
}

// MARK: - Signal (for highlighting)

struct Signal: Codable, Identifiable {
    let id = UUID()
    let signalId: String
    let pair: String
    let signalType: String // "LONG" or "SHORT"
    let patternSequence: [Int]
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case signalId, pair, signalType, patternSequence, timestamp
    }
    
    var isRecent: Bool {
        guard let date = ISO8601DateFormatter().date(from: timestamp) else { return false }
        let age = Date().timeIntervalSince(date)
        return age < 3600 // 1 hour
    }
}
