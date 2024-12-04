import SwiftUI

// MARK: - Theme
enum Theme {
    static let backgroundColor = Color(hex: "#1A1A2E")
    static let cardBackground = Color(hex: "#16213E")
    static let textColor = Color.white
    static let inputBackground = Color.white.opacity(0.15)
    static let accentColor = Color.blue
}

// MARK: - Main View
struct AIView: View {
    @StateObject private var viewModel = AIViewModel()
    
    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    inputSection
                    if let error = viewModel.errorMessage {
                        errorView(message: error)
                    }
                    analyzeButton
                    resultSection
                }
                .padding()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .foregroundColor(Theme.accentColor)
            
            Text("Health AI Assistant")
                .font(.title)
                .bold()
                .foregroundColor(Theme.textColor)
        }
        .padding(.vertical)
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter Symptoms")
                .font(.headline)
                .foregroundColor(Theme.textColor)
            
            TextEditor(text: $viewModel.symptomsInput)
                .frame(height: 120)
                .padding()
                .background(Theme.inputBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.accentColor.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(Theme.textColor)
            
            Text("Separate multiple symptoms with commas")
                .font(.caption)
                .foregroundColor(Theme.textColor.opacity(0.7))
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }
    
    private var analyzeButton: some View {
        Button(action: viewModel.analyzeSymptoms) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "waveform.path.ecg")
                }
                Text(viewModel.isLoading ? "Analyzing..." : "Analyze Symptoms")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.accentColor)
            .cornerRadius(12)
            .foregroundColor(.white)
        }
        .disabled(viewModel.isLoading)
    }
    
    private var resultSection: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let response = viewModel.predictionResponse {
                resultsView(response: response)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Theme.textColor))
            Text("Processing...")
                .foregroundColor(Theme.textColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }
    
    private func resultsView(response: PredictionResponse) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            resultCard("Condition", response.predicted_disease, "cross.case.fill")
            resultCard("Medications", response.medications.joined(separator: ", "), "pill.fill")
            resultCard("Precautions", response.precautions, "shield.lefthalf.fill")
            resultCard("Diet", response.recommended_diet.joined(separator: ", "), "leaf.fill")
            resultCard("Exercise", response.workout.joined(separator: ", "), "figure.walk")
        }
    }
    
    private func resultCard(_ title: String, _ content: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Theme.accentColor)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
            }
            
            Text(content)
                .foregroundColor(Theme.textColor.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
    
    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(Theme.textColor)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int & 0xFF0000) >> 16) / 255.0
        let g = Double((int & 0x00FF00) >> 8) / 255.0
        let b = Double(int & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview
struct AIView_Previews: PreviewProvider {
    static var previews: some View {
        AIView()
    }
}
