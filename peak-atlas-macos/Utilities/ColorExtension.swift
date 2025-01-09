//
//  ColorExtension.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 07/11/24.
//

import SwiftUI

extension Color {
    
    static let rightBackgroundColor = Color.init(hex: "#141414", opacity: 0.7)
    static let leftBackgroundColor = Color.init(hex: "#050505", opacity: 0.5)
    static let transparent = Color.init(hex: "#050505", opacity: 0)
    static let arrayColor: [Color] = [Color.init(hex: "#06D8E5", opacity: 1),
                                      Color.init(hex: "#06E55F", opacity: 1),
                                      Color.init(hex: "#E506C1", opacity: 1),
                                      Color.init(hex: "#32a852", opacity: 1),
                                      Color.init(hex: "#00edd1", opacity: 1),
                                      Color.init(hex: "#cded00", opacity: 1),
                                      Color.init(hex: "#ff00fb", opacity: 1),
                                      Color.init(hex: "#fa0213", opacity: 1),
                                      Color.init(hex: "#fa5102", opacity: 1),
                                      Color.init(hex: "#07eb90", opacity: 1)]
    
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB
            (_, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: opacity
        )
    }
}

enum ColorType: String {
    case baseLeftColor
    case baseRightColor
    case fontColor
}

extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        
        self.init(red: red, green: green, blue: blue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Double(self.cgColor?.components?[0] ?? 0), forKey: .red)
        try container.encode(Double(self.cgColor?.components?[1] ?? 0), forKey: .green)
        try container.encode(Double(self.cgColor?.components?[2] ?? 0), forKey: .blue)
    }
    
    private enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
}

class ColorSingleton: ObservableObject {
    static let shared = ColorSingleton()
    
    func saveColor(selectedColor: Color, colorType: ColorType) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(selectedColor) {
            UserDefaults.standard.set(encoded, forKey: colorType.rawValue)
        }
    }
        
    // Load color from UserDefaults
    func fetchColor(colorType: ColorType) -> Color? {
        guard let colorData = UserDefaults.standard.data(forKey: colorType.rawValue) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(Color.self, from: colorData)
    }
}
