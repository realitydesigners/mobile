# iOS App Template

Reusable Swift files for quickly bootstrapping iOS apps with native StoreKit 2 subscriptions, Core Data, dark mode theming, and polished UI.

## The Problem and Solution

**Problem:** You create an Xcode project, copy template files in, but Xcode doesn't "see" them because they're not in the .xcodeproj file.

**Solution:** The surefire workflow below ensures everything stays in sync.

## Surefire Setup (Do This Every Time)

### Step 1: Create Xcode Project

1. Xcode -> File -> New -> Project -> App
2. Name it (e.g., MyApp)
3. Set your Team and Bundle ID
4. **CHECK "Use Core Data"** <- Important!
5. Choose a location (e.g., ~/Projects/MyApp)

Xcode creates the project with Core Data already configured.

### Step 2: Add UserProfile Entity to Core Data

The template uses a `UserProfile` entity. Add it to your model:

1. Open `MyApp.xcdatamodeld` in Xcode
2. Click "Add Entity" at the bottom
3. Rename it to `UserProfile`
4. Add these attributes:

| Attribute | Type | Optional |
|-----------|------|----------|
| id | UUID | No |
| name | String | Yes |
| email | String | Yes |
| avatarURL | String | Yes |
| createdAt | Date | No |
| updatedAt | Date | No |
| hasCompletedOnboarding | Boolean | No (default: NO) |

5. In the Data Model Inspector (right panel):
   - Codegen: Class Definition
   - Module: Current Product Module

### Step 3: Copy Template Files Into Project Folder

Copy the Swift files from template/ into your Xcode project's source folder:

    cp template/*.swift ~/Projects/MyApp/MyApp/

### Step 4: Add Files to Xcode Project

This is the critical step that makes Xcode "see" your files:

1. In Xcode, right-click on your MyApp folder in the navigator
2. Select "Add Files to MyApp..."
3. Navigate to ~/Projects/MyApp/MyApp/
4. Select ALL the template Swift files you copied
5. UNCHECK "Copy items if needed" (files are already there)
6. CHECK "Create groups"
7. Click Add

### Step 5: Delete Xcode's Starter Files

Delete the files Xcode auto-created (your template replaces them):
- MyAppApp.swift (you have AppTemplateApp.swift)
- Xcode's ContentView.swift (you have yours)

**Keep Persistence.swift** - Xcode created this and it's already configured for your app!

### Step 6: Rename App Entry Point

1. Rename AppTemplateApp.swift to MyAppApp.swift
2. Inside the file, rename the struct from AppTemplateApp to MyAppApp

### Step 7: Configure In-App Purchase (Optional for Testing)

For testing purchases in the simulator:
1. File -> New -> File -> StoreKit Configuration File
2. Add your products matching the ID in AppConfig.productId
3. Edit Scheme -> Run -> Options -> StoreKit Configuration -> Select your file

## Editing in Cursor

Once files are added to Xcode properly, you can:
1. Open the project folder in Cursor
2. Edit any .swift file
3. Changes appear in Xcode immediately (Cmd+B to rebuild)

## Template Files

    template/
    - AppConfig.swift          <- Configure your app here
    - AppTemplateApp.swift     <- App entry point (rename this)
    - ThemeManager.swift       <- Colors, glass effects, buttons
    - ContentView.swift        <- Flow: loading -> paywall -> main
    - LoadingView.swift        <- Splash screen
    - OnboardingView.swift     <- User onboarding
    - PaywallView.swift        <- Subscription screen (native StoreKit 2)
    - MainTabView.swift        <- Tab navigation
    - HomeView.swift           <- Replace with your feature
    - SettingsView.swift       <- Profile, privacy, terms
    - PurchaseManager.swift    <- Native StoreKit 2 integration
    - LocationService.swift    <- Location helpers
    - LocationPickerView.swift <- City picker
    - Utilities.swift          <- Helpers

**Note:** Persistence.swift and .xcdatamodeld are NOT in template - Xcode creates these for you!

## Configure Your App

Edit AppConfig.swift:

    // App Identity
    static let appName = "My App"
    static let tagline = "Your tagline here"

    // In-App Purchase
    static let productId = "com.yourcompany.myapp.premium"

    // Feature Flags
    static let debugBypassPaywall = true  // For testing
    static let enableOnboarding = true
    static let enableLoadingScreen = true

## In-App Purchase Setup

This template uses **native StoreKit 2** - no third-party dependencies!

### Create Your Product in App Store Connect

1. Go to App Store Connect -> Your App -> In-App Purchases
2. Create a new subscription or in-app purchase
3. Copy the Product ID
4. Paste it in AppConfig.productId

### PurchaseManager API

    // Check subscription status
    if purchaseManager.isSubscribed { ... }

    // Start a purchase
    let success = await purchaseManager.startPurchase()

    // Restore purchases
    let restored = await purchaseManager.restorePurchases()

## Theme Usage

View Modifiers:
- .glass() - Glass card effect
- .etherealCard() - Card with padding
- .etherealInput() - Text field styling
- .etherealButton() - Primary button
- .shimmer() - Loading animation

Colors:
- AppTheme.background1 - Dark background
- AppTheme.pearl - White accent
- AppTheme.celestialBlue - Primary accent
- AppTheme.textPrimary - Main text
- AppTheme.textMuted - Subtle text

## Checklist for New App

- [ ] Create Xcode project with "Use Core Data" checked
- [ ] Add UserProfile entity to Core Data model (see Step 2)
- [ ] Copy template Swift files to project folder
- [ ] Add files to Xcode (right-click -> Add Files)
- [ ] Delete Xcode's auto-generated ContentView.swift and MyAppApp.swift
- [ ] Rename AppTemplateApp.swift to YourAppApp.swift
- [ ] Update AppConfig.swift with your settings
- [ ] Add your app icon to Assets.xcassets
- [ ] Replace HomeView with your main feature

## Troubleshooting

**"UserProfile" not found error?**
You need to add the UserProfile entity to your Core Data model (Step 2).

**Files not showing in Xcode?**
Right-click -> Add Files to project.

**Changes in Cursor not appearing in Xcode?**
Make sure you unchecked "Copy items if needed" when adding files.

**Products not loading in simulator?**
Create a StoreKit Configuration File and set it in your scheme.
