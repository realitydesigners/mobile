//
//  ResoBox.swift
//  mobile
//
//  2D nested box visualization - matches web design system exactly
//

import SwiftUI

struct ResoBox: View {
    let slice: BoxSlice
    let pair: String?
    let showPriceLines: Bool
    let signal: Signal?
    
    init(slice: BoxSlice, pair: String? = nil, showPriceLines: Bool = true, signal: Signal? = nil) {
        self.slice = slice
        self.pair = pair
        self.showPriceLines = showPriceLines
        self.signal = signal
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                if !slice.boxes.isEmpty {
                    let sortedBoxes = sortBoxesByMagnitude(slice.boxes)
                    let size = min(geometry.size.width, geometry.size.height)
                    
                    ResoBoxRecursive(
                        box: sortedBoxes[0],
                        index: 0,
                        prevBox: nil,
                        containerSize: size,
                        slice: slice,
                        sortedBoxes: sortedBoxes,
                        pair: pair,
                        showPriceLines: showPriceLines,
                        signal: signal
                    )
                    .frame(width: size, height: size, alignment: .topTrailing)
                    .clipped()
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func sortBoxesByMagnitude(_ boxes: [Box]) -> [Box] {
        return boxes.sorted { abs($0.value) > abs($1.value) }
    }
}

// MARK: - Recursive Box Component

struct ResoBoxRecursive: View {
    let box: Box
    let index: Int
    let prevBox: Box?
    let containerSize: CGFloat
    let slice: BoxSlice
    let sortedBoxes: [Box]
    let pair: String?
    let showPriceLines: Bool
    let signal: Signal?
    
    // Default box colors matching web version exactly
    private let positiveColor = Color(hex: "24FF66")
    private let negativeColor = Color(hex: "303238")
    
    // Default styles matching web version exactly
    private let borderRadius: CGFloat = 4
    private let showBorder = true
    
    private var calculatedSize: CGFloat {
        containerSize * pow(0.86, CGFloat(index))
    }
    
    private var boxColor: Color {
        box.value > 0 ? positiveColor : negativeColor
    }
    
    private var matchesSignal: Bool {
        guard let signal = signal, signal.isRecent, let pair = pair else { return false }
        return boxMatchesSignal(box, signal: signal, pair: pair)
    }
    
    // Calculate where to position the NEXT (child) box within THIS box
    // This matches the web CSS positioning logic exactly:
    // positionStyle = !prevBox
    //   ? { top: 0, right: 0 }
    //   : isFirstDifferent
    //     ? prevBox.value > 0 ? { top: 0, right: 0 } : { bottom: 0, right: 0 }
    //     : box.value < 0 ? { bottom: 0, right: 0 } : { top: 0, right: 0 }
    private func getNextBoxYOffset() -> CGFloat {
        guard index < sortedBoxes.count - 1 else { return 0 }
        
        let nextBox = sortedBoxes[index + 1]
        let nextSize = containerSize * pow(0.86, CGFloat(index + 1))
        let currentBox = box  // This is prevBox for the next box
        
        // isFirstDifferent for the NEXT box (does next box have different sign than current?)
        let nextIsFirstDifferent = (nextBox.value > 0 && currentBox.value < 0) ||
                                   (nextBox.value < 0 && currentBox.value > 0)
        
        if nextIsFirstDifferent {
            // Use currentBox's sign (which is prevBox for the next box)
            if currentBox.value > 0 {
                // top: 0, right: 0 → top-right corner
                return 0
            } else {
                // bottom: 0, right: 0 → bottom-right corner
                return calculatedSize - nextSize
            }
        } else {
            // Use nextBox's sign
            if nextBox.value < 0 {
                // bottom: 0, right: 0 → bottom-right corner
                return calculatedSize - nextSize
            } else {
                // top: 0, right: 0 → top-right corner
                return 0
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Box background layer (pure black)
            RoundedRectangle(cornerRadius: borderRadius)
                .fill(Color.black)
            
            // Color fill layer (solid color, no gradient for now)
            RoundedRectangle(cornerRadius: borderRadius)
                .fill(boxColor)
            
            // Border
            if showBorder {
                RoundedRectangle(cornerRadius: borderRadius)
                    .stroke(Color.black, lineWidth: 1)
            }
            
            // Price lines
            if showPriceLines {
                priceLines
                    .frame(width: calculatedSize, height: calculatedSize)
            }
            
            // Nested boxes - positioned at corner using position()
            if index < sortedBoxes.count - 1 {
                let nextSize = containerSize * pow(0.86, CGFloat(index + 1))
                let isBottomPosition = getNextBoxYOffset() > 0
                
                // Position child at corner:
                // Top-right: child's top-right at parent's top-right
                // Bottom-right: child's bottom-right at parent's bottom-right
                let xPos = calculatedSize - nextSize / 2  // Right side
                let yPos = isBottomPosition 
                    ? calculatedSize - nextSize / 2  // Bottom
                    : nextSize / 2                    // Top
                
                ResoBoxRecursive(
                    box: sortedBoxes[index + 1],
                    index: index + 1,
                    prevBox: box,
                    containerSize: containerSize,
                    slice: slice,
                    sortedBoxes: sortedBoxes,
                    pair: pair,
                    showPriceLines: showPriceLines,
                    signal: signal
                )
                .position(x: xPos, y: yPos)
            }
        }
        .frame(width: calculatedSize, height: calculatedSize)
    }
    
    // isFirstDifferent for THIS box (used for price line logic)
    private var isFirstDifferent: Bool {
        guard let prevBox = prevBox else { return false }
        return (box.value > 0 && prevBox.value < 0) || (box.value < 0 && prevBox.value > 0)
    }
    
    @ViewBuilder
    private var priceLines: some View {
        let isConsecutivePositive = (prevBox?.value ?? 0) > 0 && box.value > 0 && !isFirstDifferent
        let isConsecutiveNegative = (prevBox?.value ?? 0) < 0 && box.value < 0 && !isFirstDifferent
        let shouldLimitPriceLines = sortedBoxes.count > 18
        
        let shouldShowTopPrice = matchesSignal || 
            ((!isFirstDifferent || (isFirstDifferent && box.value > 0)) &&
             (!shouldLimitPriceLines || isFirstDifferent || index == 0) &&
             !isConsecutivePositive)
        
        let shouldShowBottomPrice = matchesSignal ||
            ((!isFirstDifferent || (isFirstDifferent && box.value < 0)) &&
             (!shouldLimitPriceLines || isFirstDifferent || index == 0) &&
             !isConsecutiveNegative)
        
        if shouldShowTopPrice {
            VStack {
                HStack {
                    Spacer()
                    Text(formatPrice(box.high))
                        .font(.kodeMono(size: 7))
                        .foregroundColor(Color(hex: "808080"))
                        .offset(x: 40, y: -14)
                }
                Spacer()
            }
        }
        
        if shouldShowBottomPrice {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(formatPrice(box.low))
                        .font(.kodeMono(size: 7))
                        .foregroundColor(Color(hex: "808080"))
                        .offset(x: 40, y: 14)
                }
            }
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        guard let pair = pair else {
            return String(format: "%.5f", price)
        }
        
        if pair.contains("JPY") {
            return String(format: "%.2f", price)
        } else if pair.contains("USD") || pair.contains("EUR") || pair.contains("GBP") {
            return String(format: "%.5f", price)
        } else {
            return String(format: "%.8f", price)
        }
    }
    
    private func boxMatchesSignal(_ box: Box, signal: Signal, pair: String) -> Bool {
        guard !signal.patternSequence.isEmpty else { return false }
        
        let point: Double = pair.contains("JPY") ? 0.01 : 0.00001
        let boxIntegerValue = Int(round(box.value / point))
        
        guard signal.patternSequence.contains(boxIntegerValue) else { return false }
        
        if signal.signalType == "LONG" {
            return boxIntegerValue > 0
        } else if signal.signalType == "SHORT" {
            return boxIntegerValue < 0
        }
        
        return false
    }
}
