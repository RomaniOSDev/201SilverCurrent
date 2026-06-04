import SwiftUI

struct AppSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search…"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(Color("AppPrimary"))
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appCard(elevation: .flat)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct FilterChipRow<Item: Hashable>: View {
    let items: [Item]
    let title: (Item) -> String
    let isSelected: (Item) -> Bool
    let onSelect: (Item) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    FilterChip(
                        title: title(item),
                        isSelected: isSelected(item),
                        action: { onSelect(item) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppPrimary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if isSelected {
                        AppGradients.primary
                    } else {
                        AppGradients.surface
                    }
                }
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color("AppAccent").opacity(isSelected ? 0 : 0.35), lineWidth: 1)
                )
        }
        .buttonStyle(ScalePressButtonStyle())
    }
}
