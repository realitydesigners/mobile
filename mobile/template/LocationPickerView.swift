//
//  LocationPickerView.swift
//  AppTemplate
//
//  Location picker with search - reusable across apps
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedCity: String
    @Binding var selectedCountry: String
    
    @StateObject private var locationService = LocationService.shared
    @StateObject private var searchCompleter = LocationSearchCompleter()
    
    @State private var searchText = ""
    @State private var showingPermissionAlert = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background1
                    .ignoresSafeArea()
                
                EtherealBackgroundView()
                
                VStack(spacing: 0) {
                    searchBar
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            currentLocationButton
                            
                            if let error = locationService.error {
                                errorMessage(error)
                            }
                            
                            if !searchCompleter.suggestions.isEmpty {
                                searchResults
                            } else if !searchText.isEmpty && !searchCompleter.isSearching {
                                noResultsMessage
                            }
                            
                            if searchText.isEmpty && searchCompleter.suggestions.isEmpty {
                                popularCities
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                }
                
                if !selectedCity.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            selectedCity = ""
                            selectedCountry = ""
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
            .alert("Location Access", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enable location in Settings to use this feature.")
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textMuted)
            
            TextField("", text: $searchText, prompt: Text("Search city").foregroundColor(AppTheme.textMuted))
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textPrimary)
                .focused($isSearchFocused)
                .onChange(of: searchText) { _, newValue in
                    searchCompleter.search(query: newValue)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    searchCompleter.clear()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            
            if searchCompleter.isSearching {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
        )
        .padding(20)
    }
    
    // MARK: - Current Location Button
    
    private var currentLocationButton: some View {
        Button(action: requestCurrentLocation) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.celestialBlue.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    if locationService.isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "location")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.celestialBlue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Current location")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Use device location")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(AppTheme.textMuted)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(16)
            .glass(intensity: 0.05, cornerRadius: 16)
        }
        .disabled(locationService.isLoading)
    }
    
    // MARK: - Error Message
    
    private func errorMessage(_ error: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.starlightGold)
            
            Text(error)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            if error.contains("denied") {
                Button("Settings") {
                    showingPermissionAlert = true
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.celestialBlue)
            }
        }
        .padding(14)
        .background(AppTheme.starlightGold.opacity(0.08))
        .cornerRadius(12)
    }
    
    // MARK: - Search Results
    
    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Results")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .textCase(.uppercase)
                .tracking(1)
                .padding(.leading, 4)
            
            VStack(spacing: 1) {
                ForEach(searchCompleter.suggestions.prefix(8), id: \.self) { suggestion in
                    Button(action: {
                        selectSuggestion(suggestion)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.twilightPurple)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.title)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(AppTheme.textMuted)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(14)
                    }
                    
                    if suggestion != searchCompleter.suggestions.prefix(8).last {
                        Divider()
                            .background(Color.white.opacity(0.05))
                    }
                }
            }
            .glass(intensity: 0.04, cornerRadius: 16)
        }
    }
    
    // MARK: - No Results
    
    private var noResultsMessage: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(AppTheme.textMuted)
            
            Text("No locations found")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Popular Cities
    
    private var popularCities: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .textCase(.uppercase)
                .tracking(1)
                .padding(.leading, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(popularCitiesList, id: \.city) { location in
                    Button(action: {
                        selectLocation(city: location.city, country: location.country)
                    }) {
                        HStack(spacing: 8) {
                            Text(location.flag)
                                .font(.system(size: 14))
                            Text(location.city)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                        }
                        .padding(14)
                        .glass(intensity: 0.04, cornerRadius: 12)
                    }
                }
            }
        }
    }
    
    private var popularCitiesList: [(city: String, country: String, flag: String)] {
        [
            ("New York", "United States", "🇺🇸"),
            ("Los Angeles", "United States", "🇺🇸"),
            ("London", "United Kingdom", "🇬🇧"),
            ("Paris", "France", "🇫🇷"),
            ("Tokyo", "Japan", "🇯🇵"),
            ("Sydney", "Australia", "🇦🇺"),
            ("Toronto", "Canada", "🇨🇦"),
            ("Berlin", "Germany", "🇩🇪"),
        ]
    }
    
    // MARK: - Actions
    
    private func requestCurrentLocation() {
        locationService.requestCurrentLocation { city, country in
            if let city = city {
                selectLocation(city: city, country: country ?? "")
            }
        }
    }
    
    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        searchCompleter.getLocationDetails(from: suggestion) { city, country in
            if let city = city {
                selectLocation(city: city, country: country ?? "")
            }
        }
    }
    
    private func selectLocation(city: String, country: String) {
        selectedCity = city
        selectedCountry = country
        dismiss()
    }
}

#Preview {
    LocationPickerView(selectedCity: .constant(""), selectedCountry: .constant(""))
}
