import SwiftUI

struct CartView: View {
    // Receive the cart items from the previous view
    let cart: [Product]
    
    var body: some View {
        VStack {
            if cart.isEmpty {
                // Show an empty state message
                Text("Your cart is empty")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
                    .padding(.horizontal)
            } else {
                // Show the list of cart items
                ScrollView {
                    ForEach(cart) { product in
                        CartItemCard(product: product)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                }
            }
            
            // Cart Summary or Checkout Button
            if !cart.isEmpty {
                VStack {
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "$%.2f", totalPrice()))
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.6))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Prod number :")
                            .font(.headline)
                        Spacer()
                        Text(String(cart.count))
                            .font(.headline)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.6))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    Button(action: {
                        // Handle checkout action
                    }) {
                        Text("Proceed to Checkout")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Cart")
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
    
    // Calculate the total price of the cart
    private func totalPrice() -> Double {
        cart.reduce(0) { $0 + $1.price }
    }

}

struct CartItemCard: View {
    let product: Product
    let baseURL = "http://172.18.7.103:3000" 
    // Construct the full URL for the image
    private func getImageURL() -> URL? {
        let imageURLString = baseURL + product.image
        return URL(string: imageURLString)
    }
    
    var body: some View {
        VStack {
            HStack {
                
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
                                .frame(height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        @unknown default:
                            EmptyView()
                        
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(String(format: "$%.2f", product.price))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 4)
        }
    }
}
/*
struct CartView_Previews: PreviewProvider {
    static var previews: some View {
            CartView(cart: [
         Product(name: "Xanax", price: 2.5, image: "xanax", category: "Vitamins"),
         Product(name: "Panadol Extra", price: 3.0, image: "pandol", category: "GSL")
         ])
         
    }
    
}
*/
