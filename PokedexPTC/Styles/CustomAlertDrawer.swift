//
//  CustomAlertDrawer.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 30/03/25.
//

import SwiftUI

struct DrawerConfig {
    var tint: Color
    var foreground: Color
    var clipShape: AnyShape
    var animation: Animation
    
    fileprivate(set) var isPresented: Bool = false
    fileprivate(set) var hideSourceButton: Bool = false
    fileprivate(set) var sourceRect: CGRect = .zero
    
    init(tint: Color = .red, foreground: Color = .white, clipShape: AnyShape = .init(.capsule), animation: Animation = .snappy(duration: 0.35, extraBounce: 0.5)) {
        self.tint = tint
        self.foreground = foreground
        self.clipShape = clipShape
        self.animation = animation
    }
}

/// Drawer source button

struct DraweButton: View {
    var title: String
    @Binding var config: DrawerConfig
    
    var body: some View {
        Button {
            config.hideSourceButton = true

            withAnimation(config.animation) {
                config.isPresented = true
            }
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(config.foreground)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(config.tint, in: config.clipShape)
        }
        .buttonStyle(ScaledButtonStyle())
        .opacity(config.hideSourceButton ? 0 : 1)
        .onGeometryChange(for: CGRect.self) {
            $0.frame(in: .global)
        } action: { newValue in
            config.sourceRect = newValue
        }

    }
}

/// Custom Alert Drawer Overlay View
extension View {
    @ViewBuilder
    func alertDrawer<Content: View>(
        config: Binding<DrawerConfig>,
        primaryTitle: String,
        secondaryTitle: String,
        onPrimaryAction: @escaping () -> Bool,
        onSecondaryAction: @escaping () -> Bool,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                GeometryReader { geometry in
                    let isPresented = config.wrappedValue.isPresented
                    
                    ZStack {
                        if isPresented {
                            Rectangle()
                                .fill(.black.opacity(0.5))
                                .transition(.opacity)
                                .onTapGesture {
                                    withAnimation(config.wrappedValue.animation, completionCriteria: .logicallyComplete) {
                                        config.wrappedValue.isPresented = false
                                        config.wrappedValue.hideSourceButton = false
                                    } completion: {
//                                        config.wrappedValue.hideSourceButton = false
                                    }
                                }
                        }
                        
                        if config.wrappedValue.hideSourceButton {
                            AlertDrawerContent(proxy: geometry,
                                               primaryTitle: primaryTitle,
                                               secondaryTitle: secondaryTitle,
                                               onPrimaryClick: onPrimaryAction,
                                               onSecondaryClick: onSecondaryAction,
                                               config: config,
                                               content: content)
                            .transition(.identity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .offset(y: -75) // Navigation Bar
                        }
                    }
                    .ignoresSafeArea()
                }
            }
    }
}


fileprivate struct AlertDrawerContent<Content: View>: View {
    var proxy: GeometryProxy
    var primaryTitle: String
    var secondaryTitle: String
    var onPrimaryClick: () -> Bool
    var onSecondaryClick: () -> Bool
    
    @Binding var config: DrawerConfig
    @ViewBuilder var content: Content
    
    var body: some View {
        let isPresented = config.isPresented
        let sourceRect = config.sourceRect
        let maxY = proxy.frame(in: .global).maxY
        let bottomPadding: CGFloat = 70
        
        VStack(spacing: 15) {
            content
                .overlay(alignment: .topTrailing) {
                    Button(action: dismissDrawe) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.primary, .gray.opacity(0.15))
                    }
                }
                .compositingGroup()
                .opacity(isPresented ? 1 : 0)
            
            
            HStack(spacing: 15) {
                GeometryReader { geometry in
                    Button {
                        if onSecondaryClick() {
                            dismissDrawe()
                        }
                    } label: {
                        Text(secondaryTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial, in: config.clipShape)
                    }
                    .offset(fixedLocation(geometry))
                    .opacity(isPresented ? 1 : 0)
                }
                .frame(height: config.sourceRect.height)
                
                GeometryReader { geometry in
                    Button {
                        if onPrimaryClick() {
                            dismissDrawe()
                        }
                    } label: {
                        Text(primaryTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(config.foreground)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(config.tint, in: config.clipShape)
                    }
                    .frame(
                        width: isPresented ? nil : sourceRect.width,
                        height: isPresented ? nil : sourceRect.height
                    )
                    .offset(fixedLocation(geometry))
                }
                .frame(height: config.sourceRect.height)
                .zIndex(1)
            }
            .buttonStyle(ScaledButtonStyle())
            .padding(.top, 10)
        }
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 15)
        .frame(
            width: isPresented ? nil : sourceRect.width,
            height: isPresented ? nil : sourceRect.height,
            alignment: .top
        )
        .background(.background)
        .clipShape(.rect(cornerRadius: sourceRect.height / 2))
        .shadow(color: .black.opacity(isPresented ? 0.1 : 0), radius: 5, x: 5, y: 5)
        .shadow(color: .black.opacity(isPresented ? 0.1 : 0), radius: 5, x: -5, y: -5)
        .padding(.horizontal, isPresented ? 20 : 0)
        .visualEffect { content, proxy in
            content
                .offset(
                    x: isPresented ? 0 : sourceRect.minX,
                    y: (isPresented ? maxY - bottomPadding : sourceRect.maxY) - proxy.size.height
                )
        }
        .allowsTightening(config.hideSourceButton)
    }
    
    private func dismissDrawe() {
        withAnimation(config.animation, completionCriteria: .logicallyComplete) {
            config.isPresented = false
            config.hideSourceButton = false

        } completion: {
//            config.hideSourceButton = false
        }
    }
    
    private func fixedLocation(_ proxy: GeometryProxy) -> CGSize {
        let isPresented = config.isPresented
        let sourceRect = config.sourceRect
        
        return CGSize(
            width: isPresented ? 0 : (sourceRect.minX - proxy.frame(in: .global).minX),
            height: isPresented ? 0 : (sourceRect.minY - proxy.frame(in: .global).maxY)
        )
    }
}

/// Custom Button Style

fileprivate struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}


struct AlertDrawerContent_Previews: PreviewProvider {
    static let pokemon1 = PokemonDetail(height: 123,
                                id: 1,
                                isDefault: true,
                                name: "magnemite",
                                order: 1,
                                sprites: Sprites(backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 other: nil),
                                stats: [Stat(baseStat: 1, effort: 1, stat: Species(name: "species", url: ""))],
                                types: [TypeElement(slot: 1, type: Species(name: "species", url: ""))],
                                weight: 123)
    
    static let pokemon2 = PokemonDetail(height: 123,
                                id: 2,
                                isDefault: true,
                                name: "magnemite2",
                                order: 1,
                                sprites: Sprites(backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 other: nil),
                                stats: [Stat(baseStat: 1, effort: 1, stat: Species(name: "species", url: ""))],
                                types: [TypeElement(slot: 1, type: Species(name: "species", url: ""))],
                                weight: 123)
    static let pokemon3 = PokemonDetail(height: 123,
                                id: 3,
                                isDefault: true,
                                name: "magnemite3",
                                order: 1,
                                sprites: Sprites(backDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 backShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShiny: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 frontShinyFemale: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/35.png",
                                                 other: nil),
                                stats: [Stat(baseStat: 1, effort: 1, stat: Species(name: "species", url: ""))],
                                types: [TypeElement(slot: 1, type: Species(name: "species", url: ""))],
                                weight: 123)

    static var previews: some View {
        ContentView(viewModel: PokedexViewModel(pokemonsDetails:[pokemon1, pokemon2, pokemon3]))
    }
}
