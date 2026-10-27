//
//  LCDesign.swift
//  LiveContainerSwiftUI
//
//  App-wide theme: palette, backdrop, glass cards, floating tab bar, navigation bar styling.
//

import SwiftUI
import UIKit

enum LCDesign {
    enum Radius {
        static let card: CGFloat = 24
        static let icon: CGFloat = 14
        static let chip: CGFloat = 8
    }

    enum Size {
        static let bannerHeight: CGFloat = 208
        static let icon: CGFloat = 62
        static let runButton = CGSize(width: 78, height: 36)
        static let badge: CGFloat = 18
    }

    enum Spacing {
        static let cardInset: CGFloat = 14
        static let list: CGFloat = 12
    }

    /// Strength of the icon-colour wash on a card, top-left corner -> bottom-right corner.
    static func washAlphas(isDark: Bool) -> (start: CGFloat, end: CGFloat) {
        isDark ? (0.42, 0.06) : (0.30, 0.04)
    }

    static var fallbackAccent: UIColor {
        UIColor(named: "FontColor") ?? LCTheme.uiViolet
    }

    /// Two or more columns of app cards, depending on the width.
    static let gridColumns = [GridItem(.adaptive(minimum: 158, maximum: 280), spacing: Spacing.list)]
}

enum LCTheme {
    static let uiViolet = UIColor(red: 0.486, green: 0.361, blue: 1.0, alpha: 1)
    static let uiCyan = UIColor(red: 0.133, green: 0.827, blue: 0.933, alpha: 1)
    static let violet = Color(uiViolet)
    static let cyan = Color(uiCyan)

    static var gradient: LinearGradient {
        LinearGradient(colors: [violet, cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Call once at start-up: navigation bar look, transparent list backgrounds on iOS 15.
    static func apply() {
        func rounded(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            guard let descriptor = base.fontDescriptor.withDesign(.rounded) else {
                return base
            }
            return UIFont(descriptor: descriptor, size: size)
        }

        let standard = UINavigationBarAppearance()
        standard.configureWithDefaultBackground()
        standard.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        standard.backgroundColor = .clear
        standard.shadowColor = .clear
        standard.titleTextAttributes = [.font: rounded(17, .bold)]
        standard.largeTitleTextAttributes = [.font: rounded(34, .heavy)]

        let edge = UINavigationBarAppearance()
        edge.configureWithTransparentBackground()
        edge.titleTextAttributes = standard.titleTextAttributes
        edge.largeTitleTextAttributes = standard.largeTitleTextAttributes

        let bar = UINavigationBar.appearance()
        bar.standardAppearance = standard
        bar.compactAppearance = standard
        bar.scrollEdgeAppearance = edge
        bar.tintColor = uiViolet

        UITableView.appearance().backgroundColor = .clear
    }
}

/// Deep gradient with two soft colour glows. Put it behind a screen with `.lcScreen()`.
struct LCBackdrop: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let dark = scheme == .dark
        ZStack {
            LinearGradient(
                colors: dark
                    ? [Color(red: 0.035, green: 0.043, blue: 0.102), Color(red: 0.078, green: 0.059, blue: 0.180)]
                    : [Color(red: 0.957, green: 0.945, blue: 1.0), Color(red: 0.910, green: 0.953, blue: 1.0)],
                startPoint: .top, endPoint: .bottom)
            Circle()
                .fill(LCTheme.violet.opacity(dark ? 0.38 : 0.22))
                .frame(width: 360, height: 360)
                .blur(radius: 90)
                .offset(x: -150, y: -280)
            Circle()
                .fill(LCTheme.cyan.opacity(dark ? 0.24 : 0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 160, y: 300)
        }
        .ignoresSafeArea()
    }
}

/// Compact section label used between groups of cards (e.g. "Hidden Apps").
struct LCSectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold))
            Text(title.uppercased())
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .tracking(0.8)
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .accessibilityAddTraits(.isHeader)
    }
}

/// Brand card on top of the app list.
struct LCAppsHero: View {
    let appCount: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LCTheme.gradient)
                    .frame(width: 52, height: 52)
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("LiveContainer")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                Text("lc.appList.appCounter %lld".localizeWithFormat(appCount))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .lcCard(tint: LCTheme.violet)
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

/// Floating pill that replaces the system tab bar.
struct LCFloatingTabBar: View {
    struct Item: Identifiable {
        let id: LCTabIdentifier
        let title: String
        let icon: String
    }

    let items: [Item]
    @Binding var selection: LCTabIdentifier
    @Namespace private var pillNamespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items) { item in
                let selected = selection == item.id
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                        selection = item.id
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.system(size: 17, weight: .semibold))
                        if selected {
                            Text(item.title)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(selected ? Color.white : Color.secondary)
                    .padding(.horizontal, selected ? 16 : 14)
                    .frame(height: 44)
                    .background {
                        if selected {
                            Capsule()
                                .fill(LCTheme.gradient)
                                .matchedGeometryEffect(id: "pill", in: pillNamespace)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.primary.opacity(0.10), lineWidth: 1))
        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 8)
        .padding(.bottom, 6)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

extension View {
    /// Glass card surface shared by SwiftUI screens and the UIKit app card.
    func lcCard(tint: Color? = nil) -> some View {
        background {
            RoundedRectangle(cornerRadius: LCDesign.Radius.card, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    if let tint {
                        RoundedRectangle(cornerRadius: LCDesign.Radius.card, style: .continuous)
                            .fill(LinearGradient(colors: [tint.opacity(0.30), tint.opacity(0.04)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: LCDesign.Radius.card, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.10), lineWidth: 1)
                }
        }
    }

    /// Gradient backdrop behind a screen, with list/scroll system backgrounds hidden.
    @ViewBuilder
    func lcScreen() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden).background(LCBackdrop())
        } else {
            self.background(LCBackdrop())
        }
    }
}
