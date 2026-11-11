//
//  AboutView.swift
//  PokedexPTC
//

import SwiftUI

struct AboutView: View {
    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.tint)
                    Text(AppInfo.name)
                        .font(.title2.bold())
                    Text("Track your trading card collection and what it's worth.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)

            Section("Disclaimer") {
                Text("\(AppInfo.name) is an unofficial, fan-made app. It is not affiliated with, endorsed, sponsored or approved by Nintendo, Creatures Inc., GAME FREAK inc. or The Pokémon Company.")
                Text("Pokémon and all related names are trademarks of their respective owners. Card names, text and images are © their respective owners and are shown for identification only.")
            }
            .font(.callout)

            Section {
                Link(destination: AppInfo.dataSourceURL) {
                    LabeledContent("Card data", value: "TCGdex")
                }
                LabeledContent("Prices", value: "TCGplayer · Cardmarket")
            } header: {
                Text("Data sources")
            } footer: {
                Text("Prices are market estimates and may be out of date. They are not an offer to buy or sell.")
            }

            Section {
                Label("Your collection is stored only on this device. The app has no accounts and collects no personal data.",
                      systemImage: "lock.shield")
                    .font(.callout)
            } header: {
                Text("Privacy")
            }

            Section {
                LabeledContent("Version", value: version)
            }
        }
        .navigationTitle("About")
    }
}

enum AppInfo {
    static var name: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Holo Vault"
    }

    static let dataSourceURL = URL(string: "https://tcgdex.dev")!
}

#Preview {
    NavigationStack { AboutView() }
}
