//
//  Cards.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

struct CardsView: View {
    private let gridItems = [GridItem(.flexible()),GridItem(.flexible()), GridItem(.flexible())]
    var cards: [Datum]
    @ObservedObject var viewModel: PokedexViewModel

    var body: some View {
        ScrollView {
            Text("Choose a card to explore its details.")
                .font(.headline)
                .padding()
            
            Divider()
            
            LazyVGrid(columns: gridItems) {
                ForEach(cards) { newCard in
                    let _ = print(newCard.images.small)
                    let _ = print("id: \(newCard.id)")
                    AsyncImage(url: URL(string: newCard.images.small)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit) // Displays the loaded image.
                        } else if phase.error != nil {
//                            Text(phase.error?.localizedDescription ?? "error")
//                                .background(.red)
                            EmptyView()
                        } else {
                           ProgressView()
                        }
                    }
                    .onTapGesture {
                        viewModel.routeToCardDetail(card: newCard)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct Cards_Previews: PreviewProvider {
    static var card = APIService.shared.mockedCard()!
    
    static var previews: some View {
        CardsView(cards: card, viewModel: PokedexViewModel(pokemonsDetails: []))
    }
}
