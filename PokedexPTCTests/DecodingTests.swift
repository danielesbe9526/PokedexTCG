//
//  DecodingTests.swift
//  PokedexPTCTests
//

import Foundation
import Testing
@testable import Binderly

@Suite("TCGdex decoding")
struct TCGDecodingTests {
    @Test("Card detail with mixed damage types, missing fields and dynamic TCGplayer variants")
    func cardDetail() throws {
        let card = try Fixture.decode(TCGCard.self, """
        {
          "id": "me06-001", "localId": "001", "name": "Heracross", "category": "Pokemon",
          "hp": "130", "types": ["Grass"],
          "set": { "id": "me06", "name": "Delta Reign", "cardCount": { "official": 103, "total": 141 } },
          "attacks": [
            { "cost": ["Grass"], "name": "Spike Draw", "effect": "Draw 2 cards.", "damage": 20 },
            { "cost": ["Grass", "Colorless"], "name": "Rage", "damage": "30+" },
            { "name": "Free" }
          ],
          "retreat": 3,
          "pricing": {
            "cardmarket": { "unit": "EUR", "avg": null, "trend": 0.02, "avg30": 0.04 },
            "tcgplayer": {
              "unit": "USD", "updated": "2026-11-10T23:49:52.465Z",
              "reverse-holofoil": { "lowPrice": 0.03, "marketPrice": 0.13 },
              "normal": { "lowPrice": 0.01, "midPrice": 0.15, "highPrice": 1.59, "marketPrice": 0.08 }
            }
          }
        }
        """)

        #expect(card.hp == 130)
        #expect(card.numberText == "001/103")
        #expect(card.attacks?.map(\.damage) == ["20", "30+", nil])
        #expect(card.attacks?.last?.cost == [])
        #expect(card.illustrator == nil)
        #expect(card.pricing?.cardmarket?.avg == nil)
        #expect(card.pricing?.cardmarket?.trend == 0.02)
        #expect(card.pricing?.tcgplayer?.variants.map(\.name) == ["normal", "reverse-holofoil"])
        #expect(card.pricing?.tcgplayer?.variants.last?.displayName == "Reverse Holofoil")
        #expect(card.pricing?.isEmpty == false)
    }

    @Test("A malformed optional block does not break the whole card")
    func tolerantOptionalBlocks() throws {
        let card = try Fixture.decode(TCGCard.self, """
        { "id": "x-1", "localId": "1", "name": "Trainer", "category": "Trainer",
          "set": { "id": "x", "name": "X" }, "attacks": "unexpected", "legal": 42, "pricing": null }
        """)
        #expect(card.attacks == nil)
        #expect(card.legal == nil)
        #expect(card.pricing == nil)
        #expect(card.largeImageURL == nil)
    }

    @Test("Set id is derived from the card id, including set ids with dashes",
          arguments: [
            ("me06-001", "001", "me06"),
            ("30th-c-008", "008", "30th-c"),
            ("tk-hs-r-2", "2", "tk-hs-r"),
            ("sv03.5-025", "025", "sv03.5")
          ])
    func setId(cardId: String, localId: String, expected: String) {
        let card = TCGCardBrief(id: cardId, localId: localId, name: "Pikachu", image: nil)
        #expect(card.setId == expected)
    }

    @Test("Image URLs append quality and webp extension, and are nil without a base")
    func imageURLs() {
        let card = TCGCardBrief(id: "base1-58", localId: "58", name: "Pikachu",
                                image: "https://assets.tcgdex.net/en/base/base1/58")
        #expect(card.smallImageURL?.absoluteString == "https://assets.tcgdex.net/en/base/base1/58/low.webp")
        #expect(card.largeImageURL?.absoluteString == "https://assets.tcgdex.net/en/base/base1/58/high.webp")
        #expect(TCGCardBrief(id: "a-1", localId: "1", name: "A", image: nil).smallImageURL == nil)
    }
}

@Suite("Set decoding")
struct SetDecodingTests {
    @Test("Set list items include the card count")
    func setBrief() throws {
        let sets = try Fixture.decode([TCGSetBrief].self, """
        [{ "id": "me06", "name": "Delta Reign", "logo": "x", "cardCount": { "total": 141, "official": 103 } },
         { "id": "old", "name": "Old Set" }]
        """)
        #expect(sets.first?.cardCount?.total == 141)
        #expect(sets.last?.cardCount == nil)
    }

    @Test("Set detail decodes its cards and tolerates a missing card list")
    func setDetail() throws {
        let set = try Fixture.decode(TCGSet.self, """
        { "id": "me06", "name": "Delta Reign", "releaseDate": "2026-11-06",
          "cards": [{ "id": "me06-001", "localId": "001", "name": "Heracross" }] }
        """)
        #expect(set.cards.map(\.id) == ["me06-001"])
        #expect(set.releaseDate == "2026-11-06")

        let empty = try Fixture.decode(TCGSet.self, #"{ "id": "x", "name": "X", "cards": "oops" }"#)
        #expect(empty.cards.isEmpty)
    }
}

@Suite("API routes")
struct APIRouteTests {
    @Test func paths() {
        #expect(APIRoute.searchCards(name: "pikachu").path == "v2/en/cards")
        #expect(APIRoute.searchCards(name: "pikachu").queryItems == [URLQueryItem(name: "name", value: "like:pikachu")])
        #expect(APIRoute.getCard(id: "me06-001").path == "v2/en/cards/me06-001")
        #expect(APIRoute.getSets.path == "v2/en/sets")
        #expect(APIRoute.getSet(id: "sv03.5").path == "v2/en/sets/sv03.5")
    }

    @Test("Requests use the configured base URL, or TCGdex by default")
    func baseURL() {
        let custom = APIInteractor(projectParameters: ["url_tcgdex": "https://example.com"], session: SessionMockedFail())
        #expect(custom.urlRequest(for: .getSets)?.url?.absoluteString == "https://example.com/v2/en/sets")

        let fallback = APIInteractor(projectParameters: [:], session: SessionMockedFail())
        #expect(fallback.urlRequest(for: .searchCards(name: "mew"))?.url?.absoluteString
                == "https://api.tcgdex.net/v2/en/cards?name=like:mew")
    }
}
