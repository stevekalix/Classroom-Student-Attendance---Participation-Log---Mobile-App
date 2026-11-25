import SwiftUI
struct AddNoteView: View {
 let studentId: Int64
 @ObservedObject var vm: NotesViewModel
 var body: some View { NoteEditorView(studentId: studentId, vm: vm) }
}
struct NoteEditorView: View {
 let studentId: Int64
 var noteId: Int64? = nil
 @ObservedObject var vm: NotesViewModel
 @State var category: NoteCategory = .participation
 @State var content = ""
 @Environment(\.dismiss) private var dismiss
 var body: some View { Form {
 Picker("Category", selection: $category) { ForEach(NoteCategory.allCases) { Text($0.title).tag($0) } }
 Section("Observation") { TextEditor(text: $content).frame(minHeight: 200).accessibilityLabel("Note content"); Text("\(content.count) / 10,000").font(.caption).foregroundStyle(.secondary) }
 if let error = vm.error { ErrorView(message: error) }
 PrimaryButton(title: "Save note", loading: vm.isSaving) { Task { if await vm.save(studentId: studentId, noteId: noteId, category: category, content: content) { dismiss() } } }
 }.navigationTitle(noteId == nil ? "Add note" : "Edit note").toolbar { Button("Cancel") { dismiss() }.disabled(vm.isSaving) }.interactiveDismissDisabled(vm.isSaving) }
}
