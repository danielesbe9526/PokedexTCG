//
//  Pokemon.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import Foundation

// MARK: - Pokemon
public struct Pokemon: Codable, Sendable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonInfo]
}

// MARK: - Result
public struct PokemonInfo: Codable, Sendable {
    let name: String
    let url: String

    /// PokeAPI urls end with the id: https://pokeapi.co/api/v2/pokemon/25/
    var id: Int? {
        url.split(separator: "/").last.flatMap { Int($0) }
    }
}


// MARK: - PokemonInfo
public struct PokemonDetail: Codable, Identifiable, Hashable, Equatable, Sendable {
    let height: Int
    public let id: Int
    let isDefault: Bool
    let name: String
    let order: Int
    let sprites: Sprites?
    let stats: [Stat]
    let types: [TypeElement]
    let weight: Int
    var species: Species? = nil

    enum CodingKeys: String, CodingKey {
        case height
        case id
        case isDefault = "is_default"
        case name, order
        case sprites, stats, types, weight, species
    }
}

extension PokemonDetail {
    /// "mr-mime" → "Mr Mime"
    var displayName: String {
        name.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
    }

    /// PokeAPI gives weight in hectograms.
    var weightInKilograms: Double { Double(weight) / 10 }

    /// PokeAPI gives height in decimeters.
    var heightInMeters: Double { Double(height) / 10 }

    /// Alternate forms (megas, regional forms, gmax...) use ids above 10000.
    var isAlternateForm: Bool { id > 10_000 }

    /// National Pokédex number, taken from the species for alternate forms.
    var nationalDexNumber: Int? {
        if let speciesId = species?.url.split(separator: "/").last.flatMap({ Int($0) }) {
            return speciesId
        }
        return isAlternateForm ? nil : id
    }

    var primaryTypeName: String {
        types.sorted { $0.slot < $1.slot }.first?.type.name ?? "normal"
    }

    var artworkURL: URL? {
        let candidates = [sprites?.other?.officialArtwork?.frontDefault, sprites?.frontDefault]
        return candidates.compactMap { $0 }.first { !$0.isEmpty }.flatMap(URL.init(string:))
    }
}

// MARK: - Species
struct Species: Codable, Hashable, Equatable, Sendable {
    let name: String
    let url: String
}

// MARK: - Sprites
public struct Sprites: Codable, Hashable, Equatable, Sendable {
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
public struct OfficialArtwork: Codable,Hashable, Equatable, Sendable {
    let frontDefault: String?
    let frontShiny: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
    }
}

// MARK: - Home
public struct Home: Codable, Hashable, Equatable, Sendable {
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
public struct DreamWorld: Codable, Hashable, Equatable, Sendable {
    let frontDefault: String?
    let frontFemale: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontFemale = "front_female"
    }
}

// MARK: - Other
public struct Other: Codable, Hashable, Equatable, Sendable {
    let dreamWorld: DreamWorld?
    let home: Home?
    let officialArtwork: OfficialArtwork?

    enum CodingKeys: String, CodingKey {
        case dreamWorld = "dream_world"
        case home
        case officialArtwork = "official-artwork"
    }
}

// MARK: - Stat
public struct Stat: Codable, Hashable, Equatable, Sendable {
    let baseStat, effort: Int
    let stat: Species

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort, stat
    }
}

// MARK: - TypeElement
public struct TypeElement: Codable, Hashable, Equatable, Sendable {
    let slot: Int
    let type: Species
}
