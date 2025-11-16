//
//  SunriseSunsetCalculator.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import Foundation
import CoreLocation

struct SunriseSunsetCalculator {
    static func calculateSunriseSunset(for location: CLLocation, date: Date = Date()) -> (sunrise: Date, sunset: Date)? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Calculate day of year
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        
        // Calculate sunrise and sunset times
        let (sunriseTime, sunsetTime) = calculateSunTimes(
            dayOfYear: dayOfYear,
            latitude: latitude,
            longitude: longitude
        )
        
        // Convert to Date
        var sunriseComponents = DateComponents(year: year, month: month, day: day)
        sunriseComponents.hour = Int(sunriseTime)
        sunriseComponents.minute = Int((sunriseTime - Double(Int(sunriseTime))) * 60)
        
        var sunsetComponents = DateComponents(year: year, month: month, day: day)
        sunsetComponents.hour = Int(sunsetTime)
        sunsetComponents.minute = Int((sunsetTime - Double(Int(sunsetTime))) * 60)
        
        guard let sunrise = calendar.date(from: sunriseComponents),
              let sunset = calendar.date(from: sunsetComponents) else {
            return nil
        }
        
        return (sunrise, sunset)
    }
    
    private static func calculateSunTimes(dayOfYear: Int, latitude: Double, longitude: Double) -> (sunrise: Double, sunset: Double) {
        // Convert latitude to radians
        let latRad = latitude * .pi / 180.0
        
        // Calculate declination of the sun
        let declination = 23.45 * sin((360.0 / 365.0) * (Double(dayOfYear) - 81.0) * .pi / 180.0)
        let declRad = declination * .pi / 180.0
        
        // Calculate hour angle
        let hourAngle = acos(-tan(latRad) * tan(declRad))
        
        // Calculate sunrise and sunset in hours (UTC)
        let sunriseUTC = 12.0 - (hourAngle * 12.0 / .pi)
        let sunsetUTC = 12.0 + (hourAngle * 12.0 / .pi)
        
        // Adjust for longitude (time zone offset)
        let longitudeOffset = longitude / 15.0
        let sunrise = sunriseUTC + longitudeOffset
        let sunset = sunsetUTC + longitudeOffset
        
        // Normalize to 0-24 range
        let normalizedSunrise = sunrise.truncatingRemainder(dividingBy: 24.0)
        let normalizedSunset = sunset.truncatingRemainder(dividingBy: 24.0)
        
        return (normalizedSunrise < 0 ? normalizedSunrise + 24 : normalizedSunrise,
                normalizedSunset < 0 ? normalizedSunset + 24 : normalizedSunset)
    }
}

