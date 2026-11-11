//
//  CollectionItem.swift
//  PokedexPTC
//

import Foundation
import SwiftData

/// A card the user owns, in one print variant. Stored only on the device.
@Model
final class CollectionItem {
    var cardId: String
    var name: String
    var localId: String
    var setName: String?
    /// TCGdex image base URL (without quality/extension).
    var imageBase: String?
    var variant: String
    var quantity: Int
    /// Last known reference price for one copy.
    var unitPrice: Double?
    var currency: String?
    var priceUpdatedAt: Date?
    var addedAt: Date

    init(cardId: String, name: String, localId: String, setName: String?, imageBase: String?,
         variant: String, quantity: Int, unitPrice: Double?, currency: String?,
         priceUpdatedAt: Date?, addedAt: Date = .now) {
        self.cardId = cardId
        self.name = name
        self.localId = localId
        self.setName = setName
        self.imageBase = imageBase
        self.variant = variant
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.currency = currency
        self.priceUpdatedAt = priceUpdatedAt
        self.addedAt = addedAt
    }

    /// Value of every copy, when a price is known.
    var totalValue: Double? {
        unitPrice.map { $0 * Double(quantity) }
    }

    /// Lets collection rows reuse the card navigation and thumbnails.
    var brief: TCGCardBrief {
        TCGCardBrief(id: cardId, localId: localId, name: name, image: imageBase, setName: setName)
    }

    func applyPrice(from card: TCGCard, at date: Date = .now) {
        let price = card.referencePrice(variant: variant)
        unitPrice = price?.value
        currency = price?.currency
        priceUpdatedAt = date
    }
}

/// Totals shown at the top of the collection.
struct CollectionSummary: Equatable {
    let copies: Int
    let uniqueCards: Int
    /// Value per currency code, because TCGplayer (USD) and Cardmarket (EUR) prices can't be added.
    let totals: [String: Double]
    let unpricedItems: Int

    init(items: [CollectionItem]) {
        copies = items.reduce(0) { $0 + $1.quantity }
        uniqueCards = Set(items.map(\.cardId)).count
        var totals: [String: Double] = [:]
        var unpriced = 0
        for item in items {
            if let value = item.totalValue, let currency = item.currency {
                totals[currency, default: 0] += value
            } else {
                unpriced += 1
            }
        }
        self.totals = totals
        unpricedItems = unpriced
    }

    /// Currencies with the largest total first.
    var sortedTotals: [(currency: String, value: Double)] {
        totals.map { (currency: $0.key, value: $0.value) }.sorted { $0.value > $1.value }
    }
}

enum CollectionSort: String, CaseIterable, Identifiable {
    case recent, value, name, set

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .recent: "Recently added"
        case .value: "Value"
        case .name: "Name"
        case .set: "Set"
        }
    }

    func sorted(_ items: [CollectionItem]) -> [CollectionItem] {
        switch self {
        case .recent:
            return items.sorted { $0.addedAt > $1.addedAt }
        case .value:
            return items.sorted { ($0.totalValue ?? -1) > ($1.totalValue ?? -1) }
        case .name:
            return items.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .set:
            return items.sorted {
                let lhs = $0.setName ?? "", rhs = $1.setName ?? ""
                if lhs != rhs { return lhs.localizedStandardCompare(rhs) == .orderedAscending }
                return $0.localId.localizedStandardCompare($1.localId) == .orderedAscending
            }
        }
    }
}

/// Collection mutations, kept out of the views so they can be tested with an in-memory container.
@MainActor
enum CollectionStore {
    /// Adds copies of a card. The same card and variant are merged into one item.
    @discardableResult
    static func add(_ card: TCGCard, variant: String, quantity: Int, in context: ModelContext) -> CollectionItem {
        let cardId = card.id
        let descriptor = FetchDescriptor<CollectionItem>(
            predicate: #Predicate { $0.cardId == cardId && $0.variant == variant }
        )
        if let existing = try? context.fetch(descriptor).first {
            existing.quantity += quantity
            existing.applyPrice(from: card)
            return existing
        }

        let item = CollectionItem(cardId: card.id, name: card.name, localId: card.localId,
                                  setName: card.set.name, imageBase: card.image,
                                  variant: variant, quantity: quantity,
                                  unitPrice: nil, currency: nil, priceUpdatedAt: nil)
        item.applyPrice(from: card)
        context.insert(item)
        return item
    }

    /// Updates the quantity; zero removes the item.
    static func setQuantity(_ quantity: Int, for item: CollectionItem, in context: ModelContext) {
        if quantity <= 0 {
            context.delete(item)
        } else {
            item.quantity = quantity
        }
    }

    /// Downloads current prices for every card in the collection, a few requests at a time.
    /// Returns how many cards could not be updated.
    static func refreshPrices(of items: [CollectionItem], using catalog: CardCatalog,
                              maxConcurrent: Int = 6) async -> Int {
        let ids = Array(Set(items.map(\.cardId)))
        var cards: [String: TCGCard] = [:]
        var failed = 0

        await withTaskGroup(of: (String, TCGCard?).self) { group in
            var next = 0
            func enqueue() {
                guard next < ids.count else { return }
                let id = ids[next]
                next += 1
                group.addTask { @MainActor in
                    (id, try? await catalog.card(id: id, refresh: true))
                }
            }
            for _ in 0 ..< min(maxConcurrent, ids.count) { enqueue() }
            for await (id, card) in group {
                if let card { cards[id] = card } else { failed += 1 }
                enqueue()
            }
        }

        let now = Date.now
        for item in items {
            if let card = cards[item.cardId] {
                item.applyPrice(from: card, at: now)
            }
        }
        return failed
    }
}
