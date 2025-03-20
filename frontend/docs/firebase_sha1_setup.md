# Firebase SHA-1 Fingerprint Setup Guide (Updated)

This document outlines the steps to generate and add your app's SHA‑1 fingerprint for Firebase, along with troubleshooting for the debug keystore.

## Troubleshooting: Debug Keystore Not Found

If you see an error similar to:
```
java.lang.Exception: Keystore file does not exist: %USERPROFILE%\.android\debug.keystore
```
follow these steps:

1. **Verify File Location:**
   - Open File Explorer.
   - Navigate to: `C:\Users\irosh\.android\`
   - Check if `debug.keystore` exists.

2. **Use Absolute Path in Command:**
   - If the file exists, use the absolute path in your terminal. For example:

     ```
     keytool -list -v -keystore "C:\Users\irosh\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
     ```

3. **If the File is Missing:**
   - Run your Flutter or Android project. Often, the debug keystore will be regenerated automatically.
   - Alternatively, you can generate a new keystore manually if needed.

## Generating Your SHA-1 Fingerprint

### For Debug Builds

1. **On Windows:**
   Open Command Prompt and run the following command (using your absolute path if necessary):
   ```
   keytool -list -v -keystore "C:\Users\irosh\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   
2. **On macOS/Linux:**
   Open a terminal and run:
   ```
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

### For Release Builds

1. Use your release keystore instead of the debug keystore:
   ```
   keytool -list -v -keystore [your-release-key.keystore] -alias [your-alias] -storepass [your_store_password] -keypass [your_key_password]
   ```

## Adding the SHA-1 Fingerprint to Firebase

1. Log in to the [Firebase Console](https://console.firebase.google.com/).
2. Select your project.
3. Click on the gear icon next to **Project Overview** and select **Project Settings**.
4. Scroll down to **Your apps** and select your Android app.
5. In the **SHA certificate fingerprints** section, click **Add fingerprint**.
6. Paste the copied SHA-1 fingerprint and save.
7. If needed, download the updated `google-services.json` file and replace it in your `frontend\android\app\` directory.

Following these steps should help resolve the error and allow you to generate your SHA-1 fingerprint correctly.