//
//  ReclamationView.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 4/12/2024.
//

import SwiftUI

struct ReclamationView: View {
    @State private var subject: String = ""
    @State private var reclamationText: String = ""
    @StateObject private var viewModel = ReclamationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Submit a Reclamation")
                            .font(.system(size: 35, weight: .bold))
                        Text("Describe your issue and submit your reclamation.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    
                    // Reclamation Input Fields
                    VStack(spacing: 20) {
                        // Subject field
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(.gray)
                            TextField("Subject", text: $subject)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5)
                        }
                        .padding(.horizontal)
                        
                        // Reclamation text field
                        VStack {
                            Text("Reclamation Details")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            TextEditor(text: $reclamationText)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .frame(height: 150)
                                .shadow(color: Color.black.opacity(0.1), radius: 5)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)
                    
                    // Submit Button
                    Button(action: {
                        withAnimation {
                            viewModel.submitReclamation(subject: subject, reclamationText: reclamationText)
                        }
                    }) {
                        ZStack {
                            Text("Submit Reclamation")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                )
                                .opacity(viewModel.isLoading ? 0 : 1)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                            }
                        }
                    }
                    .disabled(isSubmitDisabled())
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            Alert(
                title: Text("Reclamation Error"),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage	 = nil
                }
            )
        }
        .onChange(of: viewModel.isReclamationSubmitted) { success in
            if success {
                dismiss() // Dismiss the view once the reclamation is successfully submitted
            }
        }
    }
    
    // Helper function to check if submit button should be disabled
    private func isSubmitDisabled() -> Bool {
        return subject.isEmpty || reclamationText.isEmpty || viewModel.isLoading
    }
}

struct ReclamationView_Previews: PreviewProvider {
    static var previews: some View {
        ReclamationView()
    }
}

