import SwiftUI
struct StatusBadge: View { let status: AttendanceStatus; var body: some View { Label(status.title, systemImage: status.symbol).font(.caption.weight(.semibold)).foregroundStyle(status.color).padding(.horizontal, 8).padding(.vertical, 5).background(status.color.opacity(0.12), in: Capsule()) } }
