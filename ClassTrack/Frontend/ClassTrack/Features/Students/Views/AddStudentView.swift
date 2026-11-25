import SwiftUI
struct AddStudentView: View {
 @StateObject private var vm = AddStudentViewModel()
 var body: some View { StudentFormView(vm: vm, title: "Add student") }
}
struct StudentFormView: View {
 @ObservedObject var vm: AddStudentViewModel
 let title: String
 @Environment(\.dismiss) private var dismiss
 @State private var saved = false
 var body: some View { Form {
 Section("Student information") { TextField("Full name", text: $vm.form.fullName); TextField("Roll ID", text: $vm.form.rollId).textInputAutocapitalization(.characters); TextField("Class name", text: $vm.form.className)
 Picker("Subject group", selection: $vm.form.subjectGroup) { ForEach(Array(Set(Constants.subjectGroups + [vm.form.subjectGroup])).sorted(), id: \.self) { Text($0).tag($0) } }
 DatePicker("Enrollment date", selection: Binding(get: { DateHelper.date(vm.form.enrollmentDate) }, set: { vm.form.enrollmentDate = DateHelper.string($0) }), displayedComponents: .date)
 }
 Section("Academic notes") { TextEditor(text: $vm.form.academicNotes).frame(minHeight: 100).accessibilityLabel("Academic notes") }
 if let error = vm.error { ErrorView(message: error) }
 PrimaryButton(title: "Save student", loading: vm.isLoading) { Task { if await vm.save() { saved = true } } }
 }.navigationTitle(title).toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(vm.isLoading) } }.interactiveDismissDisabled(vm.isLoading)
 .alert("Student saved", isPresented: $saved) { Button("Done") { dismiss() } }
 }
}
