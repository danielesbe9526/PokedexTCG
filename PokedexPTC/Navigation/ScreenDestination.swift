//
//  ScreenDestination.swift
//  GraphQLCountries
//
//  Created by Daniel Beltran on 24/03/25.
//

import SwiftUI

public enum ScreenDestination: Hashable, Sendable, Equatable {
    case pokedexMainView
    case TCGView
    case pokemonDetailView(name: String, url: String)
}
