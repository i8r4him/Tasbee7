# How to Add Font to Info.plist - Step by Step

## Method 1: Using Info Tab (Easiest)

### Step 1: Open Project Settings
1. In Xcode, click on **"Tasbee7"** (the blue project icon at the top of Project Navigator)
2. In the main panel, you'll see "TARGETS" - click on **"Tasbee7"** under TARGETS
3. Click on the **"Info"** tab at the top

### Step 2: Add the Font Key
1. Look for a section called **"Custom iOS Target Properties"**
2. Scroll down to see if **"Fonts provided by application"** already exists
3. **If it doesn't exist:**
   - Click the **"+"** button (usually at the bottom of the list)
   - In the search box that appears, type: `Fonts provided by application`
   - Select it from the dropdown
   - Set the **Type** to: **Array** (click on the type dropdown and select "Array")

### Step 3: Add the Font File
1. Expand the **"Fonts provided by application"** array (click the arrow)
2. Click the **"+"** button under the array
3. Type: `ScheherazadeNew-Regular.ttf`
4. Press Enter

### Step 4: Verify
You should now see:
```
Fonts provided by application (Array)
  Item 0: ScheherazadeNew-Regular.ttf
```

### Step 5: Clean and Rebuild
1. **Product** → **Clean Build Folder** (or press **Cmd+Shift+K**)
2. **Product** → **Build** (or press **Cmd+B**)
3. **Product** → **Run** (or press **Cmd+R**)

---

## Method 2: Using Build Settings (Alternative)

If Method 1 doesn't work:

1. Select **"Tasbee7"** project → **"Tasbee7"** target
2. Click **"Build Settings"** tab
3. Search for: `INFOPLIST_KEY_UIAppFonts`
4. If found, expand it and add `ScheherazadeNew-Regular.ttf`
5. If not found:
   - Click **"+"** → **"Add User-Defined Setting"**
   - Name: `INFOPLIST_KEY_UIAppFonts`
   - Type: Array
   - Add: `ScheherazadeNew-Regular.ttf`

---

## Troubleshooting

**Can't find "Fonts provided by application"?**
- Make sure you're in the **Info** tab (not Build Settings)
- Try typing `UIAppFonts` instead
- Or use Method 2 (Build Settings)

**Font still not working?**
- Make sure the font file is added to Target Membership:
  1. Select `ScheherazadeNew-Regular.ttf` in Project Navigator
  2. In File Inspector (right panel), check **"Target Membership"**
  3. ✅ **"Tasbee7"** must be checked

