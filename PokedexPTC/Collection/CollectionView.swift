//
//  CollectionView.swift
//  PokedexPTC
//

import SwiftData
import SwiftUI

struct CollectionView: View {
    let catalog: CardCatalog

    @Environment(\.modelContext) private var context
    @Query private var items: [CollectionItem]
    @AppStorage("collection.sort") private var sort: CollectionSort = .recent
    @State private var filter = ""
    @State private var isRefreshing = false
    @State private var refreshFailures = 0
    @State private var showRefreshAlert = false

    private var visibleItems: [CollectionItem] {
        let query = filter.trimmingCharacters(in: .whitespaces)
        let matching = query.isEmpty ? items : items.filter {
            $0.name.localizedCaseInsensitiveContains(query) || ($0.setName ?? "").localizedCaseInsensitiveContains(query)
        }
        return sort.sorted(matching)
    }

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView {
                    Label("Your collection is empty", systemImage: "square.stack.3d.up")
                } description: {
                    Text("Find a card in Explore and tap + to add it.")
                }
            } else {
                list
            }
        }
        .navigationTitle("Collection")
        .toolbar {
            if !items.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort by", selection: $sort) {
                            ForEach(CollectionSort.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        Button {
                            Task { await refreshPrices() }
                        } label: {
                            Label("Update prices", systemImage: "arrow.clockwise")
                        }
                        .disabled(isRefreshing)
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("Some prices couldn't be updated", isPresented: $showRefreshAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(refreshFailures) cards failed. Check your connection and pull down to try again.")
        }
    }

    private var list: some View {
        List {
            Section {
                SummaryHeader(summary: CollectionSummary(items: items), isRefreshing: isRefreshing)
            }

            Section {
                ForEach(visibleItems) { item in
                    NavigationLink(value: item.brief) {
                        CollectionRow(item: item)
                    }
                }
                .onDelete { offsets in
                    let shown = visibleItems
                    for index in offsets {
                        context.delete(shown[index])
                    }
                }
            } footer: {
                if let oldest = items.compactMap(\.priceUpdatedAt).min() {
                    Text("Prices from TCGplayer or Cardmarket, updated \(oldest.formatted(.relative(presentation: .named))). Values are estimates.")
                }
            }
        }
        .searchable(text: $filter, prompt: "Filter by name or set")
        .refreshable { await refreshPrices() }
    }

    private func refreshPrices() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        let failures = await CollectionStore.refreshPrices(of: items, using: catalog)
        if failures > 0 {
            refreshFailures = failures
            showRefreshAlert = true
        }
    }
}

private struct SummaryHeader: View {
    let summary: CollectionSummary
    let isRefreshing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Estimated value")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if summary.sortedTotals.isEmpty {
                Text("—")
                    .font(.largeTitle.bold())
            } else {
                ForEach(summary.sortedTotals, id: \.currency) { total in
                    Text(total.value, format: .currency(code: total.currency))
                        .font(summary.sortedTotals.first?.currency == total.currency ? .largeTitle.bold() : .title3.bold())
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
            }

            HStack(spacing: 6) {
                Text("\(summary.copies) cards · \(summary.uniqueCards) unique")
                if summary.unpricedItems > 0 {
                    Text("· \(summary.unpricedItems) without price")
                }
                if isRefreshing {
                    ProgressView().controlSize(.mini)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

private struct CollectionRow: View {
    let item: CollectionItem

    var body: some View {
        HStack(spacing: 12) {
            CardThumbnail(card: item.brief, cornerRadius: 4)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2)
                Text("\(item.setName ?? "—") · #\(item.localId)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("\(CardVariant.displayName(item.variant)) · ×\(item.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            if let value = item.totalValue, let currency = item.currency {
                Text(value, format: .currency(code: currency))
                    .font(.callout.monospacedDigit())
                    .fixedSize()
            } else {
                Text("—")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        CollectionView(catalog: CardCatalog())
    }
    .modelContainer(for: CollectionItem.self, inMemory: true)
}
