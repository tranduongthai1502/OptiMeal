# Bugfix Requirements Document

## Introduction

This document specifies requirements for fixing **FOUR bugs** in the OptiMeal Flutter Web application that significantly impact usability:

**Bug #1: Flutter Web ViewInsets Assertion Crash (CRITICAL - APP KILLER)**
- **Severity:** CRITICAL - Entire app crashes and becomes completely unusable
- **Error:** `DartError: Assertion failed: _viewInsets.isNonNegative`
- **Location:** Flutter SDK Web internal (window.dart)
- **Trigger:** Virtual keyboard hide event OR browser window resize
- **Root Cause:** physicalSize calculation returns negative values, triggering assertion failure that stops the execution thread
- **Impact:** Complete application crash on mobile web browsers when keyboard interaction occurs and during desktop browser resize events

**Bug #2: OpenStreetMap Tile Loading Failures**
- **Severity:** High - Map feature non-functional
- **Error:** `net::ERR_CONNECTION_REFUSED` and `ClientException: Failed to fetch`
- **Location:** `home_map_search_screen.dart` using `flutter_map ^8.3.2`
- **Trigger:** Navigation to Food Map screen on Flutter Web
- **Impact:** Map tiles fail to load, preventing users from discovering nearby food listings

**Bug #3: UI Overflow at home_map_search_screen.dart:141**
- **Severity:** Medium - Visual corruption
- **Error:** RenderFlex overflow exception
- **Location:** `home_map_search_screen.dart` line 141
- **Trigger:** Screen resize, keyboard appearance, or certain viewport dimensions
- **Root Cause:** Stack with Column layout doesn't properly constrain child widgets, causing overflow when available space is insufficient
- **Suggested Fix:** Use Expanded/Flexible or add ScrollView, check Stack constraints
- **Impact:** UI breaks, widgets rendered outside bounds, visual corruption

**Bug #4: Persistent "Không tải được dữ liệu. Kiểm tra mạng." Error Display**
- **Severity:** Medium - Confusing UX
- **Error:** Error message appears even when data loads successfully
- **Location:** `home_map_search_screen.dart` line 257 (listingsAsync.when error case)
- **Trigger:** Initial app load, navigation to Food Map screen
- **Symptom:** Error message "Không tải được dữ liệu. Kiểm tra mạng." appears EVEN when data loads successfully
- **Root Cause:** `nearbyListingsStreamProvider` wraps Firestore stream but doesn't properly handle initial loading state or network check errors
- **Related Code:**
  - `watchNearbyListings` in `ListingsRepositoryImpl` returns raw stream without error handling
  - `nearbyListingsStreamProvider` uses location provider which may be in error state
  - AsyncValue.error is triggered but data may still be loading or available
- **Impact:** Confusing UX - users see error message even when listings display correctly

All four bugs must be fixed to restore full Flutter Web functionality. The ViewInsets crash (Bug #1) is the highest priority as it prevents any app usage.

## Bug Analysis

### Current Behavior (Defect)

#### Bug #1: ViewInsets Assertion Crash (CRITICAL)

**1.1** WHEN virtual keyboard hides on mobile web browsers (Chrome, Safari, Edge on iOS/Android) THEN the system triggers `_viewInsets.isNonNegative` assertion failure within the Flutter SDK `window.dart` module

**1.2** WHEN the browser console logs the error "DartError: Assertion failed: _viewInsets.isNonNegative" THEN the system SHALL have calculated at least one negative dimension value (top, bottom, left, or right < 0) in the ViewInsets parameters

**1.3** WHEN browser window is resized to dimensions where (viewport height - keyboard height) < 0 or (viewport width - system UI width) < 0 on desktop THEN the system calculates negative physicalSize values

**1.4** WHEN the physicalSize calculation detects viewport height < 100px or width < 100px during resize events THEN the system proceeds with dimension subtraction that can produce negative ViewInsets values

**1.5** WHEN assertion failure occurs THEN the system SHALL display a blank white screen OR frozen UI AND the browser console SHALL contain the stack trace starting with "Assertion failed" AND all interactive elements SHALL become unresponsive

**1.6** IF the execution thread stops due to assertion THEN the system SHALL require a full page reload (F5 or refresh button) to restore functionality AND any unsaved user input in forms or draft listings SHALL be lost

#### Bug #2: OpenStreetMap Tile Loading Failures

**1.7** WHEN user navigates to the Food Map screen on Flutter Web AND the initial tile request exceeds 5 seconds without response THEN the system SHALL log `net::ERR_CONNECTION_REFUSED` OR `ClientException: Failed to fetch` in the browser console

**1.8** IF tile loading fails for 50% or more of visible tiles within a 30-second window THEN the system SHALL display blank/gray placeholders in the map viewport where tiles should appear

**1.9** WHEN the system attempts to fetch a tile from `https://tile.openstreetmap.org/{z}/{x}/{y}.png` AND receives HTTP connection error THEN the system SHALL retry the request exactly 2 times with 1-second delay between attempts

**1.10** IF the third retry attempt fails THEN the system SHALL display a placeholder tile image (solid gray or "X" icon) in that tile's position AND SHALL NOT display any user-facing error message

**1.11** WHEN network errors occur during tile loading THEN the system SHALL log error details to browser console (error type, tile coordinates, timestamp) AND SHALL display a loading spinner overlay on affected tiles for the duration of retry attempts (up to 3 seconds total)

#### Bug #3: UI Overflow Exception

**1.12** WHEN screen is resized to small viewport dimensions (height < 600px OR width < 400px) on Flutter Web THEN the system MAY trigger RenderFlex overflow exception at `home_map_search_screen.dart:141` displaying error message "RenderFlex overflowed by [X] pixels"

**1.13** WHEN virtual keyboard appears on mobile web browsers reducing available screen height by 200-400px THEN the system MAY calculate insufficient space for Stack children (Column with fixed-height components) resulting in overflow exception

**1.14** IF overflow occurs THEN the system SHALL display yellow-and-black striped overflow indicator bars where widgets exceed their parent boundaries AND SHALL log "RenderFlex overflowed by [pixels] pixels on the [dimension]" to console

**1.15** WHEN Column layout inside Stack attempts to render children whose combined heights exceed available viewport height THEN the system SHALL render widgets outside visible bounds OR SHALL display overflow indicators without graceful degradation

**1.16** IF Stack constraints are unbounded in a dimension AND Column children have fixed sizes (e.g., SizedBox(height: 104), Expanded, SizedBox(height: 64)) THEN the system calculates total height and triggers overflow when sum > available space

#### Bug #4: Persistent Error Message Display

**1.17** WHEN user navigates to Food Map screen for the first time in a session THEN the system MAY display error message "Không tải được dữ liệu. Kiểm tra mạng." (Cannot load data. Check your network.) at line 257 even though listings data is loading or already loaded successfully

**1.18** IF `nearbyListingsStreamProvider` transitions through AsyncValue states (loading → data/error) AND location provider is in error state (GPS denied, location unavailable) THEN the system SHALL display error message from listingsAsync.when error case while listings may still be available

**1.19** WHEN Firestore stream initializes and emits first event THEN IF stream wrapper catches any exception during setup (network check, location error, permission denied) THEN the system SHALL set AsyncValue to AsyncValue.error even if stream subsequently emits valid data

**1.20** IF `ListingsRepositoryImpl.watchNearbyListings` returns a stream that errors immediately on subscription BUT then recovers and emits data THEN the listingsAsync.when may evaluate to error case while data is actually present in subsequent stream events

**1.21** WHEN error message is displayed at bottom-left of map viewport THEN the system SHALL show text "Không tải được dữ liệu. Kiểm tra mạng." in red color (AppColors.error) for the duration of AsyncValue.error state even if visible listings are rendering correctly on the map above

### Expected Behavior (Correct)

#### Bug #1: ViewInsets Assertion Crash Prevention (CRITICAL)

**2.1** WHEN virtual keyboard hide event triggers physicalSize recalculation on mobile web browsers THEN the system SHALL validate that all ViewInsets parameters (top, bottom, left, right) are >= 0 before passing them to ViewInsets constructor

**2.2** IF any calculated ViewInsets dimension (top, bottom, left, or right) is < 0 during keyboard hide THEN the system SHALL clamp that dimension to 0 AND SHALL log a warning message to browser console containing the original negative value and the affected dimension name

**2.3** WHEN browser window resize event triggers dimension recalculation THEN the system SHALL validate that (viewport height - keyboard height) >= 0 AND (viewport width - system UI width) >= 0 before creating ViewInsets

**2.4** IF resize calculation produces any negative dimension THEN the system SHALL apply max(0, calculatedValue) to each ViewInsets parameter (top, bottom, left, right) AND SHALL log a warning with the format "ViewInsets dimension clamped: [dimension_name] from [negative_value] to 0"

**2.5** WHEN ViewInsets validation detects negative values THEN the system SHALL log to browser console with severity "WARNING" AND message format "Invalid ViewInsets detected: [dimension]=[value], clamping to zero" AND SHALL include stack trace

**2.6** WHEN keyboard hide or resize events occur AND dimension validation/clamping is applied THEN the system SHALL preserve all application state (user input in text fields, navigation stack, provider state) AND SHALL NOT trigger page reload

**2.7** WHEN keyboard or resize events trigger ViewInsets recalculation THEN the system SHALL complete the UI update cycle without throwing exceptions AND SHALL render the updated layout within 100ms of the event

#### Bug #2: OpenStreetMap Tile Loading Fixes

**2.8** WHEN user navigates to the Food Map screen on Flutter Web THEN the system SHALL initiate tile requests to the configured primary tile provider within 500ms

**2.9** IF the primary tile provider (`https://tile.openstreetmap.org`) responds with HTTP connection error OR timeout (> 10 seconds) THEN the system SHALL automatically switch to fallback tile provider (`https://{s}.tile.opentopomap.org`) for subsequent tile requests

**2.10** WHEN tile loading encounters network errors (connection refused, timeout, 5xx errors) for a specific tile THEN the system SHALL retry that tile request up to 3 times with exponential backoff delays (1s, 2s, 4s)

**2.11** IF all retry attempts fail for a tile THEN the system SHALL first attempt to load from fallback provider THEN IF fallback also fails SHALL load from local cache IF available THEN IF no cache SHALL display error placeholder tile

**2.12** WHEN 20% or more of visible tiles fail to load after all retry/fallback attempts THEN the system SHALL display a user-facing error banner at the top of the map with message "Map tiles temporarily unavailable. Check your internet connection or try again later." AND SHALL include a "Retry" button

**2.13** WHEN running on Flutter Web AND making tile requests THEN IF userAgentPackageName is set THEN the system SHALL use value "OptiMeal-Web" ELSE SHALL omit the parameter entirely to comply with OSM tile usage policies

**2.14** WHEN tile requests are made to OpenStreetMap servers THEN the system SHALL enforce a rate limit of maximum 2 requests per second per tile zoom level

**2.15** WHEN map is displayed THEN the system SHALL show attribution text "© OpenStreetMap contributors" in the bottom-right corner of the map viewport with font size >= 10px and contrasting background

**2.16** WHEN a tile request is initiated THEN the system SHALL display a loading indicator (animated spinner or pulsing effect) on that tile's placeholder for the duration of the request (max 10 seconds including retries)

**2.17** WHEN the system switches to fallback tile provider due to primary provider failure THEN the system SHALL log an info message to browser console with format "Tile provider failover: switched from [primary_url] to [fallback_url] at [timestamp]"

#### Bug #3: UI Overflow Prevention

**2.18** WHEN screen is resized to small viewport dimensions (height < 600px OR width < 400px) on Flutter Web THEN the system SHALL apply responsive layout constraints using Flexible OR Expanded widgets to prevent overflow

**2.19** IF available viewport height minus fixed elements (top bar: 104px, bottom bar: 64px) is less than child widget requirements THEN the system SHALL wrap overflowing content in SingleChildScrollView OR shall reduce fixed element sizes proportionally

**2.20** WHEN virtual keyboard appears reducing viewport height by 200-400px THEN the system SHALL recalculate Stack child constraints AND SHALL ensure Column children adapt to remaining space without triggering overflow exceptions

**2.21** IF Column layout inside Stack calculates total child height > available parent height THEN the system SHALL apply Flexible/Expanded to adaptable children (map area) AND SHALL maintain fixed sizes only for critical UI elements (search bar, controls)

**2.22** WHEN Stack constraints are evaluated during layout phase THEN the system SHALL ensure all children have bounded constraints (maxHeight and maxWidth defined) before measuring child widget sizes

**2.23** IF layout calculation detects potential overflow (child size > parent size) THEN the system SHALL gracefully degrade by shrinking flexible components (map viewport) while preserving minimum sizes for fixed elements (buttons: 48x48px minimum touch target)

**2.24** WHEN responsive layout is applied THEN the system SHALL render without overflow indicators (no yellow-black stripes) AND SHALL NOT log "RenderFlex overflowed" messages to console for viewport sizes >= 320x568px (iPhone SE minimum)

#### Bug #4: Accurate Error State Display

**2.25** WHEN user navigates to Food Map screen THEN the system SHALL display loading state message "Đang tải đơn thực phẩm..." (Loading food listings...) during initial data fetch AND SHALL NOT prematurely show error message

**2.26** IF `nearbyListingsStreamProvider` is in loading state (AsyncValue.loading) THEN the system SHALL display loading indicator AND SHALL wait for first stream event (data or error) before showing any error message

**2.27** WHEN Firestore stream emits data successfully (even if location provider has errors) THEN the system SHALL display data state with listing count "Có [N] đơn gần bạn" AND SHALL NOT show error message as long as listings data is available

**2.28** IF location provider is in error state BUT Firestore stream returns valid listings data THEN the system SHALL show GPS warning banner separately (at top) AND SHALL display listings data (not error message) at bottom

**2.29** WHEN `ListingsRepositoryImpl.watchNearbyListings` stream encounters network error or Firestore permission denied THEN the system SHALL wrap stream in error handler that logs error AND SHALL only transition to AsyncValue.error if stream fails to emit any data within 10 seconds

**2.30** IF stream initialization throws exception BUT later recovers with valid data THEN the system SHALL reset AsyncValue to AsyncValue.data once valid listings are received AND SHALL hide any previously displayed error message

**2.31** WHEN error state is displayed (listingsAsync.when error case) THEN the system SHALL show error message "Không tải được dữ liệu. Kiểm tra mạng." ONLY IF no listings data is available in current stream state

**2.32** WHEN multiple AsyncValue sources exist (location provider, listings stream) THEN the system SHALL evaluate error display based on listings data availability FIRST, location errors SECOND (lower priority for error message display)

### Unchanged Behavior (Regression Prevention)

#### General Flutter Web Behavior

**3.1** WHEN virtual keyboard appears on mobile web browsers THEN the system SHALL adjust the viewport bottom padding by the keyboard height (typically 200-400px) AND SHALL scroll the focused text input field into the visible viewport area within 300ms

**3.2** WHEN browser window is resized to valid dimensions (width >= 320px AND height >= 568px) THEN the system SHALL trigger MediaQuery update AND SHALL recompute all responsive layout breakpoints AND SHALL redraw all visible widgets within 200ms

**3.3** WHEN user taps on a TextField or TextFormField widget THEN the system SHALL display the virtual keyboard within 500ms AND SHALL maintain focus on the tapped field until user dismisses keyboard or taps elsewhere

**3.4** WHEN ViewInsets calculations produce all positive values (top >= 0, bottom >= 0, left >= 0, right >= 0) THEN the system SHALL create ViewInsets objects using the calculated values without modification AND SHALL NOT apply clamping or logging

**3.5** WHEN application runs on desktop browsers with keyboard/mouse input AND user resizes window to dimensions >= 1024x768 THEN the system SHALL maintain 60fps rendering AND SHALL complete layout recalculation within 100ms without throwing exceptions

#### Map Feature Behavior

**3.6** WHEN user interacts with the map on native mobile platforms (Android API >= 21, iOS >= 12.0) using `google_maps_flutter` THEN the system SHALL load tiles from Google Maps servers with < 2 second average latency AND SHALL NOT apply any web-specific tile loading logic

**3.7** WHEN map displays user location marker (blue dot) AND search radius circle (configurable km) THEN the system SHALL render both overlays on top of the tile layer with z-index > base tiles AND SHALL update marker position when location changes (GPS accuracy <= 50m)

**3.8** WHEN user taps on a food listing marker AND the listing data is available in the provider state THEN the system SHALL open the listing bottom sheet within 300ms AND SHALL display listing title, description, pickup address, available quantity, and expiration date

**3.9** IF listing data is unavailable or fails to load THEN the system SHALL display error message in bottom sheet "Unable to load listing details. Please try again."

**3.10** WHEN user enters text in the search bar THEN the system SHALL filter displayed markers in real-time (debounced 300ms) by matching search text case-insensitively against listing title OR description fields using substring matching

**3.11** WHEN user clicks "My Location" button AND device GPS permission is granted AND location is available THEN the system SHALL center the map on user's current GPS coordinates (latitude, longitude) with zoom level 15 within 2 seconds

**3.12** IF GPS permission is denied OR location is unavailable THEN the system SHALL display a snackbar message "Location access required to center map" AND SHALL NOT change map center position

**3.13** WHEN OpenStreetMap attribution is displayed in the map footer THEN the system SHALL show the exact text "© OpenStreetMap contributors" with a clickable link to https://www.openstreetmap.org/copyright AND SHALL maintain visibility regardless of map zoom or pan state

**3.14** WHEN route calculation is triggered between two points THEN the system SHALL display the calculated polyline path on the map overlay AND SHALL show distance in km and estimated time in the route info card

**3.15** IF routing service fails or returns error THEN the system SHALL display route calculation independently of tile loading status (tiles may load or fail without affecting route display)

#### Layout and Constraint Behavior

**3.16** WHEN viewport size is >= 600px height AND >= 400px width THEN the system SHALL render all UI components without overflow AND SHALL maintain normal layout proportions (search bar 12px from top, controls 16px from edges)

**3.17** WHEN Stack contains Column with multiple children on platforms other than Flutter Web small viewports THEN the system SHALL calculate layout constraints normally without applying scroll views or additional flexibility unless explicitly designed

**3.18** IF viewport has sufficient space (height > combined child heights + padding) THEN the system SHALL render Column children with their natural/specified sizes without shrinking or expanding beyond layout requirements

**3.19** WHEN Expanded widget is used within Column inside Stack THEN the system SHALL allocate remaining space after fixed-size children are measured AND SHALL fill exactly the available space without overflow

**3.20** IF map viewport (Expanded widget) is rendered on native mobile platforms OR desktop with large screens THEN the system SHALL occupy all remaining vertical space between top elements (104px) and bottom elements (64px) without scrolling

#### Error Display Logic

**3.21** WHEN Firestore stream emits error event (network failure, permission denied, timeout) AND no cached data is available THEN the system SHALL display error message "Không tải được dữ liệu. Kiểm tra mạng." as the appropriate user feedback

**3.22** IF previous successful data exists in AsyncValue AND new stream subscription fails THEN the system SHALL retain previous data in AsyncValue.data state AND SHALL display that cached data rather than transitioning to error state

**3.23** WHEN location permission is denied BUT listings can be loaded with default location (Đà Nẵng center: 16.0544, 108.2022) THEN the system SHALL display GPS warning banner AND SHALL show listings data normally (not error message)

**3.24** IF both location provider AND listings stream are in error states simultaneously THEN the system SHALL display the listings error message (higher priority) in the bottom status area AND SHALL display GPS warning in the top banner area

**3.25** WHEN listingsAsync.when evaluates states in native mobile app (Android/iOS) with stable network THEN the system SHALL transition smoothly through loading → data without showing error state under normal conditions

**3.26** IF stream error occurs but recovers within 3 seconds (e.g., temporary network glitch) THEN the system SHALL show loading state during recovery AND SHALL proceed to data state once stream emits valid events

**3.27** WHEN user is viewing map with displayed listings AND stream connection is interrupted temporarily THEN the system SHALL maintain currently displayed markers on map AND SHALL only show error message if interruption persists > 10 seconds without recovery

