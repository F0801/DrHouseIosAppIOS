import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    // Profile picture and upload button
                    ZStack {
                        // Profile picture
                        Image(systemName: "person.circle.fill") // Placeholder image
                            .resizable()
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .padding()

                        // Upload Image Button
                        Button(action: {
                            // Action for uploading an image
                            print("Upload Image tapped")
                        }) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding(10)
                                .background(Color.blue.opacity(0.5))
                                .clipShape(Circle())
                                .padding(5)
                        }
                        .offset(x: 60, y: 80) // Position the button over the image
                    }
                    
                    // Welcome text
                    Text("Welcome To your profile, Dear")
                        .font(.body)
                        .foregroundColor(.black)
                    
                    // Name
                    Text("John Doe") // This should be dynamic in real-world apps
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.black)

                    // Edit profile button (navigate to EditProfileView)
                    NavigationLink(destination: EditProfileView()) {
                        Text("Edit Profile")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.black.opacity(0.9))
                            .cornerRadius(50)
                    }
                    .padding(.top, 20)
                    // Reclamation button (navigate to ReclamationView)
                    NavigationLink(destination: ReclamationView()) {
                        Text("Reclamation")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.black.opacity(0.9))
                            .cornerRadius(50)
                    }
                    .padding(.top, 20)

                    // Logout button
                    Button(action: {
                        // Action for logging out (implement logout functionality here)
                        print("Log Out tapped")
                    }) {
                        Text("Logout")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.black.opacity(0.9))
                            .cornerRadius(50)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
