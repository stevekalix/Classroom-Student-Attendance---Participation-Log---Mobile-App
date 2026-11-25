import SwiftUI
struct DashboardCard: View { let title: String; let value: String; let symbol: String; var color: Color = AppColors.primary
 var body: some View { VStack(alignment: .leading, spacing: 12) { Image(systemName: symbol).foregroundStyle(color); Text(value).font(.system(.title, design: .rounded).bold()); Text(title).font(.subheadline).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading).padding().background(AppColors.card, in: RoundedRectangle(cornerRadius: 18)).accessibilityElement(children: .combine) }
}
