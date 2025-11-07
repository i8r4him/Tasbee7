# Location Permissions Setup for Reminders

To make the reminder system work correctly, you need to add location permissions to `Info.plist`.

## Steps:

1. Open the project in Xcode
2. Select the `Info.plist` file (or open Target Settings > Info tab)
3. Add the following keys:

### Required Keys:

**NSLocationWhenInUseUsageDescription**
- Value: "We need your location to accurately calculate sunrise and sunset times to send morning and evening athkar reminders"

**NSLocationAlwaysAndWhenInUseUsageDescription** (Optional)
- Value: "We need your location to accurately calculate sunrise and sunset times to send morning and evening athkar reminders"

### How to Add in Xcode:

1. In Project Navigator, select the project
2. Select Target "Tasbee7"
3. Go to the "Info" tab
4. In the "Custom iOS Target Properties" section, click "+"
5. Add the keys mentioned above with their values

Or you can add the keys directly in `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to accurately calculate sunrise and sunset times to send morning and evening athkar reminders</string>
```

## Notes:

- The app only requests "When In Use" permission
- Location is only used to calculate sun times, it's not tracked
- Users can deny permission, but reminders won't work accurately without location
