//
//  CardGrid.swift
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

/// Grid of cards. Each cell pushes `TCGCardBrief` onto the enclosing NavigationStack.
/// `LazyVGrid` only builds the cells (and downloads the images) that scroll into view,
/// so every card is listed at once without manual paging.
struct CardGrid: View {
    let phase: Phase<[TCGCardBrief]>
    var emptyTitle: LocalizedStringKey = "No cards found"
    var emptyMessage: LocalizedStringKey = "Try a different name."
    var showsSetName = true
    let onRetry: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 180), spacing: 12, alignment: .top)]

    var body: some View {
        switch phase {
        case .loading:
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(0 ..< 9, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondary.opacity(0.12))
                        .aspectRatio(TCGCardCell.cardAspectRatio, contentMode: .fit)
                }
            }
            .accessibilityLabel("Loading cards…")

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
            ContentUnavailableView {
                Label(emptyTitle, systemImage: "rectangle.stack.badge.minus")
            } description: {
                Text(emptyMessage)
            }

        case .loaded(let cards):
            VStack(alignment: .leading, spacing: 12) {
                Text("\(cards.count) cards")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(cards) { card in
                        NavigationLink(value: card) {
                            TCGCardCell(card: card, showsSetName: showsSetName)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct TCGCardCell: View {
    static let cardAspectRatio: CGFloat = 0.716
    let card: TCGCardBrief
    var showsSetName = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            CardThumbnail(card: card, cornerRadius: 6)

            if showsSetName {
                Text(card.setName ?? card.setId)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text(card.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Text("#\(card.localId)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(card.name), \(card.setName ?? card.setId), number \(card.localId)")
        .accessibilityAddTraits(.isButton)
    }
}

/// Small card image with a placeholder for cards that have no image yet.
struct CardThumbnail: View {
    let card: TCGCardBrief
    var cornerRadius: CGFloat = 6

    var body: some View {
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
                            RoundedRectangle(cornerRadius: cornerRadius).fill(Color.secondary.opacity(0.12))
                            ProgressView()
                        }
                    }
                }
            } else {
                placeholder
            }
        }
        .aspectRatio(TCGCardCell.cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.secondary.opacity(0.12))
            Image(systemName: "photo")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            CardGrid(phase: .loaded(PreviewData.cards), onRetry: {})
                .padding()
        }
    }
}
