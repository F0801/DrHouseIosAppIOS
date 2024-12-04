//
//  CustomTabBar.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 2/12/2024.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    let tab = TabItem(rawValue: index)!
                    if index == 2 { // AI tab in the middle
                        // Special AI Button
                        Button(action: { selectedTab = index }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 60, height: 60)
                                        .shadow(color: .black.opacity(0.2), radius: 5)
                                    
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                .offset(y: -20)
                                
                                Text(tab.title)
                                    .font(.caption2)
                                    .foregroundColor(selectedTab == index ? .blue : .gray)
                                    .offset(y: -20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        // Regular Tab Button
                        TabBarButton(
                            image: tab.icon,
                            text: tab.title,
                            isSelected: selectedTab == index
                        ) {
                            selectedTab = index
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(
                Color.white
                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: -5)
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarButton: View {
    let image: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: image)
                    .font(.system(size: 24))
                Text(text)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

