import SwiftUI
struct CustomTextField: View { let title: String; @Binding var text: String; var body: some View { TextField(title, text: $text).textFieldStyle(.roundedBorder).accessibilityLabel(title) } }
