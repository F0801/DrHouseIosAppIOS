import SwiftUI
import UIKit

struct PharmacyView: View {
    @StateObject private var viewModel = PharmacyViewModel()
    @State private var selectedImage: UIImage? = nil // To store the selected image
    @State private var ocrResult: String = "" // To store the OCR text result
    @State private var isImagePickerPresented: Bool = false // State to control image picker presentation

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                // Image Picker Button
                               Button(action: {
                                   isImagePickerPresented.toggle() // Show image picker
                               }) {
                                   Text("Select Prescription Image")
                                       .font(.headline)
                                       .padding()
                                       .frame(maxWidth: .infinity)
                                       .background(Color.blue)
                                       .foregroundColor(.white)
                                       .cornerRadius(8)
                               }
                               .padding(.horizontal)
                               
                               // OCR Result Section
                               if !ocrResult.isEmpty {
                                   Text("OCR Result: \(ocrResult)")
                                       .font(.body)
                                       .padding()
                                       .background(Color.green.opacity(0.1))
                                       .cornerRadius(8)
                                       .padding(.horizontal)
                               }

                
                // Search Bar Section
                SearchBarView(searchText: $viewModel.searchText)
                    .padding(.horizontal)
                
                // Category Section
                CategorySectionView(categories: viewModel.categories, selectedCategory: $viewModel.selectedCategory)
                    .padding(.horizontal)
                
                // Product Grid Section
                ProductGridView(products: viewModel.filteredProducts, addToCart: viewModel.addToCart)
                    .padding(.horizontal)
                
                // Cart Navigation Button
                CartNavigationView(cart: viewModel.cart)
                    .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Pharmacy Shop")
            .sheet(isPresented: $isImagePickerPresented) {
                // Show the image picker when triggered
                ImagePickerController(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { newImage in
                // When an image is selected, trigger OCR
                if let image = newImage {
                    uploadImageForOCR(image)
                }
            }
        }
    }
    
    func uploadImageForOCR(_ image: UIImage) {
           guard let imageData = image.jpegData(compressionQuality: 0.8) else {
               print("Failed to get JPEG data from image")
               return
           }

           // Call the OCR API (NestJS Backend)
           OCRService.uploadImage(imageData: imageData) { result in
               switch result {
               case .success(let text):
                   // Update the OCR result
                   ocrResult = text
               case .failure(let error):
                   print("OCR failed with error: \(error)")
               }
           }
       }
   }

struct SearchBarView: View {
    @Binding var searchText: String // This is bound to the HeroCardView

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search products...", text: $searchText)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = "" // Clear the search when the "X" button is tapped
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray.opacity(0.3)))
    }
}
struct CategorySectionView: View {
   // Now we take the categories from the ViewModel
   var categories: [String]
   @Binding var selectedCategory: String
   
   var body: some View {
       ScrollView(.horizontal, showsIndicators: false) {
           HStack(spacing: 16) {
               ForEach(categories, id: \.self) { category in
                   Button(action: {
                       selectedCategory = category
                   }) {
                       Text(category)
                           .fontWeight(.semibold)
                           .font(.subheadline)
                           .padding(.horizontal, 16)
                           .padding(.vertical, 10)
                           .background(selectedCategory == category ? Color.blue.opacity(0.8) : Color.gray.opacity(0.05))
                           .foregroundColor(selectedCategory == category ? .white : .primary)
                           .cornerRadius(20)
                           .shadow(radius: selectedCategory == category ? 5 : 0)
                           .animation(.easeInOut(duration: 0.2), value: selectedCategory) // Smooth category transition
                   }
               }
           }
       }
       .padding(.vertical, 12)
   }
}


   struct ProductGridView: View {
       var products: [Product]
       var addToCart: (Product) -> Void
       
       var body: some View {
           ScrollView {
               LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                   ForEach(products) { product in
                       ProductCard(product: product, onAddToCart: {
                           addToCart(product)
                       })
                   }
               }
           }
       }
   }

   struct CartNavigationView: View {
       var cart: [Product]
       
       var body: some View {
           NavigationLink(destination: CartView(cart: cart)) {
               Text("View Cart (\(cart.count))")
                   .fontWeight(.bold)
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(Color.blue.opacity(0.7))
                   .foregroundColor(.white)
                   .cornerRadius(8)
                   .shadow(radius: 5)
           }
           .padding(.bottom)
       }
   }



struct ProductCard: View {
    let product: Product
    let onAddToCart: () -> Void
    let baseURL = "http://172.18.7.103:3000"  // Base URL

    // Construct the full URL for the image
    private func getImageURL() -> URL? {
        let imageURLString = baseURL + product.image
        return URL(string: imageURLString)
    }

    var body: some View {
        VStack {
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
            .frame(height: 150)

            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(String(format: "$%.2f", product.price))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Button(action: onAddToCart) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Add to Cart")
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.yellow.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 3)
            }
            .padding(.top, 8)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ImagePicker: View {
    @Binding var selectedImage: UIImage? // Bind the selected image to the parent view
    @Environment(\.dismiss) private var dismiss // Dismiss the image picker

    @State private var isImagePickerPresented = false

    var body: some View {
        VStack {
            Button("Select Image") {
                isImagePickerPresented.toggle()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerController(selectedImage: $selectedImage)
            }
        }
    }
}

/*struct CartView: View {
   var cart: [Product]
   
   var body: some View {
       List(cart) { product in
           Text(product.name)
       }
       .navigationTitle("Cart")
   }
}
*/
struct PharmacyShopView_Previews: PreviewProvider {
   static var previews: some View {
       PharmacyView()
   }
}

