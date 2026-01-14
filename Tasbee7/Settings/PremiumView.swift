//
//  PremiumView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 14.01.26.
//

import SwiftUI
import StoreKit

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.subscriptionIDs.group) private var subscriptionGroupID
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    var body: some View {
        SubscriptionStoreView(groupID: subscriptionGroupID) {
            PremiumShopContent(themeColor: themeColor)
        }
        .backgroundStyle(.clear)
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.prominentPicker)
        .navigationTitle("عضوية تسبيح")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Premium Shop Content

private struct PremiumShopContent: View {
    let themeColor: Color
    
    var body: some View {
        VStack {
            iconImage
            VStack(spacing: 3) {
                title
                description
            }
        }
        .padding(.vertical)
        .padding(.top, 40)
    }
    
    @ViewBuilder
    private var iconImage: some View {
        Image(systemName: "crown.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100)
            .foregroundStyle(themeColor)
            .symbolRenderingMode(.hierarchical)
    }
    
    @ViewBuilder
    private var title: some View {
        Text("عضوية تسبيح")
            .font(.largeTitle.bold())
    }
    
    @ViewBuilder
    private var description: some View {
        Text("استمتع بميزات حصرية مع عضوية تسبيح: إحصائيات متقدمة، ودجات مخصصة، وميزات إضافية، ودعم التطوير.")
            .fixedSize(horizontal: false, vertical: true)
            .font(.title3.weight(.medium))
            .padding([.bottom, .horizontal])
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Premium Box (for Settings)

struct PremiumBox: View {
    let themeColor: Color
    
    var body: some View {
        ZStack {
            // Animated Mesh Gradient Background
            if #available(iOS 18.0, *) {
                AnimatedMeshGradient(themeColor: themeColor)
            } else {
                // Fallback gradient for iOS 17 and below
                LinearGradient(
                    colors: [themeColor, themeColor.opacity(0.7), themeColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // Content
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text("عضوية تسبيح")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    
                    // Description
                    Text("ميزات حصرية ودعم التطوير")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
        }
        .cornerRadius(25)
        .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.vertical, 4)
    }
}

// MARK: - Animated Mesh Gradient

struct AnimatedMeshGradient: View {
    let themeColor: Color
    
    @State private var colors: [Color] = []
    @State private var timer: Timer?
    
    // 2x2 mesh grid points
    private let points: [SIMD2<Float>] = [
        [0, 0], [1, 0],
        [0, 1], [1, 1]
    ]
    
    var body: some View {
        MeshGradient(
            width: 2,
            height: 2,
            points: points,
            colors: colors.isEmpty ? initialColors : colors
        )
        .onAppear {
            colors = initialColors
            startAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var initialColors: [Color] {
        [
            themeColor.opacity(0.8),
            themeColor,
            themeColor,
            themeColor.opacity(0.8)
        ]
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3.0)) {
                colors = [
                    randomColorVariation(),
                    randomColorVariation(),
                    randomColorVariation(),
                    randomColorVariation()
                ]
            }
        }
    }
    
    private func randomColorVariation() -> Color {
        let components = themeColor.components
        return Color(
            red: max(0, min(1, components.red + Double.random(in: -0.2...0.2))),
            green: max(0, min(1, components.green + Double.random(in: -0.2...0.2))),
            blue: max(0, min(1, components.blue + Double.random(in: -0.2...0.2)))
        )
    }
}

// Extension for color components
extension Color {
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return (0, 0, 0, 0)
        }
        
        return (Double(r), Double(g), Double(b), Double(o))
    }
}

#Preview {
    PremiumView()
}
