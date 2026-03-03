# 🌊 Aquanimity

**Aquanimity** is a gamified focus application built with Flutter. It challenges users to stay off their phones by simulating a deep-sea submarine dive. Success rewards you with rare sunken treasures; failure (leaving the app) results in "The Bends" and a loss of depth.

## 🚀 How It Works

### 1. The Dive (Focus Session)
* **Launch:** Users enter a dive duration (or 0 for an "Endless" session).
* **Descent:** The submarine descends at a rate of 1 meter per second.
* **Focus Check:** If the user minimizes the app or switches to another task, the device triggers a haptic vibration warning of "The Bends," and the dive is aborted, losing progress.

### 2. The Treasure System
* **Salvage:** Upon completing a successful dive, a random treasure is generated based on the depth reached. 
* **Rarity Tiers:**
  * ⚪ **Common:** 
  * 🟢 **Uncommon:** 
  * 🔵 **Rare:**
  * 🟣 **Epic:** 
  * 🟡 **Legendary:** 
  * 🔴 **Mythic:** 
* **Duplicates & Coins:** If you salvage an item already in your vault, it is automatically converted into **Coins** based on its rarity value.

### 3. The Treasure Vault
* **Collection:** View all your unique salvaged items.
* **Swipe-to-Sell:** Need more gold? Swipe any item to the left to sell it for coins. High-rarity items fetch a significantly higher price.

## 🛠 Features
* **Persistent Storage:** Uses `shared_preferences` to keep track of your total depth, coins, and inventory.
* **Haptic Feedback:** Physical vibration alerts for focus breaks.
* **Responsive UI:** Optimized with `SafeArea` and `FittedBox` for a consistent experience across Web and Mobile.

## 📦 Installation & Setup

1. **Prerequisites:** * [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
   * An Android/iOS Emulator or physical device.

2. **Clone the Project:**
   ```bash
   git clone [https://github.com/your-username/aquanimity.git](https://github.com/your-username/aquanimity.git)
   cd aquanimity