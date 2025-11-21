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
            // Background gradient
            LinearGradient(
                colors: [
                    themeColor.opacity(0.1),
                    themeColor.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? themeColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, themeColor: themeColor)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage == onboardingPages.count - 1 {
                        // Get Started button on last page
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("ابدأ الآن")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(themeColor)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Next and Skip buttons
                        HStack {
                            Button {
                                completeOnboarding()
                            } label: {
                                Text("تخطي")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    currentPage += 1
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("التالي")
                                    Image(systemName: "arrow.left")
                                }
                                .foregroundStyle(themeColor)
                            }
                        }
                        .font(.headline)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
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
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(themeColor)
            }
            
            // Title and description
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            
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
