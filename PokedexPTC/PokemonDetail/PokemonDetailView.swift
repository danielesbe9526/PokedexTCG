//
//  PokemonDetailView.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokedexViewModel
    @ObservedObject var viewModelTCG: PokemonTGCViewModel

    @State var showTGC = false
    @State var section: PokemonDetailSection = .pokemon
    
    let pokemon: PokemonDetail
    
    var body: some View {
        VStack {
            Form {
                Picker("", selection: $section) {
                    Text("Pokemon Info")
                        .tag(PokemonDetailSection.pokemon)
                    
                    Text("Cards")
                        .tag(PokemonDetailSection.tcg)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                
                if section == .pokemon {
                    Section("Profile") {
                        if let urlImage = pokemon.sprites?.other?.officialArtwork.frontDefault {
                            AsyncImage(url: URL(string: urlImage)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                
                            } placeholder: {
                                ZStack {
                                    Image(systemName: "photo")
                                    ProgressView()
                                }
                            }
                            .frame(width: 300, height: 300)
                        }
                        
                        
                        HStack {
                            Text("id:")
                                .padding(.horizontal)
                            Spacer()
                            Text("\(pokemon.id)")
                                .padding(.horizontal)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("types:")
                                .padding(.horizontal)
                            Spacer()
                            iconTypeForTag(types: pokemon.types)
                                .frame(height: 40)
                        }
                        
                        HStack {
                            Text("weight:")
                                .padding(.horizontal)
                            Spacer()
                            Text("\(pokemon.weight)")
                                .padding(.horizontal)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("heigth:")
                                .padding(.horizontal)
                            Spacer()
                            Text("\(pokemon.height)")
                                .padding(.horizontal)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section("Stats") {
                        ForEach(pokemon.stats, id: \.stat.name) { stat in
                            HStack {
                                Text("\(stat.stat.name):")
                                    .padding(.horizontal)
                                Spacer()
                                Text("\(stat.baseStat)")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    if let sprites = pokemon.sprites {
                        imagesSection(sprites: sprites)
                    }
                } else {
                    CardsView(cards: viewModelTCG.cards, viewModel: viewModel)
                }
            }
        }
        .navigationTitle(pokemon.name)
        .onAppear {
            viewModelTCG.cards = []
            viewModelTCG.getTCG(for: pokemon.name)
        }
//        .onDisappear {
//            viewModelTCG.cards = []
//        }
        .sheet(isPresented: $viewModelTCG.requestFails) {
            withAnimation(.bouncy) {
                VStack(alignment: .leading, spacing: 15) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("No pokemons cards found")
                        .font(.title2.bold())
                    
                    Text("Sorry, we couldn't load the cards at this moment. Please try again later.")
                        .foregroundStyle(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
            }
        }
    }
}

@ViewBuilder
func iconTypeForTag(types: [TypeElement]) -> some View {
    ForEach(types, id: \.type.name) { type in
        if let image = Utils.getTagForType(type: type.type.name) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            EmptyView()
        }
    }
}

@ViewBuilder
func imagesSection(sprites: Sprites) -> some View {
    Section("Sprites") {
        HStack {
            spriteImage(url: sprites.frontDefault)
            spriteImage(url: sprites.frontShiny)
            spriteImage(url: sprites.backDefault)
            spriteImage(url: sprites.backShiny)
        }
    }
}

@ViewBuilder func spriteImage(url: String?) -> some View {
    if let url {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
            
        } placeholder: {
            ProgressView()
        }
        .frame(width: 80, height: 80)
    } else {
        EmptyView()
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
//    https://pokeapi.co/api/v2/pokemon/112
    static let pokemon1 = PokemonDetail(height: 19,
                                id: 112,
                                isDefault: true,
                                name: "rhydon",
                                order: 177,
                                sprites: Sprites(backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/112.png",
                                                 backFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/112.png",
                                                 backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/112.png",
                                                 backShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/112.png",
                                                 frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/112.png",
                                                 frontFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/112.png",
                                                 frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/112.png",
                                                 frontShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/112.png",
                                                 other: nil),
                                stats: [
                                    Stat(baseStat: 105,
                                         effort: 0,
                                         stat: Species(name: "hp", url: "https://pokeapi.co/api/v2/stat/1/")),
                                    Stat(baseStat: 130,
                                         effort: 2,
                                         stat: Species(name: "attack", url: "https://pokeapi.co/api/v2/stat/1/")),
                                    Stat(baseStat: 130,
                                         effort: 2,
                                         stat: Species(name: "defense", url: "https://pokeapi.co/api/v2/stat/1/")),
                                    Stat(baseStat: 130,
                                         effort: 2,
                                         stat: Species(name: "special-attack", url: "https://pokeapi.co/api/v2/stat/1/")),
                                    Stat(baseStat: 130,
                                         effort: 2,
                                         stat: Species(name: "special-defense", url: "https://pokeapi.co/api/v2/stat/1/")),
                                    Stat(baseStat: 130,
                                         effort: 2,
                                         stat: Species(name: "speed", url: "https://pokeapi.co/api/v2/stat/1/"))],
                                types: [
                                    TypeElement(slot: 1,
                                                type:
                                                    Species(name: "ground", url: "https://pokeapi.co/api/v2/type/5/")),
                                    TypeElement(slot: 2,
                                                type:
                                                    Species(name: "rock", url: "https://pokeapi.co/api/v2/type/6/"))],
                                weight: 123)
    
    static var previews: some View {
        PokemonDetailView(viewModel: PokedexViewModel(pokemonsDetails: []), viewModelTCG: PokemonTGCViewModel(), pokemon: pokemon1)
    }
}

enum PokemonDetailSection {
    case pokemon
    case tcg
}
