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
    
    @Published var pokemons: [PokemonInfo] = [PokemonInfo(name: "omastar", url: "https://pokeapi.co/api/v2/pokemon/139/"),
                                              PokemonInfo(name: "magnemite", url: "https://pokeapi.co/api/v2/pokemon/81/")]
    
    @Published var pokemonsDetails: [PokemonDetail] = []
    @Published var selectedPokemon: PokemonDetail? = nil
    
    var nextUrl: String = ""
    var previous: String = ""
    
    var currentPage = 0
    
    public init(apiInteractor: PokedexApiType?, destination: DestinationViewModel?) {
        self.apiInteractor = apiInteractor
        self.destination = destination
    }
    
    @MainActor
    func getPokemons() {
        Task {
            let pokemons = try await apiInteractor?.getPokemons(offset: currentPage)
            if let pokemons = pokemons {
                self.pokemons.append(contentsOf: pokemons.results)
                self.currentPage += 20
                self.pokemons.forEach {
                    getPokemonDetail(url: $0.url)
                }
            } else {
                requestFails = true
            }
        }
    }
    
    @MainActor
    func getPokemonDetail(url: String) {
        Task {
            let pokemon = try await apiInteractor?.getPokemonDetails(id: url)
            if let pokemon = pokemon {
                pokemonsDetails.append(pokemon)
            } else {
                requestFails = true
            }
        }
    }
}

extension PokedexViewModel {
    @MainActor
    func routeToDetail(pokemonInfo: PokemonInfo) {
        destination?.navigate(to: .pokemonDetailView(name: pokemonInfo.name, url: pokemonInfo.url))
    }
}
