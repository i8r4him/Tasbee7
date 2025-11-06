# How to Add Your Downloaded Font to the Project

## Step 1: Add the Font File to Xcode
1. Open Xcode
2. In the Project Navigator (left sidebar), locate the `Tasbee7/Fonts` folder
3. Drag and drop your font file (.ttf or .otf) into the `Fonts` folder in Xcode
4. **Important**: In the dialog that appears:
   - ✅ Check "Copy items if needed"
   - ✅ Make sure "Tasbee7" target is selected
   - Click "Finish"

## Step 2: Register the Font in Info.plist
Since your project uses `GENERATE_INFOPLIST_FILE = YES`, you need to add the font via Build Settings:

### Option A: Using Build Settings (Recommended)
1. Select your project in the Project Navigator (top item "Tasbee7")
2. Select the "Tasbee7" target
3. Go to the "Build Settings" tab
4. Search for "INFOPLIST_KEY_UIAppFonts" or "Fonts provided by application"
5. If it doesn't exist, click the "+" button and add a new key:
   - Key: `UIAppFonts` or `Fonts provided by application`
   - Type: Array
   - Add your font filename (e.g., `Quran-Madina.ttf`)

### Option B: Create Info.plist (Alternative)
1. Right-click on the `Tasbee7` folder in Project Navigator
2. Select "New File..."
3. Choose "Property List"
4. Name it `Info.plist`
5. Add a key: `UIAppFonts` (type: Array)
6. Add your font filename as a string item

## Step 3: Find the Actual Font Name
The font filename is different from the font's PostScript name that you use in code.

### Method 1: Use FontHelper (After building)
Add this temporarily to any view to see available fonts:
```swift
.onAppear {
    let fonts = FontHelper.listAllFonts()
    print("Available fonts: \(fonts)")
}
```

### Method 2: Check Font File Properties
- Right-click the font file on your Mac
- Select "Get Info"
- Look for the "Full Name" or "PostScript Name"

### Method 3: Common Font Names
Common Quran font names:
- `Quran-Madina` → might be `QuranMadina` or `Quran-Madina-Regular`
- `Mcs-Quran` → might be `McsQuran` or `Mcs-Quran-Regular`
- `me_quran` → might be `ME-Quran` or `me_quran-Regular`

## Step 4: Update the Code
Once you know the font's PostScript name, I'll add it to the `AthkarFont` enum in `Theme.swift`.

**Tell me:**
1. The font filename you added (e.g., `Quran-Madina.ttf`)
2. The font's PostScript name (if you found it)

Then I'll update the code to include your font in the font picker menu!

