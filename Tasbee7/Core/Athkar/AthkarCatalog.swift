//
//  AthkarCatalog.swift
//  Tasbee7
//
//  The table of contents of Hisn al-Muslim: groups in order, each with its chapter titles in order.
//  This is the single source of truth for grouping, ordering and group symbols.
//  To add a chapter, add its exact JSON title to the right group.
//

import Foundation

struct CatalogGroup: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let systemImage: String
    let titles: [String]
}

enum AthkarCatalog {
    /// The chapter that the morning and evening reminders open.
    static let morningEveningTitle = "أذكار الصباح والمساء"

    static let groups: [CatalogGroup] = [
        CatalogGroup(
            name: "مقدمة",
            systemImage: "book.fill",
            titles: [
                "المقدمة",
                "فضل الذكر"
            ]
        ),
        CatalogGroup(
            name: "الاستيقاظ والنوم",
            systemImage: "bed.double.fill",
            titles: [
                "أذكار الاستيقاظ من النوم",
                "أذكار النوم",
                "الدعاء إذا تقلب ليلاً",
                "دعاء القلق والفزع في النوم ومن بلي بالوحشة",
                "ما يفعل من رأى الرؤيا أو الحلم"
            ]
        ),
        CatalogGroup(
            name: "الصباح والمساء",
            systemImage: "sun.horizon.fill",
            titles: [
                "أذكار الصباح والمساء"
            ]
        ),
        CatalogGroup(
            name: "الصلاة",
            systemImage: "hands.sparkles.fill",
            titles: [
                "دعاء الذهاب إلى المسجد",
                "دعاء دخول المسجد",
                "دعاء الخروج من المسجد",
                "أذكار الأذان",
                "دعاء الاستفتاح",
                "دعاء الركوع",
                "دعاء الرفع من الركوع",
                "دعاء السجود",
                "دعاء الجلسة بين السجدتين",
                "دعاء سجود التلاوة",
                "التشهد",
                "الصلاة على النبي صلى الله عليه وسلم بعد التشهد",
                "الدعاء بعد التشهد الأخير وقبل السلام",
                "الأذكار بعد السلام من الصلاة",
                "دعاء قنوت الوتر",
                "الذكر عقب السلام من الوتر",
                "دعاء صلاة الاستخارة"
            ]
        ),
        CatalogGroup(
            name: "الوضوء",
            systemImage: "drop.fill",
            titles: [
                "الذكر قبل الوضوء",
                "الذكر بعد الفراغ من الوضوء"
            ]
        ),
        CatalogGroup(
            name: "الثياب",
            systemImage: "tshirt.fill",
            titles: [
                "دعاء لبس الثوب",
                "دعاء لبس الثوب الجديد",
                "الدعاء لمن لبس ثوباً جديداً",
                "ما يقول إذا وضع الثوب"
            ]
        ),
        CatalogGroup(
            name: "الخلاء",
            systemImage: "toilet.fill",
            titles: [
                "دعاء دخول الخلاء",
                "دعاء الخروج من الخلاء"
            ]
        ),
        CatalogGroup(
            name: "المنزل",
            systemImage: "house.fill",
            titles: [
                "الذكر عند الخروج من المنزل",
                "الذكر عند الدخول المنزل"
            ]
        ),
        CatalogGroup(
            name: "الطعام",
            systemImage: "fork.knife",
            titles: [
                "الدعاء قبل الطعام",
                "الدعاء عند الفراغ من الطعام",
                "دعاء الضيف لصاحب الطعام",
                "الدعاء لمن سقاه أو إذا أراد ذلك",
                "الدعاء إذا أفطر عند أهل بيت",
                "دعاء الصائم إذا حضر الطعام ولم يفطر",
                "ما يقول الصائم إذا سابه أحد",
                "الدعاء عند إفطار الصائم"
            ]
        ),
        CatalogGroup(
            name: "العطاس",
            systemImage: "face.smiling",
            titles: [
                "دعاء العطاس",
                "ما يقالُ للكافر إذا عطس فحمد الله"
            ]
        ),
        CatalogGroup(
            name: "الزواج",
            systemImage: "heart.fill",
            titles: [
                "الدعاء للمتزوج",
                "دعاء المتزوج لنفسه ودعاء شراء الدابة",
                "الدعاء قبل إتيان الزوجة"
            ]
        ),
        CatalogGroup(
            name: "المرض والوفاة",
            systemImage: "cross.case.fill",
            titles: [
                "الدعاء للمريض في عيادته",
                "فضل عيادة المريض",
                "دعاء المريض الذي يئس من حياته",
                "تلقين المحتضر",
                "دعاء من أصيب بمصيبة",
                "الدعاء عند إغماض الميت",
                "الدعاء للميت في الصلاة عليه",
                "الدعاء للفرط في الصلاة عليه",
                "دعاء التعزية",
                "الدعاء عند إدخال الميت القبر",
                "الدعاء بعد دفن الميت",
                "دعاء زيارة القبور",
                "ما يقول من أحس وجعاً في جسده"
            ]
        ),
        CatalogGroup(
            name: "المولود",
            systemImage: "figure.child",
            titles: [
                "تهنئة المولود له وجوابه",
                "ما يعوذ به الأولاد"
            ]
        ),
        CatalogGroup(
            name: "السفر",
            systemImage: "airplane",
            titles: [
                "دعاء السفر",
                "دعاء ركوب الدابة",
                "دعاء دخول القرية أو البلدة",
                "دعاء دخول السوق",
                "الدعاء إذا تعس المركوب",
                "دعاء المسافر للمقيم",
                "دعاء المقيم للمسافر",
                "التكبير والتسبيح في سير السفر",
                "دعاء المسافر إذا أسحر",
                "الدعاء إذا نزل منزلا في سفر أو غيره",
                "ذكر الرجوع من السفر"
            ]
        ),
        CatalogGroup(
            name: "الحج",
            systemImage: "building.columns.fill",
            titles: [
                "كيف يلبي المحرم في الحج أو العمرة",
                "التكبيرة إذا أتي الركن الأسود",
                "الدعاء بين الركن اليماني والحجر الأسود",
                "دعاء الوقوف على الصفا والمروة",
                "الدعاء يوم عرفة",
                "الذكر عند المشعر الحرام",
                "التكبيرة عند رمي الجمار مع كل حصاة"
            ]
        ),
        CatalogGroup(
            name: "الطبيعة",
            systemImage: "cloud.fill",
            titles: [
                "دعاء الريح",
                "دعاء الرعد",
                "من أدعية الاستسقاء",
                "الدعاء إذا نزل المطر",
                "الذكر بعد نزول المطر",
                "من أدعية الاستصحاء",
                "دعاء رؤية الهلال",
                "الدعاء عند رؤية باكورة الثمر"
            ]
        ),
        CatalogGroup(
            name: "الحيوانات",
            systemImage: "pawprint.fill",
            titles: [
                "دعاء صياح الديك ونهيق الحمار",
                "دعاء نباح الكلاب بالليل"
            ]
        ),
        CatalogGroup(
            name: "الهم والحزن والكرب",
            systemImage: "heart.text.square.fill",
            titles: [
                "دعاء الهم والحزن",
                "دعاء الكرب",
                "الدعاء حينما يقع مالا يرضاه أو غلب على أمره",
                "ما يقول ويفعل من أتاه أمر يسره أو يكرهه",
                "ما يفعل من أتاه أمر يسره",
                "ما يقول عند التعجب والأمر السار"
            ]
        ),
        CatalogGroup(
            name: "الشيطان والوسوسة",
            systemImage: "eye.trianglebadge.exclamationmark",
            titles: [
                "دعاء الوسوسة في الصلاة والقراءة",
                "دعاء طرد الشيطان ووساوسه",
                "دعاء من أصابه شك في الإيمان",
                "ما يعصم به من الدجال"
            ]
        ),
        CatalogGroup(
            name: "العدو والسلطان",
            systemImage: "shield.fill",
            titles: [
                "دعاء لقاء العدو وذي السلطان",
                "دعاء من خاف ظلم السلطان",
                "الدعاء على العدو",
                "ما يقول من خاف قوماً"
            ]
        ),
        CatalogGroup(
            name: "الدين والمال",
            systemImage: "dollarsign.circle.fill",
            titles: [
                "الدعاء قضاء الدين",
                "الدعاء لمن أقرض عند القضاء",
                "الدعاء لمن عرض عليك ماله"
            ]
        ),
        CatalogGroup(
            name: "الغضب",
            systemImage: "flame.fill",
            titles: [
                "دعاء الغضب"
            ]
        ),
        CatalogGroup(
            name: "العين",
            systemImage: "eye.fill",
            titles: [
                "دعاء من خشي أن يصيب شيئاً بعينه",
                "دعاء من رأى مبتلى"
            ]
        ),
        CatalogGroup(
            name: "المجلس",
            systemImage: "person.3.fill",
            titles: [
                "ما يقال في المجلس",
                "كفارة المجلس ومايختم به المجالس"
            ]
        ),
        CatalogGroup(
            name: "السلام",
            systemImage: "hand.wave.fill",
            titles: [
                "إفشاء السلام",
                "كيف يرد السلام على الكافر إذا سلم"
            ]
        ),
        CatalogGroup(
            name: "الدعاء للمسلمين",
            systemImage: "person.2.fill",
            titles: [
                "الدعاء لمن قال إني أحبك في الله",
                "الدعاء لمن قال غفر الله لك",
                "الدعاء لمن قال بارك الله فيك",
                "الدعاء لمن سببته",
                "ما يقول المسلم إذا مدح المسلم",
                "ما يقول المسلم إذا زكي",
                "الدعاء لمن صنع إليك معروفاً"
            ]
        ),
        CatalogGroup(
            name: "الذكر والتسبيح",
            systemImage: "sparkles",
            titles: [
                "فضل التسبيح والتحميد ، والتهليل ، والتكبير",
                "كيف كان النبي صلى الله عليه وسلم يسبح ؟",
                "من أنواع الخير والآداب الجامعة"
            ]
        ),
        CatalogGroup(
            name: "الصلاة على النبي",
            systemImage: "star.fill",
            titles: [
                "فضل الصلاة على النبي صلى الله عليه وسلم"
            ]
        ),
        CatalogGroup(
            name: "الاستغفار",
            systemImage: "arrow.uturn.backward.circle.fill",
            titles: [
                "الاستغفار والتوبة"
            ]
        ),
        CatalogGroup(
            name: "الذبح",
            systemImage: "scissors",
            titles: [
                "ما يقول عند الذبح أو النحر"
            ]
        ),
        CatalogGroup(
            name: "الكراهية",
            systemImage: "xmark.circle.fill",
            titles: [
                "دعاء كراهية الطيرة"
            ]
        ),
        CatalogGroup(
            name: "الخوف من الشرك",
            systemImage: "exclamationmark.triangle.fill",
            titles: [
                "دعاء الخوف من الشرك"
            ]
        ),
        CatalogGroup(
            name: "الذنب",
            systemImage: "hand.raised.fill",
            titles: [
                "ما يقول ويفعل من أذنب ذنباً"
            ]
        ),
        CatalogGroup(
            name: "الصعوبة",
            systemImage: "mountain.2.fill",
            titles: [
                "دعاء من استصعب عليه أمر"
            ]
        ),
        CatalogGroup(
            name: "الفزع",
            systemImage: "bolt.fill",
            titles: [
                "ما يقال عند الفزع"
            ]
        ),
        CatalogGroup(
            name: "الشياطين",
            systemImage: "eye.trianglebadge.exclamationmark.fill",
            titles: [
                "ما يقول لرد كيد مردة الشياطين"
            ]
        )
    ]

    /// Chapter title → its group's name.
    static let groupNameByTitle: [String: String] = {
        var map: [String: String] = [:]
        for group in groups {
            for title in group.titles { map[title] = group.name }
        }
        return map
    }()

    /// Chapter title → its position in the book, for stable sorting.
    static let orderByTitle: [String: Int] = {
        var map: [String: Int] = [:]
        for (index, title) in groups.flatMap(\.titles).enumerated() { map[title] = index }
        return map
    }()

    static func group(named name: String) -> CatalogGroup? {
        groups.first { $0.name == name }
    }

    static func order(of title: String) -> Int {
        orderByTitle[title] ?? Int.max
    }
}
