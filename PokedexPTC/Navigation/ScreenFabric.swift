//
//  ScreenFabric.swift
//  GraphQLCountries
//
//  Created by Daniel Beltran on 24/03/25.
//

import SwiftUI

struct ScreenFabric {
    @ObservedObject var pokedexViewModel: PokedexViewModel
    @ObservedObject var pokemonTGCViewModel: PokemonTGCViewModel
    
    weak var session: APIInteractor?

    init(session: APIInteractor? = nil,
         pokedexViewModel: PokedexViewModel,
         pokemonTGCViewModel: PokemonTGCViewModel) {
        self.pokedexViewModel = pokedexViewModel
        self.pokemonTGCViewModel = pokemonTGCViewModel
        self.session = session
    }
    
    @ViewBuilder
    func createView(item: ScreenDestination) -> some View {
        switch item {
        case .pokedexMainView:
            ContentView(viewModel: pokedexViewModel)
        case .pokemonDetailView(let name, let url):
            PokemonDetailView(pokemonInfo: PokemonInfo(id: 1, name: name, url: url),
                              viewModel: pokedexViewModel,
                              viewModelTCG: pokemonTGCViewModel)
        case .TCGView:
            CardsView()
        }
    }
}

