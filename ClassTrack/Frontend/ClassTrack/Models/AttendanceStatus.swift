import SwiftUI
enum AttendanceStatus: String, Codable, CaseIterable, Identifiable {
 case present = "PRESENT", absent = "ABSENT", late = "LATE", unmarked = "UNMARKED"
 var id: String { rawValue }
 var title: String { rawValue.capitalized }
 var symbol: String { switch self { case .present: "checkmark.circle.fill"; case .absent: "xmark.circle.fill"; case .late: "clock.fill"; case .unmarked: "minus.circle" } }
 var color: Color { switch self { case .present: .green; case .absent: .red; case .late: .orange; case .unmarked: .secondary } }
}
