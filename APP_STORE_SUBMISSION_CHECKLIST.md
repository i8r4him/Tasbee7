# App Store Submission Checklist for Tasbee7

## 📋 Current Project Status

**Bundle Identifier:** `i8r4him.Tasbee7`  
**Version:** 1.0  
**Build:** 1  
**Category:** Education  
**Deployment Target:** iOS 26.0

---

## ✅ What You Already Have

- [x] **Bundle Identifier** - Set to `i8r4him.Tasbee7`
- [x] **Version & Build Numbers** - Set in project (1.0 / 1)
- [x] **Location Permission** - `NSLocationWhenInUseUsageDescription` in Info.plist
- [x] **Font Registration** - Scheherazade font registered
- [x] **App Category** - Set to Education
- [x] **Development Team** - DMKPB2487F
- [x] **Code Signing** - Automatic signing enabled
- [x] **All Core Features** - Home, Search, Sebha, Settings, Notifications

---

## 🔴 CRITICAL - Must Complete Before Submission

### 1. App Icon (REQUIRED) ⚠️
**Status:** ❌ **MISSING - Cannot submit without this**

**What to do:**
1. Create a **1024x1024 PNG** image
   - Design tools: Figma, Canva, Photoshop, or AI (Midjourney/DALL-E)
   - Keep it simple, recognizable at small sizes
   - No transparency, solid background
   - Design ideas: Tasbih beads, prayer beads, minimal Arabic calligraphy

2. Add to Xcode:
   - Open `Assets.xcassets` → `AppIcon`
   - Drag your 1024x1024 image to the **Universal iOS** slot
   - Build and test on device/simulator to verify it displays

**Resources:**
- [Apple's App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- Free design: Canva, Figma (free tier)

---

### 2. Privacy Policy (REQUIRED) ⚠️
**Status:** ❌ **MISSING - Required for location-based apps**

**What to do:**
1. Create a privacy policy page
   - Template provided in `PRIVACY_POLICY_TEMPLATE.md` (if exists)
   - Must explain:
     - What location data is collected
     - Why it's collected (sunrise/sunset calculations)
     - That data is NOT stored or shared
     - All data is local only

2. Host it online (choose one):
   - **GitHub Pages** (free, easy):
     ```bash
     # Create a new GitHub repo
     # Enable GitHub Pages in repo settings
     # Upload privacy-policy.html or privacy-policy.md
     # URL: https://yourusername.github.io/repo-name/privacy-policy
     ```
   - **Your own website** (if you have one)
   - **Free hosting:** Netlify, Vercel, or similar

3. Save the URL - you'll need it for App Store Connect

**Why:** Your app uses location services, so Apple requires a privacy policy URL.

---

### 3. Complete Empty Views ⚠️
**Status:** ⚠️ **Some views are placeholders**

Check these views and complete them:
- [ ] `FeatureRequestView.swift` - Currently shows "Hello, World!"
- [ ] `HelpFeedbackView.swift` - Currently shows "Hello, World!"
- [ ] `AboutView.swift` - Currently shows "Hello, World!"
- [ ] `PrivacyPolicyView.swift` - Needs content or link to hosted policy
- [ ] `WhatsNewView.swift` - Needs "What's New" content

**Action:** Either implement these views or remove them from Settings if not ready.

---

### 4. Update Share URL ⚠️
**Status:** ⚠️ **Currently points to placeholder**

In `SettingsView.swift`:
```swift
private let shareURL = URL(string: "https://tasbee7.app")!
```

**Action:** Update to your actual App Store URL after submission, or remove share button if not ready.

---

## 🟡 IMPORTANT - Before Submission

### 5. Test on Real Device
**Status:** ⚠️ **Must test before submission**

**What to test:**
- [ ] Home view loads and displays all sections
- [ ] Search functionality works
- [ ] Sebha counter increments correctly
- [ ] Favorites save and load properly
- [ ] Notifications request permission correctly
- [ ] Location permission flow works
- [ ] Settings can change theme colors
- [ ] Font changes apply correctly
- [ ] App icon displays correctly on home screen
- [ ] Badge clears when app opens
- [ ] Notification tap opens app to Home tab

**Why:** Apple may reject if basic functionality doesn't work.

---

### 6. App Store Screenshots (REQUIRED)
**Status:** ❌ **MISSING**

**Required sizes:**
- **iPhone 6.7"** (iPhone 14 Pro Max, 15 Pro Max): **1290 x 2796 pixels**
- **iPhone 6.5"** (iPhone 11 Pro Max, XS Max): **1242 x 2688 pixels**
- **iPhone 5.5"** (iPhone 8 Plus): **1242 x 2208 pixels** (optional but recommended)
- **Minimum 3 screenshots per device size**

**What to capture:**
1. Home view with sections visible
2. Search results or search interface
3. Sebha counter
4. Settings page
5. Athkar detail view

**Tools:**
- Xcode Simulator (Cmd+S to save screenshot)
- Screenshot editing: Canva, Figma, or Preview
- Optionally add text overlays: "أذكار المسلم", "بحث سريع", etc.

---

### 7. App Store Connect Setup
**Status:** ⚠️ **Need to create listing**

**Steps:**
1. **Create account** (if needed):
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Sign in with Apple Developer account ($99/year)

2. **Create app listing:**
   - Click "+" to create new app
   - Fill in:
     - **Name:** Tasbee7 (or your preferred name)
     - **Primary Language:** Arabic
     - **Bundle ID:** `i8r4him.Tasbee7` (must match exactly)
     - **SKU:** Unique identifier (e.g., `tasbee7-001`)

3. **App Information:**
   - **Category:** Lifestyle / Reference (or Education)
   - **Age Rating:** 4+ (likely)
   - **Price:** Free (or set price)

4. **Privacy Policy URL:**
   - Add the URL you created in step 2

---

### 8. App Description (REQUIRED)
**Status:** ⚠️ **Need to write**

**Suggested Arabic description:**
```
تطبيق تسبيح - أذكار المسلم

تطبيق شامل للأذكار والتسبيحات اليومية مع ميزات متقدمة:

✨ المميزات:
• أذكار الصباح والمساء من كتاب حصن المسلم
• عداد تسبيح رقمي مع إشعارات
• نظام المفضلة لحفظ الأذكار المهمة
• بحث سريع في جميع الأذكار
• تذكيرات ذكية بناءً على شروق وغروب الشمس
• ألوان واجهة قابلة للتخصيص
• خطوط عربية جميلة

📱 سهل الاستخدام ومصمم بعناية لتجربة ممتعة في الذكر والتسبيح.
```

**What to include:**
- Key features
- Keywords for App Store search
- Support contact information
- Any additional features

---

### 9. App Preview Video (Optional but Recommended)
**Status:** ⚠️ **Optional**

- 15-30 seconds showing key features
- Can significantly improve downloads
- Show: Home view, Search, Sebha counter, Settings

---

## 🟢 NICE TO HAVE (Can Add Later)

### 10. English Localization
- Add English translations for broader reach
- Can be added in future updates

### 11. Widget Support
- Home screen widget showing daily athkar
- Lock screen widget for quick access

### 12. iCloud Sync
- Sync favorites across devices
- Requires iCloud setup

---

## 📋 Pre-Submission Checklist

### Before Building:
- [ ] App icon created and added to Assets (1024x1024)
- [ ] Privacy policy created and hosted online
- [ ] All placeholder views completed or removed
- [ ] Share URL updated or removed
- [ ] Version and build numbers verified
- [ ] Info.plist permissions verified

### Before Uploading:
- [ ] Tested on real device (not just simulator)
- [ ] All features working correctly
- [ ] No crashes or bugs
- [ ] Screenshots prepared for all required sizes
- [ ] App description written (Arabic)

### In App Store Connect:
- [ ] App listing created
- [ ] Screenshots uploaded
- [ ] App description added
- [ ] Privacy policy URL added
- [ ] Age rating completed
- [ ] Pricing set
- [ ] Support URL (optional)
- [ ] Marketing URL (optional)

### Submission:
- [ ] Archive build in Xcode (Product > Archive)
- [ ] Upload to App Store Connect
- [ ] Submit for review
- [ ] Wait for review (usually 24-48 hours)

---

## ⏱️ Estimated Timeline

- **Icon Creation:** 1-2 hours (or hire designer)
- **Privacy Policy:** 30 minutes
- **Complete Views:** 1-2 hours
- **Testing:** 1 hour
- **Screenshots:** 1-2 hours
- **App Store Connect Setup:** 1-2 hours
- **App Description:** 30 minutes

**Total:** ~6-10 hours of work + 24-48 hours for Apple review

---

## 🚀 Quick Start Guide

### Step 1: Critical Items (Do First)
1. **Create app icon** (1024x1024 PNG)
2. **Create privacy policy** and host it online
3. **Complete or remove placeholder views**

### Step 2: Testing & Assets
4. **Test on real device**
5. **Take screenshots** for all required sizes
6. **Write app description**

### Step 3: App Store Connect
7. **Set up App Store Connect** listing
8. **Upload screenshots and description**
9. **Add privacy policy URL**

### Step 4: Submit
10. **Archive and upload** build
11. **Submit for review**

---

## 🔗 Resources

- [App Store Connect](https://appstoreconnect.apple.com)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Icon Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)

---

## ⚠️ Common Rejection Reasons

1. **Missing app icon** - Will be rejected immediately
2. **Missing privacy policy** - Required for location apps
3. **Placeholder content** - "Hello, World!" views will be rejected
4. **Broken functionality** - Test thoroughly
5. **Misleading information** - Ensure descriptions match functionality
6. **Incomplete metadata** - Fill all required fields

---

## 📝 Notes

- **Bundle ID:** `i8r4him.Tasbee7` - Make sure this matches exactly in App Store Connect
- **Version:** Start with 1.0, increment for updates
- **Build:** Start with 1, increment for each submission
- **Category:** Currently set to Education, consider Lifestyle/Reference
- **Deployment Target:** iOS 26.0 - Very high, consider lowering to iOS 17.0+ for broader reach

---

**Current Status:** ⚠️ **Not Ready** - Missing app icon, privacy policy, and some views need completion

**Priority:** Focus on Critical items first, then Important items, then Nice-to-have

