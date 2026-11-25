import SwiftUI
struct EmptyStateView: View { let title: String; var message = ""; var symbol = "tray"; var body: some View { ContentUnavailableView(title, systemImage: symbol, description: Text(message)) } }
