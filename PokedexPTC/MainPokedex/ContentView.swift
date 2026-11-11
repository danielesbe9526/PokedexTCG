//
//  ContentView.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

// MARK: - Spinning pokeball shown while AsyncImage loads

struct LoadingPokeballView: View {
    @State private var angle: Double = 0

    var body: some View {
        Image("pokeball")
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(.secondary)
            .frame(width: 40, height: 40)
            .rotationEffect(.degrees(angle))
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Circular progress indicator shown in the navigation bar

struct CircularProgressView: View {
    let progress: Double   // 0.0 … 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.25), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.red, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.2), value: progress)
        }
        .frame(width: 22, height: 22)
        .accessibilityElement()
        .accessibilityLabel("Loading Pokédex")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

// MARK: - Main Pokedex list

struct ContentView: View {
    let viewModel: PokedexViewModel

    @State private var searchText = ""
    @State private var typeFilter: String?

    private let columns = [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 12)]

    var body: some View {
        ViewWrapper(title: "Pokédex") {
            content
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if viewModel.isLoading && viewModel.progress < 1 && !viewModel.pokemonsDetails.isEmpty {
                            CircularProgressView(progress: viewModel.progress)
                        }
                        typeFilterMenu
                    }
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Name or number"
                )
        }
        .task {
            viewModel.loadIfNeeded()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.pokemonsDetails.isEmpty {
            switch viewModel.state {
            case .failed(let message):
                ContentUnavailableView {
                    Label("Couldn't load the Pokédex", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try again") { viewModel.retry() }
                        .buttonStyle(.borderedProminent)
                }
            default:
                skeletonGrid
            }
        } else {
            let results = filteredPokemons
            ScrollView {
                if viewModel.failedCount > 0 && !viewModel.isLoading {
                    Label("\(viewModel.failedCount) Pokémon couldn't be loaded. Pull to refresh.",
                          systemImage: "exclamationmark.triangle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(results) { pokemon in
                        Button {
                            viewModel.routeToDetail(pokemon)
                        } label: {
                            PokemonCardView(pokemon: pokemon)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .overlay {
                if results.isEmpty {
                    if searchText.isEmpty {
                        ContentUnavailableView("No \(typeFilter?.capitalized ?? "") Pokémon",
                                               systemImage: "line.3.horizontal.decrease.circle")
                    } else {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }
        }
    }

    private var skeletonGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0 ..< 12, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 150)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .scrollDisabled(true)
        .accessibilityLabel("Loading Pokédex")
    }

    private var typeFilterMenu: some View {
        Menu {
            Picker("Type", selection: $typeFilter) {
                Text("All types").tag(String?.none)
                ForEach(PokemonType.all, id: \.self) { type in
                    Text(type.capitalized).tag(Optional(type))
                }
            }
        } label: {
            Image(systemName: typeFilter == nil
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel("Filter by type")
    }

    // MARK: - Search

    private var filteredPokemons: [PokemonDetail] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        return viewModel.pokemonsDetails.filter { pokemon in
            if let typeFilter, !pokemon.types.contains(where: { $0.type.name == typeFilter }) {
                return false
            }
            guard !query.isEmpty else { return true }
            if let number = Int(query.trimmingCharacters(in: CharacterSet(charactersIn: "#"))) {
                return pokemon.id == number
            }
            return pokemon.name.contains(query) || pokemon.displayName.lowercased().contains(query)
        }
    }
}

// MARK: - Card

struct PokemonCardView: View {
    let pokemon: PokemonDetail

    var body: some View {
        let typeColor = Color(PokemonType.color(for: pokemon.primaryTypeName))

        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [typeColor.opacity(0.3), typeColor.opacity(0.06)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(pokemon.displayName)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 4)
                    if pokemon.isAlternateForm {
                        Text("Form")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.thinMaterial, in: Capsule())
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)

                Spacer(minLength: 0)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        if let number = pokemon.nationalDexNumber {
                            Text("#\(String(format: "%04d", number))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        iconTypeForTag(types: pokemon.types)
                            .frame(maxHeight: 16)
                    }
                    .padding(.leading, 10)
                    .padding(.bottom, 10)

                    Spacer(minLength: 0)

                    ZStack {
                        Image("pokeball")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .offset(x: 10, y: 15)

                        pokemonImage
                    }
                    .frame(width: 85, height: 85)
                    .clipped()
                    .padding(.bottom, 4)
                    .padding(.trailing, 6)
                }
            }
        }
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityText: String {
        let types = pokemon.types.map { $0.type.name.capitalized }.formatted(.list(type: .and))
        return String(localized: "\(pokemon.displayName), number \(pokemon.nationalDexNumber ?? pokemon.id), \(types) type")
    }

    @ViewBuilder
    private var pokemonImage: some View {
        if let url = pokemon.artworkURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image("pokeball")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.secondary.opacity(0.35))
                default:
                    LoadingPokeballView()
                }
            }
        } else {
            Image("pokeball")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.secondary.opacity(0.4))
        }
    }
}

// MARK: - Preview

#Preview {
    let bulbasaur = PokemonDetail(
        height: 7, id: 1, isDefault: true, name: "bulbasaur", order: 1,
        sprites: Sprites(
            backDefault: nil, backFemale: nil, backShiny: nil, backShinyFemale: nil,
            frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
            frontFemale: nil, frontShiny: nil, frontShinyFemale: nil, other: nil),
        stats: [Stat(baseStat: 45, effort: 0, stat: Species(name: "hp", url: ""))],
        types: [TypeElement(slot: 1, type: Species(name: "grass", url: ""))],
        weight: 69)

    return NavigationStack {
        ContentView(viewModel: PokedexViewModel(pokemonsDetails: [bulbasaur]))
    }
}
