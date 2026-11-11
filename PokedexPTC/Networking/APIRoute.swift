//
//  APIRoute.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation

/// TCGdex endpoints (https://tcgdex.dev) — free, no API key.
public enum APIRoute {
    case searchCards(name: String)
    case getCard(id: String)
    case getSets
    case getSet(id: String)
}

public extension APIRoute {
    /// Language used for card data.
    static let language = "en"

    var method: HTTPMethod {
        .get
    }

    var path: String {
        switch self {
        case .searchCards:
            return "v2/\(Self.language)/cards"
        case .getCard(let id):
            return "v2/\(Self.language)/cards/\(id)"
        case .getSets:
            return "v2/\(Self.language)/sets"
        case .getSet(let id):
            return "v2/\(Self.language)/sets/\(id)"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .searchCards(let name):
            return [URLQueryItem(name: "name", value: "like:\(name)")]
        case .getCard, .getSets, .getSet:
            return []
        }
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
