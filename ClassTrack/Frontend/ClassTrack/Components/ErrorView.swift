import SwiftUI
struct ErrorView: View { let message: String; var retry: (() -> Void)?
 var body: some View { VStack(spacing: 12) { Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red); if let retry { Button("Try again", action: retry) } }.padding().accessibilityElement(children: .combine) }
}
