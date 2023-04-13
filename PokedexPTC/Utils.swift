//
//  Utils.swift
//  PokedexPTC
//
//  Created by Daniel Beltran on 12/04/23.
//

import Foundation
import UIKit

class Utils {
    static func getIconForType(type: String) -> UIImage? {
        switch type {
        case "Colorless":
            return UIImage(named: "Normal")
        case "Darkness":
            return UIImage(named: "Dark")
        case "Dragon":
            return UIImage(named: type)
        case "Fairy":
            return UIImage(named: type)
        case "Fighting":
            return UIImage(named: "Fight")
        case "Fire":
            return UIImage(named: type)
        case "Grass":
            return UIImage(named: type)
        case "Lightning":
            return UIImage(named: "Electric")
        case "Metal":
            return UIImage(named: "Steel")
        case "Psychic":
            return UIImage(named: type)
        case "Water":
            return UIImage(named: type)
        default:
            return UIImage(named: "normal")
        } 
    }
    
    static func getTagForType(type: String) -> UIImage? {
        switch type {
        case "normal":
            return UIImage(named: "TagNormal")
        case "fire":
            return UIImage(named: "TagFire")
        case "water":
            return UIImage(named: "TagWater")
        case "grass":
            return UIImage(named: "TagGrass")
        case "flying":
            return UIImage(named: "TagFlying")
        case "fighting":
            return UIImage(named: "TagFighting")
        case "poison":
            return UIImage(named: "TagPoison")
        case "electric":
            return UIImage(named: "TagElectric")
        case "ground":
            return UIImage(named: "TagGround")
        case "rock":
            return UIImage(named: "TagRock")
        case "psychic":
            return UIImage(named: "TagPsychic")
        case "ice":
            return UIImage(named: "TagIce")
        case "bug":
            return UIImage(named: "TagBug")
        case "ghost":
            return UIImage(named: "TagGhost")
        case "steel":
            return UIImage(named: "TagSteel")
        case "dragon":
            return UIImage(named: "TagDragon")
        case "dark":
            return UIImage(named: "TagDark")
        case "fairy":
            return UIImage(named: "TagFairy")
        default:
            return UIImage(named: "TagNormal")
        }
    }
    
    static func getColorForType(type: String) -> UIColor {
        switch type {
        case "Colorless":
            return UIColor.lightGray
        case "Darkness":
            return UIColor.init(hexString: "705746")
        case "Dragon":
            return UIColor.init(hexString: "6F35FC")
        case "Fairy":
            return UIColor.init(hexString: "D685AD")
        case "Fighting":
            return UIColor.init(hexString: "C22E28")
        case "Fire":
            return UIColor.init(hexString: "EE8130")
        case "Grass":
            return UIColor.init(hexString: "7AC74C")
        case "Lightning":
            return UIColor.init(hexString: "F7D02C")
        case "Metal":
            return UIColor.init(hexString: "B7B7CE")
        case "Psychic":
            return UIColor.init(hexString: "F95587")
        case "Water":
            return UIColor.init(hexString: "6390F0")
        default:
            return UIColor.init(hexString: "A8A77A")
        }
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
