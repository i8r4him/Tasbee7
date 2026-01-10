//
//  OnboardingView.swift
//  Tasbee7
//
//  Created by Assistant on 20.11.25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, themeColor: themeColor)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom section
                VStack(spacing: 24) {
                    // Page indicator
                    HStack(spacing: 6) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? themeColor : Color.secondary.opacity(0.3))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Action button
                    Button {
                        if currentPage == onboardingPages.count - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        }
                    } label: {
                        Text(currentPage == onboardingPages.count - 1 ? "ابدأ الآن" : "متابعة")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(themeColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
            }
        }
        .gradientBackground(
            startColor: themeColor.opacity(0.3),
            endColor: .clear
        )
        .interactiveDismissDisabled()
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
        dismiss()
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon with circular background - matching app aesthetic
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(themeColor)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.bottom, 50)
            
            // Title - Large and bold
            Text(page.title)
                .font(.system(size: 34, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 16)
            
            // Description - Readable and clear
            Text(page.description)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "book.pages.fill",
        title: "أذكار شاملة",
        description: "مجموعة كاملة من الأذكار اليومية من حصن المسلم، منظمة بشكل سهل وواضح"
    ),
    OnboardingPage(
        icon: "bell.badge.fill",
        title: "تذكير ذكي",
        description: "احصل على تذكيرات أذكار الصباح والمساء بناءً على أوقات الشروق والغروب في موقعك"
    ),
    OnboardingPage(
        icon: "point.3.connected.trianglepath.dotted",
        title: "سبحة رقمية",
        description: "سبحة إلكترونية مع اهتزاز لطيف لمساعدتك على التسبيح والذكر"
    ),
    OnboardingPage(
        icon: "star.fill",
        title: "المفضلة",
        description: "احفظ الأذكار المفضلة لديك للوصول السريع إليها في أي وقت"
    ),
    OnboardingPage(
        icon: "magnifyingglass",
        title: "بحث سريع",
        description: "ابحث عن أي ذكر بسهولة وسرعة من خلال البحث المتقدم"
    ),
    OnboardingPage(
        icon: "paintpalette.fill",
        title: "تخصيص الواجهة",
        description: "اختر اللون المفضل لديك وخصص تجربتك في التطبيق"
    )
]

#Preview {
    OnboardingView()
}
