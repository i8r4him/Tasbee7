# Settings Folder Organization Guide

## Recommended Structure

```
Settings/
├── Views/
│   ├── SettingsView.swift (main settings view)
│   ├── About/
│   │   ├── AboutView.swift
│   │   └── WhatsNewView.swift
│   ├── Support/
│   │   ├── HelpFeedbackView.swift
│   │   └── FeatureRequestView.swift
│   ├── Notifications/
│   │   └── NotificationsSettingsView.swift
│   └── Privacy/
│       └── PrivacyPolicyView.swift
├── Managers/
│   ├── LocationManager.swift
│   ├── NotificationManager.swift
│   └── NotificationDelegate.swift
└── Utilities/
    └── SunriseSunsetCalculator.swift
```

## How to Organize in Xcode

### Option 1: Using Xcode (Recommended)

1. **Create Groups in Xcode:**
   - Right-click on `Settings` folder in Xcode
   - Select "New Group"
   - Create these groups:
     - `Views`
     - `Views/About`
     - `Views/Support`
     - `Views/Notifications`
     - `Views/Privacy`
     - `Managers`
     - `Utilities`

2. **Move Files:**
   - Drag files from the Settings folder to their respective groups
   - Xcode will automatically update file references

### Option 2: Using Finder + Xcode

1. **Create folders in Finder:**
   - Navigate to `Tasbee7/Settings/` in Finder
   - Create folders: `Views`, `Managers`, `Utilities`
   - Inside `Views`, create: `About`, `Support`, `Notifications`, `Privacy`

2. **Move files in Finder:**
   - Move files to their respective folders

3. **Update in Xcode:**
   - In Xcode, right-click `Settings` folder
   - Select "Add Files to Tasbee7..."
   - Select the new folder structure
   - Make sure "Create groups" is selected
   - Click "Add"

## File Organization

### Views/
- **SettingsView.swift** - Main settings view
- **About/** - About and What's New views
- **Support/** - Help and feature request views
- **Notifications/** - Notification settings view
- **Privacy/** - Privacy policy view

### Managers/
- **LocationManager.swift** - Location services manager
- **NotificationManager.swift** - Notification scheduling manager
- **NotificationDelegate.swift** - Notification delegate handler

### Utilities/
- **SunriseSunsetCalculator.swift** - Sunrise/sunset calculation utility

## Benefits

✅ **Better organization** - Easy to find files  
✅ **Clear separation** - Views, managers, and utilities are separated  
✅ **Scalability** - Easy to add new files in the right place  
✅ **Maintainability** - Clear structure for future developers

