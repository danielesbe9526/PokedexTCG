//
//  PokemonDetailView.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemonInfo: PokemonInfo

    @StateObject var viewModel: PokedexViewModel
    @StateObject var viewModelTCG: PokemonTGCViewModel

    @State var showTGC = false
    
    var body: some View {
        if let pokemon = viewModel.selectedPokemon {
                VStack {
                    Form {
                        Section("Profile") {
                            AsyncImage(url: URL(string: (pokemon.sprites?.other?.officialArtwork.frontDefault)!)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 300, height: 300)
                            
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
                        
                        Button("Show TCG") {
                            showTGC.toggle()
                        }

                        if showTGC {
                            if !viewModelTCG.cards.isEmpty {
                                pokemonTCGSection(cards: viewModelTCG.cards) {
                                    viewModelTCG.getTCG(for: pokemon.name)
                                }.onAppear {
                                    viewModelTCG.getTCG(for: pokemon.name)
                                }
                            } else {
                                ProgressView {
                                    Text("Loading")
                                        .fontWeight(.bold)
                                }.onAppear {
                                    viewModelTCG.getTCG(for: pokemon.name)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(pokemon.name)
        } else {
            ProgressView {
                Text("Loading")
                    .fontWeight(.bold)
            }.onAppear {
                viewModel.getPokemonDetail(url: pokemonInfo.url)
            }

//            let pokemon = APIService.shared.mockedPokemon()!
//            let card = APIService.shared.mockedCard()!
//
//            VStack {
//                Form {
//                    Section("Profile") {
//                        AsyncImage(url: URL(string: (pokemon.sprites?.other?.officialArtwork.frontDefault)!)) { image in
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//
//                        } placeholder: {
//                            Color.gray
//                        }
//                        .frame(width: 300, height: 300)
//
//                    }
//
//                    if let sprites = pokemon.sprites {
//                        imagesSection(sprites: sprites)
//                    }
//
//
//                    HStack {
//                        Text("types:")
//                            .padding(.horizontal)
//                        Spacer()
//                        iconTypeForTag(types: pokemon.types)
//                    }
////                    pokemonTCGSection(cards: card) {
////                        viewModelTCG.getTCG(for: pokemon.name)
////                    }
//                }
//            }
        }
    }
}

@ViewBuilder func pokemonTCGSection(cards: [Datum], tapped: (@escaping ()-> Void)) -> some View {
    Section("POkemon TCG") {
        CardsView(cards: cards)
        Button {
            tapped()
        } label: {
            HStack {
                Text("Load More Cards")
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
            }
        }
    }
}

@ViewBuilder func iconTypeForTag(types: [TypeElement]) -> some View {
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

@ViewBuilder func imagesSection(sprites: Sprites) -> some View {
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
    //    static var pokemon = APIService.shared.mockedPokemon()!
    static var pokemonSelected = PokemonInfo(id: 1, name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
    static var previews: some View {
        PokemonDetailView(pokemonInfo: pokemonSelected, viewModel: PokedexViewModel(apiInteractor: nil, destination: nil), viewModelTCG: PokemonTGCViewModel())
    }
}
