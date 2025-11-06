# How to Add New Fonts in the Future

## Quick Guide

### Step 1: Add Font File to Project
1. Download your font file (.ttf or .otf)
2. In Xcode, drag the font file into the `Tasbee7/Fonts` folder
3. **Important**: Check "Copy items if needed" and select "Tasbee7" target
4. Click "Finish"

### Step 2: Register Font in Info.plist
1. Select project "Tasbee7" → Target "Tasbee7" → **"Info"** tab
2. Find **"Fonts provided by application"** (or add it if it doesn't exist)
3. Expand the array
4. Click **"+"** and add your font filename (e.g., `MyFont-Regular.ttf`)

### Step 3: Find the Font's PostScript Name
After building and running the app, check the Console when you open an athkar detail page. It will show all available fonts.

Or use this code temporarily in any view:
```swift
.onAppear {
    let fonts = FontHelper.listAllFonts()
    print("Available fonts: \(fonts)")
}
```

### Step 4: Add Font to Code
Edit `Tasbee7/Utilities/Theme.swift`:

1. **Add a new case** to the `AthkarFont` enum:
```swift
enum AthkarFont: String, CaseIterable, Identifiable {
    case system = "النظام"
    case scheherazade = "شهرزاد"
    case myNewFont = "اسم الخط الجديد"  // Add this line
    // ...
}
```

2. **Add the font case** in the `font` computed property:
```swift
var font: Font {
    switch self {
    case .system:
        return .system(.body, design: .default)
    case .scheherazade:
        // ... existing code ...
    case .myNewFont:  // Add this case
        if let font = UIFont(name: "MyFont-PostScriptName", size: 17) {
            return Font(font)
        }
        return .system(.body, design: .serif)
    }
}
```

### Step 5: Clean and Rebuild
1. **Clean Build Folder**: Cmd+Shift+K
2. **Build**: Cmd+B
3. **Run**: Cmd+R

---

## Example: Adding "Amiri" Font

### 1. Add file: `Amiri-Regular.ttf` to `Tasbee7/Fonts`

### 2. Register in Info.plist:
- Add `Amiri-Regular.ttf` to "Fonts provided by application" array

### 3. Update `Theme.swift`:
```swift
enum AthkarFont: String, CaseIterable, Identifiable {
    case system = "النظام"
    case scheherazade = "شهرزاد"
    case amiri = "أميري"  // Add this
    
    // ...
    
    var font: Font {
        switch self {
        case .system:
            return .system(.body, design: .default)
        case .scheherazade:
            // ... existing code ...
        case .amiri:  // Add this
            if let font = UIFont(name: "Amiri-Regular", size: 17) {
                return Font(font)
            }
            return .system(.body, design: .serif)
        }
    }
}
```

### 4. Rebuild and test!

---

## Tips

- **Font filename** ≠ **PostScript name**: The filename is what you add to Info.plist, but the PostScript name is what you use in code
- Use `FontHelper.listAllFonts()` to find the exact PostScript name
- Always test after adding a new font
- If font doesn't work, check Console for available fonts

