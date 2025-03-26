//
//  PokemonListViewModel.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import Foundation
import Combine

@MainActor
public class PokedexViewModel: ObservableObject {
    private let apiInteractor: PokedexApiType?
    var destination: DestinationViewModel?
    
    @Published var showSpiner = false
    @Published var requestFails = false
    
    @Published var pokemons: [PokemonInfo] = []
    @Published var pokemonsDetails: [PokemonDetail] = []
    @Published var selectedPokemon: PokemonDetail? = nil
    
    var nextUrl: String = ""
    var previous: String = ""
    var currentPage = 0
    
    public init(apiInteractor: PokedexApiType?, destination: DestinationViewModel?) {
        self.apiInteractor = apiInteractor
        self.destination = destination
    }
    
    /// Previews init
    public init(pokemonsDetails: [PokemonDetail]) {
        self.pokemonsDetails = pokemonsDetails
        self.apiInteractor = nil
        self.destination = nil
    }
    
    @MainActor
    func getPokemons() {
        Task {
            showSpiner = true
            let pokemons = try await apiInteractor?.getPokemons(limit: 50, offset: currentPage)
            if let pokemons = pokemons {
                self.pokemons.append(contentsOf: pokemons.results)
                self.currentPage += 50
                let urls = self.pokemons.map { $0.url }
                await getPokemonsDetails(urls: urls)
                showSpiner = false
                
                if self.pokemonsDetails.count < 1302 {
                    let queries = self.extractNextUrlParameters(form: pokemons.next ?? "")
                    askFortheRest(limit: pokemons.count - (queries.limit ?? 0), Offset: queries.limit ?? 0)
                }
            } else {
                requestFails = true
            }
        }
    }
    
    func askFortheRest(limit: Int, Offset: Int) {
        let pokemonQueue = DispatchQueue(label:"com.downloadPokemons.backgroundQueue",qos: .background)
        pokemonQueue.async { [weak self] in
            
            guard let self = self else { return }
            var auxPokemon: [PokemonInfo] = []
            var auxPokemonDetails: [PokemonDetail] = []
            
            Task {
                let pokemons = try await self.apiInteractor?.getPokemons(limit: limit, offset: Offset)
                if let pokemonsBack = pokemons {
                    let urls = pokemonsBack.results.map { $0.url }
                    auxPokemon.append(contentsOf: pokemonsBack.results)
                    print("Number of pokemons \(auxPokemon.count)")
                    
                    
                    await withTaskGroup(of: PokemonDetail?.self) { group in
                        for url in urls {
                            group.addTask {
                                do {
                                    guard let id = await self.extractPokemonId(from: url) else { return nil }
                                    return try await self.apiInteractor?.getPokemonDetails(id: "\(id)")
                                } catch {
                                    print("Error fetching pokemon detail: \(error)")
                                    return nil
                                }
                            }
                        }
                        
                        for await task in group {
                            if let pokemon = task {
                                auxPokemonDetails.append(pokemon)
                            } else {
                                await MainActor.run {
                                    self.requestFails = true
                                }
                            }
                        }
                    }
                    print("Number of pokemons detail \(auxPokemonDetails.count)")
                    
                    let sortedPokemons = auxPokemonDetails.sorted { $0.id < $1.id }
                    
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.pokemonsDetails.append(contentsOf: sortedPokemons)
                    }
                } else {
                    await MainActor.run {
                        self.requestFails = true
                    }
                }
            }
        }
    }
    
    @MainActor
    func getPokemonDetail(url: String) {
        Task {
            guard let id = extractPokemonId(from: url) else { return }
            let pokemon = try await apiInteractor?.getPokemonDetails(id: "\(id)")
            if let pokemon = pokemon {
                pokemonsDetails.append(pokemon)
            } else {
                requestFails = true
            }
        }
    }
    
    @MainActor
    func getPokemonsDetails(urls: [String]) async {
        await withTaskGroup(of: PokemonDetail?.self) { group in
            for url in urls {
                group.addTask {
                    do {
                        guard let id = await self.extractPokemonId(from: url) else { return nil }
                        return try await self.apiInteractor?.getPokemonDetails(id: "\(id)")

                    } catch {
                        print("Error fetching pokemon detail: \(error)")
                        return nil
                    }
                }
            }
            
            for await pokemon in group {
                if let pokemon = pokemon {
                    pokemonsDetails.append(pokemon)
                    pokemonsDetails = pokemonsDetails.sorted {
                        $0.id < $1.id
                    }
                } else {
                    requestFails = true
                }
            }
        }
    }
}

private extension PokedexViewModel {
    
    func extractPokemonId(from url: String) -> Int? {
        let urlComponents = url.split(separator: "/")
        if let idString = urlComponents.last, let id = Int(idString) {
            return id
        }
        
        return nil
    }
    
    func extractNextUrlParameters(form url: String) -> (limit: Int?, offset: Int?) {
        guard let url = URL(string: url) else {
            return (nil, nil)
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        
        let offset = queryItems?.first(where: { $0.name == "offset" })?.value.flatMap { Int($0) }
        let limit = queryItems?.first(where: { $0.name == "limit" })?.value.flatMap { Int($0) }
        
        return (offset, limit)
    }
}

extension PokedexViewModel {
    @MainActor
    func routeToDetail() {
        destination?.navigate(to: .pokemonDetailView)
    }
}
