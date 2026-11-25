import SwiftUI
@main
struct ClassTrackApp: App {
 @StateObject private var auth = AuthViewModel()
 @StateObject private var router = AppRouter()
 @AppStorage("appearance") private var appearance = Appearance.system.rawValue
 var body: some Scene { WindowGroup { RootView().environmentObject(auth).environmentObject(router).tint(AppColors.primary).preferredColorScheme(Appearance(rawValue: appearance)?.colorScheme) } }
}
