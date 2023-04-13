//
//  CardDetail.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 12/04/23.
//

import SwiftUI

struct CardDetail: View {
    let card: Datum
    
    var body: some View {
//        NavigationView {
            VStack {
                Form {
                    VStack {
                        AsyncImage(url: URL(string: card.images.small)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 400, height: 400)
                        
                        HStack {
                            Text("id: \(card.id)")
                                .font(.system(size: 12,weight: .thin, design: .rounded))
                                .padding(.horizontal)
                            
                            Text("\(card.number)/\(card.datumSet.printedTotal)")
                                .font(.system(size: 12,weight: .thin, design: .rounded))
                                .padding(.horizontal)
                        }
                    }
                    
                    Section("Profile") {
                        HStack {
                            Text(card.supertype ?? "")
                                .font(.system(size: 18, design: .monospaced))
                                .foregroundColor(.black)
                            if let subtypes = card.subtypes {
                                ForEach(subtypes, id: \.self) { type in
                                    Text(type)
                                        .font(.system(size: 16, weight: .light))
                                }
                            }
                            Spacer()
                            Text("HP \(card.hp ?? "")")
                                .font(.system(size: 18, design: .monospaced))
                            iconType(types: card.types)
                                .padding()
                        }
                    }
                    
                    Section("Prices") {
                        VStack {
                            HStack {
                                Spacer()
                                Text("From TCGplayer")
                                    .font(.system(size: 24,weight: .semibold))
                                    .padding(.vertical)
                                Spacer()
                            }
                            
                            // HOLOFOILD
                            VStack {
                                Text("HoloFoild")
                                    .font(.system(size: 16, weight: .none, design: .none))
                                HStack {
                                    VStack {
                                        Text("Market")
                                            .font(.system(size: 14, weight: .light, design: .monospaced))
                                        Text("$\(card.tcgplayer?.prices.holofoil?.market ?? 0.0 , specifier: "%.2f")")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16, weight: .light, design: .monospaced))
                                    }
                                    Spacer()
                                    VStack {
                                        Text("low")
                                            .font(.system(size: 14, weight: .light, design: .monospaced))
                                        Text("$\(card.tcgplayer?.prices.holofoil?.low ?? 0.0 , specifier: "%.2f")")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16, weight: .light, design: .monospaced))
                                    }
                                    Spacer()
                                    VStack {
                                        Text("Mid")
                                            .font(.system(size: 14, weight: .light, design: .monospaced))
                                        Text("$\(card.tcgplayer?.prices.holofoil?.mid ?? 0.0 , specifier: "%.2f")")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16, weight: .light, design: .monospaced))
                                    }
                                    Spacer()
                                    VStack {
                                        Text("High")
                                            .font(.system(size: 14, weight: .light, design: .monospaced))
                                        Text("$\(card.tcgplayer?.prices.holofoil?.high ?? 0.0 , specifier: "%.2f")")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16, weight: .light, design: .monospaced))
                                    }
                                }
                            }.padding()
                            
                            // Reversed HoloFoild
                            VStack {
                                Text("Reverse HoloFoild")
                                    .font(.system(size: 16, weight: .none, design: .none))
                                
                                HStack {
                                    VStack {
                                        Text("Market")
                                            .font(.system(size: 14, weight: .light, design: .none))

                                        Text("$\(card.tcgplayer?.prices.reverseHolofoil?.market ?? 0.0 , specifier: "%.2f")")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16, weight: .light, design: .none))
                                    }
                                    Spacer()
                                    VStack {
                                        Text("low")
                                            .font(.system(size: 14, weight: .light, design: .none))
                                        Text("$\(card.tcgplayer?.prices.reverseHolofoil?.low ?? 0.0 , specifier: "%.2f")")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16, weight: .light, design: .none))
                                    }
                                    Spacer()
                                    VStack {
                                        Text("Mid")
                                            .font(.system(size: 14, weight: .light, design: .none))
                                        Text("$\(card.tcgplayer?.prices.reverseHolofoil?.mid ?? 0.0 , specifier: "%.2f")")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16, weight: .light, design: .none))
                                    }
                                    Spacer()
                                    VStack {
                                        Text("High")
                                            .font(.system(size: 14, weight: .light, design: .none))
                                        Text("$\(card.tcgplayer?.prices.reverseHolofoil?.high ?? 0.0 , specifier: "%.2f")")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16, weight: .light, design: .none))
                                    }
                                }
                            }.padding()
                            
                            VStack {
                                Text("From CardMarket")
                                    .font(.system(size: 16, weight: .none, design: .none))
                                
                                VStack {
                                    HStack {
                                        VStack {
                                            Text("Price Trend")
                                                .font(.system(size: 14, weight: .light, design: .monospaced))
                                            Text("\(card.cardmarket?.prices["averageSellPrice"] ?? 0.0, specifier: "%.2f")€")
                                                .foregroundColor(.brown)
                                                .font(.system(size: 16, weight: .light, design: .monospaced))

                                        }
                                        Spacer()
                                        VStack {
                                            Text("1 avg")
                                                .font(.system(size: 14, weight: .light, design: .monospaced))
                                            Text("\(card.cardmarket?.prices["avg1"] ?? 0.0, specifier: "%.2f")€")
                                                .foregroundColor(.brown)
                                                .font(.system(size: 16, weight: .light, design: .monospaced))
                                        }
                                        Spacer()
                                        VStack {
                                            Text("7 avg")
                                                .font(.system(size: 14, weight: .light, design: .monospaced))
                                            Text("\(card.cardmarket?.prices["avg7"] ?? 0.0, specifier: "%.2f")€")
                                                .foregroundColor(.brown)
                                                .font(.system(size: 16, weight: .light, design: .monospaced))
                                        }
                                        Spacer()
                                        VStack {
                                            Text("30 avg")
                                                .font(.system(size: 14, weight: .light, design: .monospaced))
                                            Text("\(card.cardmarket?.prices["avg30"] ?? 0.0, specifier: "%.2f")€")
                                                .foregroundColor(.brown)
                                                .font(.system(size: 16, weight: .light, design: .monospaced))
                                        }
                                    }
                                }
                            }.padding()
                        }
                      
                    }
                    
                    Section("Attacks") {
                        if let attacks = card.attacks {
                            ForEach(attacks, id: \.name) { attack in
                                VStack {
                                    HStack {
                                        iconType(types: attack.cost)
                                        Text(attack.name)
                                            .font(.system(size: 20,weight: .semibold, design: .rounded))
                                        Spacer()
                                    }
                                    Text(attack.text)
                                        .font(.system(size: 14,weight: .none, design: .serif))

                                }
                            }
                        }
                        HStack {
                            VStack {
                                Text("WEAKNESS")
                                    .font(.system(size: 14, weight: .thin, design: .rounded))

                                weaknessesWith(values: card.weaknesses)
                            }
                            Spacer()
                            VStack {
                                Text("RESISTANCE")
                                    .font(.system(size: 14, weight: .thin, design: .rounded))
                                if let resistances = card.resistances, !resistances.isEmpty {
                                    weaknessesWith(values: resistances)
                                } else {
                                    Text("N/A")
                                        .font(.system(size: 18, weight: .thin, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .padding()
                                }
                            }
                            Spacer()
                            VStack {
                                Text("RETREAT COST")
                                    .font(.system(size: 14, weight: .thin, design: .rounded))
                                if let cost = card.retreatCost {
                                    iconType(types: cost)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        VStack {
                            Text("ARTIST")
                                .font(.system(size: 14, weight: .ultraLight, design: .monospaced))

                            Text(card.artist)
                                .font(.system(size: 12, weight: .ultraLight, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack {
                            Text("RARITY")
                                .font(.system(size: 14, weight: .ultraLight, design: .monospaced))
                            Text(card.rarity ?? "")
                                .font(.system(size: 12, weight: .ultraLight, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        VStack {
                            Text("SET")
                                .font(.system(size: 14, weight: .ultraLight, design: .monospaced))
                            Text(card.datumSet.name)
                                .font(.system(size: 12, weight: .ultraLight, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
//            .navigationTitle(card.name)
//            .navigationBarTitleDisplayMode(.inline)
//        }
    }
}

@ViewBuilder func iconType(types: [String]) -> some View {
    ForEach(types, id: \.self) { type in
        if let image = Utils.getIconForType(type: type) {
            Image(uiImage: image)
                .frame(width: 10, height: 10)
                .padding()
        } else {
            EmptyView()
        }
    }
}

@ViewBuilder func weaknessesWith(values: [Resistance]?) -> some View {
    if let values {
        ForEach(values, id: \.type) { value in
            HStack {
                iconType(types: [value.type])
                Text("\(value.value)")
            }
        }
        
    } else {
        EmptyView()
    }
}

struct CardDetail_Previews: PreviewProvider {
    static let card = APIService.shared.mockedDatum()!
    static var previews: some View {
        CardDetail(card: card)
    }
}
