# IponGPT Technical Implementation Guide

## Overview
This document provides detailed technical implementation steps for transforming PesoTracker into IponGPT, organized by Front End (UI screens) and Back End (technical infrastructure) components.

---

# FRONT END

## 1. Home Screen (HomeScreen)

### Current Layout:
![Home Screen Current Layout](../old-layout-images/home.png)

### Current Features:
- Basic greeting with user name ("Kumusta, Phill!")
- Current Streak card with flame icon showing 0 days and best streak
- Gastos Summary section with Today/This Month totals (₱0.00)
- Top Categories breakdown (Bills: ₱556.00, Food: ₱500.00)
- Savings Goals preview with "Walang savings goals pa" message
- Bottom navigation with Home, Mga Gastos, Goals, Hamon tabs
- Green floating "+" button for adding new items
- Settings gear icon in top right

### Proposed UI Changes:
- **Add prominent "+" button in center** for quick Money In/Money Out entry → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#11-add-prominent--button-in-center-for-quick-money-inmoney-out-entry)
- **Multiple wallet selector** at top (Cash, Card, VPS, etc.) with balance display → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#12-implement-multiple-wallet-selector-with-balance-display)
- **Enhanced streak visualization** with possible animations and/or confetti → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#13-create-enhanced-streak-visualization-with-animations)
- **Total balance display** prominently at top with hide/show toggle → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#14-add-total-balance-display-with-hideshow-toggle)
- **Money Insider section** showing visual spending trends with mini charts → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#15-implement-money-insider-section-with-mini-charts)
- **AI Coach floating icon** for quick access to financial advisor → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#16-add-ai-coach-floating-icon-for-quick-access)
- **Cultural motivational phrases** below sections ("Konting tiis, Josh! Ipon na malapit na!") → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#17-integrate-cultural-motivational-phrases)
- **Enhanced visual design** with thermometer-style progress bars → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#18-create-thermometer-style-progress-bars)
- **Quick action cards** for common tasks (Add Expense, Check Goals, View Challenges) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#19-implement-quick-action-cards-for-common-tasks)

### Implementation Details:
```dart
// New wallet selector widget
class WalletSelector extends StatelessWidget {
  final List<Wallet> wallets;
  final Wallet selectedWallet;
  final Function(Wallet) onWalletChanged;
  
  // Displays horizontal scrolling wallet cards
  // Shows balance for each wallet
  // Allows quick switching between wallets
}

// Enhanced streak visualization
class EnhancedStreakCard extends StatefulWidget {
  // Animated flame icons
  // Confetti animation on streak milestones
  // Best streak tracking display
  // Progress towards next milestone
}

// Money Insider mini charts
class SpendingTrendsWidget extends StatelessWidget {
  // Mini pie chart for category breakdown
  // Weekly spending line graph
  // Comparison with previous period
}
```

---

## 2. Refactor Expense Screen (AddExpenseScreen)

### Current Layout:
![Add Expense Screen Current Layout](../old-layout-images/add-expense.png)

### Current Features:
- Amount input field
- Category dropdown selection
- Subcategory selection
- Description text field
- Date picker
- Form validation
- Basic expense creation
- restricted to expense only. 

### Proposed UI Changes:
- **Unified Money In/Money Out tabs** in single screen and call the page "Transactions" → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#21-create-unified-money-inmoney-out-tabs)

![money example](../images/improvments/money-in-out.png)
- **Voice input button** with "Nag-spend ako ng ₱50 sa breakfast" support → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#22-add-voice-input-button-with-filipino-phrase-support)
- **Photo receipt capture** button with auto-categorization preview → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#23-implement-photo-receipt-capture-with-auto-categorization)
- **Filipino-specific categories** → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#24-create-filipino-specific-categories-system):
  - Pagkain, Transportasyon (Jeep/Bus/MRT/LRT/Trike)
  - Bills (Kuryente/Tubig/Internet/Load)
  - Shopping (Grocery, Damit)
  - Entertainment (Movies, Gimik, Inuman)

![catagory examples](../images/improvments/catagories.png)
- **Recurring transaction toggle** with frequency options → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#25-add-recurring-transaction-toggle-with-frequency-options)
- **Location-based hints** (optional) for common places → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#26-implement-location-based-hints-feature)
- **Quick amount buttons** (₱20, ₱50, ₱100, ₱200) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#27-add-quick-amount-buttons-for-common-values)
- **Recent transactions suggestions** for faster entry → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#28-create-recent-transactions-suggestions-system)
- **Wallet selection** integrated into the form → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#29-integrate-wallet-selection-into-form)

### Implementation Details:
```dart
class UnifiedTransactionEntry extends StatefulWidget {
  // TabBar for Money In/Money Out
  // Voice recognition integration
  // Camera integration for receipt capture
  // ML-based category suggestion from photos
}

class VoiceInputWidget extends StatefulWidget {
  // Speech-to-text integration
  // Natural language processing for Filipino phrases
  // Automatic amount and category extraction
}

class PhotoReceiptCapture extends StatefulWidget {
  // Camera integration
  // OCR for text extraction from receipts
  // Smart category suggestion based on merchant
}
```

---

## 3. Expense List Screen (ExpenseListScreen)

### Current Layout:
![Expense List Screen Current Layout](../old-layout-images/expenses.png)

### Current Features:
- "Mga Gastos" title with settings icon
- Search bar with "Search expenses..." placeholder
- Category filter tabs (All, Pagkain, Transportasyon, Bills)
- Expense cards showing:
  - Category icons (Bills with calendar icon, Food with utensils icon)
  - Expense description and category type
  - Amount in green (₱556.00, ₱500.00)
  - Date timestamps (Aug 22, 2025, Aug 20, 2025)
- Green floating "+" button for adding expenses
- Bottom navigation

### Proposed UI Changes:
- **Visual category icons** instead of text labels → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#31-replace-text-labels-with-visual-category-icons)
- **Enhanced expense cards** with merchant logos/icons → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#32-enhance-expense-cards-with-merchant-logosicons)
- **Swipe actions** for quick edit/delete/duplicate → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#33-add-swipe-actions-for-quick-editdeleteduplicate)
- **Advanced filtering** by category, date range, amount → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#34-implement-advanced-filtering-system)
- **Search functionality** with smart suggestions → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#35-add-search-functionality-with-smart-suggestions)
- **Visual spending patterns** with mini charts per category → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#36-create-visual-spending-patterns-with-mini-charts)
- **Bulk operations** (select multiple, bulk delete/edit) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#37-implement-bulk-operations-feature)
- **Receipt photos** displayed as thumbnails on cards → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#38-add-receipt-photos-as-thumbnails-on-cards)
- **Quick stats bar** showing total, average, highest expense → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#39-create-quick-stats-bar-with-totals-and-averages)

### Implementation Details:
```dart
class EnhancedExpenseCard extends StatelessWidget {
  // Category icons and colors
  // Receipt photo thumbnails
  // Swipe action buttons
  // Visual amount highlighting
}

class ExpenseFilterSheet extends StatefulWidget {
  // Date range picker
  // Category multi-select
  // Amount range slider
  // Saved filter presets
}
```

---

## 4. Goals Screen (GoalsScreen)

### Current Layout:
![Goals Screen Current Layout](../old-layout-images/goals.png)

### Current Features:
- "My Goals" title with settings icon
- Goal duration tabs (All, Short, Medium, Long)
- Goal Statistics card with empty state message
- "No goals yet" placeholder with folder icon
- "Create your first goal to see statistics here" instruction
- "Walang savings goals pa" message at bottom
- "Create First Goal" text
- Green "+ create goal" button at bottom
- Green floating flag icon button
- Bottom navigation with Goals tab highlighted

### Proposed UI Changes:
- **Goal templates** with preset options (Phone, Baguio trip, emergency fund, tuition) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#41-create-goal-templates-with-preset-options)
- **Thermometer-style progress bars** with milestone animations → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#42-implement-thermometer-style-progress-bars-with-animations)
- **Visual progress indicators** with confetti on achievements → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#43-add-visual-progress-indicators-with-milestone-celebrations)
- **Social sharing buttons** ("I'm 50% closer to my Siargao trip!") → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#44-create-social-sharing-buttons-for-achievements)
- **Timeline calculators** showing projected completion dates → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#45-add-timeline-calculators-for-completion-dates)
- **Goal categories** with different visual themes → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#46-implement-goal-categories-with-visual-themes)
- **Quick contribute button** for easy progress updates → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#47-add-quick-contribute-button-for-progress-updates)
- **Achievement badges** for completed goals → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#48-create-achievement-badges-for-completed-goals)
- **Progress photos** option to add visual motivation → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#49-add-progress-photos-option-for-visual-motivation)

### Implementation Details:
```dart
class ThermometerProgressBar extends StatefulWidget {
  // Animated filling effect
  // Milestone markers
  // Confetti animation on milestones
}

class GoalTemplateSelector extends StatelessWidget {
  // Predefined goal templates
  // Visual template cards
  // Smart default amounts and timelines
}

class SocialShareButton extends StatelessWidget {
  // Integration with social platforms
  // Custom share images
  // Progress celebration messages
}
```

---

## 5. Add/Edit Goal Screen (AddGoalScreen, EditGoalScreen)

### Current Layout:
![Add Goals Screen Current Layout](../old-layout-images/add-goal.png)

### Current Features:
- Goal type selection
- Popular Goal types
- Goal name input
- Goal Description
- Target amount input
- Target date picker
- Basic form validation

### Proposed UI Changes:
- **Visual goal type selection** with icons and descriptions → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#51-implement-visual-goal-type-selection-with-icons)
- **Smart amount suggestions** based on goal type → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#52-add-smart-amount-suggestions-based-on-goal-type)
- **Timeline calculator** showing required daily/weekly savings → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#53-create-timeline-calculator-for-required-savings)
- **Visual progress preview** of what the completed goal will look like → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#54-add-visual-progress-preview-feature)
- **Motivation image upload** for personal goal visualization → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#55-implement-motivation-image-upload-feature)
- **Sub-goals creation** for large goals broken into milestones → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#56-create-sub-goals-for-large-objectives)
- **Reminder notifications** setup for regular contributions → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#57-add-reminder-notifications-setup)

### Implementation Details:
```dart
class GoalTypeSelector extends StatelessWidget {
  // Visual grid of goal types
  // Icons and descriptions
  // Smart defaults for each type
}

class TimelineCalculator extends StatefulWidget {
  // Interactive calculations
  // Visual timeline display
  // Adjustment sliders for flexibility
}
```

---

## 6. Challenges/Gamification Screen (ChallengesScreen, BadgesScreen)

### Current Layout:
![Challenges Screen Current Layout](../old-layout-images/challange.png)

### Current Features:
- "Mga Hamon" (Challenges) title with settings icon
- Challenge period tabs (Overview, Daily, Weekly, Monthly)
- Your Challenge Stats section with colored stat cards:
  - Points: 0 (yellow with star icon)
  - Active: 0 (green with info icon)
  - Done: 0 (green with checkmark icon)
  - Badges: 0 (red with badge icon)
  - Streak: 0 days (red with flame icon)
  - Level: 1 (purple with trend icon)
- Level progress bar showing "Level 1" and "100 points to Level 2"
- Active Challenges section with empty state
- "No active challenges" message with folder icon
- Instructions to "Swipe right to choose new challenges in Daily, Weekly, or Monthly tabs"
- Earned Badges section with "View All" link
- Bottom navigation with Hamon (trophy icon) tab highlighted

### Proposed UI Changes:
- **Enhanced challenge cards** with Filipino-themed designs → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#61-create-enhanced-challenge-cards-with-filipino-themes)
- **Passive challenge tracking** with automatic enrollment → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#62-implement-passive-challenge-tracking-system)
- **Challenge types** → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#63-add-filipino-challenge-types):
  - Tipid Tuesday, No Kape, Baon Lang
  - Jeepney Mode, Week-long Saver
  - Receipt Warrior, Masinop na Pinoy, Ipon Master
- **Community leaderboards** (Barangay/barkada/family competitions) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#64-add-community-leaderboards-feature)
- **Visual progress tracking** with animated progress bars → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#65-create-visual-progress-tracking-with-animations)
- **Achievement celebrations** with confetti and sound effects → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#66-implement-achievement-celebrations-with-effects)
- **Challenge history** showing completed challenges → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#67-add-challenge-history-display)
- **Social features** for sharing achievements → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#68-create-social-features-for-sharing-achievements)

### Implementation Details:
```dart
class FilipinoChallengeCard extends StatefulWidget {
  // Cultural theming and colors
  // Progress animations
  // Community ranking display
}

class LeaderboardWidget extends StatelessWidget {
  // Community rankings
  // Friend/family comparisons
  // Achievement showcases
}
```

---

## 7. Settings Screen (SettingsScreen)

### Current Layout:
![Settings Screen Current Layout](../old-layout-images/settings.png)

### Current Features:
- "Settings" title with back arrow and home icon
- User profile card showing:
  - User avatar ("P" in green circle)
  - Name ("Phill") with "Current" badge
  - Level and streak ("Level 1 • 0 day streak")
  - Monthly Income ("Monthly Income: ₱8000")
  - Three-dot menu option
- Account section with:
  - Profile option ("Name, avatar, preferences")
  - User Management ("Manage local users / accounts")
- App section with:
  - Language setting ("Filipino / English")
  - Theme setting ("System default")
  - Notifications toggle (enabled - green switch)
- Data section with:
  - Export data option
  - Import data option
  - Clear all local data (in red text)

### Proposed UI Changes:
- **Enhanced privacy controls** with clear explanations → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#71-enhance-privacy-controls-with-clear-explanations)
- **Security settings** (biometric/PIN setup) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#72-add-security-settings-with-biometricpin-setup)
- **Notification preferences** with granular controls → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#73-create-granular-notification-preferences)
- **Data management** (export, backup, delete options) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#74-implement-data-management-features)
- **Premium upgrade** section with feature comparisons → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#75-add-premium-upgrade-section)
- **AI Coach settings** (personality, language preference) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#76-create-ai-coach-settings-panel)
- **Wallet management** for multiple accounts → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#77-implement-wallet-management-system)
- **Cultural preferences** (Taglish level, regional dialects) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#78-add-cultural-preferences-options)

### Implementation Details:
```dart
class PrivacyControlPanel extends StatefulWidget {
  // Toggle switches for each privacy setting
  // Clear explanations of data usage
  // Easy export/delete options
}

class SecuritySetupScreen extends StatefulWidget {
  // Biometric authentication setup
  // PIN creation and confirmation
  // Security level indicators
}
```

---

## 8. AI Coach Chat Screen (New)

### Current Features:
- Not implemented

### Proposed UI Changes:
- **Chat interface** with conversational AI → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#81-create-chat-interface-with-conversational-ai)
- **Quick action chips** for common questions → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#82-add-quick-action-chips-for-common-questions)
- **Taglish support** with language mixing → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#83-implement-taglish-support-with-language-mixing)
- **Contextual advice** based on spending patterns → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#84-create-contextual-advice-based-on-spending-patterns)
- **Visual insights** with charts and graphs in chat → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#85-add-visual-insights-with-charts-in-chat)
- **Voice interaction** option for hands-free use → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#86-implement-voice-interaction-option)
- **Smart suggestions** based on financial behavior → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#87-create-smart-suggestions-based-on-behavior)
- **Educational content** delivery through conversations → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#88-add-educational-content-delivery-system)

### Implementation Details:
```dart
class AICoachChatScreen extends StatefulWidget {
  // Chat bubble UI
  // Quick action buttons
  // Voice input/output integration
  // Contextual response generation
}

class ChatBubble extends StatelessWidget {
  // Different styles for user/AI messages
  // Rich content support (charts, images)
  // Timestamp and status indicators
}

class QuickActionChips extends StatelessWidget {
  // Predefined question buttons
  // Context-aware suggestions
  // Popular query shortcuts
}
```

---

## 9. Reports/Analytics Screen (New)

### Current Features:
- Basic expense summaries

### Proposed UI Changes:
- **Visual charts** (pie/bar/line charts for categories) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#91-create-visual-charts-for-category-analysis)

![Visual Chart example](../images/improvments/visual-charts.png)
- **Trend analysis** with time period comparisons → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#92-implement-trend-analysis-with-time-comparisons)
- **Story-style recaps** with Filipino context → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#93-add-story-style-recaps-with-filipino-context)
- **Spending pattern insights** with recommendations → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#94-create-spending-pattern-insights-with-recommendations)
- **Goal progress analytics** with projections → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#95-implement-goal-progress-analytics-with-projections)
- **Export options** (CSV, PDF for premium users) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#96-add-export-options-for-data)
- **Comparative analysis** (month-over-month, year-over-year) → [Implementation Details](FRONTEND_IMPLEMENTATION_DETAILS.md#97-create-comparative-analysis-features)

### Implementation Details:
```dart
class InteractiveChartWidget extends StatefulWidget {
  // Multiple chart types
  // Touch interactions
  // Drill-down capabilities
}

class SpendingInsightsCard extends StatelessWidget {
  // AI-generated insights
  // Actionable recommendations
  // Cultural context integration
}
```

---

# BACK END

## 1. State Management Migration (Provider → Riverpod)

### Overview:
Migrate from Provider to Riverpod for improved compile-time safety, better testing, and more flexible dependency injection. Riverpod eliminates BuildContext dependency and provides better error handling.

### Key Benefits:
- Compile-time safety prevents runtime provider errors
- Enhanced testing capabilities with easier mocking
- Automatic disposal and better memory management
- Support for computed states and complex dependency graphs

→ [Detailed Implementation Guide](BACKEND_IMPLEMENTATION_DETAILS.md#1-state-management-migration-provider--riverpod)

---

## 2. AI Financial Coach Service

### Overview:
Implement a rule-based AI financial coach that provides contextual advice, insights, and nudges based on user spending patterns, goals, and financial behavior. Start with predefined rules and patterns for MVP.

### Key Features:
- Contextual financial advice based on spending patterns
- Multi-language support (English, Filipino, Taglish)
- Daily nudges and reminders
- Goal-specific tips and encouragement
- Pattern recognition for overspending alerts

→ [Detailed Implementation Guide](BACKEND_IMPLEMENTATION_DETAILS.md#2-ai-financial-coach-service)

---

## 3. Security & Privacy Enhancements

### Overview:
Implement comprehensive security measures including biometric/PIN authentication, encrypted local storage, and privacy controls to protect sensitive financial data.

### Key Features:
- Biometric authentication (fingerprint, face recognition) with PIN fallback
- AES encryption for all locally stored financial data
- Granular privacy controls with clear explanations
- Secure data export/import functionality
- Complete data deletion capabilities

→ [Detailed Implementation Guide](BACKEND_IMPLEMENTATION_DETAILS.md#3-security--privacy-enhancements)

---

## 4. Database Enhancements

### Overview:
Extend the current Hive database with new data models, encryption support, and additional boxes for enhanced features like wallets, AI coach history, and challenges.

### Key Enhancements:
- Add new encrypted Hive boxes for wallets, coach history, challenges
- Implement database compaction and maintenance routines
- Create data migration utilities for schema updates
- Add backup/restore functionality with password protection
- Performance optimization for large datasets

→ [Detailed Implementation Guide](BACKEND_IMPLEMENTATION_DETAILS.md#4-database-enhancements)

---

## 5. Monetization System

### Overview:
Implement freemium model with in-app purchases for premium features. Include feature gating, subscription management, and upgrade prompts.

### Key Components:
- In-app purchase integration for premium subscriptions
- Feature gating system to control access to premium features
- Subscription status tracking and validation
- Upgrade prompts and premium feature showcases
- Local subscription verification with receipt validation

→ [Detailed Implementation Guide](BACKEND_IMPLEMENTATION_DETAILS.md#5-monetization-system)

---

## 6. Voice & Photo Processing

### Overview:
Add voice input for Filipino phrases and photo receipt processing with OCR to automatically extract transaction details and categorize expenses.

### Key Features:
- Speech-to-text with Filipino/Taglish phrase recognition
- Natural language processing for amount and category extraction
- OCR integration for receipt text extraction
- Philippine merchant recognition and auto-categorization
- Image optimization and compression for storage

→ [Detailed Implementation Guide](BACKEND_IMPLEMENTATION_DETAILS.md#6-voice--photo-processing)

---

## 7. Offline-First Architecture

### Overview:
Ensure full app functionality when offline with background sync when connected. Implement conflict resolution and data consistency strategies.

### Key Components:
- Background sync service for data synchronization
- Conflict resolution strategies for concurrent edits
- Connection status monitoring and retry mechanisms
- Optimistic updates with rollback capabilities
- Queued operations for offline actions

→ [Detailed Implementation Guide](BACKEND_IMPLEMENTATION_DETAILS.md#7-offline-first-architecture)

---

## 8. Performance & Optimization

### Overview:
Optimize app performance through image compression, database maintenance, memory management, and efficient data loading strategies.

### Key Optimizations:
- Image compression while maintaining OCR quality
- Database compaction and archiving strategies
- Lazy loading for large datasets
- Memory usage optimization for expense lists
- Background task scheduling for maintenance

→ [Detailed Implementation Guide](BACKEND_IMPLEMENTATION_DETAILS.md#8-performance--optimization)

---

## Implementation Timeline

### Phase 1 (Weeks 1-3): Foundation & Migration
- Set up Riverpod dependencies
- Begin Provider to Riverpod migration
- Implement basic security features
- Set up encrypted storage

### Phase 2 (Weeks 4-6): Core Features
- Complete state management migration
- Implement AI Coach MVP (rule-based)
- Add voice input functionality
- Enhance home screen UI

### Phase 3 (Weeks 7-9): Advanced Features
- Photo receipt processing
- Multiple wallets support
- Enhanced gamification
- Privacy controls

### Phase 4 (Weeks 10-12): Monetization & Polish
- In-app purchase integration
- Premium features implementation
- Performance optimization
- Comprehensive testing

---

## Testing Strategy

### Unit Tests:
- Provider/Riverpod state management
- Business logic and calculations
- AI Coach rule engine
- Data processing services

### Integration Tests:
- Database operations
- API integrations
- Voice and photo processing
- Sync functionality

### UI Tests:
- Screen navigation flows
- Form validations
- Visual component behavior
- Accessibility compliance

### Performance Tests:
- Database query performance
- Image processing speed
- Memory usage optimization
- Battery consumption monitoring