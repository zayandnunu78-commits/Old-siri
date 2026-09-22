//
//  EraPickerView.swift
//  Classic Assistant
//

import SwiftUI

struct EraPickerView: View {
    @ObservedObject var settings: AppSettings

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(SiriEra.allCases) { era in
                    EraCard(era: era, isSelected: era == settings.era)
                        .onTapGesture { settings.era = era }
                        .accessibilityAddTraits(era == settings.era ? [.isSelected, .isButton] : .isButton)
                        .accessibilityLabel("\(era.label), \(era.yearLabel). \(era.tagline)")
                }
            }
            .padding(16)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Choose an era")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct EraCard: View {
    let era: SiriEra
    let isSelected: Bool
    private var theme: EraTheme { EraTheme(era: era) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(LinearGradient(colors: theme.accentColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 36, height: 36)
            Text(era.label).font(.headline).foregroundStyle(.white)
            Text(era.yearLabel).font(.caption).foregroundStyle(.white.opacity(0.6))
            Text(era.tagline)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.06)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.white : Color.white.opacity(0.15), lineWidth: isSelected ? 2 : 1)
        )
    }
}
