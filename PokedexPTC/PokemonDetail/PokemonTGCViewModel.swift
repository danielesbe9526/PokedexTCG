//
//  PokemonTGCViewModel.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 12/04/23.
//

import Foundation
import Combine

class PokemonTGCViewModel: ObservableObject {
    @Published var requestFails = false
    @Published var cards: [Datum] = []
    
    var nextUrl: String = ""
    var previous: String = ""
    var currentPage = 1

    private var cancellable: AnyCancellable?
    
    init() { }

    func getTCG(for pokemon: String) {
        cancellable = APIService.shared.getPokemonTGC(page: currentPage, pokemon: pokemon)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let strongSelf = self else { return }
                switch completion {
                case .failure(let error):
                    strongSelf.requestFails = true
                    print(error)
                case .finished:
                    print("finished TCG")
                }
            }, receiveValue: { [weak self] returnedCards in
                guard let strongSelf = self else { return }
                strongSelf.cards.append(contentsOf: returnedCards.data)
            })
    }

    func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        
        return output.data
    }
}
