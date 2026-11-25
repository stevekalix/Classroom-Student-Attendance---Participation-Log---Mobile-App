import SwiftUI

struct AttendanceHistoryView: View {
    @ObservedObject var vm: StudentDetailViewModel
    let studentId: Int64
    @State private var selectedRecord: Attendance?
    @State private var selectedStatus: AttendanceStatus = .present

    var body: some View {
        List {
            if let error = vm.error {
                ErrorView(message: error) { Task { await vm.load(studentId) } }
            }
            if let message = vm.attendanceMessage {
                Label(message, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            if vm.isLoading || vm.isSavingAttendance { LoadingView() }
            if vm.history.isEmpty && !vm.isLoading && vm.error == nil {
                EmptyStateView(title: "No attendance recorded")
            }
            ForEach(vm.history) { record in
                HStack {
                    Text(record.attendanceDate)
                    Spacer()
                    Menu {
                        ForEach([AttendanceStatus.present, .absent, .late]) { status in
                            Button {
                                selectedStatus = status
                                selectedRecord = record
                            } label: {
                                Label(status.title, systemImage: status.symbol)
                            }
                            .disabled(status == record.status)
                        }
                    } label: {
                        StatusBadge(status: record.status)
                    }
                    .disabled(vm.isLoading || vm.isSavingAttendance)
                    .accessibilityLabel("Edit attendance for \(record.attendanceDate), currently \(record.status.title)")
                }
            }
        }
        .navigationTitle("Attendance history")
        .refreshable { if !vm.isSavingAttendance { await vm.load(studentId) } }
        .confirmationDialog("Update saved attendance?", isPresented: Binding(
            get: { selectedRecord != nil },
            set: { if !$0 { selectedRecord = nil } }
        ), titleVisibility: .visible) {
            Button("Mark \(selectedStatus.title)") {
                guard let record = selectedRecord else { return }
                let status = selectedStatus
                selectedRecord = nil
                Task { await vm.updateAttendance(record, status: status) }
            }
            Button("Cancel", role: .cancel) { selectedRecord = nil }
        } message: {
            Text("The saved status for \(selectedRecord?.attendanceDate ?? "this date") will be changed.")
        }
    }
}