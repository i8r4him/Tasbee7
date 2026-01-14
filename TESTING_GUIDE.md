# 🧪 Testing StoreKit & Subscriptions Guide

## 📋 Overview

There are **3 ways** to test your subscription system:
1. **Local Testing** (Simulator - No real money, fastest)
2. **Sandbox Testing** (Device - Real App Store flow, fake money)
3. **TestFlight** (Beta testers - Production-like)

---

## 🖥️ Method 1: Local Testing (Recommended First)

### Step 1: Create StoreKit Configuration File

1. **In Xcode:** File → New → File...
2. Search for **"StoreKit Configuration File"**
3. Name it: `Tasbee7Store.storekit`
4. Click **Create**

### Step 2: Configure Products

Add your products to the `.storekit` file:

```json
{
  "identifier" : "21891681",
  "subscriptionGroupIdentifier" : "21891681",
  "products" : [
    {
      "displayName" : "عضوية شهرية",
      "familyShareable" : false,
      "internalID" : "6670001",
      "localizations" : [
        {
          "description" : "اشتراك شهري للميزات المميزة",
          "displayName" : "عضوية شهرية",
          "locale" : "ar"
        }
      ],
      "productID" : "com.tasbee7.premium.monthly",
      "referenceName" : "Monthly Subscription",
      "subscriptionDuration" : "P1M",
      "subscriptionGroupID" : "21891681",
      "type" : "RecurringSubscription"
    },
    {
      "displayName" : "عضوية سنوية",
      "familyShareable" : false,
      "internalID" : "6670002",
      "localizations" : [
        {
          "description" : "اشتراك سنوي - وفر 30%",
          "displayName" : "عضوية سنوية",
          "locale" : "ar"
        }
      ],
      "productID" : "com.tasbee7.premium.annual",
      "referenceName" : "Annual Subscription",
      "subscriptionDuration" : "P1Y",
      "subscriptionGroupID" : "21891681",
      "type" : "RecurringSubscription"
    }
  ],
  "settings" : {
    "_failTransactionsEnabled" : false,
    "_locale" : "ar",
    "_storefront" : "SAU",
    "_storeKitErrors" : [ ]
  },
  "version" : {
    "major" : 3,
    "minor" : 0
  }
}
```

### Step 3: Enable StoreKit Configuration

1. **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** in the left sidebar
3. Go to **Options** tab
4. Under **StoreKit Configuration**, select `Tasbee7Store.storekit`
5. Click **Close**

### Step 4: Test in Simulator

1. **Run** the app in simulator (⌘R)
2. Go to **Settings** → Tap **Premium Box**
3. You'll see your subscriptions!
4. **Purchase** one (no real money charged)
5. **Verify:**
   - Settings shows "عضو مميز" badge
   - Premium status is active

### Step 5: Test StoreKit Features

#### Test Scenarios:
```
✅ Purchase monthly subscription
✅ Purchase annual subscription  
✅ Cancel subscription
✅ Restore purchases
✅ Check status after restart
✅ Upgrade from monthly to annual
```

#### Debug StoreKit Transactions:

In Xcode: **Debug** → **StoreKit** → **Manage Transactions**

Here you can:
- View all purchases
- Expire subscriptions
- Refund transactions
- Clear all purchases

---

## 📱 Method 2: Sandbox Testing (Real Device)

### Prerequisites:

1. **Products must be created in App Store Connect**
2. **Subscription Group ID must match** (`21891681`)
3. **Wait 2-4 hours** after creating products

### Step 1: Create Sandbox Tester

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. **Users and Access** → **Sandbox Testers**
3. Click **"+"** to add tester
4. Fill in:
   - Email: `test@example.com` (use unique email)
   - Password: Strong password
   - First/Last Name: Test User
   - Country: Saudi Arabia (or your region)
5. Click **Create**

### Step 2: Prepare Device

1. **On your iPhone:**
   - Settings → App Store
   - **Sign Out** of your real Apple ID
   - Keep signed out (don't sign in with sandbox account yet)

2. **Important:** Don't sign into sandbox account in Settings!
   - Only sign in when prompted by your app

### Step 3: Install on Device

1. In Xcode, select your physical device
2. Build and run (⌘R)
3. App installs on device

### Step 4: Test Purchase Flow

1. Open app → Settings → Premium Box
2. Tap to open subscription view
3. Select a subscription plan
4. Tap **Subscribe**
5. **When prompted**, sign in with **sandbox tester account**
6. Complete purchase
7. Verify premium status appears

### Step 5: Test Scenarios

```bash
✅ Fresh purchase
✅ App restart (status persists)
✅ Restore purchases on another device
✅ Cancel subscription (Settings → Apple ID → Subscriptions)
✅ Resubscribe after cancellation
✅ Upgrade/downgrade plans
```

### Sandbox Testing Tips:

- **Accelerated time:** 5 minutes = 1 day (for testing renewals)
- **Free trials:** Complete immediately in sandbox
- **Cancellation:** Immediate in sandbox (real: end of period)
- **Clear purchases:** Settings → Developer → Clear Sandbox Purchase History

---

## 🚀 Method 3: TestFlight Testing

### Step 1: Submit Build

1. Archive your app (Product → Archive)
2. Distribute → App Store Connect
3. Upload build
4. Wait for processing (~10-15 minutes)

### Step 2: Configure in App Store Connect

1. Go to your app → **TestFlight** tab
2. Select the build
3. Add **Beta Testers** (internal or external)
4. **Add Subscription Information:**
   - What's included in each tier
   - Free trial details (if any)
   - Pricing

### Step 3: Test with Beta Testers

1. Invite testers via email
2. They install via TestFlight app
3. They can make **real sandbox purchases**
4. Get feedback on purchase flow

---

## 🎯 Complete Testing Checklist

### Functionality Tests:

```
□ Purchase monthly subscription
□ Purchase annual subscription
□ Premium features unlock immediately
□ Restore purchases works
□ Status shows correctly in Settings
□ Status persists after app restart
□ Status updates when subscription expires
□ Upgrade from monthly to annual
□ Downgrade from annual to monthly
□ Cancel subscription
□ Resubscribe after cancellation
□ Multiple subscriptions (only highest should show)
```

### UI Tests:

```
□ Premium box shows for non-subscribers
□ Premium badge shows for subscribers
□ Subscription screen displays correctly
□ Prices show in correct currency
□ Arabic text displays properly
□ Manage subscription button works
□ Restore purchases button works
□ Loading states work correctly
```

### Edge Cases:

```
□ Poor network connection
□ App crash during purchase
□ Background app refresh
□ Device switch (restore on new device)
□ Expired subscription (reverts to free)
□ Refunded purchase (revokes access)
□ Transaction verification failure
```

---

## 🐛 Debugging Tools

### 1. Console Logs

Add to `StoreManager.swift`:

```swift
logger.log("Checking subscription status...")
logger.debug("Transaction ID: \(transaction.id)")
logger.error("Verification failed: \(error)")
```

View logs in Xcode: **View** → **Debug Area** → **Show Debug Area**

### 2. Xcode StoreKit Manager

**Debug** → **StoreKit** → **Manage Transactions**

Features:
- View all purchases
- Expire subscriptions immediately
- Simulate refunds
- Clear purchase history
- Test different scenarios

### 3. Subscription Status Debug View

Add to your app (Debug builds only):

```swift
#if DEBUG
struct SubscriptionDebugView: View {
    @Environment(SubscriptionStatusModel.self) var subscriptionStatus
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Subscription Debug")
                .font(.headline)
            
            Text("Status: \(subscriptionStatus.status.description)")
            Text("Is Premium: \(subscriptionStatus.status.isPremium ? "Yes" : "No")")
            
            Button("Force Check Status") {
                // Trigger manual refresh
            }
        }
        .padding()
    }
}
#endif
```

---

## 📊 What to Monitor

### During Testing:

1. **Console Output:**
   ```
   ✅ "Processing transaction ID..."
   ✅ "Transaction verified"
   ✅ "Subscription status updated"
   ```

2. **Subscription Status:**
   - Check `subscriptionStatusModel.status` value
   - Verify it changes correctly

3. **UI Updates:**
   - Premium badge appears/disappears
   - Features lock/unlock properly

---

## 🎓 Testing Best Practices

### 1. Start Simple

```
1. Test local StoreKit first
2. Fix any issues
3. Move to sandbox testing
4. Test on multiple devices
5. Beta test with users
```

### 2. Test All Scenarios

- Don't just test happy path
- Try edge cases
- Test poor network
- Test app crashes mid-purchase

### 3. Verify Security

- Check transaction verification works
- Ensure expired subscriptions lock features
- Test receipt validation

### 4. Document Issues

Keep a testing log:
```
Date: 2026-01-14
Scenario: Purchase monthly subscription
Result: ✅ Success
Notes: Status updated immediately
```

---

## 🆘 Common Issues & Solutions

### "Product not found"

**Solution:**
- Wait 2-4 hours after creating products in App Store Connect
- Verify product IDs match exactly
- Check subscription group ID is correct

### "Purchase failed"

**Solution:**
- Check internet connection
- Verify sandbox account is signed in
- Clear sandbox purchase history
- Try different sandbox account

### "Status not updating"

**Solution:**
- Check `.subscriptionStatusTask` is attached
- Verify `StoreManager` is initialized
- Look for errors in console logs
- Restart app

### "Restore purchases does nothing"

**Solution:**
- Ensure you have previous purchases
- Check sandbox account matches
- Verify `AppStore.sync()` is called

---

## 📝 Quick Start Commands

### Clear Sandbox Purchases:
```
Device Settings → Developer → Clear Sandbox Purchase History
```

### View StoreKit Transactions:
```
Xcode → Debug → StoreKit → Manage Transactions
```

### Reset Subscription Status:
```swift
// In StoreKit Manager
Click "Delete All Transactions"
```

---

## 🎉 You're Ready!

### Testing Flow:

1. **Start:** Local testing with `.storekit` file
2. **Verify:** All purchase flows work
3. **Move:** Sandbox testing on device
4. **Confirm:** Real App Store integration works
5. **Launch:** TestFlight beta testing
6. **Deploy:** Production release

### Next Steps:

1. ✅ Create `.storekit` file
2. ✅ Configure products
3. ✅ Test in simulator
4. ✅ Create sandbox account
5. ✅ Test on device
6. ✅ Submit to TestFlight

---

**You're all set to test subscriptions! Start with local testing and work your way up! 🚀**
