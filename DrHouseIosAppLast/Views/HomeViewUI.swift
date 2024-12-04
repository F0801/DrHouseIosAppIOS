import SwiftUI



struct HomeView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Binding var navigationPath: NavigationPath
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ZStack {
                switch selectedTab {
                case 0: // Home
                    HomeTabView(viewModel: viewModel, navigationPath: $navigationPath)
                case 1: // Marketplace
                    PharmacyView()
                case 2: // AI
                    AIView()
                case 3: // Lifestyle
                    LifestyleView()
                case 4: // Profile
                    ProfileView()
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}
