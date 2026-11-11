//
//  TCGApiType.swift
//  PokedexPTC
//

import Foundation

protocol TCGApiType: Sendable {
    func searchCards(name: String) async throws -> [TCGCardBrief]
    func getCard(id: String) async throws -> TCGCard
    func getSets() async throws -> [TCGSetBrief]
    func getSet(id: String) async throws -> TCGSet
}

/// TCGdex implementation.
struct TCGApiCore: TCGApiType {
    private let apiInteractor: APIInteractor

    init(apiInteractor: APIInteractor) {
        self.apiInteractor = apiInteractor
    }

    func searchCards(name: String) async throws -> [TCGCardBrief] {
        try await apiInteractor.request(.searchCards(name: name), as: [TCGCardBrief].self)
    }

    func getCard(id: String) async throws -> TCGCard {
        try await apiInteractor.request(.getCard(id: id), as: TCGCard.self)
    }

    func getSets() async throws -> [TCGSetBrief] {
        try await apiInteractor.request(.getSets, as: [TCGSetBrief].self)
    }

    func getSet(id: String) async throws -> TCGSet {
        try await apiInteractor.request(.getSet(id: id), as: TCGSet.self)
    }
}
