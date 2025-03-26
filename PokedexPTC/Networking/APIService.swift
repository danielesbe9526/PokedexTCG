//
//  NetworkManager.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import Foundation
import Combine

class APIService {
    
    static let shared = APIService()
    
    func getPokemons(limit: Int = 20, offset: Int) -> AnyPublisher<Pokemon, Error> {
        guard var components = URLComponents(string: "https://pokeapi.co/api/v2/pokemon") else {
            return Fail(error: NSError(domain: "invalid URL", code: -1000)).eraseToAnyPublisher()
        }
        components.queryItems = [
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = components.url else {
            return Fail(error: NSError(domain: "invalid URL components", code: -1000)).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(handleOutput)
            .decode(type: Pokemon.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getPokemonDetail(url: String) -> AnyPublisher<PokemonDetail, Error> {
        guard let url = URL(string: url) else {
            return Fail(error: NSError(domain: "invalid URL", code: -1000)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(handleOutput)
            .decode(type: PokemonDetail.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    
    func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        
        return output.data
    }
    
    func getPokemonTGC(page: Int, pokemon: String) -> AnyPublisher<Card, Error> {
        guard var components = URLComponents(string: "https://api.pokemontcg.io/v2/cards") else {
            return Fail(error: NSError(domain: "invalid URL", code: -1000)).eraseToAnyPublisher()
        }
        
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(10)"),
            URLQueryItem(name: "q", value: "name:\(pokemon)")
        ]

        guard let url = components.url else {
            return Fail(error: NSError(domain: "invalid URL components", code: -1000)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue("91d29717-88fe-459f-ae2a-d37e4d7a36ae", forHTTPHeaderField: "X-Api-Key")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(handleOutput)
            .decode(type: Card.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func mockedPokemon() -> PokemonDetail? {
        guard let url = Bundle.main.url(forResource: "pokemonMocked", withExtension: "json") else {return nil}
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(PokemonDetail.self, from: data)
            return jsonData
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func mockedCard() -> [Datum]? {
        guard let url = Bundle.main.url(forResource: "CardsMocked", withExtension: "json") else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(Card.self, from: data)
            return jsonData.data
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func mockedDatum() -> Datum? {
        guard let url = Bundle.main.url(forResource: "CardMocked", withExtension: "json") else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(Datum.self, from: data)
            return jsonData
        } catch {
            print(error)
        }
        
        return nil
    }
}
