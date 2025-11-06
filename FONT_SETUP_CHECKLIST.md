# Font Setup Checklist for ScheherazadeNew-Regular

## ✅ Verification Steps

### 1. Font File Location
- [x] Font file exists: `Tasbee7/Fonts/ScheherazadeNew-Regular.ttf`

### 2. Xcode Target Membership
**IMPORTANT:** Check this in Xcode:
1. Select `ScheherazadeNew-Regular.ttf` in Project Navigator
2. In File Inspector (right panel), check "Target Membership"
3. ✅ Make sure "Tasbee7" is **checked**

### 3. Info.plist Registration
The font should be registered. Check in Xcode:
1. Select project "Tasbee7" (top item)
2. Select target "Tasbee7"
3. Go to "Info" tab
4. Look for "Fonts provided by application" or `UIAppFonts`
5. ✅ Should contain: `ScheherazadeNew-Regular.ttf`

### 4. Build and Test
1. **Clean Build Folder**: Cmd+Shift+K
2. **Build**: Cmd+B
3. **Run**: Cmd+R

### 5. Test the Font
1. Open any athkar detail view
2. Tap the font icon (Aa) in toolbar
3. Select "شهرزاد"
4. Check Xcode console for debug messages:
   - ✅ "Using Scheherazade font: [name]" = Success!
   - ⚠️ "Scheherazade font not found" = Check console for available fonts

### 6. If Font Doesn't Work
Check Xcode console output. The code will print:
- All available custom fonts
- Which font name it tried
- The actual PostScript name if found

**Common Issues:**
- Font not added to target → Fix in step 2
- Font not in Info.plist → Fix in step 3
- Wrong PostScript name → Check console output, then update `Theme.swift`

## Current Font Name Attempts
The code tries these names in order:
1. `ScheherazadeNew-Regular`
2. `ScheherazadeNew`
3. `ScheherazadeNew-Regular` (duplicate check)
4. `Scheherazade New`
5. `ScheherazadeNewRegular`
6. Family name search: "Scheherazade New", "ScheherazadeNew", "Scheherazade"

If none work, check the console output to see the actual PostScript name!

