//
//  APIRoute.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation

public enum APIRoute {
    // PokeAPI
    case getPokemons(limit: Int, offset: Int)
    case getPokemonDetail(id: String)
    case getTypeInfo(name: String)

    // TCGdex (https://tcgdex.dev) — free, no API key, up to date.
    case getCards(query: TCGCardQuery)
    case getCard(id: String)
    case getSets
}

public enum TCGCardQuery: Sendable, Hashable {
    /// National Pokédex number. Avoids false positives such as "Pikachu on the Ball".
    case dexId(Int)
    /// Fallback when there is no Pokédex number.
    case name(String)
}

public enum APIHost {
    case pokeApi
    case tcgdex
}

public extension APIRoute {
    /// Language used for TCGdex. Card names are matched by Pokédex number, so this only affects display text.
    static let tcgLanguage = "en"

    var host: APIHost {
        switch self {
        case .getPokemons, .getPokemonDetail, .getTypeInfo:
            return .pokeApi
        case .getCards, .getCard, .getSets:
            return .tcgdex
        }
    }

    var method: HTTPMethod {
        .get
    }

    var path: String {
        switch self {
        case .getPokemons:
            return "api/v2/pokemon"
        case .getPokemonDetail(let id):
            return "api/v2/pokemon/\(id)"
        case .getTypeInfo(let name):
            return "api/v2/type/\(name)"
        case .getCards:
            return "v2/\(Self.tcgLanguage)/cards"
        case .getCard(let id):
            return "v2/\(Self.tcgLanguage)/cards/\(id)"
        case .getSets:
            return "v2/\(Self.tcgLanguage)/sets"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .getPokemons(let limit, let offset):
            return [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        case .getCards(.dexId(let dexId)):
            return [URLQueryItem(name: "dexId", value: "eq:\(dexId)")]
        case .getCards(.name(let name)):
            return [URLQueryItem(name: "name", value: "like:\(name)")]
        case .getPokemonDetail, .getTypeInfo, .getCard, .getSets:
            return []
        }
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
