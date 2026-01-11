//
//  FavoritesService.swift
//  mobile
//
//  Manages user favorites from Supabase
//

import Foundation
import Combine
import Supabase

struct UserFavorite: Codable {
    let pair: String
    let position: Int
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case pair
        case position
        case userId = "user_id"
    }
}

struct InsertFavorite: Encodable {
    let userId: String
    let pair: String
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case pair
        case position
    }
}

@MainActor
class FavoritesService: ObservableObject {
    static let shared = FavoritesService()
    
    @Published var favorites: [String] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private init() {}
    
    func fetchFavorites() async {
        isLoading = true
        error = nil
        
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            let response: [UserFavorite] = try await supabase
                .from("user_favorites")
                .select("pair, position, user_id")
                .eq("user_id", value: userId.uuidString)
                .order("position")
                .execute()
                .value
            
            self.favorites = response.map { $0.pair }
            print("Fetched \(favorites.count) favorites: \(favorites)")
        } catch {
            self.error = error.localizedDescription
            print("Error fetching favorites: \(error)")
            self.favorites = []
        }
        
        isLoading = false
    }
    
    func addFavorite(_ pair: String) async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            let lastPosition = favorites.count
            let insert = InsertFavorite(
                userId: userId.uuidString,
                pair: pair.uppercased().trimmingCharacters(in: .whitespaces),
                position: lastPosition
            )
            
            try await supabase
                .from("user_favorites")
                .insert(insert)
                .execute()
            
            favorites.append(pair.uppercased())
        } catch {
            print("Error adding favorite: \(error)")
        }
    }
    
    func removeFavorite(_ pair: String) async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            try await supabase
                .from("user_favorites")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .eq("pair", value: pair.uppercased().trimmingCharacters(in: .whitespaces))
                .execute()
            
            favorites.removeAll { $0.uppercased() == pair.uppercased() }
        } catch {
            print("Error removing favorite: \(error)")
        }
    }
    
    func reorderFavorites(_ newOrder: [String]) async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id
            
            // Delete all existing
            try await supabase
                .from("user_favorites")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .execute()
            
            // Insert new order
            let inserts = newOrder.enumerated().map { index, pair in
                InsertFavorite(
                    userId: userId.uuidString,
                    pair: pair.uppercased().trimmingCharacters(in: .whitespaces),
                    position: index
                )
            }
            
            if !inserts.isEmpty {
                try await supabase
                    .from("user_favorites")
                    .insert(inserts)
                    .execute()
            }
            
            self.favorites = newOrder
        } catch {
            print("Error reordering favorites: \(error)")
        }
    }
}
