//
//  PreviewData.swift
//  PokedexPTC
//
//  Sample data for SwiftUI previews.
//

import Foundation

enum PreviewData {
    static let cards: [TCGCardBrief] = [
        TCGCardBrief(id: "me06-001", localId: "001", name: "Heracross",
                     image: nil, setName: "Delta Reign"),
        TCGCardBrief(id: "sv03.5-025", localId: "025", name: "Pikachu",
                     image: "https://assets.tcgdex.net/en/sv/sv03.5/025", setName: "151"),
        TCGCardBrief(id: "30th-c-008", localId: "008", name: "Pikachu", image: nil, setName: "30th Celebration")
    ]

    static let card: TCGCard? = {
        let json = """
        {
          "id": "me06-001", "localId": "001", "name": "Heracross", "category": "Pokemon",
          "illustrator": "Satoshi Ito", "rarity": "Common", "hp": 130, "types": ["Grass"], "stage": "Basic",
          
          "set": { "id": "me06", "name": "Delta Reign", "cardCount": { "official": 103, "total": 141 } },
          "attacks": [
            { "cost": ["Grass"], "name": "Spike Draw", "effect": "Draw 2 cards.", "damage": 20 },
            { "cost": ["Grass", "Grass", "Colorless"], "name": "High Horsepower",
              "effect": "This Pokémon also does 30 damage to itself.", "damage": 130 }
          ],
          "weaknesses": [{ "type": "Fire", "value": "×2" }],
          "retreat": 3,
          "legal": { "standard": false, "expanded": true },
          "pricing": {
            "cardmarket": { "updated": "2026-11-10T23:49:36.538Z", "unit": "EUR", "avg": null, "low": 0.02,
                            "trend": 0.02, "avg1": 0.05, "avg7": 0.04, "avg30": 0.04 },
            "tcgplayer": { "unit": "USD", "updated": "2026-11-10T23:49:52.465Z",
              "normal": { "lowPrice": 0.01, "midPrice": 0.15, "highPrice": 1.59, "marketPrice": 0.08 } }
          }
        }
        """
        return try? JSONDecoder().decode(TCGCard.self, from: Data(json.utf8))
    }()
}
