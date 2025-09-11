# IponGPT AI Screen Design Prompts

This document contains detailed AI prompts for generating visual designs of each screen in the IponGPT application, incorporating all the proposed UI changes, visual design system, and Filipino-centric design elements.

## Table of Contents

1. [Home Screen (HomeScreen)](#1-home-screen-homescreen)
2. [Transactions Screen (Refactored AddExpenseScreen)](#2-transactions-screen-refactored-addexpensescreen)
3. [Expense List Screen (ExpenseListScreen)](#3-expense-list-screen-expenselistscreen)
4. [Goals Screen (GoalsScreen)](#4-goals-screen-goalsscreen)
5. [Add/Edit Goal Screen](#5-addedit-goal-screen)
6. [Challenges/Gamification Screen (ChallengesScreen)](#6-challengesgamification-screen-challengesscreen)
7. [Settings Screen (SettingsScreen)](#7-settings-screen-settingsscreen)
8. [AI Coach Chat Screen (New)](#8-ai-coach-chat-screen-new)
9. [Reports/Analytics Screen (New)](#9-reportsanalytics-screen-new)
10. [Visual Design System Reference](#10-visual-design-system-reference)

---

## 1. Home Screen (HomeScreen)

**AI Prompt:**
```
Create a modern Filipino financial app home screen with the following specifications:

LAYOUT & STRUCTURE:
- Top section: Multiple wallet selector showing horizontal scrolling cards (Cash, Card, VPS) with individual balances
- Prominent total balance display at top with peso (₱) symbol and hide/show toggle eye icon
- Center: Large prominent "+" button for quick Money In/Money Out entry
- Enhanced streak visualization with animated flame icons and confetti effects for milestones
- Money Insider section with mini charts showing visual spending trends (pie chart for categories, weekly line graph)
- AI Coach floating icon in bottom right for quick access
- Cultural motivational phrases in Filipino: "Konting tiis, Josh! Ipon na malapit na!"
- Quick action cards for common tasks (Add Expense, Check Goals, View Challenges)
- Gastos Summary with Today/This Month totals
- Top Categories breakdown with visual category icons
- Savings Goals preview with thermometer-style progress bars

VISUAL DESIGN SYSTEM:
- Primary colors: Green #4CAF50 (prosperity), Blue #2196F3 (trust), Orange #FF9800 (energy)
- Cultural colors: Sunset Orange #FF7043, Ocean Blue #0288D1, Rice Gold #FFB300, Bamboo Green #388E3C
- Typography: Poppins for headers (32px bold), Inter for body text (16px), JetBrains Mono for amounts
- Cards: 12px border radius, 2dp elevation, 16px padding, warm friendly appearance
- Filipino-themed icons: Jeepney, sari-sari store, bahay kubo, coconut elements
- Warm color temperature throughout with rounded corners and organic shapes

FILIPINO CULTURAL ELEMENTS:
- Greeting: "Kumusta, [Name]!" at top
- Mixed Taglish motivational text with proper spacing
- Philippine flag colors (blue, red, yellow) in achievement badges
- Sunset orange gradients and tropical visual elements
- Celebration confetti with Filipino flag colors for achievements

INTERACTIONS:
- Animated button press (150ms scale down to 0.95x with bounce)
- Card tap animations (200ms elevation increase + subtle scale)
- Streak flames with flickering animation
- Progressive fill animations for progress bars (600ms)
- Bottom navigation: Home, Mga Gastos, Goals, Hamon tabs
```

---

## 2. Transactions Screen (Refactored AddExpenseScreen)

**AI Prompt:**
```
Design a unified transaction entry screen for a Filipino financial app with these specifications:

LAYOUT & STRUCTURE:
- Screen title: "Transactions" with back navigation
- Top: Tab bar with "Money Out" and "Money In" tabs with Material Design styling
- Voice input button prominently displayed with microphone icon and "Tap to speak" text
- Photo receipt capture button with camera icon and preview functionality
- Amount input field with quick amount buttons (₱20, ₱50, ₱100, ₱200)
- Filipino-specific category selector with cultural icons and names
- Wallet selection dropdown integrated into form
- Description field with recent transaction suggestions
- Date picker with calendar integration
- Recurring transaction toggle with frequency options
- Location-based hints section (optional)

CATEGORY SYSTEM:
- Pagkain (Food) with rice bowl and jeepney food cart icons
- Transportasyon with jeepney, MRT, tricycle, bus icons
- Bills section: Kuryente (electricity), Tubig (water), Internet, Load
- Shopping: Grocery, Damit (clothes) with SM Mall and market basket icons
- Entertainment: Movies, Gimik, Inuman with karaoke mic and festival icons
- Each category with distinct color coding and Filipino cultural icons

VISUAL DESIGN:
- Primary Green #4CAF50 for save/confirm actions
- Accent Orange #FF9800 for voice and camera buttons
- Cultural colors for categories matching Filipino context
- Input fields: 12px border radius, filled style with #FAFAFA background
- Typography: Inter 16px for labels, Poppins bold for headers, JetBrains Mono for amounts
- Voice input: Large circular button with pulsing animation when active
- Camera button: Rounded rectangle with preview thumbnail capability

FILIPINO ELEMENTS:
- Category names in Filipino: "Pagkain", "Transportasyon", "Kuryente"
- Voice input supports phrases like "Nag-spend ako ng ₱50 sa breakfast"
- Cultural context in category icons (jeepney for transport, sari-sari store for shopping)
- Peso currency formatting with proper ₱ symbol integration
- Form validation messages in friendly Taglish

INTERACTIONS:
- Tab switching with slide animations (300ms)
- Voice input with real-time speech recognition visualization
- Photo capture with OCR preview and auto-categorization suggestions
- Quick amount buttons with ripple effects
- Category selection with visual feedback and icon animations
```

---

## 3. Expense List Screen (ExpenseListScreen)

**AI Prompt:**
```
Create a new comprehensive expense tracking list screen for a Filipino financial app:

LAYOUT & STRUCTURE:
- Header: "Mga Gastos" title with settings icon
- Search bar with "Search expenses..." placeholder and smart suggestions
- Visual category filter tabs with icons instead of text labels
- Quick stats bar showing total, average, and highest expense for current period
- Enhanced expense cards with merchant logos/icons and receipt thumbnails
- Swipe actions for edit/delete/duplicate on each expense item
- Advanced filtering floating action button
- Bulk operations toolbar (appears when items selected)
- Empty state with friendly illustration when no expenses

EXPENSE CARD DESIGN:
- Category icon with background color matching expense category
- Merchant logo/icon when available (Jollibee, SM, etc.)
- Receipt photo thumbnail (24x24px) when available
- Expense description with Filipino text support
- Amount in JetBrains Mono font with proper peso formatting
- Date in MMM dd format
- Category name in category color
- Swipe left reveals: Edit (blue), Delete (red), Duplicate (orange)
- Card elevation: 2dp with 12px border radius

VISUAL DESIGN SYSTEM:
- Background: #FAFAFA with card backgrounds #FFFFFF
- Category colors: Food #FF9800, Transport #2196F3, Bills #F44336
- Typography: Inter regular 16px for descriptions, Inter medium 12px for categories
- Cultural icons: Jeepney for transport, bangus for food, bahay kubo for home expenses
- Search bar: Rounded with 12px radius, subtle shadow

FILTERING & SEARCH:
- Visual category chips with icons and count badges
- Date range picker with calendar view
- Amount range slider with peso formatting
- Saved filter presets: "This Month", "Last Week", "Food Only"
- Smart search suggestions based on previous entries
- Quick filter shortcuts for common views

FILIPINO ELEMENTS:
- Category names: "Pagkain", "Transportasyon", "Bills"
- Cultural merchant recognition: "Jollibee", "SM Mall", "7-Eleven"
- Mixed language support in descriptions
- Filipino date formatting preferences
- Cultural spending pattern insights

INTERACTIONS:
- Pull-to-refresh with loading animation
- Infinite scroll with pagination (20 items per page)
- Smooth swipe animations for actions
- Card tap animation (200ms elevation + scale)
- Bulk selection with checkbox animations
- Filter sheet slide-up animation (350ms)
```

---

## 4. Goals Screen (GoalsScreen)

**AI Prompt:**
```
Design an inspiring Filipino savings goals management screen:

LAYOUT & STRUCTURE:
- Header: "My Goals" with motivational Filipino phrase subtitle
- Goal duration tabs: All, Short, Medium, Long with progress indicators
- Goal templates section with preset visual cards (Phone, Baguio trip, Emergency fund, Tuition)
- Active goals with thermometer-style progress bars and milestone animations
- Quick contribute floating button for easy progress updates
- Achievement badges section for completed goals
- Social sharing buttons with celebration messages
- Timeline calculators showing projected completion dates
- Empty state with encouraging Filipino messaging

GOAL CARDS:
- Large thermometer progress indicator (vertical, 200px height)
- Goal category icons with visual themes (travel, gadgets, emergency, education)
- Progress percentage prominently displayed
- Target amount vs current amount in peso formatting
- Projected completion date with calendar icon
- Quick contribute button (+₱100, +₱500, +₱1000)
- Progress photos option for visual motivation
- Milestone markers on thermometer (25%, 50%, 75%, 100%)

VISUAL DESIGN:
- Primary Green #4CAF50 for progress and success states
- Purple #9C27B0 for dreams and aspirations
- Rice Gold #FFB300 for achievement celebrations
- Thermometer design: Bamboo Green #388E3C with gradient fill
- Cards: Elevated (4dp) with warm, rounded appearance (16px radius)
- Typography: Poppins bold for goal names, Inter for details

GOAL TEMPLATES:
- Travel goals: Ocean Blue background with coconut palm illustrations
- Gadgets: Tech-focused with modern gradients
- Emergency fund: Secure green with shield iconography
- Education: Academic purple with graduation cap elements
- Each template with smart default amounts and Filipino context

CELEBRATIONS & ACHIEVEMENTS:
- Confetti animation with Philippine flag colors
- Fireworks effect for completed goals
- Trophy and badge system with cultural elements
- Social sharing: "I'm 50% closer to my Siargao trip!" with custom images
- Achievement phrases in Taglish: "Ang galing mo!" celebrations

FILIPINO CULTURAL ELEMENTS:
- Goal suggestions: "Baguio trip", "iPhone para sa family", "Emergency fund"
- Motivational phrases: "Kaya mo yan!", "Konting tiis pa!"
- Cultural destination goals: Siargao, Palawan, Boracay
- Filipino family-oriented goal categories
- Bayanihan-inspired community sharing features

INTERACTIONS:
- Thermometer fill animation (800ms) on progress updates
- Milestone confetti triggers at 25%, 50%, 75%, 100%
- Goal template card selection with preview animation
- Share button with platform selection (Facebook, Instagram, WhatsApp)
- Quick contribute with satisfying progress animation
```

---

## 5. Add/Edit Goal Screen

**AI Prompt:**
```
Create a comprehensive goal creation/editing interface for a Filipino savings app:

LAYOUT & STRUCTURE:
- Header with back navigation and "Create Goal" or "Edit Goal" title
- Visual goal type selector with icon grid and descriptions
- Goal name input with suggestions based on type
- Smart amount suggestions panel based on selected goal type
- Target amount input with peso formatting and calculator
- Timeline calculator showing required daily/weekly savings with visual breakdown
- Visual progress preview of completed goal appearance
- Motivation image upload area with camera/gallery options
- Sub-goals creation for large objectives (milestone breakdown)
- Reminder notifications setup with frequency selector
- Save/Update button with confirmation

GOAL TYPE SELECTOR:
- Grid layout with large visual cards (2x3 on mobile)
- Travel: Ocean Blue with tropical elements and airplane icon
- Electronics: Tech gradient with smartphone/laptop icons
- Emergency: Green with shield and safety icons
- Education: Purple with books and graduation cap
- Home: Warm orange with bahay kubo illustration
- Business: Professional blue with growth charts
- Each type shows typical amount ranges and timeframes

SMART SUGGESTIONS:
- iPhone 15: ₱60,000-₱80,000 (12-18 months)
- Baguio Family Trip: ₱15,000-₱25,000 (3-6 months)
- Emergency Fund: ₱50,000-₱100,000 (12-24 months)
- College Tuition: ₱30,000-₱60,000 per semester
- Business Capital: ₱20,000-₱100,000+ (varies)
- Amounts adjust based on user's previous savings patterns

TIMELINE CALCULATOR:
- Interactive visual showing daily/weekly/monthly breakdown
- Slider to adjust timeline affecting required amounts
- Progress visualization: "Save ₱500/week for 20 weeks"
- Calendar integration showing key milestone dates
- Realistic vs optimistic timeline options
- Visual progress projection with thermometer preview

VISUAL DESIGN:
- Input fields: Material Design with Filipino-friendly styling
- Primary colors: Green #4CAF50 for positive actions
- Typography: Poppins for headers, Inter for body text
- Amount inputs: JetBrains Mono for currency clarity
- Progress preview: Miniature thermometer with current → target visualization
- Cultural color coding per goal type

MOTIVATION FEATURES:
- Photo upload area: "Add a picture of your goal"
- Pre-loaded inspiration images for common goals
- Progress photo timeline for visual motivation
- Milestone celebration previews
- Sharing template preview: "I'm saving for [goal]!"

SUB-GOALS SYSTEM:
- Milestone breakdown for large goals (>₱50,000)
- Visual timeline with checkpoint markers
- Individual progress tracking per milestone
- Celebration triggers for each sub-goal completion
- Dependency management (unlock next milestone)

FILIPINO ELEMENTS:
- Goal name suggestions in mixed English/Filipino
- Cultural context in amount suggestions
- Regional destination pricing (Baguio vs Boracay vs Siargao)
- Family-oriented goal options prominently featured
- Taglish motivational placeholders: "Para sa future ko!"

INTERACTIONS:
- Goal type selection with card flip animation
- Amount input with calculator popup
- Timeline slider with real-time calculation updates
- Photo upload with crop and filter options
- Preview animations showing goal completion celebration
- Form validation with friendly Filipino error messages
```

---

## 6. Challenges/Gamification Screen (ChallengesScreen)

**AI Prompt:**
```
Design a vibrant Filipino-themed gamification and challenges screen:

LAYOUT & STRUCTURE:
- Header: "Mga Hamon" with level indicator and profile avatar
- Challenge period tabs: Overview, Daily, Weekly, Monthly with progress rings
- User stats section with colorful metric cards in grid layout
- Level progress bar with Filipino-themed level names
- Active challenges carousel with Filipino challenge types
- Community leaderboards with Barangay/Barkada comparisons
- Earned badges showcase with "View All" expansion
- Challenge history timeline with completed achievements
- Social sharing section for achievements

STATS DASHBOARD:
- Points: Yellow card with star icon and current point total
- Active Challenges: Green card with info icon and count
- Completed: Green card with checkmark and achievement count
- Badges: Red card with badge icon and collection progress
- Streak: Red card with flame icon and day counter
- Level: Purple card with trend icon and progress to next level
- Each card with Filipino-inspired gradient backgrounds

FILIPINO CHALLENGE TYPES:
- Tipid Tuesday: Weekly no-spend challenge with savings thermometer
- No Kape Week: Coffee spending restriction with coffee cup icon crossed out
- Baon Lang: Homemade lunch challenge with packed meal illustration
- Jeepney Mode: Public transport only challenge with jeepney icon
- Receipt Warrior: Photo receipt collection with camera badge
- Masinop na Pinoy: Monthly savings target with Filipino flag elements
- Ipon Master: Consecutive saving days with piggy bank progression

VISUAL DESIGN SYSTEM:
- Challenge cards: Elevated design with cultural theming
- Filipino flag colors integrated in achievement elements
- Progress rings with tropical color gradients
- Typography: Poppins bold for challenge names, Inter for descriptions
- Cultural icons: Jeepney, sari-sari store, coconut, bangus
- Warm color temperature with sunset orange accents
- Badge designs inspired by Filipino medals and awards

COMMUNITY FEATURES:
- Leaderboard with avatar photos and nicknames
- Barangay competition levels (neighborhood challenges)
- Family/Barkada group challenges with shared progress
- Achievement sharing with pre-made celebration images
- Community milestone celebrations with group rewards
- Regional challenges specific to Filipino cities

GAMIFICATION ELEMENTS:
- Level system with Filipino-themed names: "Kuripot", "Matipid", "Ipon Master"
- Progress animations with confetti in Philippine flag colors
- Streak flames with tropical fire effects
- Badge collection with cultural achievement themes
- Point system with peso-equivalent rewards
- Milestone celebrations with fireworks animations

CHALLENGE PROGRESS:
- Visual progress bars with cultural motifs
- Real-time tracking with automatic updates
- Passive challenge enrollment suggestions
- Challenge difficulty indicators (Easy/Moderate/Hard)
- Reward previews and achievement celebrations
- Challenge completion certificates with Filipino flair

INTERACTIONS:
- Challenge card selection with flip animation
- Progress ring animations (800ms fill)
- Badge unlock celebrations with sound effects
- Leaderboard position changes with smooth transitions
- Achievement confetti with Philippine flag colors
- Challenge enrollment with confirmation animations
- Social share with platform-specific optimizations
```

---

## 7. Settings Screen (SettingsScreen)

**AI Prompt:**
```
Create a comprehensive settings interface for a Filipino financial app with privacy-first design:

LAYOUT & STRUCTURE:
- Header: "Settings" with back navigation
- User profile card with avatar, name, level, streak, and monthly income
- Account section: Profile management, User Management for local accounts
- Security section: Biometric/PIN setup, Privacy controls
- App preferences: Language (Filipino/English), Theme, Notifications
- AI Coach settings: Personality adjustment, Language preference
- Wallet management: Multiple account configuration
- Data management: Export, Import, Backup, Clear data options
- Premium upgrade section with feature comparison
- Cultural preferences: Taglish level, Regional dialects

PROFILE CARD:
- Large circular avatar with user initial or photo
- Name with "Current" badge indicator
- Level display: "Level 1" with experience progress
- Streak counter: "0 day streak" with flame icon
- Monthly income: "₱8,000" with edit capability
- Three-dot menu for quick actions
- Background gradient with subtle Filipino cultural patterns

SECURITY SECTION:
- Biometric authentication toggle with fingerprint/face icons
- PIN setup with number pad preview
- Privacy controls with detailed explanations
- Data encryption status indicator
- Access control for sensitive features
- Two-factor authentication options
- Security level indicator (Basic/Enhanced/Maximum)

APP PREFERENCES:
- Language selector: Filipino/English/Auto with flag icons
- Theme options: Light/Dark/System with preview thumbnails
- Notification granular controls with individual toggles
- Currency display preferences (peso symbol positioning)
- Date/time format selection
- Regional settings for Philippines

AI COACH CUSTOMIZATION:
- Personality sliders: Formal ↔ Casual, Brief ↔ Detailed
- Language mixing preference: Pure English ↔ Heavy Taglish
- Coaching frequency: Daily/Weekly/As-needed
- Advice style: Conservative/Balanced/Aggressive
- Cultural context level: International/Filipino-focused

WALLET MANAGEMENT:
- Multiple wallet creation and editing
- Wallet types: Cash, Banking, E-wallet (GCash, PayMaya)
- Balance visibility controls per wallet
- Default wallet selection
- Wallet categorization and color coding
- Bank account linking interface

DATA MANAGEMENT:
- Export options: CSV, JSON, PDF with date range selection
- Import data from other apps with format selection
- Backup to cloud with encryption options
- Data deletion with confirmation flows
- Storage usage indicator
- Privacy-compliant data handling explanations

PREMIUM FEATURES:
- Feature comparison table: Free vs Premium
- Subscription management interface
- Premium badge display on profile
- Feature unlock animations
- Pricing in Philippine pesos
- Family sharing options

VISUAL DESIGN:
- Settings cards with subtle elevation (2dp)
- Filipino-themed accent colors
- Toggle switches with cultural color schemes
- Typography: Inter for readability, clear hierarchy
- Privacy-first iconography with shield and lock symbols
- Warm, trustworthy color palette

CULTURAL PREFERENCES:
- Taglish intensity slider with examples
- Regional dialect options: Tagalog, Bisaya, Ilocano
- Cultural celebration preferences
- Local holiday recognition settings
- Regional spending category preferences
- Community feature participation levels

INTERACTIONS:
- Smooth toggle animations with haptic feedback
- Settings search with real-time filtering
- Contextual help tooltips for complex features
- Confirmation dialogs for destructive actions
- Success animations for setting changes
- Accessibility support for all interactive elements
```

---

## 8. AI Coach Chat Screen (New)

**AI Prompt:**
```
Design a Filipino financial advisor chat interface:

LAYOUT:
- Header with friendly AI coach avatar and status
- Chat bubbles: User (right, blue), AI (left, gray) 
- Quick action chips: "Spending trends", "Goal progress", "Tips para makatipid"
- Text input with voice button and send button
- Mini charts embedded in AI responses

VISUAL DESIGN:
- Chat bubbles: 16px radius with subtle shadows
- Colors: Primary Green #4CAF50, Cultural Orange #FF7043
- Typography: Inter for chat text, JetBrains Mono for amounts
- Filipino AI avatar with warm, approachable design

FILIPINO ELEMENTS:
- Taglish responses: "Medyo mataas ang gastos mo sa kape this week"
- Cultural advice: "Try mag-baon instead of buying lunch"
- Local context: Jeepney vs Grab comparisons, SSS/Pag-IBIG references
- Motivational phrases: "Kaya mo yan!", "₱500 pa lang para sa goal mo!"

KEY FEATURES:
- Voice input with Filipino phrase recognition
- Embedded mini charts (pie charts, progress bars)
- Smart suggestions based on spending patterns
- Educational tips about Filipino financial practices
- Export chat insights as images
```

---

## 9. Reports/Analytics Screen (New)

**AI Prompt:**
```
Design a Filipino financial analytics dashboard:

LAYOUT:
- Header: "Analytics" with date selector and export button
- Summary cards: Total spent, Average daily, Biggest expense, Savings rate
- Main chart area with pie/bar/line chart options
- Story-style recap in conversational Filipino
- Category breakdown with spending insights
- Goal progress section with thermometer indicators

VISUAL CHARTS:
- Pie chart with Filipino flag-inspired colors
- Bar charts with peso formatting (₱1,000, ₱2,000)
- Smooth animations (800ms) for chart drawing
- Interactive: tap segments for details
- Export options: PNG, PDF

SUMMARY CARDS:
- Large peso amounts with JetBrains Mono font
- Color-coded: Green for savings, Red for overspending
- Cultural icons: Jeepney (transport), Rice bowl (food)
- 12px rounded corners, 4dp elevation

FILIPINO STORY RECAPS:
- "This month, nag-spend ka ng ₱12,000, mostly sa pagkain"
- "Compared sa last month, mas matipid ka sa shopping"
- "Achievement: Naka-achieve mo ang savings goal mo!"
- Cultural context: "Pasko season kaya tumaas ang gastos"

SPENDING INSIGHTS:
- "Pwede mo i-reduce ang coffee expenses by ₱500/month"
- "Jeepney vs Grab: Save ₱300/week with public transport"
- "Home cooking saves ₱2,000/month vs restaurants"
- Category recommendations with cultural context

VISUAL DESIGN:
- Colors: Primary Green #4CAF50, Warning Red #F44336
- Typography: Inter for text, JetBrains Mono for amounts
- Cultural color coding and Filipino category names
- Accessibility compliant with high contrast options
```

---

## 10. Visual Design System Reference

**AI Design System Prompt:**
```
Create a comprehensive Filipino-centric design system for IponGPT financial app:

COLOR PALETTE:
Primary: Green #4CAF50 (prosperity), Blue #2196F3 (trust), Orange #FF9800 (energy), Red #F44336 (alerts)
Secondary: Yellow #FFC107 (gold), Purple #9C27B0 (dreams), Teal #009688 (calm), Indigo #3F51B5 (data)
Neutrals: Dark Gray #424242, Medium Gray #757575, Light Gray #BDBDBD, Background #FAFAFA, Cards #FFFFFF
Cultural: Sunset Orange #FF7043, Ocean Blue #0288D1, Rice Gold #FFB300, Bamboo Green #388E3C
Philippine Flag: Blue #0038A8, Red #CE1126, Yellow #FCE02A

TYPOGRAPHY SYSTEM:
Primary Font: Inter (clean, modern, readable)
Display Font: Poppins (bold headers, 32px for titles)
Secondary Font: Nunito Sans (friendly, for Filipino text)
Monospace: JetBrains Mono (numbers, currency, data)
Filipino considerations: Extra line height for mixed languages, proper peso symbol integration

ICONOGRAPHY:
Standard: Material Icons with 400 weight
Custom Filipino: Jeepney, sari-sari store, bahay kubo, bangus, coconut, tricycle
Category Icons: Cultural relevance (rice bowl for food, jeepney for transport)
Achievement badges: Philippine flag color integration
Size standards: 16px, 20px, 24px, 32px, 48px

COMPONENT SPECIFICATIONS:
Cards: 12px border radius, 2-4dp elevation, 16px padding, warm shadows
Buttons: 48dp height, 12px radius, bold text, proper touch targets (44dp minimum)
Progress indicators: Thermometer style (vertical), circular with cultural colors
Input fields: Rounded (12px), filled style, proper contrast ratios
Navigation: Material Design with Filipino flag accents

ANIMATIONS:
Micro-interactions: 150ms button press (0.95x scale), bounce curves
Page transitions: 300ms slide animations, fade + scale for modals
Content: Staggered list animations (50ms delays), progressive chart drawing (800ms)
Cultural celebrations: Confetti with flag colors, fireworks for achievements
Loading states: Peso coin spinning, tropical particle effects

ACCESSIBILITY:
WCAG AA compliance: 4.5:1 contrast ratios minimum
Typography: 14px minimum font size, 1.5x line height
Touch targets: 44dp minimum, clear focus indicators
Motion: Reduced motion support, alternative static indicators
Color blindness: Icons + text, not just color coding

CULTURAL DESIGN ELEMENTS:
Visual language: Warm color temperature, rounded corners, organic shapes
Motifs: Traditional weaving patterns, coconut palms, ocean waves, bahay kubo silhouettes
Festival colors: Bright, celebratory palettes for special occasions
Filipino visual identity: Hospitality, warmth, community, prosperity themes
Text handling: Taglish support, long category names (ellipsis), cultural phrases
```

This comprehensive set of AI prompts provides detailed specifications for each screen in the IponGPT application, incorporating all the visual design elements, Filipino cultural context, and technical requirements outlined in the Technical Implementation Guide.