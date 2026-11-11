//
//  ScreenFabric.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 24/03/25.
//

import SwiftUI

/// Builds the screen for each navigation destination. View models are owned by the App
/// and use `@Observable`, so views only re-render for the properties they read.
struct ScreenFabric {
    let pokedexViewModel: PokedexViewModel
    let pokemonTGCViewModel: PokemonTGCViewModel

    @MainActor @ViewBuilder
    func createView(item: ScreenDestination) -> some View {
        switch item {
        case .pokedexMainView:
            ContentView(viewModel: pokedexViewModel)
        case .pokemonDetailView(let pokemon):
            PokemonDetailView(viewModel: pokedexViewModel,
                              viewModelTCG: pokemonTGCViewModel,
                              pokemon: pokemon)
        case .cardDetail(let card):
            CardDetail(card: card, viewModel: pokemonTGCViewModel)
        }
    }
}
