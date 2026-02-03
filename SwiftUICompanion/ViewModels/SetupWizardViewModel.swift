import Foundation
import Combine
import SwiftUI

enum SetupWizardStep {
    case welcome
    case networkSetup
    case apiKeyConfig
    case channelSetup
    case completion
}

enum AIProvider: String, CaseIterable {
    case anthropic = "Anthropic"
    case openAI = "OpenAI"
    case google = "Google"
}

enum MessagingChannel: String, CaseIterable {
    case telegram = "Telegram"
    case discord = "Discord"
    case whatsApp = "WhatsApp"
    case slack = "Slack"
    case signal = "Signal"
    case iMessage = "iMessage"
}

class SetupWizardViewModel: ObservableObject {
    @Published var currentStep: SetupWizardStep = .welcome
    @Published var gatewayURL: String = ""
    @Published var apiKey: String = ""
    @Published var selectedProvider: AIProvider = .anthropic
    @Published var selectedChannels: Set<MessagingChannel> = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func advanceToNextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .networkSetup
        case .networkSetup:
            validateGatewayURL()
        case .apiKeyConfig:
            validateAPIKey()
        case .channelSetup:
            currentStep = .completion
        case .completion:
            saveConfiguration()
        }
    }
    
    private func validateGatewayURL() {
        isLoading = true
        errorMessage = nil
        
        ConfigurationService.shared.validateGatewayURL(gatewayURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "Invalid Gateway URL: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] isValid in
                if isValid {
                    self?.currentStep = .apiKeyConfig
                }
            }
            .store(in: &cancellables)
    }
    
    private func validateAPIKey() {
        isLoading = true
        errorMessage = nil
        
        ConfigurationService.shared.validateAPIKey(apiKey, provider: selectedProvider)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "API Key Validation Failed: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] isValid in
                if isValid {
                    self?.currentStep = .channelSetup
                }
            }
            .store(in: &cancellables)
    }
    
    private func saveConfiguration() {
        isLoading = true
        errorMessage = nil
        
        ConfigurationService.shared.saveConfiguration(
            gatewayURL: gatewayURL, 
            apiKey: apiKey, 
            provider: selectedProvider, 
            channels: selectedChannels
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.errorMessage = "Configuration Save Failed: \(error.localizedDescription)"
            }
        } receiveValue: { [weak self] success in
            if success {
                self?.currentStep = .completion
            }
        }
        .store(in: &cancellables)
    }
    
    func launchOpenClaw() {
        // TODO: Implement actual OpenClaw launch mechanism
        print("Launching OpenClaw with configuration:")
        print("Gateway URL: \(gatewayURL)")
        print("AI Provider: \(selectedProvider.rawValue)")
        print("Selected Channels: \(selectedChannels)")
    }
    
    // Clean up cancellables when view model is deallocated
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}