//
//  TypeEffectivenessTests.swift
//  PokedexPTCTests
//

import Testing
@testable import PokedexPTC

@Suite("Type effectiveness")
struct TypeEffectivenessTests {
    // Real PokeAPI relations (subset) for Ground and Rock.
    let ground = Fixture.typeInfo("ground",
                                  doubleFrom: ["water", "grass", "ice"],
                                  halfFrom: ["poison", "rock"],
                                  noneFrom: ["electric"],
                                  doubleTo: ["fire", "electric"])
    let rock = Fixture.typeInfo("rock",
                                doubleFrom: ["water", "grass", "fighting", "ground", "steel"],
                                halfFrom: ["normal", "fire", "poison", "flying"],
                                doubleTo: ["fire", "ice"])

    @Test("Dual types multiply: Ground makes it immune to Electric, Water/Grass become ×4")
    func dualType() {
        let result = TypeEffectiveness(defendingTypes: [ground, rock])

        #expect(result.defensive["electric"] == 0)
        #expect(result.defensive["water"] == 4)
        #expect(result.defensive["grass"] == 4)
        #expect(result.defensive["poison"] == 0.25)
        #expect(result.defensive["fire"] == 0.5)
        // Ground resists Rock (½); Rock is weak to Ground (×2) and Ground does not modify it.
        #expect(result.defensive["rock"] == 0.5)
        #expect(result.defensive["ground"] == 2)
        #expect(result.strongAgainst == ["electric", "fire", "ice"])
    }

    @Test("Opposite modifiers cancel out and are not listed")
    func cancellation() {
        let a = Fixture.typeInfo("a", doubleFrom: ["fire"])
        let b = Fixture.typeInfo("b", halfFrom: ["fire"])
        let result = TypeEffectiveness(defendingTypes: [a, b])
        #expect(result.defensive["fire"] == nil)
        #expect(result.isEmpty)
    }

    @Test("Groups are sorted from most to least damage")
    func groupsOrder() {
        let groups = TypeEffectiveness(defendingTypes: [ground, rock]).groups.map(\.multiplier)
        #expect(groups == [4, 2, 0.5, 0.25, 0])
    }

    @Test("Multiplier labels", arguments: [(0.0, "0×"), (0.25, "¼×"), (0.5, "½×"), (2.0, "2×"), (4.0, "4×")])
    func labels(multiplier: Double, label: String) {
        #expect(TypeEffectiveness.label(for: multiplier) == label)
    }
}
