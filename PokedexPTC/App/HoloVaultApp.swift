//
//  HoloVaultApp.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftData
import SwiftUI

@main
struct HoloVaultApp: App {
    let catalog: CardCatalog

    init() {
        // AsyncImage uses URLSession.shared, which reads URLCache.shared. The default is too small
        // for card images, so they were downloaded again on every scroll.
        URLCache.shared = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024)

        let apiInteractor = APIInteractor(projectParameters: Self.loadConfiguration(), session: Session())
        catalog = CardCatalog(api: TCGApiCore(apiInteractor: apiInteractor))
    }

    var body: some Scene {
        WindowGroup {
            RootView(catalog: catalog)
        }
        .modelContainer(for: CollectionItem.self)
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
