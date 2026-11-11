//
//  CardDetail.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 12/04/23.
//

import SwiftUI

struct CardDetail: View {
    let card: TCGCardBrief
    let viewModel: PokemonTGCViewModel

    @State private var phase: Phase<TCGCard> = .loading
    @State private var showZoom = false

    var body: some View {
        Form {
            imageSection

            switch phase {
            case .loading:
                Section {
                    ProgressView("Loading card…")
                        .frame(maxWidth: .infinity)
                }
            case .failed(let message):
                Section {
                    ContentUnavailableView {
                        Label("Couldn't load card details", systemImage: "exclamationmark.icloud")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try again") { Task { await load() } }
                            .buttonStyle(.borderedProminent)
                    }
                }
            case .loaded(let detail):
                CardDetailSections(card: detail)
            }
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: card.id) {
            await load()
        }
        .fullScreenCover(isPresented: $showZoom) {
            if let url = card.largeImageURL {
                ZoomableImageView(url: url, title: card.name)
            }
        }
    }

    private func load() async {
        phase = .loading
        do {
            phase = .loaded(try await viewModel.card(id: card.id))
        } catch is CancellationError {
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    private var imageSection: some View {
        Section {
            VStack(spacing: 8) {
                if let url = card.largeImageURL {
                    Button {
                        showZoom = true
                    } label: {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fit)
                            case .failure:
                                imagePlaceholder
                            default:
                                ZStack {
                                    // Show the small image already in cache while the large one downloads.
                                    AsyncImage(url: card.smallImageURL) { image in
                                        image.resizable().aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        Color.secondary.opacity(0.12)
                                    }
                                    ProgressView()
                                }
                            }
                        }
                        .aspectRatio(TCGCardCell.cardAspectRatio, contentMode: .fit)
                        .frame(maxWidth: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(card.name) card image")
                    .accessibilityHint("Opens the image full screen")

                    Text("Tap to zoom")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    imagePlaceholder
                        .aspectRatio(TCGCardCell.cardAspectRatio, contentMode: .fit)
                        .frame(maxWidth: 240)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .listRowBackground(Color.clear)
    }

    private var imagePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.12))
            VStack(spacing: 8) {
                Image(systemName: "photo").font(.largeTitle)
                Text("Image not available yet").font(.footnote)
            }
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Detail sections

private struct CardDetailSections: View {
    let card: TCGCard

    var body: some View {
        Section("Profile") {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text([card.category, card.stage].compactMap { $0 }.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let evolveFrom = card.evolveFrom {
                        Text("Evolves from \(evolveFrom)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let hp = card.hp {
                    Text("HP \(hp)")
                        .font(.title3.bold().monospacedDigit())
                }
                if let types = card.types {
                    EnergyIcons(types: types, size: 22)
                }
            }

            LabeledContent("Set", value: card.set.name)
            LabeledContent("Number", value: card.numberText)
            if let rarity = card.rarity {
                LabeledContent("Rarity", value: rarity)
            }
            if let illustrator = card.illustrator {
                LabeledContent("Illustrator", value: illustrator)
            }
            if let regulationMark = card.regulationMark {
                LabeledContent("Regulation mark", value: regulationMark)
            }
            if let legal = card.legal {
                LabeledContent("Legal") {
                    HStack(spacing: 6) {
                        LegalityBadge(format: String(localized: "Standard"), isLegal: legal.standard ?? false)
                        LegalityBadge(format: String(localized: "Expanded"), isLegal: legal.expanded ?? false)
                    }
                }
            }
        }

        if let abilities = card.abilities, !abilities.isEmpty {
            Section("Abilities") {
                ForEach(abilities, id: \.name) { ability in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(ability.type.map { LocalizedStringKey($0) } ?? "Ability")
                                .font(.caption.bold())
                                .foregroundStyle(.red)
                            Text(ability.name)
                                .font(.headline)
                        }
                        if let effect = ability.effect {
                            Text(effect).font(.callout)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }

        if let attacks = card.attacks, !attacks.isEmpty {
            Section("Attacks") {
                ForEach(attacks, id: \.name) { attack in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            EnergyIcons(types: attack.cost, size: 18)
                            Text(attack.name)
                                .font(.headline)
                            Spacer()
                            if let damage = attack.damage, !damage.isEmpty {
                                Text(damage)
                                    .font(.headline.monospacedDigit())
                            }
                        }
                        if let effect = attack.effect, !effect.isEmpty {
                            Text(effect)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                    .accessibilityElement(children: .combine)
                }
            }
        }

        if card.category == "Pokemon" {
            Section {
                HStack(alignment: .top) {
                    modifierColumn(title: "Weakness", values: card.weaknesses)
                    Spacer()
                    modifierColumn(title: "Resistance", values: card.resistances)
                    Spacer()
                    VStack(spacing: 6) {
                        Text("Retreat").font(.caption).foregroundStyle(.secondary)
                        if let retreat = card.retreat, retreat > 0 {
                            EnergyIcons(types: Array(repeating: "Colorless", count: retreat), size: 18)
                        } else {
                            Text("—")
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }

        if let description = card.description, !description.isEmpty {
            Section("Description") {
                Text(description)
                    .font(.callout)
                    .italic()
            }
        }

        PricesSection(pricing: card.pricing)
    }

    private func modifierColumn(title: LocalizedStringKey, values: [TCGTypeModifier]?) -> some View {
        VStack(spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            if let values, !values.isEmpty {
                ForEach(values, id: \.type) { value in
                    HStack(spacing: 4) {
                        EnergyIcons(types: [value.type], size: 18)
                        if let modifier = value.value {
                            Text(modifier).font(.callout.monospacedDigit())
                        }
                    }
                }
            } else {
                Text("—")
            }
        }
    }
}

private struct LegalityBadge: View {
    let format: String
    let isLegal: Bool

    var body: some View {
        Label(format, systemImage: isLegal ? "checkmark.circle.fill" : "xmark.circle")
            .font(.caption)
            .foregroundStyle(isLegal ? .green : .secondary)
            .accessibilityLabel(isLegal ? Text("\(format): legal") : Text("\(format): not legal"))
    }
}

// MARK: - Prices

private struct PricesSection: View {
    let pricing: TCGPricing?

    var body: some View {
        if let pricing, !pricing.isEmpty {
            if let tcgplayer = pricing.tcgplayer, !tcgplayer.variants.isEmpty {
                let currency = tcgplayer.unit ?? "USD"
                Section {
                    ForEach(tcgplayer.variants) { variant in
                        VStack(alignment: .leading, spacing: 10) {
                            HeadlinePriceRow(title: Text(variant.displayName),
                                             caption: "Market",
                                             value: variant.market,
                                             currency: currency)
                            PriceStrip(items: [
                                PriceItem(title: "Low", value: variant.low, tint: .red),
                                PriceItem(title: "Mid", value: variant.mid, tint: .blue),
                                PriceItem(title: "High", value: variant.high, tint: .green)
                            ], currency: currency)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("TCGplayer prices")
                } footer: {
                    UpdatedFooter(date: tcgplayer.updated)
                }
            }

            if let cardmarket = pricing.cardmarket, cardmarket.hasValues {
                let currency = cardmarket.unit ?? "EUR"
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HeadlinePriceRow(title: Text("Price trend"),
                                         caption: "Trend",
                                         value: cardmarket.trend,
                                         currency: currency)
                        PriceStrip(items: [
                            PriceItem(title: "1-day avg", value: cardmarket.avg1),
                            PriceItem(title: "7-day avg", value: cardmarket.avg7),
                            PriceItem(title: "30-day avg", value: cardmarket.avg30)
                        ], currency: currency)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Cardmarket prices")
                } footer: {
                    UpdatedFooter(date: cardmarket.updated)
                }
            }
        } else {
            Section("Prices") {
                Text("No price data available for this card yet.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct PriceItem {
    let title: LocalizedStringKey
    let value: Double?
    var tint: Color = .primary
}

/// Variant name on the left and its reference price (market / trend), large, on the right.
private struct HeadlinePriceRow: View {
    let title: Text
    let caption: LocalizedStringKey
    let value: Double?
    let currency: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            title
                .font(.headline)
            Spacer(minLength: 12)
            VStack(alignment: .trailing, spacing: 0) {
                PriceText(value: value, currency: currency)
                    .font(.title3.bold().monospacedDigit())
                Text(caption)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Secondary prices. Shown in one row when they fit; otherwise as a vertical list,
/// so long values (e.g. "US$ 20.000,00") are never truncated or shrunk.
private struct PriceStrip: View {
    let items: [PriceItem]
    let currency: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    VStack(spacing: 2) {
                        Text(item.title)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        PriceText(value: item.value, currency: currency)
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(item.tint)
                    }
                    .fixedSize()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                    .accessibilityElement(children: .combine)
                }
            }

            VStack(spacing: 6) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    LabeledContent {
                        PriceText(value: item.value, currency: currency)
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(item.tint)
                    } label: {
                        Text(item.title)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private struct PriceText: View {
    let value: Double?
    let currency: String

    var body: some View {
        if let value {
            Text(value, format: .currency(code: currency))
                .lineLimit(1)
                .fixedSize()
        } else {
            Text("—").foregroundStyle(.secondary)
        }
    }
}

private struct UpdatedFooter: View {
    let date: String?

    var body: some View {
        if let date, let parsed = Self.parse(date) {
            Text("Updated \(parsed.formatted(date: .abbreviated, time: .shortened))")
        }
    }

    private static func parse(_ value: String) -> Date? {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return withFraction.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }
}

// MARK: - Zoom

private struct ZoomableImageView: View {
    let url: URL
    let title: String

    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    var body: some View {
        NavigationStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                scale = min(max(lastScale * value.magnification, 1), 5)
                            }
                            .onEnded { _ in
                                lastScale = scale
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring) {
                            scale = scale > 1 ? 1 : 2.5
                            lastScale = scale
                        }
                    }
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Energy icons

/// TCG energy icons (Grass, Fire, Lightning, Colorless...).
struct EnergyIcons: View {
    let types: [String]
    var size: CGFloat = 18

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(types.enumerated()), id: \.offset) { _, type in
                if let image = Utils.getIconForType(type: type) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(types.joined(separator: ", "))
    }
}

#Preview {
    NavigationStack {
        CardDetail(card: PreviewData.cards[0], viewModel: PokemonTGCViewModel())
    }
}
