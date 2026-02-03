import SwiftUI
import Combine

struct SetupWizardView: View {
    @StateObject private var viewModel = SetupWizardViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                Image("logo_optimized", bundle: .main)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                
                Text("OpenClawKit Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                switch viewModel.currentStep {
                case .welcome:
                    WelcomeView(viewModel: viewModel)
                case .networkSetup:
                    NetworkSetupView(viewModel: viewModel)
                case .apiKeyConfig:
                    APIKeyConfigView(viewModel: viewModel)
                case .channelSetup:
                    ChannelSetupView(viewModel: viewModel)
                case .completion:
                    CompletionView(viewModel: viewModel)
                }
                
                Spacer()
            }
            .padding()
            .blur(radius: viewModel.isLoading ? 3 : 0)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
            }
        }
    }
}

struct WelcomeView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    
    var body: some View {
        VStack {
            Text("Welcome to OpenClawKit")
                .font(.title2)
            
            Text("Let's configure your OpenClaw assistant")
                .font(.subheadline)
                .padding()
            
            Button("Get Started") {
                viewModel.advanceToNextStep()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct NetworkSetupView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    
    var body: some View {
        VStack {
            Text("Network Configuration")
                .font(.title2)
            
            TextField("OpenClaw Gateway URL", text: $viewModel.gatewayURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
            
            Button("Validate and Continue") {
                viewModel.advanceToNextStep()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.gatewayURL.isEmpty)
        }
    }
}

struct APIKeyConfigView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    
    var body: some View {
        VStack {
            Text("AI Provider Configuration")
                .font(.title2)
            
            TextField("API Key", text: $viewModel.apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
            
            Picker("AI Provider", selection: $viewModel.selectedProvider) {
                ForEach(AIProvider.allCases, id: \.self) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button("Validate and Continue") {
                viewModel.advanceToNextStep()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.apiKey.isEmpty)
        }
    }
}

struct ChannelSetupView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    
    var body: some View {
        VStack {
            Text("Messaging Channels")
                .font(.title2)
            
            List {
                ForEach(MessagingChannel.allCases, id: \.self) { channel in
                    Toggle(channel.rawValue, isOn: Binding(
                        get: { viewModel.selectedChannels.contains(channel) },
                        set: { isOn in
                            if isOn {
                                viewModel.selectedChannels.insert(channel)
                            } else {
                                viewModel.selectedChannels.remove(channel)
                            }
                        }
                    ))
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Button("Save Configuration") {
                viewModel.advanceToNextStep()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.selectedChannels.isEmpty)
        }
    }
}

struct CompletionView: View {
    @ObservedObject var viewModel: SetupWizardViewModel
    
    var body: some View {
        VStack {
            Text("Setup Complete!")
                .font(.title)
            
            Text("Your OpenClaw assistant is now configured")
                .font(.subheadline)
                .padding()
            
            Button("Launch OpenClaw") {
                viewModel.launchOpenClaw()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}