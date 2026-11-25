import SwiftUI
struct NotesListView: View {
 let studentId: Int64
 @StateObject private var vm = NotesViewModel()
 @State private var adding = false
 @State private var editing: ProgressNote?, deleting: ProgressNote?
 var body: some View { List {
 if let error = vm.error { ErrorView(message: error) { Task { await vm.load(studentId: studentId) } } }
 if vm.isLoading { LoadingView() }
 if vm.notes.isEmpty && !vm.isLoading && vm.error == nil { EmptyStateView(title: "No notes yet", message: "Record progress, participation or classroom observations.", symbol: "note.text") }
 ForEach(vm.notes) { note in VStack(alignment: .leading, spacing: 8) { Text(note.category.title).font(.headline).foregroundStyle(AppColors.primary); Text(note.content); Text(String(note.updatedAt.prefix(10))).font(.caption).foregroundStyle(.secondary) }.padding(.vertical, 6).swipeActions { Button(role: .destructive) { deleting = note } label: { Label("Delete", systemImage: "trash") }; Button { editing = note } label: { Label("Edit", systemImage: "pencil") }.tint(.blue) } }
 }.navigationTitle("Progress notes").task { await vm.load(studentId: studentId) }.refreshable { await vm.load(studentId: studentId) }
 .toolbar { Button { adding = true } label: { Label("Add note", systemImage: "plus") } }
 .sheet(isPresented: $adding) { NavigationStack { AddNoteView(studentId: studentId, vm: vm) } }
 .sheet(item: $editing) { note in NavigationStack { EditNoteView(note: note, vm: vm) } }
 .alert("Delete this note?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) { Button("Cancel", role: .cancel) { deleting = nil }; Button("Delete", role: .destructive) { if let note = deleting { Task { await vm.delete(note) } }; deleting = nil } }
 }
}
