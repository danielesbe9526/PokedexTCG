//
//  AddToCollectionSheet.swift
//  PokedexPTC
//

import SwiftData
import SwiftUI

struct AddToCollectionSheet: View {
    let card: TCGCard

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var variant: String
    @State private var quantity = 1

    init(card: TCGCard) {
        self.card = card
        _variant = State(initialValue: card.ownableVariants.first ?? CardVariant.normal)
    }

    private var price: CardPrice? { card.referencePrice(variant: variant) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(card.name).font(.headline)
                        Text("\(card.set.name) · #\(card.numberText)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    if card.ownableVariants.count > 1 {
                        Picker("Variant", selection: $variant) {
                            ForEach(card.ownableVariants, id: \.self) { name in
                                Text(CardVariant.displayName(name)).tag(name)
                            }
                        }
                    }
                    Stepper(value: $quantity, in: 1 ... 999) {
                        LabeledContent("Quantity", value: "\(quantity)")
                    }
                }

                Section {
                    LabeledContent("Price per card") {
                        priceText(price?.value)
                    }
                    LabeledContent("Estimated value") {
                        priceText(price.map { $0.value * Double(quantity) })
                            .bold()
                    }
                } footer: {
                    Text("Prices are market estimates from TCGplayer or Cardmarket and may not match what you paid.")
                }
            }
            .navigationTitle("Add to collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        CollectionStore.add(card, variant: variant, quantity: quantity, in: context)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func priceText(_ value: Double?) -> some View {
        if let value, let currency = price?.currency {
            Text(value, format: .currency(code: currency))
                .monospacedDigit()
        } else {
            Text("—").foregroundStyle(.secondary)
        }
    }
}

/// Owned copies of one card, editable from the card detail screen.
struct OwnedCopiesSection: View {
    @Environment(\.modelContext) private var context
    @Query private var items: [CollectionItem]

    init(cardId: String) {
        _items = Query(filter: #Predicate<CollectionItem> { $0.cardId == cardId }, sort: \.variant)
    }

    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    Stepper {
                        LabeledContent(CardVariant.displayName(item.variant), value: "×\(item.quantity)")
                    } onIncrement: {
                        CollectionStore.setQuantity(item.quantity + 1, for: item, in: context)
                    } onDecrement: {
                        CollectionStore.setQuantity(item.quantity - 1, for: item, in: context)
                    }
                }
            } header: {
                Text("In your collection")
            } footer: {
                Text("Lower the quantity to zero to remove it.")
            }
        }
    }
}
