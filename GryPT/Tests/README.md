# GryPT Test Suite

This directory contains unit tests and UI tests for the GryPT application.

## Test Structure

The test suite is organized as follows:

- `GryPTTests.swift` - Main test file that can run all unit tests
- `AuthViewModelTests.swift` - Tests for the authentication flow
- `ChatViewModelTests.swift` - Tests for the chat interaction
- `WalletViewModelTests.swift` - Tests for the wallet functionality
- `UITests/` - Directory containing UI tests

## Running Tests

### Unit Tests

To run unit tests from Xcode:
1. Select the GryPTTests scheme
2. Press Cmd+U or navigate to Product > Test

### UI Tests

To run UI tests from Xcode:
1. Select the GryPTUITests scheme
2. Press Cmd+U or navigate to Product > Test

## Test Scope

### Unit Tests

- **AuthViewModel Tests** - Verify the authentication logic
- **ChatViewModel Tests** - Verify chat interaction and transaction processing
- **WalletViewModel Tests** - Verify wallet balance loading and transaction history

### UI Tests

- **Launch Tests** - Verify app launches correctly with splash screen
- **Authentication Flow** - Verify sign-in process
- **Tab Navigation** - Verify switching between Chat and Holdings tabs
- **Chat Interaction** - Verify sending messages and receiving responses
- **Profile Flow** - Verify opening and closing the profile view

## Mock Services

The tests use mock implementations of services:

- `MockAPIService` - Simulates backend responses for testing chat functionality
- `MockRPCService` - Simulates blockchain RPC responses for testing wallet functionality

## UI Testing Mode

The app can detect UI testing mode by checking for the "UITesting" launch argument. In this mode:
- The splash screen is skipped
- Authentication can bypass Face ID
- Network requests are mocked 