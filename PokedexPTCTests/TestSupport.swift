//
//  TestSupport.swift
//  PokedexPTCTests
//

import Foundation
@testable import PokedexPTC

enum Fixture {
    static func pokemon(id: Int, name: String? = nil, types: [String] = ["normal"], speciesId: Int? = nil) -> PokemonDetail {
        PokemonDetail(
            height: 10, id: id, isDefault: true, name: name ?? "pokemon-\(id)", order: id,
            sprites: nil,
            stats: [Stat(baseStat: 50, effort: 0, stat: Species(name: "hp", url: ""))],
            types: types.enumerated().map { TypeElement(slot: $0.offset + 1, type: Species(name: $0.element, url: "")) },
            weight: 100,
            species: speciesId.map { Species(name: "species", url: "https://pokeapi.co/api/v2/pokemon-species/\($0)/") }
        )
    }

    static func typeInfo(_ name: String,
                         doubleFrom: [String] = [], halfFrom: [String] = [], noneFrom: [String] = [],
                         doubleTo: [String] = []) -> TypeInfo {
        TypeInfo(name: name, damageRelations: DamageRelations(
            doubleDamageFrom: doubleFrom.map(TypeName.init(name:)),
            doubleDamageTo: doubleTo.map(TypeName.init(name:)),
            halfDamageFrom: halfFrom.map(TypeName.init(name:)),
            halfDamageTo: [],
            noDamageFrom: noneFrom.map(TypeName.init(name:)),
            noDamageTo: []
        ))
    }

    static func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
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

struct FakePokedexApi: PokedexApiType {
    var total: Int
    var failingIds: Set<Int> = []
    var listError: APIError?
    let log = CallLog()

    func getPokemons(limit: Int, offset: Int) async throws -> Pokemon {
        await log.record("list")
        if let listError { throw listError }
        let ids = (1 ... max(total, 1)).prefix(limit).map { $0 + offset }
        return Pokemon(count: total, next: nil, previous: nil,
                       results: total == 0 ? [] : ids.map { PokemonInfo(name: "p\($0)", url: "https://pokeapi.co/api/v2/pokemon/\($0)/") })
    }

    func getPokemonDetails(id: String) async throws -> PokemonDetail {
        await log.record("detail")
        let numericId = Int(id) ?? 0
        if failingIds.contains(numericId) { throw APIError.server(status: 500) }
        return Fixture.pokemon(id: numericId)
    }

    func getTypeInfo(name: String) async throws -> TypeInfo {
        await log.record("type:\(name)")
        return Fixture.typeInfo(name)
    }
}

struct FakeTCGApi: TCGApiType {
    var cards: [TCGCardBrief]
    var sets: [TCGSetBrief]
    let log = CallLog()

    func getCards(query: TCGCardQuery) async throws -> [TCGCardBrief] {
        await log.record("cards:\(query)")
        return cards
    }

    func getCard(id: String) async throws -> TCGCard {
        await log.record("card:\(id)")
        return try Fixture.decode(TCGCard.self, """
        { "id": "\(id)", "localId": "1", "name": "Test", "set": { "id": "s", "name": "Set" } }
        """)
    }

    func getSets() async throws -> [TCGSetBrief] {
        await log.record("sets")
        return sets
    }
}
