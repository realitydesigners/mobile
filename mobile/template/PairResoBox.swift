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
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(pair)
                    .font(.russoOne(size: 16))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                if let price = dashboardProvider.getCurrentPrice(for: pair) {
                    Text(formatPrice(price))
                        .font(.kodeMono(size: 12))
                        .foregroundColor(.white)
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
            
            // Range slider
            if let totalCount = boxSlice?.boxes.count, totalCount > 0 {
                BoxRangeSlider(
                    startIndex: $startIndex,
                    visibleCount: $maxBoxCount,
                    totalCount: totalCount
                )
                .frame(height: 68)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .background(Color.black)
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
        switch dashboardProvider.viewMode {
        case .twoD:
            ResoBox(slice: slice, pair: pair, showPriceLines: true, signal: signal)
                .padding(16)
        case .threeD:
            ResoBox3D(slice: slice, pair: pair, signal: signal)
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
                .font(.outfit(size: 12))
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

// MARK: - View Mode Selector (Global)

struct ViewModeSelector: View {
    @Binding var viewMode: ViewMode
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewMode = mode
                    }
                } label: {
                    ZStack {
                        if viewMode == mode {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                        }
                        
                        Image(systemName: iconForMode(mode))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(viewMode == mode ? .white : Color(hex: "606878"))
                    }
                    .frame(width: 28, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "0A0B0D"))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    private func iconForMode(_ mode: ViewMode) -> String {
        switch mode {
        case .twoD:
            return "square.grid.2x2"
        case .threeD:
            return "cube"
        }
    }
}

// MARK: - Box Range Slider (matches web RangeSlider)

struct BoxRangeSlider: View {
    @Binding var startIndex: Int
    @Binding var visibleCount: Int
    let totalCount: Int
    
    @State private var dragMode: DragMode = .none
    @State private var dragStartOffset: CGFloat = 0
    @State private var initialStartIndex: Int = 0
    @State private var initialVisibleCount: Int = 0
    
    private let minVisibleCount = 2
    private let edgeHitZone: CGFloat = 16
    
    // Time scale labels matching web version
    private let timeScaleLabels = ["1M", "1W", "3D", "1D", "12H", "4H", "1H", "30m", "15m", "5m", "1m", "30s", "1s"]
    
    enum DragMode {
        case none
        case body
        case startEdge
        case endEdge
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Slider track
            sliderTrack
            
            // Labels below
            labelsView
        }
    }
    
    private var sliderTrack: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let unitWidth = trackWidth / CGFloat(totalCount)
            let selectionStart = CGFloat(startIndex) * unitWidth
            let selectionWidth = CGFloat(visibleCount) * unitWidth
            
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "070809"))
                    .frame(height: geometry.size.height)
                
                // Selection bar
                ZStack {
                    // Main selection background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "0A0B0D"),
                                    Color(hex: "070809")
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                    
                    // Inner gradient overlay
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "1d2025"),
                                    Color(hex: "16181c"),
                                    Color(hex: "1d2025")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(0.4)
                    
                    // Radial highlight
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: selectionWidth * 0.7
                            )
                        )
                    
                    // Start edge indicator
                    HStack {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white.opacity(dragMode == .startEdge ? 0.8 : 0.4))
                            .frame(width: 2)
                            .shadow(color: dragMode == .startEdge ? .white : .clear, radius: 6)
                        Spacer()
                    }
                    
                    // End edge indicator
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white.opacity(dragMode == .endEdge ? 0.8 : 0.4))
                            .frame(width: 2)
                            .shadow(color: dragMode == .endEdge ? .white : .clear, radius: 6)
                    }
                }
                .frame(width: selectionWidth, height: geometry.size.height)
                .offset(x: selectionStart)
                .shadow(color: Color.black.opacity(0.8), radius: 15)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if dragMode == .none {
                                // Determine drag mode based on touch location
                                let localX = value.startLocation.x - selectionStart
                                if localX < edgeHitZone {
                                    dragMode = .startEdge
                                } else if localX > selectionWidth - edgeHitZone {
                                    dragMode = .endEdge
                                } else {
                                    dragMode = .body
                                }
                                dragStartOffset = value.startLocation.x
                                initialStartIndex = startIndex
                                initialVisibleCount = visibleCount
                            }
                            
                            let delta = value.location.x - dragStartOffset
                            let indexDelta = Int(round(delta / unitWidth))
                            
                            switch dragMode {
                            case .body:
                                // Move the entire selection
                                let newStart = clamp(initialStartIndex + indexDelta, min: 0, max: totalCount - visibleCount)
                                startIndex = newStart
                                
                            case .startEdge:
                                // Resize from start
                                let newStart = clamp(initialStartIndex + indexDelta, min: 0, max: initialStartIndex + initialVisibleCount - minVisibleCount)
                                let newCount = initialVisibleCount - (newStart - initialStartIndex)
                                startIndex = newStart
                                visibleCount = clamp(newCount, min: minVisibleCount, max: totalCount - newStart)
                                
                            case .endEdge:
                                // Resize from end
                                let newCount = clamp(initialVisibleCount + indexDelta, min: minVisibleCount, max: totalCount - startIndex)
                                visibleCount = newCount
                                
                            case .none:
                                break
                            }
                        }
                        .onEnded { _ in
                            dragMode = .none
                        }
                )
            }
        }
        .frame(height: 36)
    }
    
    private var labelsView: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            
            ZStack(alignment: .leading) {
                ForEach(Array(timeScaleLabels.enumerated()), id: \.offset) { index, label in
                    let position = CGFloat(index) / CGFloat(timeScaleLabels.count - 1)
                    let labelValue = Int(position * CGFloat(totalCount))
                    let inRange = labelValue >= startIndex && labelValue <= startIndex + visibleCount
                    
                    VStack(spacing: 1) {
                        // Tick mark (dashed line)
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 0, height: 8)
                            .overlay(
                                Rectangle()
                                    .stroke(
                                        inRange ? Color.white.opacity(0.8) : Color.white.opacity(0.3),
                                        style: StrokeStyle(lineWidth: 1, dash: [2, 2])
                                    )
                                    .frame(width: 1)
                            )
                        
                        // Label text
                        Text(label)
                            .font(.kodeMono(size: 9))
                            .foregroundColor(inRange ? Color.white : Color(hex: "606878"))
                    }
                    .position(x: position * trackWidth, y: geometry.size.height / 2)
                }
            }
        }
        .frame(height: 24)
    }
    
    private func clamp(_ value: Int, min: Int, max: Int) -> Int {
        Swift.max(min, Swift.min(max, value))
    }
}
