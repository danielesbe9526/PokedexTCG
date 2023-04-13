//
//  ContentView.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PokemonViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(searchResults, id: \.name) { pokemon in
                    NavigationLink {
                        PokemonDetailView(pokemonInfo: pokemon)
                    } label: {
                        Text(pokemon.name)
                    }
                }
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear {
                        viewModel.getPokemons2()
                    }
            }
            .navigationTitle("Pokemon")
            .toolbar {
                Button("pokemon TCG") {
//                    viewModelTCG.getTCG(for: )
                }
            }
        }.searchable(text: $searchText)
           
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
        ContentView()
    }
}
