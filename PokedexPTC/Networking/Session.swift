//
//  Session.swift
//  GraphQLCountries
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation

final public class Session: SessionProtocol {
    let decoder = JSONDecoder()
    
    public func request<T>(urlRequest: URLRequest, for type: T.Type) async throws -> Result<T, Error> where T : Decodable {
        let session = URLSession(configuration: .ephemeral)
        let (data, response) = try await session.data(for: urlRequest)
        print(urlRequest.url?.absoluteString ?? "🐛 Bad urlRequest")
        let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJson = responseJson as? [String: Any] {
            if urlRequest.url?.pathComponents.last ==  "pokemon" {
                print("Body Response: \(responseJson)")
            }
        }
        
        let responseResult: HTTPURLResponse? = response as? HTTPURLResponse
        let code = responseResult?.statusCode ?? 0
        if 200 ... 299 ~= code {
            return .success(try decoder.decode(T.self, from: data))
        } else {
            return .failure(URLError(.badServerResponse))
        }
    }
}

// Testing Mock objects

final public class SessionMockedFail: SessionProtocol {
    public func request<T: Decodable>(urlRequest: URLRequest, for type: T.Type) async throws -> Result<T, Error> {
        .failure(ResponseError.unknown)
    }
}

final public class SessionMockedSucces: SessionProtocol {
    public func request<T: Decodable>(urlRequest: URLRequest, for type: T.Type) async throws -> Result<T, Error> {
        .success(type.self as! T)
    }
}

