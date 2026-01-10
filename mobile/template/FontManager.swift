//
//  FontManager.swift
//  mobile
//
//  Custom font management - matches web fonts (Kode Mono, Outfit, Russo One)
//

import SwiftUI

// MARK: - Custom Font Names

enum AppFont {
    // Kode Mono - for prices, data, monospace text
    static let kodeMono = "KodeMono-Regular"
    static let kodeMonoMedium = "KodeMono-Medium"
    static let kodeMonoSemiBold = "KodeMono-SemiBold"
    static let kodeMonoBold = "KodeMono-Bold"
    
    // Outfit - main body font (variable font)
    static let outfit = "Outfit-Regular"
    
    // Russo One - display/heading font
    static let russoOne = "RussoOne-Regular"
}

// MARK: - Font Extension

extension Font {
    // Kode Mono (monospace for prices/data)
    static func kodeMono(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = AppFont.kodeMonoBold
        case .semibold:
            fontName = AppFont.kodeMonoSemiBold
        case .medium:
            fontName = AppFont.kodeMonoMedium
        default:
            fontName = AppFont.kodeMono
        }
        return .custom(fontName, size: size)
    }
    
    // Outfit (body text) - using variable font
    static func outfit(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Variable font - use custom with weight modifier
        return .custom("Outfit", size: size).weight(weight)
    }
    
    // Russo One (display/headings)
    static func russoOne(size: CGFloat) -> Font {
        .custom(AppFont.russoOne, size: size)
    }
}

// MARK: - UIFont Extension (for UIKit components)

extension UIFont {
    static func kodeMono(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = AppFont.kodeMonoBold
        case .semibold:
            fontName = AppFont.kodeMonoSemiBold
        case .medium:
            fontName = AppFont.kodeMonoMedium
        default:
            fontName = AppFont.kodeMono
        }
        return UIFont(name: fontName, size: size) ?? .monospacedSystemFont(ofSize: size, weight: weight)
    }
    
    static func outfit(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        // Try variable font first
        if let font = UIFont(name: "Outfit", size: size) {
            let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight]
            let descriptor = font.fontDescriptor.addingAttributes([.traits: traits])
            return UIFont(descriptor: descriptor, size: size)
        }
        return .systemFont(ofSize: size, weight: weight)
    }
    
    static func russoOne(size: CGFloat) -> UIFont {
        UIFont(name: AppFont.russoOne, size: size) ?? .systemFont(ofSize: size, weight: .bold)
    }
}

// MARK: - Debug Helper

struct FontDebugView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Available Fonts")
                    .font(.headline)
                
                ForEach(UIFont.familyNames.sorted(), id: \.self) { family in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(family)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(UIFont.fontNames(forFamilyName: family), id: \.self) { name in
                            Text(name)
                                .font(.custom(name, size: 14))
                        }
                    }
                }
            }
            .padding()
        }
    }
}

/*
 SETUP INSTRUCTIONS:
 
 1. Download font files (.ttf or .otf):
    - Kode Mono: https://fonts.google.com/specimen/Kode+Mono
    - Outfit: https://fonts.google.com/specimen/Outfit
    - Russo One: https://fonts.google.com/specimen/Russo+One
 
 2. Add font files to the Fonts folder:
    /mobile/mobile/Fonts/
    ├── KodeMono-Regular.ttf
    ├── KodeMono-Medium.ttf
    ├── KodeMono-Bold.ttf
    ├── Outfit-Regular.ttf
    ├── Outfit-Medium.ttf
    ├── Outfit-SemiBold.ttf
    ├── Outfit-Bold.ttf
    └── RussoOne-Regular.ttf
 
 3. In Xcode, add the Fonts folder to your project:
    - Right-click on mobile folder → Add Files to "mobile"
    - Select the Fonts folder
    - Check "Copy items if needed"
    - Check "Create folder references"
    - Check your target in "Add to targets"
 
 4. Add to Info.plist (in Xcode: Target → Info → Custom iOS Target Properties):
    Add key: "Fonts provided by application" (UIAppFonts)
    Add items:
    - KodeMono-Regular.ttf
    - KodeMono-Medium.ttf
    - KodeMono-Bold.ttf
    - Outfit-Regular.ttf
    - Outfit-Medium.ttf
    - Outfit-SemiBold.ttf
    - Outfit-Bold.ttf
    - RussoOne-Regular.ttf
 
 5. Verify fonts are loaded by using FontDebugView() in a preview
    or checking the console for font names.
 
 6. Use fonts in SwiftUI:
    Text("Price: 1.2345")
        .font(.kodeMono(size: 12))
    
    Text("Welcome")
        .font(.outfit(size: 16, weight: .medium))
    
    Text("RTHMN")
        .font(.russoOne(size: 24))
 */
