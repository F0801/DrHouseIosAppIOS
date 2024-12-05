import SwiftUI
import Lottie
// MARK: - Theme
enum Theme {
    static let backgroundColor = Color("#1A1A2E")
    static let cardBackground = Color("#16213E")
    static let textColor = Color.blue
    static let inputBackground = Color.white.opacity(0.15)
    static let accentColor = Color.blue
}

// MARK: - Main View
struct AIView: View {
    @StateObject private var viewModel = AIViewModel()
    @State private var isInputExpanded = false
    @State private var showResults = false
    
    var body: some View {
        ZStack {
            Theme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    modernInputSection
                    if let error = viewModel.errorMessage {
                        modernErrorView(message: error)
                    }
                    modernAnalyzeButton
                    if !viewModel.symptomsInput.isEmpty {
                        resultSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding()
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isInputExpanded)
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
                .shadow(color: Theme.accentColor.opacity(0.5), radius: 10)
            
            Text("Health AI Assistant")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textColor)
                .shadow(color: Color.black.opacity(0.2), radius: 2)
        }
        .padding(.vertical)
    }
    
    private var modernInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "stethoscope")
                    .foregroundColor(Theme.accentColor)
                Text("Symptoms")
                    .font(.headline)
                    .foregroundColor(Theme.textColor)
            }
            .padding(.horizontal)
            
            ZStack(alignment: .topLeading) {
                if viewModel.symptomsInput.isEmpty {
                    Text("Enter your symptoms here...")
                        .foregroundColor(Theme.textColor.opacity(0.5))
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $viewModel.symptomsInput)
                    .frame(height: isInputExpanded ? 150 : 100)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.cardBackground)
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                    )
                    .foregroundColor(Theme.textColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Theme.accentColor, Theme.accentColor.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .onTapGesture {
                        withAnimation {
                            isInputExpanded = true
                        }
                    }
            }
            
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Theme.accentColor.opacity(0.7))
                Text("Separate multiple symptoms with commas")
                    .font(.caption)
                    .foregroundColor(Theme.textColor.opacity(0.7))
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardBackground.opacity(0.7))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
    }
    
    private var modernAnalyzeButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                viewModel.analyzeSymptoms()
                showResults = true
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "waveform.path.ecg.rectangle")
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Text(viewModel.isLoading ? "Analyzing..." : "Analyze Symptoms")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Theme.accentColor, Theme.accentColor.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Theme.accentColor.opacity(0.4), radius: 8, y: 4)
            .foregroundColor(.white)
        }
        .disabled(viewModel.isLoading)
        .scaleEffect(viewModel.isLoading ? 0.95 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isLoading)
    }
    
    private var resultSection: some View {
        Group {
            if viewModel.isLoading {
                modernLoadingView
            } else if let response = viewModel.predictionResponse {
                modernResultsView(response: response)
            }
        }
    }
    
    private var modernLoadingView: some View {
        VStack(spacing: 20) {
            LottieLoadingView() // You'll need to implement this
            Text("Processing your symptoms...")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Theme.textColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(20)
    }
    
    private func modernResultsView(response: PredictionResponse) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(ResultSection.allCases, id: \.self) { section in
                modernResultCard(
                    section.title,
                    section.content(from: response),
                    section.icon,
                    section.color
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private func modernResultCard(_ title: String, _ content: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.2))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Theme.textColor)
            }
            
            Text(content)
                .font(.system(.body, design: .rounded))
                .foregroundColor(Theme.textColor.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 44)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardBackground)
                .shadow(color: color.opacity(0.2), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// Add this enum for organizing result sections
enum ResultSection: CaseIterable {
    case condition, medications, precautions, diet, workout
    
    var title: String {
        switch self {
        case .condition: return "Condition"
        case .medications: return "Medications"
        case .precautions: return "Precautions"
        case .diet: return "Recommended Diet"
        case .workout: return "Exercise Plan"
        }
    }
    
    var icon: String {
        switch self {
        case .condition: return "cross.case.fill"
        case .medications: return "pill.fill"
        case .precautions: return "shield.lefthalf.fill"
        case .diet: return "leaf.fill"
        case .workout: return "figure.walk"
        }
    }
    
    var color: Color {
        switch self {
        case .condition: return .red
        case .medications: return .blue
        case .precautions: return .orange
        case .diet: return .green
        case .workout: return .purple
        }
    }
    
    func content(from response: PredictionResponse) -> String {
        switch self {
        case .condition: return response.predicted_disease
        case .medications: return response.medications.joined(separator: ", ")
        case .precautions: return response.precautions
        case .diet: return response.recommended_diet.joined(separator: ", ")
        case .workout: return response.workout.joined(separator: ", ")
        }
    }
}
// MARK: - Preview
struct AIView_Previews: PreviewProvider {
    static var previews: some View {
        AIView()
    }
}
// MARK: - Lottie Loading View
 // Make sure to add Lottie package to your project first

struct LottieLoadingView: View {
    var body: some View {
        // If you don't have Lottie animations yet, use this alternative loading view
        VStack(spacing: 16) {
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(Theme.accentColor, lineWidth: 4)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            Text("Processing...")
                .font(.system(.body, design: .rounded))
                .foregroundColor(Theme.textColor)
        }
        .frame(width: 200, height: 200)
    }
    
    @State private var isAnimating = false
}

// MARK: - Modern Error View
func modernErrorView(message: String) -> some View {
    HStack(spacing: 12) {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.red)
            .font(.system(size: 24))
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(Color.red.opacity(0.2))
            )
        
        VStack(alignment: .leading, spacing: 4) {
            Text("Error")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Theme.textColor.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        
        Spacer()
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Theme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
    )
    .transition(.scale.combined(with: .opacity))
}

// MARK: - Custom Loading Animation View (Alternative to Lottie)
struct CustomLoadingView: View {
    @State private var isAnimating = false
    private let duration: Double = 1.5
    
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(Theme.accentColor.opacity(0.2), lineWidth: 4)
                .frame(width: 60, height: 60)
            
            // Animated circle
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Theme.accentColor.opacity(0.5), Theme.accentColor]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: duration)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Medical cross
            Image(systemName: "cross.case.fill")
                .foregroundColor(Theme.accentColor)
                .font(.system(size: 20))
                .opacity(isAnimating ? 1 : 0.5)
                .animation(
                    Animation.easeInOut(duration: duration/2)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Then update your modernLoadingView to use either of these:
private var modernLoadingView: some View {
    VStack(spacing: 20) {
        // Use either CustomLoadingView or LottieLoadingView
        CustomLoadingView()
        
        Text("Processing your symptoms...")
            .font(.system(.body, design: .rounded))
            .foregroundColor(Theme.textColor)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 20)
            .fill(Theme.cardBackground)
            .shadow(color: Color.black.opacity(0.15), radius: 10)
    )
}
