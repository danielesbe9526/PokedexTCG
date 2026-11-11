//
//  ExploreView.swift
//  PokedexPTC
//

import SwiftUI

/// Home tab: browse sets (newest first) or search cards by name.
struct ExploreView: View {
    let catalog: CardCatalog

    @State private var query = ""
    @State private var results: Phase<[TCGCardBrief]> = .loading
    @State private var sets: Phase<[TCGSetBrief]> = .loading

    private var searchKey: String? { CardCatalog.normalizedQuery(query) }

    var body: some View {
        Group {
            if searchKey != nil {
                ScrollView {
                    CardGrid(phase: results,
                             emptyMessage: "Check the spelling or try a shorter name.",
                             onRetry: { Task { await search() } })
                        .padding()
                }
            } else {
                setsList
            }
        }
        .navigationTitle("Explore")
        .searchable(text: $query, prompt: "Search cards by name")
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .task(id: searchKey) {
            guard searchKey != nil else { return }
            // Debounce: a new keystroke cancels this task before the request starts.
            do { try await Task.sleep(for: .milliseconds(350)) } catch { return }
            await search()
        }
        .task {
            if case .loaded = sets { return }
            await loadSets()
        }
    }

    @ViewBuilder
    private var setsList: some View {
        switch sets {
        case .loading:
            ProgressView("Loading sets…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't load sets", systemImage: "exclamationmark.icloud")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") { Task { await loadSets() } }
                    .buttonStyle(.borderedProminent)
            }
        case .loaded(let sets):
            List {
                Section {
                    ForEach(sets) { set in
                        NavigationLink(value: set) {
                            SetRow(set: set)
                        }
                    }
                } header: {
                    Text("Sets · newest first")
                } footer: {
                    Text("Search above to find a card in any set.")
                }
            }
            .refreshable { await loadSets() }
        }
    }

    private func search() async {
        guard let searchKey else { return }
        results = .loading
        do {
            let cards = try await catalog.search(name: searchKey)
            // Ignore late results if the query changed meanwhile.
            guard searchKey == CardCatalog.normalizedQuery(query) else { return }
            results = .loaded(cards)
        } catch is CancellationError {
        } catch {
            results = .failed(error.localizedDescription)
        }
    }

    private func loadSets() async {
        do {
            sets = .loaded(try await catalog.setsNewestFirst())
        } catch is CancellationError {
        } catch {
            sets = .failed(error.localizedDescription)
        }
    }
}

private struct SetRow: View {
    let set: TCGSetBrief

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(set.name)
                .font(.body)
            if let total = set.cardCount?.total {
                Text("\(total) cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Every card in one set.
struct SetCardsView: View {
    let set: TCGSetBrief
    let catalog: CardCatalog

    @State private var phase: Phase<[TCGCardBrief]> = .loading

    var body: some View {
        ScrollView {
            CardGrid(phase: phase,
                     emptyMessage: "This set has no cards listed yet.",
                     showsSetName: false,
                     onRetry: { Task { await load() } })
                .padding()
        }
        .navigationTitle(set.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: set.id) {
            await load()
        }
    }

    private func load() async {
        phase = .loading
        do {
            phase = .loaded(try await catalog.cards(in: set))
        } catch is CancellationError {
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        ExploreView(catalog: CardCatalog())
    }
}
