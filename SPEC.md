# SalesTrack Lite - Specification Document

## 1. Project Overview

**Project Name:** SalesTrack Lite  
**Type:** Offline-first mobile application (iOS & Android)  
**Core Goal:** A simple mobile app for small shop owners to add products, record sales quickly, and view daily earnings with a clean, intuitive UI.

---

## 2. Technology Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter (latest stable) |
| Language | Dart |
| Local Database | Hive (NoSQL, offline-first) |
| State Management | Provider |
| Charts | fl_chart (for weekly bar chart) |
| Architecture | Clean Architecture (UI / Business Logic / Data) |

---

## 3. Data Models

### Product
```dart
- id: String (UUID)
- name: String
- price: double
- createdAt: DateTime
```

### Sale
```dart
- id: String (UUID)
- productId: String
- productName: String (denormalized for display)
- quantity: int
- unitPrice: double
- total: double
- createdAt: DateTime
```

---

## 4. Core Features

### 4.1 Product Management
- Add new product (name + price)
- View all products in a list
- Delete product (swipe to delete)
- Products stored locally via Hive

### 4.2 Record Sale
- Select product from dropdown
- Input quantity (numeric keyboard)
- Auto-calculate total (price × quantity)
- Save sale to local Hive database
- Instant feedback on save

### 4.3 Daily Summary Dashboard
- Today's total sales (formatted as currency)
- Today's transaction count
- Weekly bar chart (last 7 days sales)
- Quick action buttons: "Record Sale", "Products"

---

## 5. UI/UX Specification

### 5.1 Screen Structure

| Screen | Route | Description |
|--------|-------|-------------|
| Dashboard | `/` | Home screen with totals and chart |
| Products | `/products` | Product list and add product |
| Record Sale | `/record-sale` | Sale entry form |

### 5.2 Navigation Flow
```
Dashboard (Home)
    ├── [Record Sale Button] → Record Sale Screen
    │                              └── [Save] → Back to Dashboard
    └── [Products Button] → Products Screen
                               └── [Add Product FAB] → Add Product Dialog
```

### 5.3 Visual Design

#### Color Palette
| Role | Color | Hex |
|------|-------|-----|
| Primary | Deep Blue | #1565C0 |
| Primary Dark | Dark Blue | #0D47A1 |
| Secondary | Amber/Gold | #FFA000 |
| Background | Off-White | #FAFAFA |
| Surface | White | #FFFFFF |
| Error | Red | #D32F2F |
| Success | Green | #388E3C |
| Text Primary | Dark Gray | #212121 |
| Text Secondary | Medium Gray | #757575 |

#### Typography
| Element | Font | Size | Weight |
|---------|------|------|--------|
| App Title | Roboto | 24sp | Bold |
| Screen Title | Roboto | 20sp | SemiBold |
| Card Title | Roboto | 18sp | Medium |
| Body Text | Roboto | 16sp | Regular |
| Caption | Roboto | 14sp | Regular |
| Button | Roboto | 16sp | Medium |

#### Spacing System (8pt grid)
- Screen padding: 16px
- Card padding: 16px
- Item spacing: 8px
- Section spacing: 24px

### 5.4 Screen Designs

#### Dashboard Screen
- App bar with "SalesTrack Lite" title
- Summary card showing "Today's Money" (large amount) and "X Transactions"
- Weekly bar chart showing last 7 days
- Two large buttons: "Record Sale" (primary) and "Products" (secondary)

#### Products Screen
- App bar with back button and "Products" title
- List of products showing name and price
- FAB button to add new product
- Swipe to delete functionality

#### Record Sale Screen
- App bar with back button and "Record Sale" title
- Product dropdown selector
- Quantity input field
- Auto-calculated total display
- "SAVE SALE" primary button

### 5.5 Widget Specifications

#### Primary Button
- Background: Primary color (#1565C0)
- Text: White, 16sp, bold
- Height: 56px
- Border radius: 8px
- Full width with 16px horizontal margin

#### Secondary Button
- Background: Transparent
- Border: 2px solid Primary
- Text: Primary color, 16sp
- Height: 56px
- Border radius: 8px
- Full width with 16px horizontal margin

#### Card
- Background: White
- Border radius: 12px
- Elevation: 2
- Padding: 16px

#### List Tile
- Height: 72px
- Divider between items
- Swipe to delete enabled

#### Text Input
- Height: 56px
- Border: 1px solid #E0E0E0
- Border radius: 8px
- Focused border: Primary color
- Keyboard: Text for name, Numeric for price/quantity

#### Dropdown
- Same styling as text input
- Dropdown icon on right
- Items show name + price

---

## 6. UX Requirements

1. **Speed**: Recording a sale must take less than 5 seconds
2. **Responsiveness**: App must feel instant (no loading states for local data)
3. **Simplicity**: No authentication required
4. **Offline**: No internet connection required
5. **Language**: Simple, non-technical terms
   - "Today's Money" instead of "Daily Revenue"
   - "Record Sale" instead of "New Transaction"
   - "Products" instead of "Inventory"

---

## 7. Folder Structure (Clean Architecture)

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Color constants
│   │   └── app_strings.dart     # String constants
│   │
│   └── utils/
│       └── formatters.dart      # Currency/date formatters
│
├── data/
│   ├── models/
│   │   ├── product.dart         # Product model + Hive adapter
│   │   └── sale.dart            # Sale model + Hive adapter
│   │
│   ├── repositories/
│   │   ├── product_repository.dart
│   │   └── sale_repository.dart
│   │
│   └── services/
│       └── hive_service.dart    # Hive initialization
│
├── providers/
│   ├── product_provider.dart    # Product state management
│   └── sale_provider.dart       # Sale state management
│
└── ui/
    ├── screens/
    │   ├── dashboard_screen.dart
    │   ├── products_screen.dart
    │   └── record_sale_screen.dart
    │
    └── widgets/
        ├── primary_button.dart
        ├── secondary_button.dart
        ├── summary_card.dart
        └── weekly_chart.dart
```

---

## 8. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  fl_chart: ^0.68.0
  uuid: ^4.4.2
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.11
```

---

## 9. Non-Functional Requirements

| Requirement | Description |
|-------------|-------------|
| Performance | App launches in under 2 seconds |
| Storage | Local storage only, no cloud sync |
| Compatibility | Android 5.0+ (API 21), iOS 12.0+ |
| Accessibility | Large touch targets (min 48x48dp) |

---

## 10. Future Enhancements (NOT in MVP)

- Monthly/weekly reports
- Product categories
- Stock management
- Customer management
- Cloud backup
- Export to CSV