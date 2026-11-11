//
//  PokedexViewModel.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import Foundation
import Observation

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

@MainActor
@Observable
public final class PokedexViewModel {
    @ObservationIgnored private let apiInteractor: PokedexApiType?
    @ObservationIgnored private let diskCache: PokedexDiskCache?
    @ObservationIgnored var destination: DestinationViewModel?

    private(set) var pokemonsDetails: [PokemonDetail] = []
    private(set) var state: LoadState = .idle
    private(set) var totalCount = 0
    private(set) var failedCount = 0

    /// Max number of detail requests in flight. Avoids firing 1300+ requests at once.
    private let maxConcurrentRequests = 8
    /// Results are published in batches so the grid is not re-rendered once per Pokémon.
    private let publishBatchSize = 40
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var typeInfoCache: [String: TypeInfo] = [:]

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return min(Double(pokemonsDetails.count) / Double(totalCount), 1)
    }

    var isLoading: Bool { state == .loading }

    public init(apiInteractor: PokedexApiType?, destination: DestinationViewModel?, diskCache: Bool = true) {
        self.apiInteractor = apiInteractor
        self.destination = destination
        self.diskCache = diskCache ? PokedexDiskCache() : nil
    }

    /// Previews init
    public init(pokemonsDetails: [PokemonDetail]) {
        self.pokemonsDetails = pokemonsDetails
        self.totalCount = pokemonsDetails.count
        self.state = .loaded
        self.apiInteractor = nil
        self.destination = nil
        self.diskCache = nil
    }

    /// Loads the Pokédex the first time it is called. Uses the disk cache when it is less than a day old.
    func loadIfNeeded() {
        guard state == .idle else { return }
        startLoading(useCache: true)
    }

    /// Fetches the list again and downloads any Pokémon that is missing (new entries or earlier failures).
    func refresh() async {
        if loadTask == nil {
            startLoading(useCache: false)
        }
        await loadTask?.value
    }

    func retry() {
        guard loadTask == nil else { return }
        startLoading(useCache: false)
    }

    private func startLoading(useCache: Bool) {
        loadTask = Task { [weak self] in
            await self?.load(useCache: useCache)
            self?.loadTask = nil
        }
    }

    private func load(useCache: Bool) async {
        guard let apiInteractor else { return }
        state = .loading
        failedCount = 0

        if useCache, pokemonsDetails.isEmpty, let diskCache {
            let cached = await Task.detached(priority: .userInitiated) { diskCache.load() }.value
            if let cached, !cached.isEmpty {
                pokemonsDetails = cached
                totalCount = cached.count
                state = .loaded
                return
            }
        }

        do {
            // First request only reads the total so the full list can be fetched in one call
            // (no hardcoded totals, no parsing of the `next` url).
            let count = try await apiInteractor.getPokemons(limit: 1, offset: 0).count
            let list = try await apiInteractor.getPokemons(limit: count, offset: 0)
            let ids = list.results.compactMap(\.id)
            totalCount = ids.count

            let known = Set(pokemonsDetails.map(\.id))
            let missing = ids.filter { !known.contains($0) }
            let failures = await fetchDetails(ids: missing, using: apiInteractor)

            failedCount = failures
            state = pokemonsDetails.isEmpty ? .failed(String(localized: "Couldn't download any Pokémon. Please try again.")) : .loaded

            if failures == 0, let diskCache {
                let snapshot = pokemonsDetails
                Task.detached(priority: .utility) { diskCache.save(snapshot) }
            }
        } catch is CancellationError {
            state = pokemonsDetails.isEmpty ? .idle : .loaded
        } catch {
            state = pokemonsDetails.isEmpty ? .failed(error.localizedDescription) : .loaded
        }
    }

    /// Downloads details with bounded concurrency and publishes them in batches. Returns the number of failures.
    private func fetchDetails(ids: [Int], using api: PokedexApiType) async -> Int {
        var failures = 0
        var buffer: [PokemonDetail] = []
        var iterator = ids.makeIterator()

        await withTaskGroup(of: PokemonDetail?.self) { group in
            func enqueueNext() {
                guard let id = iterator.next() else { return }
                group.addTask { try? await api.getPokemonDetails(id: "\(id)") }
            }

            for _ in 0 ..< maxConcurrentRequests { enqueueNext() }

            while let result = await group.next() {
                if let pokemon = result {
                    buffer.append(pokemon)
                } else {
                    failures += 1
                }
                enqueueNext()

                if buffer.count >= publishBatchSize {
                    publish(&buffer)
                }
            }
        }

        publish(&buffer)
        return failures
    }

    private func publish(_ buffer: inout [PokemonDetail]) {
        guard !buffer.isEmpty else { return }
        pokemonsDetails = (pokemonsDetails + buffer).sorted { $0.id < $1.id }
        buffer.removeAll(keepingCapacity: true)
    }
}

// MARK: - Type effectiveness

extension PokedexViewModel {
    func typeEffectiveness(for types: [TypeElement]) async throws -> TypeEffectiveness {
        let infos = try await withThrowingTaskGroup(of: TypeInfo.self) { group in
            for element in types {
                let name = element.type.name
                if let cached = typeInfoCache[name] {
                    group.addTask { cached }
                } else if let apiInteractor {
                    group.addTask { try await apiInteractor.getTypeInfo(name: name) }
                }
            }
            var result: [TypeInfo] = []
            for try await info in group {
                result.append(info)
            }
            return result
        }
        for info in infos {
            typeInfoCache[info.name] = info
        }
        return TypeEffectiveness(defendingTypes: infos)
    }
}

// MARK: - Navigation

extension PokedexViewModel {
    func routeToDetail(_ pokemon: PokemonDetail) {
        destination?.navigate(to: .pokemonDetailView(pokemon: pokemon))
    }

    func routeToCardDetail(card: TCGCardBrief) {
        destination?.navigate(to: .cardDetail(card))
    }
}

// MARK: - Disk cache

/// Stores the decoded Pokédex in Caches so the app does not download 1300+ details on every launch.
struct PokedexDiskCache: Sendable {
    private struct Payload: Codable {
        let savedAt: Date
        let pokemons: [PokemonDetail]
    }

    /// PokeAPI responses are cached by their CDN for one day (`max-age=86400`).
    var maxAge: TimeInterval = 86_400

    private var fileURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appending(path: "pokedex-cache-v1.json")
    }

    func load() -> [PokemonDetail]? {
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(Payload.self, from: data),
              Date().timeIntervalSince(payload.savedAt) < maxAge else {
            return nil
        }
        return payload.pokemons
    }

    func save(_ pokemons: [PokemonDetail]) {
        let payload = Payload(savedAt: Date(), pokemons: pokemons)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
