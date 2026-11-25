import SwiftUI
struct LoginView: View {
 @EnvironmentObject private var auth: AuthViewModel
 @State private var email = "", password = ""
 @State private var showPassword = false
 var body: some View {
 ScrollView { VStack(alignment: .leading, spacing: 24) {
 Image(systemName: "graduationcap.fill").font(.system(size: 52)).foregroundStyle(AppColors.primary).padding(.top, 40)
 Text("ClassTrack").font(AppTypography.title)
 Text("Every student. Every day.").font(.title3).foregroundStyle(.secondary)
 VStack(spacing: 16) {
 TextField("Email", text: $email).textContentType(.username).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled().accessibilityIdentifier("login.email")
 HStack { Group { if showPassword { TextField("Password", text: $password) } else { SecureField("Password", text: $password) } }.textContentType(.password).accessibilityIdentifier("login.password"); Button { showPassword.toggle() } label: { Image(systemName: showPassword ? "eye.slash" : "eye") }.accessibilityLabel(showPassword ? "Hide password" : "Show password") }
 }.textFieldStyle(.roundedBorder)
 if let error = auth.error { ErrorView(message: error) }
 PrimaryButton(title: "Sign in", loading: auth.isLoading) { Task { await auth.authenticate(email: email.trimmingCharacters(in: .whitespaces), password: password) } }.accessibilityIdentifier("login.submit")
 if auth.biometricEnabled && auth.biometricsAvailable { Button("Unlock with Face ID / Touch ID") { Task { await auth.unlock() } } }
 NavigationLink("Create a teacher account") { RegisterView() }
 Text("Your classroom records stay private to your account.").font(.footnote).foregroundStyle(.secondary)
 }.padding(28) }.background(AppColors.background).navigationTitle("")
 }
}
