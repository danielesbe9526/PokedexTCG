//
//  TestSupport.swift
//  PokedexPTCTests
//

import Foundation
@testable import HoloVault

enum Fixture {
    static func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    /// Card detail with optional TCGplayer variants (`name: market`) and Cardmarket trend.
    static func card(id: String = "sv03.5-025", name: String = "Pikachu",
                     tcgplayer: [String: Double]? = nil, cardmarketTrend: Double? = nil) throws -> TCGCard {
        var pricing: [String] = []
        if let tcgplayer {
            let variants = tcgplayer.map { "\"\($0.key)\": { \"marketPrice\": \($0.value), \"midPrice\": 999 }" }
            pricing.append("\"tcgplayer\": { \"unit\": \"USD\", \(variants.joined(separator: ", ")) }")
        }
        if let cardmarketTrend {
            pricing.append("\"cardmarket\": { \"unit\": \"EUR\", \"trend\": \(cardmarketTrend) }")
        }
        let pricingJSON = pricing.isEmpty ? "null" : "{ \(pricing.joined(separator: ", ")) }"
        return try decode(TCGCard.self, """
        { "id": "\(id)", "localId": "025", "name": "\(name)", "image": "https://assets.tcgdex.net/en/sv/sv03.5/025",
          "set": { "id": "sv03.5", "name": "151" }, "pricing": \(pricingJSON) }
        """)
    }
}

/// Thread-safe call recorder for the fakes.
actor CallLog {
    private(set) var calls: [String] = []

    func record(_ call: String) {
        calls.append(call)
    }

    func count(of call: String) -> Int {
        calls.filter { $0 == call }.count
    }
}

struct FakeTCGApi: TCGApiType {
    var cards: [TCGCardBrief] = []
    var sets: [TCGSetBrief] = []
    var setDetails: [String: TCGSet] = [:]
    var failingCardIds: Set<String> = []
    /// Market price returned for every card detail, so price refreshes can be observed.
    var marketPrice: Double = 1
    let log = CallLog()

    func searchCards(name: String) async throws -> [TCGCardBrief] {
        await log.record("search:\(name)")
        return cards
    }

    func getCard(id: String) async throws -> TCGCard {
        await log.record("card:\(id)")
        if failingCardIds.contains(id) { throw APIError.server(status: 500) }
        return try Fixture.card(id: id, tcgplayer: ["normal": marketPrice])
    }

    func getSets() async throws -> [TCGSetBrief] {
        await log.record("sets")
        return sets
    }

    func getSet(id: String) async throws -> TCGSet {
        await log.record("set:\(id)")
        guard let set = setDetails[id] else { throw APIError.server(status: 404) }
        return set
    }
}
