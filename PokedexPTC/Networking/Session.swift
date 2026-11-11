//
//  Session.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation

/// Errors surfaced by the networking layer. They keep the cause so the UI can show a useful message.
public enum APIError: Error, LocalizedError, Equatable {
    case invalidRequest
    case offline
    case server(status: Int)
    case decoding(String)
    case transport(String)

    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return String(localized: "The request could not be built. Check Configuration.plist.")
        case .offline:
            return String(localized: "You appear to be offline. Check your connection and try again.")
        case .server(let status):
            return String(localized: "The server is having trouble (HTTP \(status)). Please try again in a moment.")
        case .decoding:
            return String(localized: "The server sent data in an unexpected format.")
        case .transport(let message):
            return message
        }
    }
}

public protocol SessionProtocol: Sendable {
    func request<T: Decodable>(_ urlRequest: URLRequest, as type: T.Type) async throws -> T
}

final public class Session: SessionProtocol, @unchecked Sendable {
    private let session: URLSession
    private let maxAttempts: Int

    /// Uses the `.default` configuration so HTTP caching (Cache-Control headers) works,
    /// backed by the shared `URLCache` configured at app start.
    public init(maxAttempts: Int = 2) {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = .shared
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.httpMaximumConnectionsPerHost = 8
        self.session = URLSession(configuration: configuration)
        self.maxAttempts = max(1, maxAttempts)
    }

    public func request<T: Decodable>(_ urlRequest: URLRequest, as type: T.Type) async throws -> T {
        var attempt = 0
        while true {
            attempt += 1
            do {
                return try await perform(urlRequest, as: type)
            } catch let error as APIError {
                // Retry once on 5xx: the TCG providers are known to return intermittent 500/502.
                if case .server(let status) = error, status >= 500, attempt < maxAttempts {
                    try await Task.sleep(for: .milliseconds(400 * attempt))
                    continue
                }
                throw error
            }
        }
    }

    private func perform<T: Decodable>(_ urlRequest: URLRequest, as type: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                throw APIError.offline
            case .cancelled:
                throw CancellationError()
            default:
                throw APIError.transport(error.localizedDescription)
            }
        }

        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard 200 ... 299 ~= status else {
            throw APIError.server(status: status)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("Decoding \(T.self) from \(urlRequest.url?.absoluteString ?? "") failed: \(error)")
            #endif
            throw APIError.decoding(String(describing: error))
        }
    }
}

// MARK: - Testing / preview doubles

final public class SessionMockedFail: SessionProtocol {
    private let error: APIError

    public init(error: APIError = .server(status: 500)) {
        self.error = error
    }

    public func request<T: Decodable>(_ urlRequest: URLRequest, as type: T.Type) async throws -> T {
        throw error
    }
}

/// Returns the given JSON payload for every request.
final public class SessionMockedSuccess: SessionProtocol {
    private let payload: Data

    public init(payload: Data) {
        self.payload = payload
    }

    public func request<T: Decodable>(_ urlRequest: URLRequest, as type: T.Type) async throws -> T {
        try JSONDecoder().decode(T.self, from: payload)
    }
}
