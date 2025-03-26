//
//  PokedexPTCApp.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

@main
struct PokedexPTCApp: App {
    let session: APIInteractor
    var fabric: ScreenFabric
    var destinationViewModel: DestinationViewModel
    let pokedexViewModel: PokedexViewModel
    let pokemonTCGViewModel: PokemonTGCViewModel
    
    init() {
        session = APIInteractor(projectParameters: plistConfigurationDictionary, session: Session())
        destinationViewModel = DestinationViewModel()
        pokedexViewModel = PokedexViewModel(apiInteractor: PokedexApiCore(apiInteractor: session), destination: destinationViewModel)
        pokemonTCGViewModel = PokemonTGCViewModel()
        
        fabric = ScreenFabric(
            session: session,
            pokedexViewModel: pokedexViewModel,
            pokemonTGCViewModel: pokemonTCGViewModel
        )
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationWrapperView(destination: destinationViewModel, fabric: fabric) {
                fabric.createView(item: .pokedexMainView)
            }
        }
    }
    
    private var plistConfigurationDictionary: [String: String] = {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist") else {
            return [:]
        }
        
        let url = URL(fileURLWithPath: path)
        
        guard let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: String] else {
            return [:]
        }
        
        return plist
    }()
}
