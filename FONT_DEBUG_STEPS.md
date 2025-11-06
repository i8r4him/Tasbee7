# Font Debugging Steps

## Issue: Nothing appears in console

### Step 1: Verify Console is Open
1. In Xcode, make sure Console is visible:
   - View → Debug Area → Activate Console
   - Or press: **Cmd+Shift+Y**
2. Make sure the filter is cleared (no text in search box)

### Step 2: Verify App is Running
1. Build and run the app: **Cmd+R**
2. Wait for app to fully launch
3. Navigate to an athkar detail page (tap any card)

### Step 3: Check if Font is Registered
The font MUST be registered in Info.plist. Check this:

1. In Xcode, select the project "Tasbee7" (top item in Project Navigator)
2. Select the "Tasbee7" target
3. Go to **"Info"** tab
4. Look for **"Fonts provided by application"** or **"UIAppFonts"**
5. It should contain: `ScheherazadeNew-Regular.ttf`

**If it's NOT there:**
1. Click the **"+"** button
2. Add key: `Fonts provided by application` (or `UIAppFonts`)
3. Set type to: **Array**
4. Add item: `ScheherazadeNew-Regular.ttf`

### Step 4: Verify Font File is in Target
1. Select `ScheherazadeNew-Regular.ttf` in Project Navigator
2. In File Inspector (right panel), check **"Target Membership"**
3. ✅ **"Tasbee7"** must be checked

### Step 5: Clean and Rebuild
1. **Clean Build Folder**: Cmd+Shift+K
2. **Build**: Cmd+B
3. **Run**: Cmd+R

### Step 6: Test Again
1. Open any athkar detail page
2. Check Console - you should see:
   ```
   ========================================
   🔍 ATHKAR DETAIL VIEW APPEARED
   ========================================
   ```

If you still see nothing, the view might not be loading. Try:
- Check if you can see the athkar detail page at all
- Try tapping the font icon (Aa) in toolbar
- Check if any errors appear in console

