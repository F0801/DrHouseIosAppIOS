import SwiftUI
import Combine

class PharmacyViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var selectedCategory: String = "All" {
        // When the category changes, trigger a new fetch
        didSet {
            fetchProductsByCategory(category: selectedCategory)
        }
    }
    @Published var cart: [Product] = []
    
    @Published var searchText: String = ""
    
    
    
    var categories: [String] = ["All", "Vitamins", "MultiVit", "Protein", "Bio-meds" , "Minerals" , "Supplements"]
    
    private var cancellables = Set<AnyCancellable>()
    private var productRepository = ProductRepository()

    init() {
        // Initially fetch all products
        fetchProducts()
    }
    
    // Fetch all products from the repository
    func fetchProducts() {
        productRepository.fetchProducts { [weak self] result in
            switch result {
            case .success(let products):
                DispatchQueue.main.async {
                    self?.products = products
                }
            case .failure(let error):
                print("Error fetching products: \(error)")
            }
        }
    }
    
    // Fetch products by category when the selected category changes
    func fetchProductsByCategory(category: String) {
        if category == "All" {
            // Fetch all products when "All" is selected
            fetchProducts()
            
        } else {
            // Fetch products by the selected category
            productRepository.fetchProductsByCategory(byCategory: category) { [weak self] result in
                switch result {
                case .success(let products):
                    DispatchQueue.main.async {
                        self?.products = products
                    }
                case .failure(let error):
                    print("Error fetching products by category: \(error)")
                }
            }
        }
    }
    
    var filteredProducts: [Product] {
           let categoryFiltered = selectedCategory == "All" ? products : products.filter { $0.category == selectedCategory }

           if searchText.isEmpty {
               return categoryFiltered
           } else {
               return categoryFiltered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
           }
       }
    
    
    // Add product to the cart
    func addToCart(product: Product) {
        cart.append(product)
    }
    
  // Remove product from the cart
    func removeFromCart(product: Product) {
        cart.removeAll { $0.id == product.id }
    }
}
