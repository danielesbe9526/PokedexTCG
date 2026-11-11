//
//  EnergyIcons.swift
//  PokedexPTC
//
//  Original energy badges built from SF Symbols and flat colors, so the app ships no third-party artwork.
//

import SwiftUI

struct EnergyIcons: View {
    let types: [String]
    var size: CGFloat = 18

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(types.enumerated()), id: \.offset) { _, type in
                EnergyBadge(type: type, size: size)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(types.joined(separator: ", "))
    }
}

struct EnergyBadge: View {
    let type: String
    var size: CGFloat = 18

    var body: some View {
        let style = Self.style(for: type)
        Image(systemName: style.symbol)
            .font(.system(size: size * 0.52, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(style.color.gradient, in: Circle())
    }

    static func style(for type: String) -> (symbol: String, color: Color) {
        switch type {
        case "Grass": ("leaf.fill", Color(hex: 0x5FA645))
        case "Fire": ("flame.fill", Color(hex: 0xE0622A))
        case "Water": ("drop.fill", Color(hex: 0x3A8BD6))
        case "Lightning": ("bolt.fill", Color(hex: 0xE8B820))
        case "Psychic": ("eye.fill", Color(hex: 0x9C4FC4))
        case "Fighting": ("hand.raised.fill", Color(hex: 0xB0552E))
        case "Darkness": ("moon.fill", Color(hex: 0x3D4552))
        case "Metal": ("shield.fill", Color(hex: 0x8A97A6))
        case "Fairy": ("sparkles", Color(hex: 0xD9629E))
        case "Dragon": ("tornado", Color(hex: 0x9E8A2E))
        default: ("star.fill", Color(hex: 0xA3A3A3))
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

#Preview {
    EnergyIcons(types: ["Grass", "Fire", "Water", "Lightning", "Psychic", "Fighting",
                        "Darkness", "Metal", "Fairy", "Dragon", "Colorless"], size: 28)
}
