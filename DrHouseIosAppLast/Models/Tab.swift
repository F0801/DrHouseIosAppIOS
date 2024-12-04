//
//  Tab.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 2/12/2024.
//

import Foundation
enum TabItem: Int {
    case home = 0
    case marketplace = 1
    case ai = 2
    case lifestyle = 3
    case profile = 4
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .marketplace: return "Market"
        case .ai: return "AI"
        case .lifestyle: return "Lifestyle"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .marketplace: return "cart.fill"
        case .ai: return "brain.head.profile" // or "wand.and.stars"
        case .lifestyle: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
}
