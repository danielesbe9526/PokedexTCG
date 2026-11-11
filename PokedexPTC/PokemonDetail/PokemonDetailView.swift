//
//  PokemonDetailView.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

struct PokemonDetailView: View {
    // View models use @Observable: SwiftUI tracks only the properties each body reads.
    let viewModel: PokedexViewModel
    let viewModelTCG: PokemonTGCViewModel
    let pokemon: PokemonDetail

    @State private var section: PokemonDetailSection = .pokemon
    @State private var effectiveness: Phase<TypeEffectiveness> = .loading
    @State private var cardsPhase: Phase<[TCGCardBrief]> = .loading
    @State private var visibleCards = CardsView.pageSize

    var body: some View {
        Form {
            Picker("Section", selection: $section) {
                Text("Pokémon Info").tag(PokemonDetailSection.pokemon)
                Text("Cards").tag(PokemonDetailSection.tcg)
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            switch section {
            case .pokemon:
                profileSection
                statsSection
                if let sprites = pokemon.sprites {
                    SpritesSection(sprites: sprites)
                }
                typeEffectivenessSection
            case .tcg:
                Section {
                    CardsView(phase: cardsPhase,
                              visibleCount: $visibleCards,
                              onSelect: { viewModel.routeToCardDetail(card: $0) },
                              onRetry: { Task { await loadCards() } })
                }
            }
        }
        .navigationTitle(pokemon.displayName)
        // Runs once per Pokémon (not every time the view reappears after coming back from a card).
        .task(id: pokemon.id) {
            async let types: Void = loadTypeEffectiveness()
            async let cards: Void = loadCards()
            _ = await (types, cards)
        }
    }

    // MARK: - Loading

    private func loadTypeEffectiveness() async {
        do {
            effectiveness = .loaded(try await viewModel.typeEffectiveness(for: pokemon.types))
        } catch is CancellationError {
        } catch {
            effectiveness = .failed(error.localizedDescription)
        }
    }

    private func loadCards() async {
        if case .loaded = cardsPhase { return }
        cardsPhase = .loading
        do {
            cardsPhase = .loaded(try await viewModelTCG.cards(for: pokemon))
        } catch is CancellationError {
        } catch {
            cardsPhase = .failed(error.localizedDescription)
        }
    }

    // MARK: - Sections

    private var profileSection: some View {
        Section("Profile") {
            if let url = pokemon.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary)
                    default:
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .accessibilityLabel("\(pokemon.displayName) artwork")
            }

            LabeledContent("Number", value: "#\(String(format: "%04d", pokemon.nationalDexNumber ?? pokemon.id))")
            LabeledContent("Types") {
                HStack(spacing: 6) {
                    iconTypeForTag(types: pokemon.types)
                }
                .frame(height: 28)
            }
            LabeledContent("Weight",
                           value: Measurement(value: pokemon.weightInKilograms, unit: UnitMass.kilograms),
                           format: .measurement(width: .abbreviated, usage: .asProvided))
            LabeledContent("Height",
                           value: Measurement(value: pokemon.heightInMeters, unit: UnitLength.meters),
                           format: .measurement(width: .abbreviated, usage: .asProvided))
        }
    }

    private var statsSection: some View {
        Section {
            ForEach(pokemon.stats, id: \.stat.name) { stat in
                StatRow(name: Self.statName(stat.stat.name), value: stat.baseStat)
            }
            LabeledContent("Total", value: "\(pokemon.stats.reduce(0) { $0 + $1.baseStat })")
                .font(.headline)
        } header: {
            Text("Base stats")
        }
    }

    @ViewBuilder
    private var typeEffectivenessSection: some View {
        switch effectiveness {
        case .loading:
            Section("Type effectiveness") {
                ProgressView().frame(maxWidth: .infinity)
            }
        case .failed:
            Section("Type effectiveness") {
                Button("Couldn't load type data. Try again") {
                    Task { await loadTypeEffectiveness() }
                }
            }
        case .loaded(let effectiveness) where !effectiveness.isEmpty:
            Section {
                ForEach(effectiveness.groups) { group in
                    TypeEffectivenessRow(title: Self.title(for: group.multiplier),
                                         multiplier: TypeEffectiveness.label(for: group.multiplier),
                                         icon: Self.icon(for: group.multiplier),
                                         names: group.types,
                                         color: Self.color(for: group.multiplier))
                }
                if !effectiveness.strongAgainst.isEmpty {
                    TypeEffectivenessRow(title: String(localized: "Strong against"), multiplier: "2×", icon: "bolt.fill",
                                         names: effectiveness.strongAgainst, color: .green)
                }
            } header: {
                Text("Type effectiveness")
            } footer: {
                Text("Damage taken from each attacking type, combining both of this Pokémon's types.")
            }
        case .loaded:
            EmptyView()
        }
    }

    // MARK: - Helpers

    private static func statName(_ name: String) -> String {
        switch name {
        case "hp": return String(localized: "HP")
        case "special-attack": return String(localized: "Sp. Atk")
        case "special-defense": return String(localized: "Sp. Def")
        case "attack": return String(localized: "Attack")
        case "defense": return String(localized: "Defense")
        case "speed": return String(localized: "Speed")
        default: return name.capitalized
        }
    }

    private static func title(for multiplier: Double) -> String {
        switch multiplier {
        case 0: return String(localized: "Immune to")
        case ..<1: return String(localized: "Resists")
        default: return String(localized: "Weak to")
        }
    }

    private static func icon(for multiplier: Double) -> String {
        switch multiplier {
        case 0: return "minus.circle.fill"
        case ..<1: return "shield.fill"
        default: return "arrow.down.heart.fill"
        }
    }

    private static func color(for multiplier: Double) -> Color {
        switch multiplier {
        case 0: return .purple
        case ..<1: return .blue
        case 4...: return .red
        default: return .orange
        }
    }
}

// MARK: - Components

private struct StatRow: View {
    let name: String
    let value: Int

    var body: some View {
        HStack(spacing: 12) {
            Text(name)
                .frame(minWidth: 64, alignment: .leading)
            Text("\(value)")
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(minWidth: 32, alignment: .trailing)
            ProgressView(value: Double(min(value, 255)), total: 255)
                .tint(value >= 100 ? .green : value >= 60 ? .orange : .red)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(name)
        .accessibilityValue("\(value)")
    }
}

private struct SpritesSection: View {
    let sprites: Sprites

    var body: some View {
        let items: [(String, String?)] = [
            (String(localized: "Front"), sprites.frontDefault),
            (String(localized: "Shiny"), sprites.frontShiny),
            (String(localized: "Back"), sprites.backDefault),
            (String(localized: "Back shiny"), sprites.backShiny)
        ]
        let available = items.compactMap { label, url in url.flatMap(URL.init(string:)).map { (label, $0) } }

        if !available.isEmpty {
            Section("Sprites") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(available, id: \.0) { label, url in
                            VStack(spacing: 4) {
                                AsyncImage(url: url) { image in
                                    image.resizable().interpolation(.none).aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 80, height: 80)
                                Text(label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(Text("\(label) sprite"))
                        }
                    }
                }
            }
        }
    }
}

private struct TypeEffectivenessRow: View {
    let title: String
    let multiplier: String
    let icon: String
    let names: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                Text(title)
                    .font(.subheadline.bold())
                Text(multiplier)
                    .font(.caption.bold())
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.12), in: Capsule())
            }
            .foregroundStyle(color)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(names, id: \.self) { name in
                        if let image = Utils.getTagForType(type: name) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 28)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(multiplier): \(names.map { $0.capitalized }.joined(separator: ", "))")
    }
}

@ViewBuilder
func iconTypeForTag(types: [TypeElement]) -> some View {
    ForEach(types, id: \.type.name) { type in
        if let image = Utils.getTagForType(type: type.type.name) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityLabel(type.type.name.capitalized)
        }
    }
}

enum PokemonDetailSection {
    case pokemon
    case tcg
}

#Preview {
    let rhydon = PokemonDetail(
        height: 19, id: 112, isDefault: true, name: "rhydon", order: 177,
        sprites: Sprites(backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/112.png",
                         backFemale: nil, backShiny: nil, backShinyFemale: nil,
                         frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/112.png",
                         frontFemale: nil, frontShiny: nil, frontShinyFemale: nil, other: nil),
        stats: [
            Stat(baseStat: 105, effort: 0, stat: Species(name: "hp", url: "")),
            Stat(baseStat: 130, effort: 2, stat: Species(name: "attack", url: "")),
            Stat(baseStat: 120, effort: 0, stat: Species(name: "defense", url: "")),
            Stat(baseStat: 45, effort: 0, stat: Species(name: "special-attack", url: "")),
            Stat(baseStat: 45, effort: 0, stat: Species(name: "special-defense", url: "")),
            Stat(baseStat: 40, effort: 0, stat: Species(name: "speed", url: ""))
        ],
        types: [
            TypeElement(slot: 1, type: Species(name: "ground", url: "")),
            TypeElement(slot: 2, type: Species(name: "rock", url: ""))
        ],
        weight: 1200)

    return NavigationStack {
        PokemonDetailView(viewModel: PokedexViewModel(pokemonsDetails: []),
                          viewModelTCG: PokemonTGCViewModel(),
                          pokemon: rhydon)
    }
}
