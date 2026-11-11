//
//  PokedexApiType.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 25/03/25.
//

import Foundation

public protocol PokedexApiType: Sendable {
    func getPokemons(limit: Int, offset: Int) async throws -> Pokemon
    func getPokemonDetails(id: String) async throws -> PokemonDetail
    func getTypeInfo(name: String) async throws -> TypeInfo
}

public struct PokedexApiCore: PokedexApiType {
    private let apiInteractor: APIInteractor

    public init(apiInteractor: APIInteractor) {
        self.apiInteractor = apiInteractor
    }

    public func getPokemons(limit: Int, offset: Int) async throws -> Pokemon {
        try await apiInteractor.request(.getPokemons(limit: limit, offset: offset), as: Pokemon.self)
    }

    public func getPokemonDetails(id: String) async throws -> PokemonDetail {
        try await apiInteractor.request(.getPokemonDetail(id: id), as: PokemonDetail.self)
    }

    public func getTypeInfo(name: String) async throws -> TypeInfo {
        try await apiInteractor.request(.getTypeInfo(name: name), as: TypeInfo.self)
    }
}
