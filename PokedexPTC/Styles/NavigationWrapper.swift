//
//  NavigationWrapper.swift
//  ContriesAPI
//
//  Created by Daniel Beltran on 15/02/24.
//

import SwiftUI

struct NavigationWrapperView<Content: View>: View {
    @ObservedObject var destination: DestinationViewModel
    var fabric: ScreenFabric
    var content: () -> Content
    
    init(destination: DestinationViewModel, fabric: ScreenFabric, @ViewBuilder content: @escaping () -> Content) {
        self.destination = destination
        self.fabric = fabric
        self.content = content
    }
    
    var body: some View {
        NavigationStack(path: $destination.destination) {
            content()
                .navigationDestination(for: ScreenDestination.self) {
                    fabric.createView(item: $0)
                }
        }
    }
}
