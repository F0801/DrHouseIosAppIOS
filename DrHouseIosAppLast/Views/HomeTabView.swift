// HomeTabView.swift
import SwiftUI
import Foundation
struct HomeTabView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            Text("Home")
                .font(.title)
            
            Button(action: {
                viewModel.logout()
                navigationPath = NavigationPath()
            }) {
                Text("Logout")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }
    
}
