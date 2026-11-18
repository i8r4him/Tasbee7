//
//  Occasions.swift
//  Tasbee7
//
//  What makes today special: Friday, Monday and Thursday fasting, the white days, Ramadan,
//  the ten days of Dhul Hijjah, Arafah, the two Eids, Ashura and the six days of Shawwal.
//  Hijri dates come from the Umm al-Qura calendar, which can differ from local moon sighting by a day.
//

import Foundation

struct Occasion: Identifiable, Hashable {
    enum Kind: String {
        case eidFitr, eidAdha, tashreeq, arafah, dhulHijjahTen
        case ramadan, lastTenNights, tasua, ashura, shawwalSix
        case whiteDays, whiteDaysTomorrow
        case friday, mondayFast, thursdayFast, mondayTomorrow, thursdayTomorrow
    }

    let kind: Kind
    let title: String
    let detail: String
    let systemImage: String
    /// A chapter of the book that goes with the day, if there is one.
    var chapterTitle: String?

    var id: Kind { kind }
}

enum Occasions {
    private enum HijriMonth {
        static let muharram = 1
        static let ramadan = 9
        static let shawwal = 10
        static let dhulHijjah = 12
    }

    /// Today's occasions, most important first.
    static func on(_ date: Date, calendar: Calendar = .current) -> [Occasion] {
        var hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        hijriCalendar.timeZone = calendar.timeZone

        let hijri = hijriCalendar.dateComponents([.month, .day], from: date)
        guard let month = hijri.month, let day = hijri.day else { return [] }
        let weekday = calendar.component(.weekday, from: date) // 1 = Sunday

        var result: [Occasion] = []
        func add(_ kind: Occasion.Kind, _ title: String, _ detail: String, _ symbol: String, chapter: String? = nil) {
            result.append(Occasion(kind: kind, title: title, detail: detail, systemImage: symbol, chapterTitle: chapter))
        }

        // Feasts first: they also mean "don't fast today".
        switch (month, day) {
        case (HijriMonth.shawwal, 1):
            add(.eidFitr, "عيد الفطر", "تقبّل الله منا ومنكم. لا يُصام يوم العيد.", "sparkles")
        case (HijriMonth.dhulHijjah, 10):
            add(.eidAdha, "عيد الأضحى", "تقبّل الله منا ومنكم. أكثِر من التكبير، ولا يُصام يوم العيد.", "sparkles")
        case (HijriMonth.dhulHijjah, 11...13):
            add(.tashreeq, "أيام التشريق", "أيام أكل وشرب وذكر لله، فأكثِر فيها من التكبير، ولا تُصام.", "sparkles")
        case (HijriMonth.dhulHijjah, 9):
            add(.arafah, "يوم عرفة", "صيامه يكفّر السنة الماضية والباقية، وخير الدعاء دعاء يوم عرفة.",
                "mountain.2.fill", chapter: "الدعاء يوم عرفة")
        case (HijriMonth.dhulHijjah, 1...8):
            add(.dhulHijjahTen, "العشر من ذي الحجة", "أفضل أيام الدنيا، فأكثِر فيها من التهليل والتكبير والتحميد.",
                "sparkles")
        case (HijriMonth.muharram, 9):
            add(.tasua, "تاسوعاء", "يُستحب صيامه مع يوم عاشوراء.", "moon.fill")
        case (HijriMonth.muharram, 10):
            add(.ashura, "يوم عاشوراء", "صيامه يكفّر السنة التي قبله.", "moon.fill")
        case (HijriMonth.shawwal, 2...30):
            add(.shawwalSix, "ست من شوال", "من صام رمضان ثم أتبعه ستاً من شوال كان كصيام الدهر.", "calendar")
        default:
            break
        }

        if month == HijriMonth.ramadan {
            if day >= 21 {
                add(.lastTenNights, "العشر الأواخر",
                    "التمس ليلة القدر، وأكثِر من: اللهم إنك عفوٌّ تحب العفو فاعفُ عني.", "sparkles")
            }
            add(.ramadan, "رمضان", "شهر الصيام والقيام والقرآن.", "moon.stars.fill",
                chapter: "الدعاء عند إفطار الصائم")
        }

        let noFastToday = isForbiddenToFast(month: month, day: day) || month == HijriMonth.ramadan

        // The white days: 13, 14 and 15 of each month (13 Dhul Hijjah is a day of Tashreeq).
        if !noFastToday, (13...15).contains(day) {
            add(.whiteDays, "الأيام البيض", "يُستحب صيام الثالث عشر والرابع عشر والخامس عشر من كل شهر هجري.",
                "moon.fill")
        } else if day == 12, month != HijriMonth.ramadan, month != HijriMonth.dhulHijjah {
            add(.whiteDaysTomorrow, "غداً تبدأ الأيام البيض", "يُستحب صيامها، فانوِ الصيام من الليل.", "moon.fill")
        }

        if weekday == 6 {
            add(.friday, "يوم الجمعة", "اقرأ سورة الكهف، وأكثِر من الصلاة على النبي ﷺ.", "building.columns.fill",
                chapter: "فضل الصلاة على النبي صلى الله عليه وسلم")
        }

        if !noFastToday {
            if weekday == 2 { add(.mondayFast, "صيام الاثنين", "يُستحب صيام يوم الاثنين.", "calendar") }
            if weekday == 5 { add(.thursdayFast, "صيام الخميس", "يُستحب صيام يوم الخميس.", "calendar") }
        }

        // The evening before, so there's time to intend the fast.
        if weekday == 1 || weekday == 4,
           let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) {
            let next = hijriCalendar.dateComponents([.month, .day], from: tomorrow)
            let blocked = next.month == HijriMonth.ramadan
                || isForbiddenToFast(month: next.month ?? 0, day: next.day ?? 0)
            if !blocked {
                if weekday == 1 {
                    add(.mondayTomorrow, "غداً الاثنين", "يُستحب صيامه، فانوِ الصيام من الليل.", "calendar")
                } else {
                    add(.thursdayTomorrow, "غداً الخميس", "يُستحب صيامه، فانوِ الصيام من الليل.", "calendar")
                }
            }
        }

        return result
    }

    /// The two Eids and the days of Tashreeq.
    static func isForbiddenToFast(month: Int, day: Int) -> Bool {
        (month == HijriMonth.shawwal && day == 1)
            || (month == HijriMonth.dhulHijjah && (10...13).contains(day))
    }
}
