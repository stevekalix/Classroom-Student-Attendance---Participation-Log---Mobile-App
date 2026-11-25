import SwiftUI
struct EditStudentView: View {
 @StateObject private var vm: EditStudentViewModel
 init(student: Student) { _vm = StateObject(wrappedValue: EditStudentViewModel(student: student)) }
 var body: some View { StudentFormView(vm: vm, title: "Edit student") }
}
