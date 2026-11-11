//
//  CardCatalog.swift
//  PokedexPTC
//

import Foundation

/// Card data source: search, sets and card details. Views own their loading state;
/// this object fetches and caches for the app's lifetime.
@MainActor
final class CardCatalog {
    static let minimumQueryLength = 2

    private let api: TCGApiType?

    private var searchCache: [String: [TCGCardBrief]] = [:]
    private var setCardsCache: [String: [TCGCardBrief]] = [:]
    private var detailCache: [String: TCGCard] = [:]
    /// TCGdex returns `/sets` in release order (oldest first).
    private var chronologicalSets: [TCGSetBrief]?

    init(api: TCGApiType? = nil) {
        self.api = api
    }

    /// Normalized search key, or nil when the query is too short to search.
    static func normalizedQuery(_ text: String) -> String? {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return query.count >= minimumQueryLength ? query : nil
    }

    /// Every set, newest first.
    func setsNewestFirst() async throws -> [TCGSetBrief] {
        try await loadSets().reversed()
    }

    /// Cards whose name contains `text`, newest set first.
    func search(name text: String) async throws -> [TCGCardBrief] {
        guard let query = Self.normalizedQuery(text) else { return [] }
        if let cached = searchCache[query] {
            return cached
        }
        guard let api else { return [] }

        async let cardsRequest = api.searchCards(name: query)
        let sets = try await loadSets()
        let cards = try await cardsRequest

        let index = Dictionary(
            sets.enumerated().map { ($0.element.id, (order: $0.offset, name: $0.element.name)) },
            uniquingKeysWith: { first, _ in first }
        )
        let sorted = cards
            .map { card -> TCGCardBrief in
                var card = card
                card.setName = index[card.setId]?.name
                return card
            }
            .sorted { lhs, rhs in
                let lhsOrder = index[lhs.setId]?.order ?? -1
                let rhsOrder = index[rhs.setId]?.order ?? -1
                if lhsOrder != rhsOrder { return lhsOrder > rhsOrder }
                return lhs.localId.localizedStandardCompare(rhs.localId) == .orderedAscending
            }

        searchCache[query] = sorted
        return sorted
    }

    /// Cards in a set, in collector-number order.
    func cards(in set: TCGSetBrief) async throws -> [TCGCardBrief] {
        if let cached = setCardsCache[set.id] {
            return cached
        }
        guard let api else { return [] }

        let detail = try await api.getSet(id: set.id)
        let cards = detail.cards
            .map { card -> TCGCardBrief in
                var card = card
                card.setName = detail.name
                return card
            }
            .sorted { $0.localId.localizedStandardCompare($1.localId) == .orderedAscending }

        setCardsCache[set.id] = cards
        return cards
    }

    /// Card detail. `refresh` skips the in-memory cache (used to update collection prices).
    func card(id: String, refresh: Bool = false) async throws -> TCGCard {
        if !refresh, let cached = detailCache[id] {
            return cached
        }
        guard let api else { throw APIError.invalidRequest }
        let card = try await api.getCard(id: id)
        detailCache[id] = card
        return card
    }

    private func loadSets() async throws -> [TCGSetBrief] {
        if let chronologicalSets {
            return chronologicalSets
        }
        guard let api else { return [] }
        let sets = try await api.getSets()
        chronologicalSets = sets
        return sets
    }
}
