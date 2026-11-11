//
//  PokedexPTCApp.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

@main
struct PokedexPTCApp: App {
    let fabric: ScreenFabric
    let destinationViewModel: DestinationViewModel

    init() {
        // AsyncImage uses URLSession.shared, which reads URLCache.shared. The default is too small for
        // 1300+ artworks (100-300 KB each), so images were downloaded again on every scroll.
        URLCache.shared = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024)

        let apiInteractor = APIInteractor(projectParameters: Self.loadConfiguration(), session: Session())
        let destinationViewModel = DestinationViewModel()
        self.destinationViewModel = destinationViewModel

        fabric = ScreenFabric(
            pokedexViewModel: PokedexViewModel(apiInteractor: PokedexApiCore(apiInteractor: apiInteractor),
                                               destination: destinationViewModel),
            pokemonTGCViewModel: PokemonTGCViewModel(apiInteractor: TCGApiCore(apiInteractor: apiInteractor))
        )
    }

    var body: some Scene {
        WindowGroup {
            NavigationWrapperView(destination: destinationViewModel, fabric: fabric) {
                fabric.createView(item: .pokedexMainView)
            }
        }
    }

    private static func loadConfiguration() -> [String: String] {
        guard let url = Bundle.main.url(forResource: "Configuration", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] else {
            return [:]
        }
        return plist
    }
}
