import Foundation
import Combine
@MainActor
final class AuthViewModel: ObservableObject {
 @Published var teacher: Teacher?
 @Published var isLoading = false
 @Published var isRestoring = true
 @Published var isLocked = false
 @Published var error: String?
 @Published var biometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
 private let service: any AuthServiceProtocol
 private let api: APIClient
 private let keychain = KeychainManager()
 private let biometrics = BiometricManager()
 private var started = false
 var biometricsAvailable: Bool { biometrics.available }
 init(service: (any AuthServiceProtocol)? = nil, api: APIClient? = nil) {
 let client = api ?? APIClient.shared; self.service = service ?? AuthService(); self.api = client
 client.onUnauthorized = { [weak self] in self?.logout() }
 }
 func restore() async {
 guard !started else { return }; started = true
 defer { isRestoring = false }
 #if DEBUG
 if ProcessInfo.processInfo.arguments.contains("-ui-testing") { return }
 #endif
 if biometricEnabled { isLocked = true; return }
 isLoading = true; defer { isLoading = false }
 do { if let token = try keychain.read() { api.token = token; teacher = try await service.me() } }
 catch { api.token = nil; teacher = nil; self.error = error.localizedDescription }
 }
 func authenticate(name: String = "", email: String, password: String, confirmation: String = "", register: Bool = false) async {
 guard !isLoading else { return }
 guard Validators.email(email), !password.isEmpty else { error = "Enter a valid email address and password."; return }
 if register && (name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || name.count > 150 || !Validators.password(password) || password != confirmation) { error = "Enter your name and matching passwords with at least 10 characters, uppercase, lowercase and a number."; return }
 isLoading = true; error = nil; defer { isLoading = false }
 do {
 api.token = nil
 let response: AuthResponse
 if register { response = try await service.register(name: name, email: email, password: password) } else { response = try await service.login(email: email, password: password) }
 try keychain.save(response.token, biometric: false)
 biometricEnabled = false; UserDefaults.standard.set(false, forKey: "biometricEnabled")
 api.token = response.token; teacher = response.teacher; isLocked = false
 } catch is CancellationError {} catch { self.error = error.localizedDescription }
 }
 func unlock() async {
 guard !isLoading else { return }; isLoading = true; error = nil; defer { isLoading = false }
 do {
 let context = try await biometrics.authenticate()
 guard let token = try keychain.read(context: context) else { logout(); error = "Saved session unavailable. Please sign in again."; return }
 api.token = token; teacher = try await service.me(); isLocked = false
 } catch { api.token = nil; self.error = error.localizedDescription }
 }
 func setBiometrics(_ enabled: Bool) async throws {
 guard let token = api.token else { throw APIError.unauthorized }
 if enabled { _ = try await biometrics.authenticate() }
 try keychain.save(token, biometric: enabled)
 biometricEnabled = enabled; UserDefaults.standard.set(enabled, forKey: "biometricEnabled")
 }
 func lock() { if biometricEnabled && teacher != nil { isLocked = true; api.token = nil } }
 func logout() {
 do { try keychain.delete() } catch { self.error = error.localizedDescription }
 api.token = nil; teacher = nil; isLocked = false; biometricEnabled = false; UserDefaults.standard.set(false, forKey: "biometricEnabled")
 }
}
