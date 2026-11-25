import SwiftUI
struct RegisterView: View {
 @EnvironmentObject private var auth: AuthViewModel
 @State private var name = "", email = "", password = "", confirmation = ""
 var body: some View { Form {
 Section("Teacher profile") { TextField("Full name", text: $name).textContentType(.name); TextField("Email", text: $email).textContentType(.emailAddress).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled() }
 Section("Secure your account") { SecureField("Password", text: $password).textContentType(.newPassword); SecureField("Confirm password", text: $confirmation).textContentType(.newPassword); Text("Use at least 10 characters with uppercase, lowercase and a number.").font(.caption).foregroundStyle(.secondary) }
 if let error = auth.error { ErrorView(message: error) }
 PrimaryButton(title: "Create account", loading: auth.isLoading) { Task { await auth.authenticate(name: name, email: email, password: password, confirmation: confirmation, register: true) } }
 }.navigationTitle("Join ClassTrack") }
}
