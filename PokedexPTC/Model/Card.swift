//
//  Card.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//
//  TCGdex models (https://tcgdex.dev). Every field that can vary between eras is optional and
//  free-form (`String` instead of closed enums) so a new set or series never breaks decoding.
//

import Foundation

// MARK: - Card list item

public struct TCGCardBrief: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    let localId: String
    let name: String
    /// Base asset URL without quality/extension. Missing for some recent or promo cards.
    let image: String?

    /// Filled by the view model from the sets list; not part of the payload.
    var setName: String? = nil

    enum CodingKeys: String, CodingKey {
        case id, localId, name, image
    }

    /// The set id is the card id minus the trailing "-localId" (set ids may contain dashes, e.g. "30th-c").
    var setId: String {
        let suffix = "-\(localId)"
        return id.hasSuffix(suffix) ? String(id.dropLast(suffix.count)) : id
    }

    var smallImageURL: URL? { TCGImage.url(base: image, quality: .low) }
    var largeImageURL: URL? { TCGImage.url(base: image, quality: .high) }
}

enum TCGImage {
    enum Quality: String {
        case low, high
    }

    static func url(base: String?, quality: Quality) -> URL? {
        guard let base, !base.isEmpty else { return nil }
        return URL(string: "\(base)/\(quality.rawValue).webp")
    }
}

// MARK: - Set list item

struct TCGSetBrief: Codable, Hashable, Sendable, Identifiable {
    let id: String
    let name: String
}

// MARK: - Card detail

struct TCGCard: Decodable, Hashable, Sendable, Identifiable {
    let id: String
    let localId: String
    let name: String
    let image: String?
    let category: String?
    let illustrator: String?
    let rarity: String?
    let hp: Int?
    let types: [String]?
    let stage: String?
    let evolveFrom: String?
    let description: String?
    let abilities: [TCGAbility]?
    let attacks: [TCGAttack]?
    let weaknesses: [TCGTypeModifier]?
    let resistances: [TCGTypeModifier]?
    let retreat: Int?
    let regulationMark: String?
    let set: TCGCardSet
    let legal: TCGLegal?
    let pricing: TCGPricing?

    var largeImageURL: URL? { TCGImage.url(base: image, quality: .high) }

    var numberText: String {
        if let official = set.cardCount?.official {
            return "\(localId)/\(official)"
        }
        return localId
    }

    enum CodingKeys: String, CodingKey {
        case id, localId, name, image, category, illustrator, rarity, hp, types, stage, evolveFrom
        case description, abilities, attacks, weaknesses, resistances, retreat, regulationMark, set, legal, pricing
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        localId = try c.decodeIfPresent(String.self, forKey: .localId) ?? ""
        name = try c.decode(String.self, forKey: .name)
        image = try c.decodeIfPresent(String.self, forKey: .image)
        category = try c.decodeIfPresent(String.self, forKey: .category)
        illustrator = try c.decodeIfPresent(String.self, forKey: .illustrator)
        rarity = try c.decodeIfPresent(String.self, forKey: .rarity)
        hp = c.decodeLossyInt(forKey: .hp)
        types = try? c.decodeIfPresent([String].self, forKey: .types)
        stage = try? c.decodeIfPresent(String.self, forKey: .stage)
        evolveFrom = try? c.decodeIfPresent(String.self, forKey: .evolveFrom)
        description = try? c.decodeIfPresent(String.self, forKey: .description)
        abilities = try? c.decodeIfPresent([TCGAbility].self, forKey: .abilities)
        attacks = try? c.decodeIfPresent([TCGAttack].self, forKey: .attacks)
        weaknesses = try? c.decodeIfPresent([TCGTypeModifier].self, forKey: .weaknesses)
        resistances = try? c.decodeIfPresent([TCGTypeModifier].self, forKey: .resistances)
        retreat = c.decodeLossyInt(forKey: .retreat)
        regulationMark = try? c.decodeIfPresent(String.self, forKey: .regulationMark)
        set = try c.decode(TCGCardSet.self, forKey: .set)
        legal = try? c.decodeIfPresent(TCGLegal.self, forKey: .legal)
        pricing = try? c.decodeIfPresent(TCGPricing.self, forKey: .pricing)
    }
}

struct TCGCardSet: Codable, Hashable, Sendable {
    struct CardCount: Codable, Hashable, Sendable {
        let official: Int?
        let total: Int?
    }

    let id: String
    let name: String
    let cardCount: CardCount?
}

struct TCGAbility: Decodable, Hashable, Sendable {
    let name: String
    let effect: String?
    let type: String?
}

struct TCGAttack: Decodable, Hashable, Sendable {
    let name: String
    let cost: [String]
    let effect: String?
    /// Int or String in the payload ("30", "30+", "50×").
    let damage: String?

    enum CodingKeys: String, CodingKey {
        case name, cost, effect, damage
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        cost = (try? c.decodeIfPresent([String].self, forKey: .cost)) ?? []
        effect = try? c.decodeIfPresent(String.self, forKey: .effect)
        damage = c.decodeLossyString(forKey: .damage)
    }
}

struct TCGTypeModifier: Codable, Hashable, Sendable {
    let type: String
    let value: String?
}

struct TCGLegal: Codable, Hashable, Sendable {
    let standard: Bool?
    let expanded: Bool?
}

// MARK: - Pricing

struct TCGPricing: Decodable, Hashable, Sendable {
    let cardmarket: CardmarketPricing?
    let tcgplayer: TCGPlayerPricing?

    enum CodingKeys: String, CodingKey {
        case cardmarket, tcgplayer
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        cardmarket = try? c.decodeIfPresent(CardmarketPricing.self, forKey: .cardmarket)
        tcgplayer = try? c.decodeIfPresent(TCGPlayerPricing.self, forKey: .tcgplayer)
    }

    var isEmpty: Bool {
        (cardmarket?.hasValues ?? false) == false && (tcgplayer?.variants.isEmpty ?? true)
    }
}

struct CardmarketPricing: Codable, Hashable, Sendable {
    let updated: String?
    let unit: String?
    let avg: Double?
    let low: Double?
    let trend: Double?
    let avg1: Double?
    let avg7: Double?
    let avg30: Double?

    var hasValues: Bool {
        [avg, low, trend, avg1, avg7, avg30].contains { $0 != nil }
    }
}

struct TCGPlayerPricing: Decodable, Hashable, Sendable {
    struct Variant: Hashable, Sendable, Identifiable {
        let name: String
        let low: Double?
        let mid: Double?
        let high: Double?
        let market: Double?

        var id: String { name }

        /// "reverse-holofoil" → "Reverse Holofoil"
        var displayName: String {
            name.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
        }
    }

    private struct VariantPayload: Decodable {
        let lowPrice: Double?
        let midPrice: Double?
        let highPrice: Double?
        let marketPrice: Double?
    }

    let updated: String?
    let unit: String?
    let variants: [Variant]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        updated = c.decodeLossyString(forKey: AnyCodingKey("updated"))
        unit = c.decodeLossyString(forKey: AnyCodingKey("unit"))
        // Variant names are dynamic keys ("normal", "holofoil", "reverse-holofoil", "1st-edition-holofoil"...).
        variants = c.allKeys
            .filter { $0.stringValue != "updated" && $0.stringValue != "unit" }
            .compactMap { key in
                guard let payload = try? c.decode(VariantPayload.self, forKey: key) else { return nil }
                return Variant(name: key.stringValue, low: payload.lowPrice, mid: payload.midPrice,
                               high: payload.highPrice, market: payload.marketPrice)
            }
            .sorted { $0.name < $1.name }
    }
}

// MARK: - Decoding helpers

struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init(_ string: String) {
        stringValue = string
        intValue = nil
    }

    init?(stringValue: String) {
        self.init(stringValue)
    }

    init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {
    /// Accepts Int, Double or String values.
    func decodeLossyString(forKey key: Key) -> String? {
        if let value = try? decodeIfPresent(String.self, forKey: key) { return value }
        if let value = try? decodeIfPresent(Int.self, forKey: key) { return String(value) }
        if let value = try? decodeIfPresent(Double.self, forKey: key) { return String(value) }
        return nil
    }

    /// Accepts Int or numeric String values.
    func decodeLossyInt(forKey key: Key) -> Int? {
        if let value = try? decodeIfPresent(Int.self, forKey: key) { return value }
        if let value = try? decodeIfPresent(String.self, forKey: key) { return Int(value) }
        return nil
    }
}
