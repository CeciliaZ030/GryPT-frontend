# Setting Up the GryPT Xcode Project

This document provides instructions for setting up the GryPT frontend as an Xcode project.

## Option 1: Using the Swift Package Manager

1. Make the setup script executable and run it:
   ```bash
   chmod +x setup_xcode_project.sh
   ./setup_xcode_project.sh
   ```

2. Open the generated Xcode project:
   ```bash
   open GryPT.xcodeproj
   ```

3. Configure the project:
   - Select the GryPT target
   - Set the "Deployment Target" to iOS 15.0 or later
   - Set the "Bundle Identifier" to your own bundle ID (e.g., com.yourname.grypt)
   - Ensure the "Info.plist" file is linked properly

## Option 2: Creating a New Xcode Project Manually

If you prefer to set up the project manually:

1. Open Xcode and create a new "App" project:
   - Choose "SwiftUI App" as the template
   - Name the project "GryPT"
   - Set the interface to "SwiftUI" and life cycle to "SwiftUI App"
   - Set minimum deployment target to iOS 15.0
   - Deselect any extra options you don't need

2. Delete the auto-generated files in the project that you don't need.

3. Add all files from the GryPT directory to your Xcode project:
   - In Xcode, right-click on the project and select "Add Files to GryPT..."
   - Navigate to the GryPT directory and select all files and folders
   - Ensure "Copy items if needed" is checked
   - Add to the appropriate targets

4. Update Info.plist:
   - Add the NSFaceIDUsageDescription entry with value "We use Face ID to securely sign your crypto transactions"

## Configuration

Before running the app, make sure to:

1. Update the RPC URL in `GryPT/Views/MainTabView.swift`:
   - Replace `YOUR_INFURA_KEY` with your actual Infura API key

2. Update the backend URL in `GryPT/Views/MainTabView.swift`:
   - Replace `https://your-grypt-backend.com` with your actual backend URL

## Building and Running

1. Select an iOS simulator or connected device
2. Click the Run button (or press Cmd+R)

## Troubleshooting

If you encounter build errors related to missing files:
- Ensure all files are properly added to the target
- Check that all imports are correct
- Verify that the file structure matches the imports

For Face ID related issues:
- Ensure the NSFaceIDUsageDescription is properly set in Info.plist
- Remember that Face ID only works on physical devices, not in the simulator 