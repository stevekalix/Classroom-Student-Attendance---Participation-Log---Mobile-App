import SwiftUI
struct BiometricLockView: View {
 @EnvironmentObject private var auth: AuthViewModel
 var body: some View { VStack(spacing: 24) { Image(systemName: "lock.shield.fill").font(.system(size: 64)).foregroundStyle(AppColors.primary); Text("Welcome back").font(AppTypography.title); Text("Unlock your classroom securely.").foregroundStyle(.secondary); if let error = auth.error { ErrorView(message: error) }; PrimaryButton(title: "Unlock with biometrics", loading: auth.isLoading) { Task { await auth.unlock() } }; Button("Use email and password") { auth.logout() } }.padding(28) }
}
