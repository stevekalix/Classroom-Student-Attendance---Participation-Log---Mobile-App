import Foundation
import Combine
@MainActor final class AppRouter: ObservableObject { @Published var tab = 0; @Published var showAddStudent = false }
