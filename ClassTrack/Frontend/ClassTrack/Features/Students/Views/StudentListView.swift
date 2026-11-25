import SwiftUI
struct StudentListView: View {
 @StateObject private var vm = StudentListViewModel()
 @EnvironmentObject private var router: AppRouter
 @State private var showFilters = false
 @State private var editing: Student?, deleting: Student?
 var body: some View {
 List {
 if let error = vm.error { ErrorView(message: error) { Task { await vm.load() } } }
 ForEach(vm.students) { student in
 NavigationLink { StudentDetailView(studentId: student.id) } label: { StudentRowView(student: student) }
 .swipeActions { Button(role: .destructive) { deleting = student } label: { Label("Delete", systemImage: "trash") }; Button { editing = student } label: { Label("Edit", systemImage: "pencil") }.tint(.blue) }
 }
 if vm.isLoading { LoadingView() }
 if vm.canLoadMore { Button("Load more students") { Task { await vm.load(reset: false) } }.disabled(vm.isLoading) }
 if vm.students.isEmpty && !vm.isLoading && vm.error == nil { EmptyStateView(title: "No students found", message: "Add a student or adjust your filters.", symbol: "person.2") }
 }.navigationTitle("Students").searchable(text: $vm.search, prompt: "Name or roll ID").refreshable { await vm.load() }
 .toolbar { ToolbarItem(placement: .topBarLeading) { Button { showFilters = true } label: { Label("Filters", systemImage: "line.3.horizontal.decrease.circle") } }; ToolbarItem(placement: .topBarTrailing) { Button { router.showAddStudent = true } label: { Label("Add student", systemImage: "plus") } } }
 .task(id: vm.search) { do { try await Task.sleep(for: .milliseconds(350)); await vm.load() } catch {} }
 .onChange(of: vm.filter) { _, _ in Task { await vm.load() } }
 .onReceive(NotificationCenter.default.publisher(for: .recordsChanged)) { _ in Task { await vm.load() } }
 .sheet(isPresented: $router.showAddStudent) { NavigationStack { AddStudentView() } }
 .sheet(item: $editing) { NavigationStack { EditStudentView(student: $0) } }
 .sheet(isPresented: $showFilters) { NavigationStack { StudentFilterView(filter: $vm.filter) } }
 .alert("Remove student from active roster?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) { Button("Cancel", role: .cancel) { deleting = nil }; Button("Delete", role: .destructive) { if let student = deleting { Task { await vm.delete(student) } }; deleting = nil } } message: { Text("Attendance history and notes will be preserved.") }
 }
}
