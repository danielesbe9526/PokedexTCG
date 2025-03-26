//
//  PokedexApiType.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 25/03/25.
//

import Foundation

public protocol PokedexApiType {
    func getPokemons(offset: Int) async throws -> Pokemon?
    func getPokemonDetails(id: String) async throws -> PokemonDetail?
}

public struct PokedexApiCore: PokedexApiType {
    weak var apiInteractor: APIInteractor?
    
    public init(apiInteractor: APIInteractor) {
        self.apiInteractor = apiInteractor
    }

    public func getPokemons(offset: Int) async throws -> Pokemon? {
        let request = APIRoute.getPokemons(offset: offset)
        let result = try await apiInteractor?.manageRequest(with: request, for: Pokemon.self)
        
        switch result {
        case .success(let value):
            return value
        case .failure, .none:
            return nil
        }
    }
    
    public func getPokemonDetails(id: String) async throws -> PokemonDetail? {
        
        let reqest = APIRoute.getPokemonDetail(id: id)
        let result = try await apiInteractor?.manageRequest(with: reqest, for: PokemonDetail.self)
        
        switch result {
        case .success(let value):
            return value
        case .failure, .none:
            return nil
        }
    }
}
