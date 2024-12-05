import SwiftUI

struct HomeTabView: View {
    @StateObject var pharmacyViewModel = PharmacyViewModel()
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Order Status Card
                    CardView(
                        title: "Your order is on the way!",
                        subtitle: "Have you taken your medicine yet?",
                        actionText: "Track order status",
                        backgroundImage: "123"
                    )
                    
                    // Lifestyle Card
                    CardView(
                        title: "Check your lifestyle",
                        subtitle: "Have you reached your goals yet?",
                        actionText: "Healthy Lifestyle",
                        backgroundImage: "sport",
                        action: { /* Add your action here */ }
                    )
                    
                    // Products Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Latest Products")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            NavigationLink(destination: PharmacyView()) {
                                Text("See all")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        ProductsCarousel(
                            products: pharmacyViewModel.filteredProducts,
                            addToCart: { product in
                                pharmacyViewModel.addToCart(product: product)
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Views
struct CardView: View {
    let title: String
    let subtitle: String
    let actionText: String
    let backgroundImage: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.4), .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Button(action: { action?() }) {
                    Text(actionText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5, y: 2)
    }
}

struct ProductsCarousel: View {
    let products: [Product]
    let addToCart: (Product) -> Void
    
    var body: some View {
        // Main container with fixed height
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(products) { product in
                        ProductCard1(product: product)
                            .onTapGesture {
                                addToCart(product)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(height: 260) // Ensure enough height for the content
    }
}

struct ProductCard1: View {
    let product: Product
    @State private var isPressed = false
    let baseURL = "http://172.18.7.103:3000"  // Base URL

    // Construct the full URL for the image
    private func getImageURL() -> URL? {
        let imageURLString = baseURL + product.image
        return URL(string: imageURLString)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Container
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                
                ZStack {
                    AsyncImage(url: getImageURL()) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                              //  .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        case .failure:
                            // Fallback image in case of failure
                            Image("defaultImage")  // Make sure to have a default image in your assets
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .frame(width: 150, height: 150)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 150)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(), value: isPressed)
    }
}
