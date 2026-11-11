//
//  PokemonTGCViewModel.swift
//  PokedexPTC
//

import Foundation

/// Data source for TCG cards. Views own their loading state; this object fetches and caches.
@MainActor
final class PokemonTGCViewModel {
    private let apiInteractor: TCGApiType?

    private var cardsCache: [TCGCardQuery: [TCGCardBrief]] = [:]
    private var cardDetailCache: [String: TCGCard] = [:]
    /// Set id → (chronological index, name). TCGdex returns `/sets` in release order.
    private var setIndex: [String: (order: Int, name: String)]?

    init(apiInteractor: TCGApiType? = nil) {
        self.apiInteractor = apiInteractor
    }

    /// All cards for a Pokémon, newest set first.
    func cards(for pokemon: PokemonDetail) async throws -> [TCGCardBrief] {
        let query = Self.query(for: pokemon)
        if let cached = cardsCache[query] {
            return cached
        }
        guard let apiInteractor else { return [] }

        async let cardsRequest = apiInteractor.getCards(query: query)
        let sets = try await loadSetIndex(using: apiInteractor)
        let cards = try await cardsRequest

        let sorted = cards
            .map { card -> TCGCardBrief in
                var card = card
                card.setName = sets[card.setId]?.name
                return card
            }
            .sorted { lhs, rhs in
                let lhsOrder = sets[lhs.setId]?.order ?? -1
                let rhsOrder = sets[rhs.setId]?.order ?? -1
                if lhsOrder != rhsOrder { return lhsOrder > rhsOrder }
                return lhs.localId.localizedStandardCompare(rhs.localId) == .orderedAscending
            }

        cardsCache[query] = sorted
        return sorted
    }

    func card(id: String) async throws -> TCGCard {
        if let cached = cardDetailCache[id] {
            return cached
        }
        guard let apiInteractor else { throw APIError.invalidRequest }
        let card = try await apiInteractor.getCard(id: id)
        cardDetailCache[id] = card
        return card
    }

    private func loadSetIndex(using api: TCGApiType) async throws -> [String: (order: Int, name: String)] {
        if let setIndex {
            return setIndex
        }
        let sets = try await api.getSets()
        let index = Dictionary(
            sets.enumerated().map { ($0.element.id, (order: $0.offset, name: $0.element.name)) },
            uniquingKeysWith: { first, _ in first }
        )
        setIndex = index
        return index
    }

    private static func query(for pokemon: PokemonDetail) -> TCGCardQuery {
        if let dexId = pokemon.nationalDexNumber {
            return .dexId(dexId)
        }
        // Alternate form without species info: search by the base name ("charizard-mega-x" → "charizard").
        let baseName = pokemon.name.split(separator: "-").first.map(String.init) ?? pokemon.name
        return .name(baseName)
    }
}
