import SwiftUI
struct EditNoteView: View { let note: ProgressNote; @ObservedObject var vm: NotesViewModel
 var body: some View { NoteEditorView(studentId: note.studentId, noteId: note.id, vm: vm, category: note.category, content: note.content) }
}
