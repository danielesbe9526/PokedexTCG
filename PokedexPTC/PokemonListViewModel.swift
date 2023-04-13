//
//  PokemonListViewModel.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import Foundation
import Combine

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [PokemonInfo] = []
    @Published var requestFails = false
    @Published var selectedPokemon: PokemonDetail? = nil
    
//    var cancellables = Set<AnyCancellable>()
    var nextUrl: String = ""
    var previous: String = ""
    
    var currentPage = 0
    private var cancellable: AnyCancellable?
    
    init() {
//        getPokemons()
    }
        
    func getPokemons2() {
        cancellable = APIService.shared.getPokemons(offset: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let strongSelf = self else { return }
                switch completion {
                case .failure(let error):
                    strongSelf.requestFails = true
                    print(error)
                case .finished:
                    print("finished")
                }
            }, receiveValue: { [weak self] returnedPokemons in
                guard let strongSelf = self else { return }
                strongSelf.pokemons.append(contentsOf: returnedPokemons.results)
                strongSelf.currentPage += 20
            })
    }
    
    func getPokemon(url: String) {
        cancellable = APIService.shared.getPokemonDetail(url: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let strongSelf = self else { return }
                switch completion {
                case .failure(let error):
                    strongSelf.requestFails = true
                    print(error)
                case .finished:
                    print("finished")
                }
            }, receiveValue: { [weak self] returnedPokemon in
                guard let strongSelf = self else { return }
                strongSelf.selectedPokemon = returnedPokemon
            })
    }
    
//
//    func getPokemons() {
//        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=0&limit=20") else { return }
//
//        // Combine Steps
//        /*
//        // 1. Create the publisher
//        // 2. subscribe publisher on background thread (this are atumatically done )
//        // 3. recive on main thread
//        // 4. try map (check data its good)
//        // 5. decode (decode data into pokemon model)
//        // 6. sink (put the item into our app)
//        // 7. store (cancel subscription if needed)
//        */
//
//        URLSession.shared.dataTaskPublisher(for: url)
//            .subscribe(on: DispatchQueue.global(qos: .background))
//            .receive(on: DispatchQueue.main)
//            .tryMap(handleOutput)
//            .decode(type: Pokemon.self, decoder: JSONDecoder())
//            .sink { (completion) in
//                print("Completion: \(completion)")
//            } receiveValue: { [weak self] returnedPokemons in
//                guard let strongSelf = self else { return }
//                strongSelf.pokemons = returnedPokemons.results
//            }
//            .store(in: &cancellables)
//    }
    
    func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        
        return output.data
    }
}
