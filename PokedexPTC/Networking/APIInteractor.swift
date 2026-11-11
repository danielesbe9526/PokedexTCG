//
//  APIInteractor.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation

public final class APIInteractor: Sendable {
    enum ConfigKey {
        static let tcgdex = "url_tcgdex"
    }

    private static let defaultBaseURL = "https://api.tcgdex.net"

    private let baseURL: String
    private let session: SessionProtocol

    public init(projectParameters: [String: String], session: SessionProtocol) {
        self.baseURL = projectParameters[ConfigKey.tcgdex] ?? Self.defaultBaseURL
        self.session = session
    }

    func request<T: Decodable>(_ route: APIRoute, as type: T.Type) async throws -> T {
        guard let urlRequest = urlRequest(for: route) else {
            throw APIError.invalidRequest
        }
        return try await session.request(urlRequest, as: T.self)
    }

    func urlRequest(for route: APIRoute) -> URLRequest? {
        guard let url = URL(string: baseURL)?.appending(path: route.path),
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
