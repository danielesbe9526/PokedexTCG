//
//  APIInteractor.swift
//  Pokedex
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation
import Combine

public final class APIInteractor {
    private let projectParameters: [String: String]
    private let session: SessionProtocol
    
    public init(projectParameters: [String : String], session: SessionProtocol) {
        self.projectParameters = projectParameters
        self.session = session
    }
    
    func manageRequest<T: Decodable>(with route: APIRoute, for type: T.Type) async throws -> Result<T, Error> {
        guard let urlRequest = getUrlRequest(with: route) else {
            return .failure(ResponseError.badRequest)
        }
        
        let result = try await session.request(urlRequest: urlRequest, for: T.self)
        return result
    }
}

private extension APIInteractor {
    func getUrlRequest(with router: APIRoute) -> URLRequest? {
        var urlString: String?
        switch router {
        case .getPokemonDetail, .getPokemons:
            urlString = projectParameters["url_pokeApi"]
        case .getPokemonTCG:
            urlString = projectParameters["url_tcg"]
        }
        
        guard let urlString,
              let url = URL(string: urlString)?.appending(path: router.path) else {
            return nil
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = router.queryItems
        
        switch router.method {
        case .get:
            return addGetRequestComponents(components: urlComponents, method: router.method.rawValue)
        case .post:
            return addBodyResquest(components: urlComponents, parameters: router.parameters, method: router.method.rawValue)
        }
    }
    
    func addGetRequestComponents(components: URLComponents?, method: String) -> URLRequest? {
        guard let components,
              let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 20
        
        if components.url?.absoluteString == projectParameters["url_tcg"] {
            request.addValue("91d29717-88fe-459f-ae2a-d37e4d7a36ae", forHTTPHeaderField: "X-Api-Key")
        }
        return request
    }
    
    func addBodyResquest(components: URLComponents?, parameters: [String: Any], method: String) -> URLRequest? {
        guard let components,
              let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 20
        if let jsonData = try? JSONSerialization.data(withJSONObject: parameters) {
            request.httpBody = jsonData
        }
        return request
    }
}

public protocol SessionProtocol {
    func request<T: Decodable>(urlRequest: URLRequest, for type: T.Type) async throws -> Result<T, Error>
}

public enum ResponseError: Error {
    case unhandled
    case decoded
    case badRequest
    case unknown
}
