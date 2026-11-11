//
//  RootView.swift
//  PokedexPTC
//

import SwiftUI

struct RootView: View {
    let catalog: CardCatalog

    var body: some View {
        TabView {
            NavigationStack {
                ExploreView(catalog: catalog)
                    .cardDestinations(catalog: catalog)
            }
            .tabItem { Label("Explore", systemImage: "magnifyingglass") }

            NavigationStack {
                CollectionView(catalog: catalog)
                    .cardDestinations(catalog: catalog)
            }
            .tabItem { Label("Collection", systemImage: "square.stack.3d.up.fill") }

            NavigationStack {
                AboutView()
            }
            .tabItem { Label("About", systemImage: "info.circle") }
        }
    }
}

private extension View {
    /// Screens reachable from any card list.
    func cardDestinations(catalog: CardCatalog) -> some View {
        navigationDestination(for: TCGCardBrief.self) { card in
            CardDetail(card: card, catalog: catalog)
        }
        .navigationDestination(for: TCGSetBrief.self) { set in
            SetCardsView(set: set, catalog: catalog)
        }
    }
}
