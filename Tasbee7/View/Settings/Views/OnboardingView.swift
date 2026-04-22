//
//  OnboardingView.swift
//  Tasbee7
//
//  Created by Assistant on 20.11.25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(AppSettings.self) private var appSettings
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 20)
                
                // App Icon
                ZStack {
                    Circle()
                        .fill(appSettings.themeColor.opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 70))
                        .foregroundStyle(appSettings.themeColor)
                        .symbolRenderingMode(.hierarchical)
                }
                .padding(.bottom, 8)
                
                // Welcome Text
                VStack(spacing: 12) {
                    Text("مرحباً بك في تسبيح")
                        .font(.system(size: 34, weight: .bold))
                    
                    Text("رفيقك اليومي للأذكار والتسبيحات")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)
                
                // Features List
                VStack(alignment: .leading, spacing: 20) {
                    OnboardingFeature(
                        icon: "book.pages.fill",
                        title: "أذكار شاملة",
                        description: "مجموعة كاملة من الأذكار اليومية من حصن المسلم",
                        themeColor: appSettings.themeColor
                    )
                    
                    OnboardingFeature(
                        icon: "bell.badge.fill",
                        title: "تذكير ذكي",
                        description: "تذكيرات بناءً على أوقات الشروق والغروب في موقعك",
                        themeColor: appSettings.themeColor
                    )
                    
                    OnboardingFeature(
                        icon: "point.3.connected.trianglepath.dotted",
                        title: "سبحة رقمية",
                        description: "عداد تسبيح مع اهتزاز لطيف لمساعدتك على الذكر",
                        themeColor: appSettings.themeColor
                    )
                    
                    OnboardingFeature(
                        icon: "star.fill",
                        title: "نظام المفضلة",
                        description: "احفظ أذكارك المفضلة للوصول السريع",
                        themeColor: appSettings.themeColor
                    )
                    
                    OnboardingFeature(
                        icon: "magnifyingglass",
                        title: "بحث متقدم",
                        description: "ابحث عن أي ذكر بسهولة وسرعة",
                        themeColor: appSettings.themeColor
                    )
                    
                    OnboardingFeature(
                        icon: "paintpalette.fill",
                        title: "تخصيص الواجهة",
                        description: "اختر اللون المفضل لديك",
                        themeColor: appSettings.themeColor
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 40)
            }
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            // Continue Button
            Button {
                completeOnboarding()
            } label: {
                Text("ابدأ الآن")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(appSettings.themeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.regularMaterial)
        }
        .appGradientBackground()
        .interactiveDismissDisabled()
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
        dismiss()
    }
}

struct OnboardingFeature: View {
    let icon: String
    let title: String
    let description: String
    let themeColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(themeColor)
                    .symbolRenderingMode(.hierarchical)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppSettings())
}
