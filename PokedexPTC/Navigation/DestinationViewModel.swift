//
//  DestinationViewModel.swift
//  GraphQLCountries
//
//  Created by Daniel Beltran on 24/03/25.
//

import Foundation

final public class DestinationViewModel: ObservableObject {
    @MainActor @Published public var destination: [ScreenDestination]
    
    @MainActor
    public var isNavigationEmpty: Bool {
        destination.isEmpty
    }
    
    @MainActor
    public init(destination: [ScreenDestination] = []) {
        self.destination = destination
    }
    
    @MainActor
    public func navigate(to destination: ScreenDestination) {
        self.destination.removeAll(where: { $0 == destination})
        self.destination.append(destination)
    }
    
    @MainActor
    public func navigateBack(to last: Int = -1) {
        guard destination.count >= last else {
            return
        }
        
        destination.removeLast()
    }
    
    @MainActor
    public func popToScreen(_ screen: ScreenDestination) {
        guard let screenIndex = destination.firstIndex(where:{ $0 == screen }) else {
            return
        }
        
        destination = Array(destination.prefix(through: screenIndex))
    }
}
