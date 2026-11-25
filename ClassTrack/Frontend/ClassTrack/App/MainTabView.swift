import SwiftUI
struct MainTabView: View {
 @EnvironmentObject private var router: AppRouter
 var body: some View {
 TabView(selection: $router.tab) {
 NavigationStack { DashboardView() }.tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }.tag(0)
 NavigationStack { StudentListView() }.tabItem { Label("Students", systemImage: "person.2.fill") }.tag(1)
 NavigationStack { AttendanceView() }.tabItem { Label("Attendance", systemImage: "checklist") }.tag(2)
 NavigationStack { SettingsView() }.tabItem { Label("Settings", systemImage: "gearshape.fill") }.tag(3)
 }
 }
}
