//
//  APIInteractor.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation

public final class APIInteractor: Sendable {
    enum ConfigKey {
        static let pokeApi = "url_pokeApi"
        static let tcgdex = "url_tcgdex"
    }

    private static let defaultURLs = [
        ConfigKey.pokeApi: "https://pokeapi.co",
        ConfigKey.tcgdex: "https://api.tcgdex.net"
    ]

    private let projectParameters: [String: String]
    private let session: SessionProtocol

    public init(projectParameters: [String: String], session: SessionProtocol) {
        self.projectParameters = projectParameters
        self.session = session
    }

    func request<T: Decodable>(_ route: APIRoute, as type: T.Type) async throws -> T {
        guard let urlRequest = urlRequest(for: route) else {
            throw APIError.invalidRequest
        }
        return try await session.request(urlRequest, as: T.self)
    }
}

private extension APIInteractor {
    func baseURL(for route: APIRoute) -> String? {
        let key: String
        switch route.host {
        case .pokeApi: key = ConfigKey.pokeApi
        case .tcgdex: key = ConfigKey.tcgdex
        }
        return projectParameters[key] ?? Self.defaultURLs[key]
    }

    func urlRequest(for route: APIRoute) -> URLRequest? {
        guard let base = baseURL(for: route),
              let url = URL(string: base)?.appending(path: route.path),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }

        let queryItems = route.queryItems
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let finalURL = components.url else { return nil }

        var request = URLRequest(url: finalURL)
        request.httpMethod = route.method.rawValue
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
