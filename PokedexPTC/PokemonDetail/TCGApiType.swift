//
//  TCGApiType.swift
//  PokedexPTC
//

import Foundation

protocol TCGApiType: Sendable {
    func getCards(query: TCGCardQuery) async throws -> [TCGCardBrief]
    func getCard(id: String) async throws -> TCGCard
    func getSets() async throws -> [TCGSetBrief]
}

/// TCGdex implementation. Replaces api.pokemontcg.io, which is deprecated (keys stop working on 2027-03-01)
/// and whose `/cards` endpoint returns frequent 5xx errors.
struct TCGApiCore: TCGApiType {
    private let apiInteractor: APIInteractor

    init(apiInteractor: APIInteractor) {
        self.apiInteractor = apiInteractor
    }

    func getCards(query: TCGCardQuery) async throws -> [TCGCardBrief] {
        try await apiInteractor.request(.getCards(query: query), as: [TCGCardBrief].self)
    }

    func getCard(id: String) async throws -> TCGCard {
        try await apiInteractor.request(.getCard(id: id), as: TCGCard.self)
    }

    func getSets() async throws -> [TCGSetBrief] {
        try await apiInteractor.request(.getSets, as: [TCGSetBrief].self)
    }
}
