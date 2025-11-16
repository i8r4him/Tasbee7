//
//  NotificationsSettingsView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI
import CoreLocation

struct NotificationsSettingsView: View {
    @AppStorage("morningReminderEnabled") private var morningEnabled: Bool = false
    @AppStorage("eveningReminderEnabled") private var eveningEnabled: Bool = false
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    @State private var locationManager = LocationManager.shared
    @State private var notificationManager = NotificationManager.shared
    @State private var sunriseTime: Date?
    @State private var sunsetTime: Date?
    @State private var isLoading = false
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    private var locationStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "غير محدد"
        case .denied, .restricted:
            return "مرفوض"
        case .authorizedWhenInUse, .authorizedAlways:
            return "مسموح"
        @unknown default:
            return "غير معروف"
        }
    }
    
    var body: some View {
        Form {
            Section {
                // Location Status
                HStack {
                    Text("حالة الموقع")
                    Spacer()
                    Text(locationStatusText)
                        .foregroundStyle(.secondary)
                }
                
                if locationManager.authorizationStatus != .authorizedWhenInUse && 
                   locationManager.authorizationStatus != .authorizedAlways {
                    Button {
                        locationManager.requestPermission()
                    } label: {
                        Text("السماح بالوصول للموقع")
                            .foregroundStyle(themeColor)
                    }
                }
                
                if let location = locationManager.location {
                    HStack {
                        Text("الموقع")
                        Spacer()
                        Text(String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("الموقع")
            } footer: {
                Text("نحتاج موقعك لحساب أوقات شروق وغروب الشمس بدقة")
            }
            
            Section {
                // Sunrise/Sunset Times
                if let sunrise = sunriseTime, let sunset = sunsetTime {
                    HStack {
                        Image(systemName: "sunrise.fill")
                            .foregroundStyle(.orange)
                        Text("شروق الشمس")
                        Spacer()
                        Text(sunrise, style: .time)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "sunset.fill")
                            .foregroundStyle(.orange)
                        Text("غروب الشمس")
                        Spacer()
                        Text(sunset, style: .time)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("احصل على الموقع أولاً")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            } header: {
                Text("أوقات الشمس")
            }
            
            Section {
                Toggle(isOn: $morningEnabled) {
                    Label("تذكير أذكار الصباح", systemImage: "sunrise.fill")
                }
                .tint(themeColor)
                .onChange(of: morningEnabled) { _, newValue in
                    Task {
                        await notificationManager.scheduleMorningReminder(enabled: newValue)
                    }
                }
                
                if morningEnabled, let sunrise = sunriseTime {
                    HStack {
                        Text("وقت التذكير")
                        Spacer()
                        if let reminderTime = Calendar.current.date(byAdding: .minute, value: 15, to: sunrise) {
                            Text(reminderTime, style: .time)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Toggle(isOn: $eveningEnabled) {
                    Label("تذكير أذكار المساء", systemImage: "sunset.fill")
                }
                .tint(themeColor)
                .onChange(of: eveningEnabled) { _, newValue in
                    Task {
                        await notificationManager.scheduleEveningReminder(enabled: newValue)
                    }
                }
                
                if eveningEnabled, let sunset = sunsetTime {
                    HStack {
                        Text("وقت التذكير")
                        Spacer()
                        if let reminderTime = Calendar.current.date(byAdding: .minute, value: 15, to: sunset) {
                            Text(reminderTime, style: .time)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("التذكيرات")
            } footer: {
                Text("سيتم إرسال التذكير بعد 15 دقيقة من شروق/غروب الشمس")
            }
            
            #if DEBUG
            Section {
                Button {
                    Task {
                        await notificationManager.sendTestNotification(type: .morning)
                    }
                } label: {
                    HStack {
                        Image(systemName: "bell.badge")
                        Text("اختبار إشعار الصباح")
                        Spacer()
                        Text("5 ثواني")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(themeColor)
                
                Button {
                    Task {
                        await notificationManager.sendTestNotification(type: .evening)
                    }
                } label: {
                    HStack {
                        Image(systemName: "bell.badge")
                        Text("اختبار إشعار المساء")
                        Spacer()
                        Text("5 ثواني")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(themeColor)
            } header: {
                Text("اختبار الإشعارات")
            } footer: {
                Text("اضغط لاختبار الإشعار - سيصل بعد 5 ثواني")
            }
            #endif
        }
        .navigationTitle("الإشعارات")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSunTimes()
        }
        .onChange(of: locationManager.location) { _, _ in
            loadSunTimes()
        }
        .onChange(of: locationManager.authorizationStatus) { _, _ in
            if locationManager.authorizationStatus == .authorizedWhenInUse || 
               locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startLocationUpdates()
                loadSunTimes()
            }
        }
    }
    
    private func loadSunTimes() {
        guard let location = locationManager.location else {
            if locationManager.authorizationStatus == .authorizedWhenInUse || 
               locationManager.authorizationStatus == .authorizedAlways {
                isLoading = true
                locationManager.startLocationUpdates()
            }
            return
        }
        
        isLoading = true
        let times = SunriseSunsetCalculator.calculateSunriseSunset(for: location)
        sunriseTime = times?.sunrise
        sunsetTime = times?.sunset
        isLoading = false
        
        // Update notifications when location changes
        Task {
            await notificationManager.updateSchedules()
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
}
