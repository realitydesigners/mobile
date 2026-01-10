//
//  PairResoBox.swift
//  mobile
//
//  Main pair visualization component that handles view modes and data
//

import SwiftUI

struct PairResoBox: View {
    let pair: String
    let boxSlice: BoxSlice?
    let isLoading: Bool
    let signal: Signal?
    
    @EnvironmentObject var dashboardProvider: DashboardProvider
    @State private var startIndex: Int = 0
    @State private var maxBoxCount: Int = 15
    @State private var viewMode: ViewMode = .default
    
    enum ViewMode: String, CaseIterable {
        case `default` = "default"
        case ryver = "ryver"
        case threeD = "3d"
        case line = "line"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(pair)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                if let price = dashboardProvider.getCurrentPrice(for: pair) {
                    Text(formatPrice(price))
                        .font(.system(size: 12, weight: .light, design: .monospaced))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Main visualization
            if isLoading {
                loadingView
            } else if let filteredSlice = filteredBoxSlice {
                visualizationView(slice: filteredSlice)
            } else {
                emptyView
            }
            
            // Range slider (only in default mode)
            if viewMode == .default {
                RangeSlider(
                    value: Binding(
                        get: { Double(startIndex) },
                        set: { startIndex = Int($0) }
                    ),
                    range: 0...Double(max(0, (boxSlice?.boxes.count ?? 0) - maxBoxCount)),
                    step: 1
                )
                .frame(height: 44)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
    
    private var filteredBoxSlice: BoxSlice? {
        guard let slice = boxSlice, !slice.boxes.isEmpty else { return nil }
        
        let endIndex = min(startIndex + maxBoxCount, slice.boxes.count)
        guard startIndex < slice.boxes.count else { return nil }
        let filteredBoxes = Array(slice.boxes[startIndex..<endIndex])
        
        return BoxSlice(
            timestamp: slice.timestamp,
            boxes: filteredBoxes
        )
    }
    
    @ViewBuilder
    private func visualizationView(slice: BoxSlice) -> some View {
        switch viewMode {
        case .default:
            ResoBox(slice: slice, pair: pair, showPriceLines: true, signal: signal)
                .padding(16)
        case .threeD:
            ResoBox3D(slice: slice, pair: pair, signal: signal)
                .padding(16)
        case .line:
            ResoLineChart(slice: slice, pair: pair)
                .padding(16)
        case .ryver:
            HStack(spacing: 16) {
                // Ryver chart placeholder
                Text("Ryver Chart")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textMuted)
                    .frame(maxWidth: .infinity)
                
                ResoBox(slice: slice, pair: pair, showPriceLines: false, signal: signal)
                    .frame(width: 100, height: 100)
            }
            .padding(16)
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.3)
            
            ProgressView()
                .tint(AppTheme.pearl)
        }
        .frame(height: 200)
        .cornerRadius(12)
        .padding(16)
    }
    
    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.textMuted)
            
            Text("No data available")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textMuted)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .padding(16)
    }
    
    private func formatPrice(_ price: Double) -> String {
        if pair.contains("JPY") {
            return String(format: "%.2f", price)
        } else if pair.contains("USD") || pair.contains("EUR") || pair.contains("GBP") {
            return String(format: "%.5f", price)
        } else {
            return String(format: "%.8f", price)
        }
    }
}

// MARK: - Range Slider

struct RangeSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)
                
                // Thumb
                Circle()
                    .fill(AppTheme.pearl)
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * (geometry.size.width - 20))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = range.lowerBound + Double(gesture.location.x / geometry.size.width) * (range.upperBound - range.lowerBound)
                                value = min(max(newValue, range.lowerBound), range.upperBound)
                            }
                    )
            }
        }
    }
}
