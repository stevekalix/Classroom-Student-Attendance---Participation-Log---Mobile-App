import SwiftUI
struct SettingsView: View {
 @EnvironmentObject private var auth: AuthViewModel
 @StateObject private var vm = SettingsViewModel()
 @AppStorage("appearance") private var appearance = Appearance.system.rawValue
 @State private var logout = false
 var body: some View { Form {
 Section("Teacher profile") { LabeledContent("Name", value: auth.teacher?.fullName ?? ""); LabeledContent("Email", value: auth.teacher?.email ?? "") }
 Section("Security") {
 Toggle("Face ID / Touch ID", isOn: Binding(get: { auth.biometricEnabled }, set: { enabled in Task { await vm.setBiometrics(enabled, auth: auth) } })).disabled(vm.isLoading || !auth.biometricsAvailable)
 if !auth.biometricsAvailable { Text("Set up a device passcode and Face ID or Touch ID to enable biometric unlock.").font(.caption).foregroundStyle(.secondary) }
 if vm.isLoading { ProgressView() }
 if let error = vm.error { ErrorView(message: error) }
 }
 Section("Appearance") { Picker("Theme", selection: $appearance) { ForEach(Appearance.allCases) { Text($0.rawValue.capitalized).tag($0.rawValue) } } }
 Section("Privacy") { Text("Your records are available only to your teacher account. Biometric information never leaves your device. ClassTrack stores only your session token in Apple Keychain. Archived students retain their attendance and notes.").font(.footnote); LabeledContent("Version", value: vm.version) }
 Button("Log out", role: .destructive) { logout = true }
 }.navigationTitle("Settings").alert("Log out of ClassTrack?", isPresented: $logout) { Button("Cancel", role: .cancel) {}; Button("Log out", role: .destructive) { auth.logout() } }
 }
}
