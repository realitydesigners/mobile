//
//  ResoBox.swift
//  mobile
//
//  2D nested box visualization component
//

import SwiftUI

struct ResoBox: View {
    let slice: BoxSlice
    let pair: String?
    let showPriceLines: Bool
    let signal: Signal?
    
    @State private var containerSize: CGFloat = 0
    
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
                    ResoBoxRecursive(
                        box: sortedBoxes[0],
                        index: 0,
                        prevBox: nil,
                        containerSize: min(geometry.size.width, geometry.size.height),
                        slice: slice,
                        sortedBoxes: sortedBoxes,
                        pair: pair,
                        showPriceLines: showPriceLines,
                        signal: signal
                    )
                }
            }
            .onAppear {
                containerSize = min(geometry.size.width, geometry.size.height)
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
    
    @State private var positiveColor = Color(hex: "7EB8DA")
    @State private var negativeColor = Color(hex: "9B8DC4")
    
    private var calculatedSize: CGFloat {
        containerSize * pow(0.86, CGFloat(index))
    }
    
    private var isFirstDifferent: Bool {
        guard let prevBox = prevBox else { return false }
        return (box.value > 0 && prevBox.value < 0) || (box.value < 0 && prevBox.value > 0)
    }
    
    private var position: BoxPosition {
        if prevBox == nil {
            return .topRight
        } else if isFirstDifferent {
            return prevBox!.value > 0 ? .topRight : .bottomRight
        } else {
            return box.value < 0 ? .bottomRight : .topRight
        }
    }
    
    private var boxColor: Color {
        box.value > 0 ? positiveColor : negativeColor
    }
    
    private var matchesSignal: Bool {
        guard let signal = signal, signal.isRecent, let pair = pair else { return false }
        return boxMatchesSignal(box, signal: signal, pair: pair)
    }
    
    var body: some View {
        ZStack(alignment: position.alignment) {
            // Box background
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black)
                .frame(width: calculatedSize, height: calculatedSize)
            
            // Box gradient
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            boxColor.opacity(0.71),
                            boxColor.opacity(0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: calculatedSize, height: calculatedSize)
            
            // Border
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black, lineWidth: 1)
                .frame(width: calculatedSize, height: calculatedSize)
            
            // Price lines
            if showPriceLines {
                priceLines
            }
            
            // Nested boxes
            if index < sortedBoxes.count - 1 {
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
                .offset(x: position.xOffset(size: calculatedSize), y: position.yOffset(size: calculatedSize))
            }
        }
    }
    
    @ViewBuilder
    private var priceLines: some View {
        let shouldLimitPriceLines = sortedBoxes.count > 18
        let shouldShowTopPrice = matchesSignal || 
            ((!isFirstDifferent || (isFirstDifferent && box.value > 0)) &&
             (!shouldLimitPriceLines || isFirstDifferent || index == 0))
        let shouldShowBottomPrice = matchesSignal ||
            ((!isFirstDifferent || (isFirstDifferent && box.value < 0)) &&
             (!shouldLimitPriceLines || isFirstDifferent || index == 0))
        
        if shouldShowTopPrice {
            VStack {
                HStack {
                    Spacer()
                    Text(formatPrice(box.high))
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(Color(hex: "808080"))
                        .offset(x: 40)
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
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundColor(Color(hex: "808080"))
                        .offset(x: 40)
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

// MARK: - Box Position Helper

enum BoxPosition {
    case topRight
    case bottomRight
    
    var alignment: Alignment {
        switch self {
        case .topRight: return .topTrailing
        case .bottomRight: return .bottomTrailing
        }
    }
    
    func xOffset(size: CGFloat) -> CGFloat {
        switch self {
        case .topRight, .bottomRight:
            return size * 0.14 * 0.5
        }
    }
    
    func yOffset(size: CGFloat) -> CGFloat {
        switch self {
        case .topRight:
            return -size * 0.14 * 0.5
        case .bottomRight:
            return size * 0.14 * 0.5
        }
    }
}
