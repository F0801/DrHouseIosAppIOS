//
//  ReclamationViewModel.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 4/12/2024.
//

import SwiftUI

class ReclamationViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isReclamationSubmitted = false
    
    func submitReclamation(subject: String, reclamationText: String) {
        // Start the loading process
        isLoading = true
        errorMessage = nil
        
        // Simulate network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Simulate success
            self.isLoading = false
            self.isReclamationSubmitted = true
            // Or simulate failure
            // self.errorMessage = "Failed to submit the reclamation"
        }
    }
}
