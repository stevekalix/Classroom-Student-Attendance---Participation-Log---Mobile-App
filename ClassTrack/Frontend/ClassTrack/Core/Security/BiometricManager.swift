import LocalAuthentication
@MainActor
struct BiometricManager {
 var available: Bool { var error: NSError?; return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) }
 func authenticate() async throws -> LAContext {
 let context = LAContext(); context.localizedFallbackTitle = ""
 let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock your ClassTrack session")
 guard success else { throw APIError.network("Biometric verification failed.") }
 return context
 }
}
