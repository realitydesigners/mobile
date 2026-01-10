//
//  SupabaseClient.swift
//  mobile
//
//  Supabase client singleton for auth and database access
//

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://mcyjrazlwwmqjyhwzhcm.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jeWpyYXpsd3dtcWp5aHd6aGNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU2NjQ3NzYsImV4cCI6MjA0MTI0MDc3Nn0.-h0l8Rsi-r6bej51HFGCljz0s-8D26slODPThU-pMM4"
    static let redirectURL = URL(string: "rthmn://auth/callback")!
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey
)
