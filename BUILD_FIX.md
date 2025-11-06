# Build Fix Instructions

## Fix README.md Build Error

The error "Multiple commands produce README.md" occurs because README.md files are being copied to the app bundle.

### To Fix:
1. In Xcode, select `Tasbee7/Data/README.md` in the Project Navigator
2. In the File Inspector (right panel), under "Target Membership"
3. **Uncheck** the "Tasbee7" target
4. Repeat for `Tasbee7/Fonts/README.md`

This will exclude the README files from being copied to the app bundle while keeping them in the project for reference.

