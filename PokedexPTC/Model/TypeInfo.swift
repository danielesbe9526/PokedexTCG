//
//  TypeInfo.swift
//  PokedexPTC
//

import Foundation

public struct TypeInfo: Codable, Sendable {
    let name: String
    let damageRelations: DamageRelations

    enum CodingKeys: String, CodingKey {
        case name
        case damageRelations = "damage_relations"
    }
}

struct DamageRelations: Codable, Sendable {
    let doubleDamageFrom: [TypeName]
    let doubleDamageTo: [TypeName]
    let halfDamageFrom: [TypeName]
    let halfDamageTo: [TypeName]
    let noDamageFrom: [TypeName]
    let noDamageTo: [TypeName]

    enum CodingKeys: String, CodingKey {
        case doubleDamageFrom = "double_damage_from"
        case doubleDamageTo   = "double_damage_to"
        case halfDamageFrom   = "half_damage_from"
        case halfDamageTo     = "half_damage_to"
        case noDamageFrom     = "no_damage_from"
        case noDamageTo       = "no_damage_to"
    }
}

struct TypeName: Codable, Identifiable, Sendable {
    var id: String { name }
    let name: String
}

// MARK: - Type effectiveness

/// Damage multipliers for a (possibly dual-typed) Pokémon.
/// Multipliers are multiplied per attacking type, so a Ground/Rock Pokémon is immune to Electric
/// (Ground ×0 overrides Rock), and ×4 / ×¼ are reported separately.
struct TypeEffectiveness: Equatable, Sendable {
    struct Group: Equatable, Sendable, Identifiable {
        let multiplier: Double
        let types: [String]
        var id: Double { multiplier }
    }

    /// Multiplier for every attacking type that is not ×1.
    let defensive: [String: Double]
    /// Types this Pokémon's own types hit for ×2 (each attacking type is used separately).
    let strongAgainst: [String]

    init(defendingTypes: [TypeInfo]) {
        var multipliers: [String: Double] = [:]
        for info in defendingTypes {
            let relations = info.damageRelations
            for type in relations.doubleDamageFrom { multipliers[type.name, default: 1] *= 2 }
            for type in relations.halfDamageFrom { multipliers[type.name, default: 1] *= 0.5 }
            for type in relations.noDamageFrom { multipliers[type.name, default: 1] *= 0 }
        }
        defensive = multipliers.filter { $0.value != 1 }
        strongAgainst = Array(Set(defendingTypes.flatMap { $0.damageRelations.doubleDamageTo.map(\.name) })).sorted()
    }

    /// Groups ordered from most to least damage taken: ×4, ×2, ×½, ×¼, ×0.
    var groups: [Group] {
        Dictionary(grouping: defensive.keys, by: { defensive[$0] ?? 1 })
            .map { Group(multiplier: $0.key, types: $0.value.sorted()) }
            .sorted { $0.multiplier > $1.multiplier }
    }

    var isEmpty: Bool { defensive.isEmpty && strongAgainst.isEmpty }

    static func label(for multiplier: Double) -> String {
        switch multiplier {
        case 0: return "0×"
        case 0.25: return "¼×"
        case 0.5: return "½×"
        default: return "\(Int(multiplier))×"
        }
    }
}
