import SwiftUI



struct HomeView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var progressViewModel: ProgressViewModel
    @StateObject private var profileViewModel : ProfileViewModel
    @StateObject private var goalSettingsViewModel: GoalSettingsViewModel
    @StateObject var pharmacyViewModel = PharmacyViewModel()
    @Binding var navigationPath: NavigationPath
    @State private var selectedTab = 0
    
    init(navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
        
        // Initialize the API service
        let apiService = ApiServiceImpl(baseURL: "http://172.18.7.103:3000")
        
        // Initialize ProgressViewModel
        let progressRepo = ProgressRepository(apiService: apiService)
        _progressViewModel = StateObject(wrappedValue: ProgressViewModel(repository: progressRepo))
        
        // Initialize GoalSettingsViewModel
        _goalSettingsViewModel = StateObject(wrappedValue: GoalSettingsViewModel())
        
        _pharmacyViewModel = StateObject(wrappedValue: PharmacyViewModel())
        
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel())
        
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ZStack {
                switch selectedTab {
                case 0: // Home
                    HomeTabView(pharmacyViewModel: pharmacyViewModel)
                case 1: // Marketplace
                    PharmacyView()
                case 2: // AI
                    AIView()
                case 3: // Lifestyle
                    ProgressScreen(
                        progressViewModel: progressViewModel,
                        goalViewModel: goalSettingsViewModel,
                        loginViewModel: viewModel
                    )
                case 4: // Profile
                    ProfileView(viewModel: viewModel, navigationPath: $navigationPath,profileviewModel:profileViewModel)
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

