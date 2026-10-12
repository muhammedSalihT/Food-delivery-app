# Food Delivery App

A complete, maintainable, production-style Flutter food delivery application built with Material 3, Riverpod, layered clean architecture, Dio networking, offline caching with Hive, and secure session management.

---

## 1. Project Overview & Architecture
This application implements a complete food delivery workflow:
- **Authentication**: Login with DummyJSON auth endpoint, secure token persistence, session restoration, and Dio 401 interception.
- **Home**: Top greeting & cart badge, search shortcut, promo banner, category chips, best sellers carousel, recommendations, infinite pagination, and offline banner.
- **Menu**: Category selector, non-destructive sorting (rating, price low-to-high, price high-to-low, shortest cook time), and infinite scrolling.
- **Search & Filter**: Debounced search (350ms), race-condition cancellation handling, local pricing & rating sliders, category filters, and empty/retry states.
- **Food Detail**: Hero image transitions, nutritional metadata (calories, servings, difficulty), ingredients chips, step-by-step instructions, quantity adjustment, and Add to Cart action.
- **Cart**: Persistent cart across restarts using Hive, swipe-to-delete with Undo snackbar, instant total synchronization, tax (5%), service fee ($1.50), and delivery fee ($2.00).
- **Confirm Order**: Local-only checkout confirmation with an order summary and cart clearing. *(No external payment gateway or remote order API is invoked).*

### Architecture & Layered Structure
The project adheres to a **feature-oriented layered architecture**:
```
lib/
├── app/
│   ├── app.dart                   # MaterialApp root configuration
│   ├── router.dart                # Centralized GoRouter navigation & auth guards
│   ├── theme/
│   │   ├── app_colors.dart        # Design tokens & color palette
│   │   ├── app_theme.dart         # Material 3 ThemeData
│   │   └── app_typography.dart    # Standardized typography scale
│   └── widgets/
│       ├── category_chips_row.dart# Reusable category selector
│       └── recipe_card.dart       # Reusable compact & list recipe cards
├── core/
│   ├── constants/
│   │   └── api_constants.dart     # DummyJSON URLs & credentials
│   ├── errors/
│   │   ├── app_failure.dart       # Typed sealed failure hierarchy
│   │   └── failure_mapper.dart    # DioException & error parser
│   ├── network/
│   │   ├── auth_interceptor.dart  # Bearer token & 401 handler
│   │   ├── dio_client.dart        # Centralized Dio HTTP client
│   │   └── network_info.dart      # Connectivity_plus wrapper
│   ├── storage/
│   │   ├── local_cache_service.dart# Hive boxes for recipes & cart
│   │   └── secure_storage_service.dart # FlutterSecureStorage for tokens
│   ├── utils/
│   │   ├── debounce.dart          # 350ms input debouncer
│   │   └── price_calculator.dart  # Deterministic pricing & fee calculator
│   └── widgets/
│       ├── empty_view.dart        # Friendly empty state widget
│       ├── error_view.dart        # Structured error & retry widget
│       ├── loading_shimmer.dart   # Shimmer skeletons for recipes
│       ├── offline_banner.dart    # Network disconnection alert
│       └── primary_button.dart    # Styled action button with loading state
└── features/
    ├── auth/                      # Data, Domain, Presentation for Authentication
    ├── cart/                      # Data, Domain, Presentation for Cart & Persistence
    ├── checkout/                  # Presentation for Confirm Order
    └── recipes/                   # Data, Domain, Presentation for Dishes, Home, Menu, Detail & Search
```

---

## 2. State Management Selection: Riverpod
**Riverpod was chosen as the single state-management solution because of its compile-safe dependency injection, testability without Flutter UI bindings, and clean lifecycle management for asynchronous operations.**

---

## 3. API Integration — DummyJSON
- **Base URL**: `https://dummyjson.com`
- **Auth Endpoint**: `POST /auth/login`
  - Demo Credentials:
    - **Username**: `emilys`
    - **Password**: `emilyspass`
- **Recipes List Endpoint**: `GET /recipes?limit=20&skip=0`
- **Recipe Search Endpoint**: `GET /recipes/search?q={query}`
- **Recipe Detail Endpoint**: `GET /recipes/{id}`

### DummyJSON Limitations & Session Handling
- DummyJSON does not maintain a server-side session refresh cycle for arbitrary custom users; token expiration and refresh tokens are simulated demonstration models.
- When an HTTP 401 Unauthorized occurs, `AuthInterceptor` immediately purges the stored token, resets auth state, and redirects the user back to the Log In screen.

---

## 4. Deterministic Mock Pricing
DummyJSON recipes do not include product pricing. Prices are deterministically calculated based on each recipe's unique ID using the formula:
$$\text{price} = 4.99 + \frac{(\text{recipeId} \times 137) \pmod{1800}}{100}$$
- **Currency**: USD (`$`)
- **Properties**: Completely stable across application restarts and shared identically across Home, Menu, Search, Food Detail, Cart, and Checkout.

### Price Breakdown & Fees
- **Subtotal**: Sum of $\text{unitPrice} \times \text{quantity}$ for all lines.
- **Tax**: $5\%$ of subtotal.
- **Service Fee**: Flat $\$1.50$ (when cart is non-empty; $\$0.00$ when empty).
- **Delivery Fee**: Flat $\$2.00$ (when cart is non-empty; $\$0.00$ when empty).
- **Calculations**: Calculated to 2 decimal places using cents representation to eliminate floating-point rounding errors.

---

## 5. Category Mapping
DummyJSON provides unstructured `mealType` and `tags`. The centralized `CategoryMappingService` normalizes these into the 5 UI categories:
1. **Meal**: Matches recipes with `mealType` containing Lunch, Dinner, Main, or Meal.
2. **Vegan**: Matches recipes where `tags` explicitly contain `vegan`, `plant-based`, or `vegetarian` (or dish names containing salad/vegan). Non-vegan meals are never misrepresented.
3. **Dessert**: Matches `mealType` Dessert, or tags containing `dessert`, `sweet`, `cake`, `pie`, or `cookie`.
4. **Snacks**: Matches `mealType` Snack, Appetizer, Breakfast, or tags containing `snack` / `side dish`.
5. **Drinks**: Matches tags/mealType containing `beverage`, `drink`, `smoothie`, `shake`, `juice`, `tea`, or `cocktail`. Fallback handling gracefully displays empty states if none match.

---

## 6. Offline Support & Persistence
- **First-Page Cache**: The first 20 recipes retrieved are cached locally in Hive (`cached_recipes` box).
- **Offline Browsing**: If the app starts without internet or network requests fail, cached dishes are restored seamlessly with an `OfflineBanner`.
- **Persistent Cart**: Cart line items are serialized to Hive (`cart_items` box) upon every mutation (add, increment, decrement, remove, clear) and restored on startup.

---

## 7. Figma Design Notes
- Design Reference: *Food Delivery App UI Kit* (`https://www.figma.com/design/N71qwDBNSWYouy8fF7k08x/...`).
- When external design kit files cannot be cloned directly into accounts without paid team seat duplication permissions, the visual tokens (vibrant delivery red/orange `#FF4B3A`, soft background `#F6F6F9`, rounded pill chips, card elevations, and typography) are faithfully preserved.
- The **Food Detail** screen was designed harmoniously with hero transitions, nutritional tags, recipe metadata, ingredient chips, and a sticky bottom cart bar.

---

## 8. Verification & How to Run

### Requirements
- Flutter SDK `^3.41.4` (or compatible 3.x)
- Dart SDK `^3.11.1`

### Running the App
```bash
# Get dependencies
flutter pub get

# Run on available device/emulator
flutter run
```

### Running Static Analysis
```bash
flutter analyze
```
*(Result: 0 issues found)*

### Running the Test Suite
```bash
flutter test
```
*(Result: 12 passing tests across unit and widget tests)*

### Local-Only Checkout Notice
**Note**: The checkout action on the *Confirm Order* screen is strictly a local simulation. No credit card details, real funds, or backend order creation requests are dispatched.
