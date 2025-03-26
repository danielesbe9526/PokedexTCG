//
//  APIRoute.swift
//  GraphQLCountries
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation

public enum APIRoute {
    case getPokemons(offset: Int)
    case getPokemonDetail(id: String)
    case getPokemonTCG(page: Int, pokemon: String)
}

public extension APIRoute {
    var method: HTTPMethod {
        switch self {
        case .getPokemons:
            return .get
        case .getPokemonDetail:
            return .get
        case .getPokemonTCG:
            return .get
        }
    }
}

public extension APIRoute {
    var path: String {
        switch self {
        case .getPokemons:
            return "api/v2/pokemon"
        case .getPokemonDetail(let id):
            return "api/v2/pokemon/\(id)"
        case .getPokemonTCG:
            return "v2/cards"
        }
    }
}

public extension APIRoute {
    var parameters: [String: Any] {
        switch self {
        case .getPokemons:
            return [:]
        case .getPokemonDetail:
            return [:]
        case .getPokemonTCG:
            return [:]
        }
    }
}

public extension APIRoute {
    var queryItems: [URLQueryItem] {
        switch self {
        case .getPokemons(let offset):
            return [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(20)")
            ]
        case .getPokemonDetail:
            return []
        case .getPokemonTCG(let page, let pokemon):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(10)"),
                URLQueryItem(name: "q", value: "name:\(pokemon)")
            ]
        }
    }
}


public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    /// ...
}
