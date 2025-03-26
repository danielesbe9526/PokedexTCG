//
//  ContentView.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: PokedexViewModel
    
    @State private var searchText = ""
    @State private var alertModel: AlertModel?

    var body: some View {
        ViewWrapper(spinerRun: $viewModel.showSpiner) {
            VStack(alignment: .leading) {
                Text("Pokedex")
                    .font(.system(size: 32, weight: .bold, design: .rounded))

                if !searchResults.isEmpty {
                    List {
                        ForEach(searchResults, id: \.name) { pokemon in
                            
                            Button {
                                viewModel.routeToDetail(pokemonInfo: pokemon)
                            } label: {
                                Text(pokemon.name)
                            }
                        }
                    }
                }
            }
            .padding()
            
        }
        .searchable(text: $searchText)
        .onAppear {
            viewModel.getPokemons()
        }
    }
    
    var searchResults: [PokemonInfo] {
           if searchText.isEmpty {
               return viewModel.pokemons
           } else {
               return viewModel.pokemons.filter {
                   $0.name.contains(searchText.lowercased())
               }
           }
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: PokedexViewModel(apiInteractor: nil, destination: nil))
    }
}
