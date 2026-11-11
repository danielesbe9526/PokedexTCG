//
//  CollectionTests.swift
//  PokedexPTCTests
//

import Foundation
import SwiftData
import Testing
@testable import HoloVault

@Suite("Reference prices")
struct ReferencePriceTests {
    @Test("Uses the TCGplayer market price of the chosen variant")
    func variantMarket() throws {
        let card = try Fixture.card(tcgplayer: ["normal": 0.5, "reverse-holofoil": 2.25])
        #expect(card.referencePrice(variant: "reverse-holofoil") == CardPrice(value: 2.25, currency: "USD"))
        #expect(card.ownableVariants == ["normal", "reverse-holofoil"])
    }

    @Test("Falls back to mid price, then to the only variant, then to Cardmarket")
    func fallbacks() throws {
        let midOnly = try Fixture.decode(TCGCard.self, """
        { "id": "a-1", "localId": "1", "name": "A", "set": { "id": "a", "name": "A" },
          "pricing": { "tcgplayer": { "unit": "USD", "holofoil": { "midPrice": 3 } } } }
        """)
        #expect(midOnly.referencePrice(variant: "holofoil")?.value == 3)
        // Only one variant listed: any requested variant uses it.
        #expect(midOnly.referencePrice(variant: "normal")?.value == 3)

        let cardmarket = try Fixture.card(cardmarketTrend: 4.5)
        #expect(cardmarket.referencePrice(variant: "normal") == CardPrice(value: 4.5, currency: "EUR"))
        #expect(cardmarket.ownableVariants == [CardVariant.normal])

        let none = try Fixture.card()
        #expect(none.referencePrice(variant: "normal") == nil)
    }

    @Test("Variant display names", arguments: [
        ("normal", "Normal"), ("reverse-holofoil", "Reverse Holofoil"), ("1st-edition-holofoil", "1St Edition Holofoil")
    ])
    func displayName(raw: String, expected: String) {
        #expect(CardVariant.displayName(raw) == expected)
    }
}

@MainActor
@Suite("Collection")
struct CollectionTests {
    let container: ModelContainer
    var context: ModelContext { container.mainContext }

    init() throws {
        container = try ModelContainer(for: CollectionItem.self,
                                       configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    private func allItems() throws -> [CollectionItem] {
        try context.fetch(FetchDescriptor<CollectionItem>())
    }

    @Test("Adding the same card and variant merges quantities; another variant is a new item")
    func addMerges() throws {
        let card = try Fixture.card(tcgplayer: ["normal": 1, "holofoil": 10])

        CollectionStore.add(card, variant: "normal", quantity: 2, in: context)
        CollectionStore.add(card, variant: "normal", quantity: 1, in: context)
        CollectionStore.add(card, variant: "holofoil", quantity: 1, in: context)

        let items = try allItems().sorted { $0.variant < $1.variant }
        #expect(items.map(\.variant) == ["holofoil", "normal"])
        #expect(items.map(\.quantity) == [1, 3])
        #expect(items.last?.totalValue == 3)
        #expect(items.first?.setName == "151")
        #expect(items.first?.brief.smallImageURL != nil)
    }

    @Test("Setting the quantity to zero removes the item")
    func quantityZeroDeletes() throws {
        let item = CollectionStore.add(try Fixture.card(), variant: "normal", quantity: 1, in: context)
        CollectionStore.setQuantity(4, for: item, in: context)
        #expect(item.quantity == 4)

        CollectionStore.setQuantity(0, for: item, in: context)
        #expect(try allItems().isEmpty)
    }

    @Test("Summary adds values per currency and counts unpriced items")
    func summary() throws {
        CollectionStore.add(try Fixture.card(id: "a-1", tcgplayer: ["normal": 2]), variant: "normal", quantity: 3, in: context)
        CollectionStore.add(try Fixture.card(id: "a-2", tcgplayer: ["normal": 1.5]), variant: "normal", quantity: 1, in: context)
        CollectionStore.add(try Fixture.card(id: "b-1", cardmarketTrend: 5), variant: "normal", quantity: 2, in: context)
        CollectionStore.add(try Fixture.card(id: "c-1"), variant: "normal", quantity: 1, in: context)

        let summary = CollectionSummary(items: try allItems())
        #expect(summary.copies == 7)
        #expect(summary.uniqueCards == 4)
        #expect(summary.totals == ["USD": 7.5, "EUR": 10])
        #expect(summary.sortedTotals.map(\.currency) == ["EUR", "USD"])
        #expect(summary.unpricedItems == 1)
    }

    @Test("Sorting by value puts unpriced items last")
    func sortByValue() throws {
        CollectionStore.add(try Fixture.card(id: "cheap", name: "Cheap", tcgplayer: ["normal": 1]), variant: "normal", quantity: 1, in: context)
        CollectionStore.add(try Fixture.card(id: "none", name: "None"), variant: "normal", quantity: 1, in: context)
        CollectionStore.add(try Fixture.card(id: "pricey", name: "Pricey", tcgplayer: ["normal": 50]), variant: "normal", quantity: 1, in: context)

        let items = try allItems()
        #expect(CollectionSort.value.sorted(items).map(\.cardId) == ["pricey", "cheap", "none"])
        #expect(CollectionSort.name.sorted(items).map(\.name) == ["Cheap", "None", "Pricey"])
    }

    @Test("Refreshing prices downloads each card once and reports failures")
    func refreshPrices() async throws {
        let card = try Fixture.card(id: "a-1", tcgplayer: ["normal": 1, "holofoil": 1])
        CollectionStore.add(card, variant: "normal", quantity: 1, in: context)
        CollectionStore.add(card, variant: "holofoil", quantity: 1, in: context)
        CollectionStore.add(try Fixture.card(id: "broken"), variant: "normal", quantity: 1, in: context)

        let api = FakeTCGApi(failingCardIds: ["broken"], marketPrice: 9)
        let failures = await CollectionStore.refreshPrices(of: try allItems(), using: CardCatalog(api: api))

        #expect(failures == 1)
        #expect(await api.log.count(of: "card:a-1") == 1)
        let normal = try allItems().first { $0.cardId == "a-1" && $0.variant == "normal" }
        #expect(normal?.unitPrice == 9)
        #expect(normal?.priceUpdatedAt != nil)
    }
}
