//
//  CardsView.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 11/04/23.
//

import SwiftUI

/// Loading state owned by a view.
enum Phase<Value> {
    case loading
    case loaded(Value)
    case failed(String)
}

struct CardsView: View {
    let phase: Phase<[TCGCardBrief]>
    @Binding var visibleCount: Int
    let onSelect: (TCGCardBrief) -> Void
    let onRetry: () -> Void

    static let pageSize = 30
    private let gridItems = Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .top), count: 3)

    var body: some View {
        switch phase {
        case .loading:
            VStack(spacing: 12) {
                ProgressView("Loading cards…")
                LazyVGrid(columns: gridItems, spacing: 10) {
                    ForEach(0 ..< 6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.secondary.opacity(0.12))
                            .aspectRatio(TCGCardCell.cardAspectRatio, contentMode: .fit)
                    }
                }
            }
            .padding(.vertical, 8)

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't load cards", systemImage: "exclamationmark.icloud")
            } description: {
                Text(message)
            } actions: {
                Button("Try again", action: onRetry)
                    .buttonStyle(.borderedProminent)
            }

        case .loaded(let cards) where cards.isEmpty:
            ContentUnavailableView("No cards found",
                                   systemImage: "rectangle.stack.badge.minus",
                                   description: Text("This Pokémon doesn't have any TCG cards yet."))

        case .loaded(let cards):
            let shown = min(visibleCount, cards.count)
            VStack(alignment: .leading, spacing: 12) {
                Text("Showing \(shown) of \(cards.count) cards · newest first")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: gridItems, spacing: 14) {
                    ForEach(cards.prefix(shown)) { card in
                        Button {
                            onSelect(card)
                        } label: {
                            TCGCardCell(card: card)
                        }
                        // Plain style: inside a Form row, default buttons would all fire on any tap.
                        .buttonStyle(.plain)
                    }
                }

                if shown < cards.count {
                    Button {
                        visibleCount += Self.pageSize
                    } label: {
                        Label("Load \(min(Self.pageSize, cards.count - shown)) more", systemImage: "arrow.down.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderless)
                    .padding(.vertical, 4)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct TCGCardCell: View {
    static let cardAspectRatio: CGFloat = 0.716
    let card: TCGCardBrief

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if let url = card.smallImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fit)
                        case .failure:
                            placeholder
                        default:
                            ZStack {
                                RoundedRectangle(cornerRadius: 6).fill(Color.secondary.opacity(0.12))
                                ProgressView()
                            }
                        }
                    }
                } else {
                    placeholder
                }
            }
            .aspectRatio(Self.cardAspectRatio, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(card.setName ?? card.setId)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Text("#\(card.localId)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(card.name), \(card.setName ?? card.setId), number \(card.localId)")
        .accessibilityAddTraits(.isButton)
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.12))
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
                Text(card.name)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(6)
        }
    }
}

#Preview {
    Form {
        CardsView(phase: .loaded(PreviewData.cards), visibleCount: .constant(30), onSelect: { _ in }, onRetry: {})
    }
}
