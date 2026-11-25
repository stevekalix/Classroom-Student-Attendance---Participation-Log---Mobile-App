import Foundation
import Combine
@MainActor final class SettingsViewModel: ObservableObject {
 @Published var isLoading = false
 @Published var error: String?
 func setBiometrics(_ enabled: Bool, auth: AuthViewModel) async {
 guard !isLoading else { return }; isLoading = true; error = nil; defer { isLoading = false }
 do { try await auth.setBiometrics(enabled) } catch { self.error = error.localizedDescription }
 }
 var version: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0" }
}
