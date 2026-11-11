//
//  ViewModelTests.swift
//  PokedexPTCTests
//

import Testing
@testable import PokedexPTC

@MainActor
@Suite("PokedexViewModel")
struct PokedexViewModelTests {
    @Test("Loads every Pokémon using the total reported by the API, sorted by id")
    func loadsAll() async {
        let api = FakePokedexApi(total: 95)
        let viewModel = PokedexViewModel(apiInteractor: api, destination: nil, diskCache: false)

        await viewModel.refresh()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.totalCount == 95)
        #expect(viewModel.pokemonsDetails.map(\.id) == Array(1 ... 95))
        #expect(viewModel.progress == 1)
        #expect(viewModel.failedCount == 0)
    }

    @Test("Failed details are counted and the rest are still shown")
    func failuresAndRetry() async {
        let api = FakePokedexApi(total: 20, failingIds: [3, 7])
        let viewModel = PokedexViewModel(apiInteractor: api, destination: nil, diskCache: false)

        await viewModel.refresh()
        #expect(viewModel.failedCount == 2)
        #expect(viewModel.pokemonsDetails.count == 18)
        #expect(viewModel.state == .loaded)
        #expect(await api.log.count(of: "detail") == 20)
        #expect(!viewModel.pokemonsDetails.contains { $0.id == 3 || $0.id == 7 })
    }

    @Test("Refresh only downloads the missing Pokémon")
    func refreshOnlyMissing() async {
        let api = FakePokedexApi(total: 10, failingIds: [5])
        let viewModel = PokedexViewModel(apiInteractor: api, destination: nil, diskCache: false)

        await viewModel.refresh()
        await viewModel.refresh()

        // 10 on the first pass + only #5 again on the second.
        #expect(await api.log.count(of: "detail") == 11)
        #expect(Set(viewModel.pokemonsDetails.map(\.id)).count == viewModel.pokemonsDetails.count)
    }

    @Test("A list error with nothing loaded surfaces a failed state")
    func listError() async {
        let api = FakePokedexApi(total: 10, listError: .offline)
        let viewModel = PokedexViewModel(apiInteractor: api, destination: nil, diskCache: false)

        await viewModel.refresh()

        #expect(viewModel.state == .failed(APIError.offline.localizedDescription))
        #expect(viewModel.pokemonsDetails.isEmpty)
    }

    @Test("Type info is cached between screens")
    func typeInfoCache() async throws {
        let api = FakePokedexApi(total: 1)
        let viewModel = PokedexViewModel(apiInteractor: api, destination: nil, diskCache: false)
        let types = Fixture.pokemon(id: 1, types: ["grass", "poison"]).types

        _ = try await viewModel.typeEffectiveness(for: types)
        _ = try await viewModel.typeEffectiveness(for: types)

        #expect(await api.log.count(of: "type:grass") == 1)
        #expect(await api.log.count(of: "type:poison") == 1)
    }
}

@MainActor
@Suite("PokemonTGCViewModel")
struct PokemonTGCViewModelTests {
    let sets = [
        TCGSetBrief(id: "base1", name: "Base Set"),
        TCGSetBrief(id: "sv03.5", name: "151"),
        TCGSetBrief(id: "30th-c", name: "30th Celebration"),
        TCGSetBrief(id: "me06", name: "Delta Reign")
    ]

    @Test("Cards are sorted newest set first and get their set name")
    func sortedNewestFirst() async throws {
        let api = FakeTCGApi(cards: [
            TCGCardBrief(id: "base1-58", localId: "58", name: "Pikachu", image: nil),
            TCGCardBrief(id: "me06-010", localId: "010", name: "Pikachu", image: nil),
            TCGCardBrief(id: "30th-c-008", localId: "008", name: "Pikachu", image: nil),
            TCGCardBrief(id: "me06-002", localId: "002", name: "Pikachu", image: nil),
            TCGCardBrief(id: "unknown-1", localId: "1", name: "Pikachu", image: nil)
        ], sets: sets)
        let viewModel = PokemonTGCViewModel(apiInteractor: api)

        let cards = try await viewModel.cards(for: Fixture.pokemon(id: 25, name: "pikachu"))

        #expect(cards.map(\.id) == ["me06-002", "me06-010", "30th-c-008", "base1-58", "unknown-1"])
        #expect(cards.first?.setName == "Delta Reign")
        #expect(cards.last?.setName == nil)
    }

    @Test("Results and sets are cached")
    func caching() async throws {
        let api = FakeTCGApi(cards: [], sets: sets)
        let viewModel = PokemonTGCViewModel(apiInteractor: api)

        _ = try await viewModel.cards(for: Fixture.pokemon(id: 25))
        _ = try await viewModel.cards(for: Fixture.pokemon(id: 25))
        _ = try await viewModel.cards(for: Fixture.pokemon(id: 6))
        _ = try await viewModel.card(id: "me06-001")
        _ = try await viewModel.card(id: "me06-001")

        #expect(await api.log.count(of: "sets") == 1)
        #expect(await api.log.count(of: "cards:\(TCGCardQuery.dexId(25))") == 1)
        #expect(await api.log.count(of: "card:me06-001") == 1)
    }

    @Test("Alternate forms query by species number, or by base name without species")
    func alternateFormQuery() async throws {
        let api = FakeTCGApi(cards: [], sets: sets)
        let viewModel = PokemonTGCViewModel(apiInteractor: api)

        _ = try await viewModel.cards(for: Fixture.pokemon(id: 10034, name: "charizard-mega-x", speciesId: 6))
        _ = try await viewModel.cards(for: Fixture.pokemon(id: 10300, name: "hawlucha-mega"))

        #expect(await api.log.count(of: "cards:\(TCGCardQuery.dexId(6))") == 1)
        #expect(await api.log.count(of: "cards:\(TCGCardQuery.name("hawlucha"))") == 1)
    }
}
