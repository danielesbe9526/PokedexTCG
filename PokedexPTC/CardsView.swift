//
//  Cards.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

struct CardsView: View {
    private let gridItems = [GridItem(.flexible()),GridItem(.flexible())]
    let cards: [Datum]
    
    var body: some View {
        VStack {
            ScrollViewReader { _ in
                LazyVGrid(columns: gridItems) {
                    ForEach(cards, id: \.id) { newCard in
                        NavigationLink {
                            CardDetail(card: newCard)
                        } label: {
                            AsyncImage(url: URL(string: newCard.images.small)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }.frame(width: 150, height: 150)
                        }
                    }
                }
            }
        }
    }
}

struct Cards_Previews: PreviewProvider {
    static var card = APIService.shared.mockedCard()!
    static var previews: some View {
        CardsView(cards: card)
    }
}
