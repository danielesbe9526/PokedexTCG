//
//  CatalogTests.swift
//  PokedexPTCTests
//

import Testing
@testable import Binderly

@MainActor
@Suite("CardCatalog")
struct CardCatalogTests {
    let sets = [
        TCGSetBrief(id: "base1", name: "Base Set"),
        TCGSetBrief(id: "sv03.5", name: "151"),
        TCGSetBrief(id: "30th-c", name: "30th Classic Collection"),
        TCGSetBrief(id: "me06", name: "Delta Reign")
    ]

    @Test("Search results are sorted newest set first and get their set name")
    func searchSorted() async throws {
        let api = FakeTCGApi(cards: [
            TCGCardBrief(id: "base1-58", localId: "58", name: "Pikachu", image: nil),
            TCGCardBrief(id: "me06-010", localId: "010", name: "Pikachu", image: nil),
            TCGCardBrief(id: "30th-c-008", localId: "008", name: "Pikachu", image: nil),
            TCGCardBrief(id: "me06-002", localId: "002", name: "Pikachu", image: nil),
            TCGCardBrief(id: "unknown-1", localId: "1", name: "Pikachu", image: nil)
        ], sets: sets)
        let catalog = CardCatalog(api: api)

        let cards = try await catalog.search(name: "Pikachu")

        #expect(cards.map(\.id) == ["me06-002", "me06-010", "30th-c-008", "base1-58", "unknown-1"])
        #expect(cards.first?.setName == "Delta Reign")
        #expect(cards.last?.setName == nil)
    }

    @Test("Queries are trimmed, lowercased and cached; short ones never hit the network")
    func searchNormalizationAndCache() async throws {
        let api = FakeTCGApi(sets: sets)
        let catalog = CardCatalog(api: api)

        _ = try await catalog.search(name: "  Mew ")
        _ = try await catalog.search(name: "mew")
        let short = try await catalog.search(name: "m")

        #expect(short.isEmpty)
        #expect(await api.log.count(of: "search:mew") == 1)
        #expect(await api.log.count(of: "search:m") == 0)
        #expect(await api.log.count(of: "sets") == 1)
    }

    @Test("Sets are listed newest first")
    func setsNewestFirst() async throws {
        let catalog = CardCatalog(api: FakeTCGApi(sets: sets))
        #expect(try await catalog.setsNewestFirst().map(\.id) == ["me06", "30th-c", "sv03.5", "base1"])
    }

    @Test("Set cards are ordered by collector number, named after the set and cached")
    func setCards() async throws {
        let detail = TCGSet(id: "sv03.5", name: "151", cards: [
            TCGCardBrief(id: "sv03.5-100", localId: "100", name: "C", image: nil),
            TCGCardBrief(id: "sv03.5-2", localId: "2", name: "A", image: nil),
            TCGCardBrief(id: "sv03.5-25", localId: "25", name: "B", image: nil)
        ])
        let api = FakeTCGApi(sets: sets, setDetails: ["sv03.5": detail])
        let catalog = CardCatalog(api: api)

        let cards = try await catalog.cards(in: sets[1])
        _ = try await catalog.cards(in: sets[1])

        #expect(cards.map(\.localId) == ["2", "25", "100"])
        #expect(cards.allSatisfy { $0.setName == "151" })
        #expect(await api.log.count(of: "set:sv03.5") == 1)
    }

    @Test("Card details are cached unless a refresh is requested")
    func cardDetailCache() async throws {
        let api = FakeTCGApi()
        let catalog = CardCatalog(api: api)

        _ = try await catalog.card(id: "me06-001")
        _ = try await catalog.card(id: "me06-001")
        _ = try await catalog.card(id: "me06-001", refresh: true)

        #expect(await api.log.count(of: "card:me06-001") == 2)
    }
}
