//
//  ResoLineChart.swift
//  mobile
//
//  Line chart visualization for box data
//

import SwiftUI

struct ResoLineChart: View {
    let slice: BoxSlice
    let pair: String?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                Path { path in
                    guard !slice.boxes.isEmpty else { return }
                    
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    let maxValue = slice.boxes.map { max($0.high, $0.low) }.max() ?? 1
                    let minValue = slice.boxes.map { min($0.high, $0.low) }.min() ?? 0
                    let range = maxValue - minValue
                    
                    // High line
                    if let firstBox = slice.boxes.first {
                        let x = CGFloat(0)
                        let y = height - CGFloat((firstBox.high - minValue) / range) * height
                        path.move(to: CGPoint(x: x, y: y))
                    }
                    
                    for (index, box) in slice.boxes.enumerated() {
                        let x = CGFloat(index) / CGFloat(slice.boxes.count - 1) * width
                        let y = height - CGFloat((box.high - minValue) / range) * height
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color(hex: "7EB8DA"), lineWidth: 1.5)
                
                Path { path in
                    guard !slice.boxes.isEmpty else { return }
                    
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    let maxValue = slice.boxes.map { max($0.high, $0.low) }.max() ?? 1
                    let minValue = slice.boxes.map { min($0.high, $0.low) }.min() ?? 0
                    let range = maxValue - minValue
                    
                    // Low line
                    if let firstBox = slice.boxes.first {
                        let x = CGFloat(0)
                        let y = height - CGFloat((firstBox.low - minValue) / range) * height
                        path.move(to: CGPoint(x: x, y: y))
                    }
                    
                    for (index, box) in slice.boxes.enumerated() {
                        let x = CGFloat(index) / CGFloat(slice.boxes.count - 1) * width
                        let y = height - CGFloat((box.low - minValue) / range) * height
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color(hex: "9B8DC4"), lineWidth: 1.5)
            }
        }
    }
}
