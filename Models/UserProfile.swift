//
//  UserProfile.swift
//  mobile
//
//  Core Data UserProfile entity
//

import Foundation
import CoreData

@objc(UserProfile)
public class UserProfile: NSManagedObject {
    
}

extension UserProfile {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }
    
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var hasCompletedOnboarding: Bool
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var id: UUID?
    @NSManaged public var avatarURL: String?
    
}

extension UserProfile : Identifiable {
    
}
