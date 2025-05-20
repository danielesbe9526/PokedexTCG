//
//  ScreenDestination.swift
//  GraphQLCountries
//
//  Created by Daniel Beltran on 24/03/25.
//

import SwiftUI

public enum ScreenDestination: Hashable, Sendable, Equatable {
    case pokedexMainView
    case pokemonDetailView(pokemon: PokemonDetail)
//    case cardsTCGView(_ cards: [Datum])
    case cardDetail(_ card: Datum)
}
