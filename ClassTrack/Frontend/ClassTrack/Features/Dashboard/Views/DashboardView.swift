import SwiftUI
import Charts
struct DashboardView: View {
 @StateObject private var vm = DashboardViewModel()
 @EnvironmentObject private var auth: AuthViewModel
 @EnvironmentObject private var router: AppRouter
 var body: some View { ScrollView { VStack(alignment: .leading, spacing: 22) {
 VStack(alignment: .leading, spacing: 6) { Text("Hello, \(auth.teacher?.fullName ?? "Teacher")").font(AppTypography.title); Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day()).foregroundStyle(.secondary) }
 if let error = vm.error { ErrorView(message: error) { Task { await vm.load() } } }
 if vm.isLoading && vm.summary == nil { LoadingView() }
 if let s = vm.summary {
 LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
 DashboardCard(title: "Enrolled students", value: String(s.totalStudents), symbol: "person.2.fill")
 DashboardCard(title: "Attendance today", value: String(format: "%.1f%%", s.attendancePercentage), symbol: "chart.bar.fill", color: AppColors.secondary)
 DashboardCard(title: "Present", value: String(s.presentCount), symbol: "checkmark.circle.fill", color: .green)
 DashboardCard(title: "Absent", value: String(s.absentCount), symbol: "xmark.circle.fill", color: .red)
 DashboardCard(title: "Late", value: String(s.lateCount), symbol: "clock.fill", color: .orange)
 DashboardCard(title: "Unmarked", value: String(s.unmarkedCount), symbol: "minus.circle", color: .secondary)
 }
 if s.totalStudents > 0 { VStack(alignment: .leading) { Text("Today at a glance").font(.headline); Chart(vm.slices) { slice in BarMark(x: .value("Status", slice.status.title), y: .value("Students", slice.count)).foregroundStyle(slice.status.color).annotation(position: .top) { Text("\(slice.count)").font(.caption) }.frame(height: 180).padding(.top, 12); Text("Present + late divided by marked students. Unmarked students are excluded.").font(.caption).foregroundStyle(.secondary) }.padding().background(AppColors.card, in: RoundedRectangle(cornerRadius: 18)) }
 Text("Quick actions").font(.title2.bold())
 LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
 Button { router.tab = 1; router.showAddStudent = true } label: { Label("Add student", systemImage: "person.badge.plus") }
 Button { router.tab = 2 } label: { Label("Mark attendance", systemImage: "checklist") }
 Button { router.tab = 1 } label: { Label("View students", systemImage: "person.2") }
 NavigationLink { StudentNotePickerView() } label: { Label("Add note", systemImage: "square.and.pencil") }
 }.buttonStyle(.bordered).controlSize(.large)
 Text("Recently enrolled").font(.title2.bold())
 if s.recentStudents.isEmpty { EmptyStateView(title: "Your classroom starts here", message: "Add your first student to begin.", symbol: "graduationcap") }
 ForEach(s.recentStudents) { student in NavigationLink { StudentDetailView(studentId: student.id) } label: { StudentRowView(student: student).frame(maxWidth: .infinity, alignment: .leading).padding().background(AppColors.card, in: RoundedRectangle(cornerRadius: 16)) }.buttonStyle(.plain) }
 Text("Recent observations").font(.title2.bold())
 if s.recentNotes.isEmpty { Text("Participation and progress notes will appear here.").foregroundStyle(.secondary) }
 ForEach(s.recentNotes) { note in NavigationLink { NotesListView(studentId: note.studentId) } label: { VStack(alignment: .leading, spacing: 8) { Text(note.category.title).font(.headline).foregroundStyle(AppColors.primary); Text(note.content).lineLimit(3).foregroundStyle(.primary); Text(String(note.updatedAt.prefix(10))).font(.caption).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading).padding().background(AppColors.card, in: RoundedRectangle(cornerRadius: 16)) } }
 }
 }.padding() }.background(AppColors.background).navigationTitle("Overview").navigationBarTitleDisplayMode(.inline).task { await vm.load() }.refreshable { await vm.load() }.onReceive(NotificationCenter.default.publisher(for: .recordsChanged)) { _ in Task { await vm.load() } }
 }
}
struct StudentNotePickerView: View {
 @StateObject private var vm = StudentListViewModel()
 var body: some View { List {
 if let error = vm.error { ErrorView(message: error) { Task { await vm.load() } } }
 ForEach(vm.students) { student in NavigationLink(student.fullName) { NotesListView(studentId: student.id) } }
 if vm.isLoading { LoadingView() }
 if vm.canLoadMore { Button("Load more") { Task { await vm.load(reset: false) } } }
 if vm.students.isEmpty && !vm.isLoading { EmptyStateView(title: "Add a student first") }
 }.navigationTitle("Choose student").searchable(text: $vm.search).task(id: vm.search) { do { try await Task.sleep(for: .milliseconds(350)); await vm.load() } catch {} } }
}
