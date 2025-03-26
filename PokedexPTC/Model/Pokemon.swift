//
//  Pokemon.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import Foundation

//   let pokemon = try? JSONDecoder().decode(Pokemon.self, from: jsonData)

import Foundation

// MARK: - Pokemon
public struct Pokemon: Codable {
    let count: Int
    let next, previous: String?
    let results: [PokemonInfo]
}

// MARK: - Result
public struct PokemonInfo: Codable , Identifiable {
    public var id: Int?
    let name: String
    let url: String
}


// MARK: - PokemonInfo
public struct PokemonDetail: Codable, Identifiable {
    let height: Int
    public let id: Int
    let isDefault: Bool
    let name: String
    let order: Int
    let sprites: Sprites?
    let stats: [Stat]
    let types: [TypeElement]
    let weight: Int

    enum CodingKeys: String, CodingKey {
        case height
        case id
        case isDefault = "is_default"
        case name, order
        case sprites, stats, types, weight
    }
}

// MARK: - Species
struct Species: Codable {
    let name: String
    let url: String
}

// MARK: - Sprites
public struct Sprites: Codable {
    let backDefault: String?
    let backFemale: String?
    let backShiny: String?
    let backShinyFemale: String?
    let frontDefault: String?
    let frontFemale: String?
    let frontShiny: String?
    let frontShinyFemale: String?
    let other: Other?
//    let animated: Sprites?

    enum CodingKeys: String, CodingKey {
        case backDefault = "back_default"
        case backFemale = "back_female"
        case backShiny = "back_shiny"
        case backShinyFemale = "back_shiny_female"
        case frontDefault = "front_default"
        case frontFemale = "front_female"
        case frontShiny = "front_shiny"
        case frontShinyFemale = "front_shiny_female"
        case other
//        case animated
    }
}

// MARK: - OfficialArtwork
public struct OfficialArtwork: Codable {
    let frontDefault, frontShiny: String

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
    }
}

// MARK: - Home
public struct Home: Codable {
    let frontDefault: String?
    let frontFemale: String?
    let frontShiny: String?
    let frontShinyFemale: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontFemale = "front_female"
        case frontShiny = "front_shiny"
        case frontShinyFemale = "front_shiny_female"
    }
}

// MARK: - DreamWorld
public struct DreamWorld: Codable {
    let frontDefault: String?
    let frontFemale: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontFemale = "front_female"
    }
}

// MARK: - Other
public struct Other: Codable {
    let dreamWorld: DreamWorld
    let home: Home
    let officialArtwork: OfficialArtwork

    enum CodingKeys: String, CodingKey {
        case dreamWorld = "dream_world"
        case home
        case officialArtwork = "official-artwork"
    }
}

// MARK: - Stat
public struct Stat: Codable {
    let baseStat, effort: Int
    let stat: Species

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort, stat
    }
}

// MARK: - TypeElement
public struct TypeElement: Codable {
    let slot: Int
    let type: Species
}
