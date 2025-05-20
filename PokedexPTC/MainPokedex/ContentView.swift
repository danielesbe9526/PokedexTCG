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
    @State private var config: DrawerConfig = .init()
        
    let columns = [GridItem(.adaptive(minimum: 120, maximum: 170))]
    
    var body: some View {
        ViewWrapper(spinerRun: $viewModel.showSpiner, title: "Pokedex") {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(searchResults) { pokemon in
                            pokemonCard(pokemon: pokemon)
                                .padding(8)
                                .frame(height: 120)
                                .background(.white)
                                .cornerRadius(8)
                                .shadow(radius: 5)
                                .onTapGesture {
                                    viewModel.selectedPokemon = pokemon
                                    viewModel.routeToDetail()
                                }
                                .padding(.horizontal, 6)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal, 4)
                
                Spacer()
               
                ProgressView(value: viewModel.progress)
                    .padding(16)
                    .progressViewStyle(.linear)
                    .tint(.red)
                
                
//                /// Botton con alerta
//                DraweButton(title: "Continue", config: $config)
//                    .padding(15)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search pokemons by name")
            .overlay {
                if searchResults.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .alertDrawer(config: $config,
                         primaryTitle: "Continue",
                         secondaryTitle: "Cancel") {
                return true
            }
                        onSecondaryAction: {
                return false
            }
            content: {
                VStack(alignment: .leading, spacing: 15) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("No pokemons found")
                        .font(.title2.bold())
                    
                    Text("some large text explaining what just occur")
                        .foregroundStyle(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 300)
                }
            }
        }
        .onAppear {
            if viewModel.pokemonsDetails.isEmpty {
                viewModel.getPokemons()
            }
        }
    }
    
    @ViewBuilder
    func iconTypeForTag(types: [TypeElement]) -> some View {
        ForEach(types, id: \.type.name) { type in
            if let image = Utils.getTagForType(type: type.type.name) {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    func pokemonCard(pokemon: PokemonDetail) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(pokemon.name.capitalized)
                    .font(.headline)
                    .padding(.bottom, 2)
                
                Text("#\(String(format: "%03d", pokemon.id))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                iconTypeForTag(types: pokemon.types)
                    .frame(maxHeight: 15)
                
            }
          
            Spacer()
            
            ZStack {
                Image("pokeball")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.gray.opacity(0.2))
                    .offset(x: 20, y: 30)
                    
                AsyncImage(url: URL(string: pokemon.sprites?.frontDefault ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Image("pokeball")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.blue)
                            .frame(width: 30, height: 30)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                    case .failure:
                        Image("pokeball")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.red)
                            .frame(width: 30, height: 30)
                    @unknown default:
                        Image("pokeball")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.gray)
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .frame(width: 40, height: 40)
        }
    }
    
    var progreesBar: some View {
        ZStack {
            
        }
    }
    
    var searchResults: [PokemonDetail] {
           if searchText.isEmpty {
               return viewModel.pokemonsDetails
           } else {
               return viewModel.pokemonsDetails.filter {
                   $0.name.contains(searchText.lowercased())
               }
           }
       }
}

struct ContentView_Previews: PreviewProvider {
    static let pokemon1 = PokemonDetail(height: 123,
                                id: 1,
                                isDefault: true,
                                name: "magnemite",
                                order: 1,
                                sprites: Sprites(backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 other: nil),
                                stats: [Stat(baseStat: 1, effort: 1, stat: Species(name: "species", url: ""))],
                                types: [TypeElement(slot: 1, type: Species(name: "species", url: ""))],
                                weight: 123)
    static let pokemon2 = PokemonDetail(height: 123,
                                id: 2,
                                isDefault: true,
                                name: "magnemite2",
                                order: 1,
                                sprites: Sprites(backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 other: nil),
                                stats: [Stat(baseStat: 1, effort: 1, stat: Species(name: "species", url: ""))],
                                types: [TypeElement(slot: 1, type: Species(name: "species", url: ""))],
                                weight: 123)
    static let pokemon3 = PokemonDetail(height: 123,
                                id: 3,
                                isDefault: true,
                                name: "magnemite3",
                                order: 1,
                                sprites: Sprites(backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 other: nil),
                                stats: [Stat(baseStat: 1, effort: 1, stat: Species(name: "species", url: ""))],
                                types: [TypeElement(slot: 1, type: Species(name: "species", url: ""))],
                                weight: 123)

    static var previews: some View {
        ContentView(viewModel: PokedexViewModel(pokemonsDetails:[pokemon1, pokemon2, pokemon3]))
    }
}
