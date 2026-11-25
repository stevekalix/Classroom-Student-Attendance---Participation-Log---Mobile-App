import SwiftUI
struct RootView: View {
 @EnvironmentObject private var auth: AuthViewModel
 @Environment(\.scenePhase) private var phase
 var body: some View {
 Group {
 if auth.isLocked { BiometricLockView() }
 else if auth.teacher != nil { MainTabView() }
 else if auth.isRestoring { LoadingView() }
 else { NavigationStack { LoginView() } }
 }.task { await auth.restore() }.onChange(of: phase) { _, next in if next == .background { auth.lock() } }
 }
}
