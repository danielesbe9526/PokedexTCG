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
        case .pokemonDetailView(let pokemon):
            PokemonDetailView(viewModel: pokedexViewModel,
                              viewModelTCG: pokemonTGCViewModel,
                              pokemon: pokemon)
//        case .cardsTCGView(let cards):
//            CardsView(cards: cards, viewModel: pokedexViewModel)
        case .cardDetail(let card):
            CardDetail(card: card)
        }
    }
}

