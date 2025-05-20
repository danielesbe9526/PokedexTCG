//
//  Card.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import Foundation


// MARK: - Card
struct Card: Codable {
    let data: [Datum]
    let page, pageSize, count, totalCount: Int
}

// MARK: - Datum
public struct Datum: Codable, Hashable, Equatable, Sendable, Identifiable {
    public let id = UUID()
    let name: String
    let supertype: String?
    let subtypes: [String]?
    let level: String?
    let hp: String?
    let types: [String]?
    let attacks: [Attack]?
    let weaknesses, resistances: [Resistance]?
    let retreatCost: [String]?
    let convertedRetreatCost: Int?
    let datumSet: DatumSet?
    let number, artist: String?
    let rarity: String?
    let nationalPokedexNumbers: [Int]?
    let legalities: Legalities?
    let images: DatumImages
    let tcgplayer: Tcgplayer?
    let cardmarket: Cardmarket?
    let evolvesFrom: String?
    let abilities: [Ability]?
    let evolvesTo: [String]?
    let flavorText: String?
    let rules: [String]?
    let regulationMark: String?

    enum CodingKeys: String, CodingKey {
        case id, name, supertype, subtypes, level, hp, types, attacks, weaknesses, resistances, retreatCost, convertedRetreatCost
        case datumSet = "set"
        case number, artist, rarity, nationalPokedexNumbers, legalities, images, tcgplayer, cardmarket, evolvesFrom, abilities, evolvesTo, flavorText, rules, regulationMark
    }
}

// MARK: - Ability
struct Ability: Codable, Hashable, Equatable, Sendable {
    let name, text: String
    let type: TypeEnum
}

enum TypeEnum: String, Codable, Hashable, Equatable, Sendable{
    case ability = "Ability"
    case pokéBody = "Poké-Body"
    case pokéPower = "Poké-Power"
    case pokémonPower = "Pokémon Power"
}

// MARK: - Attack
struct Attack: Codable, Hashable, Equatable, Sendable{
    let name: String
    let cost: [String]
    let convertedEnergyCost: Int
    let damage, text: String
}


// MARK: - Cardmarket
struct Cardmarket: Codable, Hashable, Equatable, Sendable {
    let url: String
    let updatedAt: String
    let prices: [String: Double]?
}

// MARK: - datumSet
struct DatumSet: Codable, Hashable, Equatable, Sendable {
    let id, name: String
    let series: Series?
    let printedTotal, total: Int
    let legalities: Legalities?
    let ptcgoCode: String?
    let releaseDate, updatedAt: String
    let images: SetImages
}

// MARK: - SetImages
struct SetImages: Codable, Hashable, Equatable, Sendable {
    let symbol, logo: String
}

// MARK: - Legalities
struct Legalities: Codable, Hashable, Equatable, Sendable {
    let unlimited: Expanded?
    let expanded, standard: Expanded?
}

enum Expanded: String, Codable, Hashable, Equatable, Sendable {
    case legal = "Legal"
}

enum Series: String, Codable, Hashable, Equatable, Sendable {
    case base = "Base"
    case blackWhite = "Black & White"
    case diamondPearl = "Diamond & Pearl"
    case eCard = "E-Card"
    case ex = "EX"
    case gym = "Gym"
    case heartGoldSoulSilver = "HeartGold & SoulSilver"
    case neo = "Neo"
    case other = "Other"
    case platinum = "Platinum"
    case pop = "POP"
    case sunMoon = "Sun & Moon"
    case swordShield = "Sword & Shield"
    case xy = "XY"
    case scarletViolet = "Scarlet & Violet"
}

// MARK: - DatumImages
struct DatumImages: Codable, Hashable, Equatable, Sendable {
    let small, large: String
}

// MARK: - Resistance
struct Resistance: Codable, Hashable, Equatable, Sendable {
    let type: String
    let value: String
}


// MARK: - Tcgplayer
struct Tcgplayer: Codable, Hashable, Equatable, Sendable {
    let url: String
    let updatedAt: String
    let prices: Prices?
}

// MARK: - Prices
struct Prices: Codable, Hashable, Equatable, Sendable {
    let holofoil, reverseHolofoil, normal, the1StEditionHolofoil: The1_StEditionHolofoil?
    let unlimitedHolofoil: The1_StEditionHolofoil?

    enum CodingKeys: String, CodingKey {
        case holofoil, reverseHolofoil, normal
        case the1StEditionHolofoil = "1stEditionHolofoil"
        case unlimitedHolofoil
    }
}

// MARK: - The1_StEditionHolofoil
struct The1_StEditionHolofoil: Codable, Hashable, Equatable, Sendable {
    let low, mid, high: Double
    let market, directLow: Double?
}
