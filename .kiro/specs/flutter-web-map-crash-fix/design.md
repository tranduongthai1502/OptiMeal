# Flutter Web Map Crash Fix - Bugfix Design

## Overview

This design addresses four critical bugs affecting the OptiMeal Flutter Web application's map functionality. The bugs range from a catastrophic ViewInsets assertion crash that makes the app unusable, to UI overflow issues and misleading error messages. The fixes employ defensive programming, fallback mechanisms, and proper error state management to ensure robust Flutter Web operation.

**Bug Priority:**
1. **CRITICAL**: ViewInsets assertion crash (Bug #1) - app killer
2. **High**: OSM tile loading failures (Bug #2) - map non-functional
3. **Medium**: UI overflow exceptions (Bug #3) - visual corruption
4. **Medium**: Persistent error messages (Bug #4) - confusing UX

**Fix Strategy:**
- Bug #1: Monkey-patch Flutter SDK's ViewInsets validation before crash occurs
- Bug #2: Multi-provider tile fallback system with exponential backoff retry
- Bug #3: Responsive layout refactor using proper Flutter Web constraints
- Bug #4: Stream error recovery + separate location/data error handling + Firestore index fix

## Glossary

- **Bug_Condition (C)**: The condition that triggers each bug - keyboard events causing negative ViewInsets, tile loading network failures, small viewport dimensions causing overflow, or stream errors displaying incorrect error messages
- **Property (P)**: The desired behavior when bugs are fixed - valid ViewInsets preventing crashes, successful tile loading with fallbacks, responsive layouts without overflow, accurate error state display
- **Preservation**: Existing functionality that must remain unchanged - native mobile map behavior, GPS location tracking, marker interactions, route calculation, normal viewport layouts
- **ViewInsets**: Flutter's representation of system UI overlays (keyboard, notches) as EdgeInsets describing physical pixels from screen edges; negative values trigger assertion failures
- **Assertion Failure**: Dart runtime check that throws exception and stops execution when condition evaluates to false; in production mode these are removed but in Flutter Web debug/profile modes they crash the app
- **physicalSize**: Browser viewport dimensions in physical pixels; calculated as (viewport width/height - system UI insets); can be negative during keyboard hide transitions
- **flutter_map**: Open-source map widget library for Flutter that uses tile-based rendering from OSM/custom providers; version ^8.3.2 used in this project
- **TileLayer**: Widget that fetches and renders map tiles from URL template; supports error callbacks and fallback mechanisms
- **errorTileCallback**: Flutter_map callback invoked when tile loading fails; receives tile coordinates, error object, and stack trace
- **userAgentPackageName**: HTTP User-Agent identifier sent with tile requests; OSM requires valid package name or omission for web apps
- **AsyncValue**: Riverpod's sealed union type representing loading/data/error states for asynchronous operations
- **StreamProvider**: Riverpod provider that listens to Dart streams and exposes AsyncValue states; automatically handles subscription lifecycle
- **Firestore Composite Index**: Cloud Firestore database index required for queries with multiple where clauses and orderBy operations; must be created via Firebase Console or automatically via index link in error messages
- **RenderFlex overflow**: Flutter layout error when child widgets exceed parent container's available space; displays yellow-black striped indicators
- **CameraConstraint.containCenter**: Flutter_map constraint ensuring map center stays within defined geographic bounds during pan/zoom operations
- **Haversine formula**: Spherical distance calculation between two GPS coordinates using great-circle distance; used for client-side radius filtering

## Bug Details

### Bug Condition

The bugs manifest under four distinct conditions that affect Flutter Web operation:

**Bug #1: ViewInsets Assertion Crash**

The bug manifests when the virtual keyboard hides on mobile web browsers OR when browser windows are resized to small dimensions. The Flutter SDK's `window.dart` module calculates `physicalSize` values that can become negative during these transitions, triggering the assertion `_viewInsets.isNonNegative` which crashes the entire app.

**Formal Specification:**
```
FUNCTION isBugCondition_ViewInsets(input)
  INPUT: input of type KeyboardEvent OR WindowResizeEvent
  OUTPUT: boolean
  
  RETURN (input.type == 'keyboard_hide' AND 
          calculatedPhysicalSize.height < 0) OR
         (input.type == 'window_resize' AND
          (viewportHeight - keyboardHeight) < 0) OR
         (input.type == 'window_resize' AND
          (viewportWidth - systemUIWidth) < 0)
END FUNCTION
```

**Bug #2: OSM Tile Loading Failures**

The bug manifests when navigation to the Food Map screen triggers tile requests to OpenStreetMap servers. On Flutter Web, these requests encounter `net::ERR_CONNECTION_REFUSED` or `ClientException: Failed to fetch` errors, leaving the map blank.

**Formal Specification:**
```
FUNCTION isBugCondition_TileLoading(input)
  INPUT: input of type TileLoadRequest
  OUTPUT: boolean
  
  RETURN input.platform == 'web' AND
         input.targetURL.contains('tile.openstreetmap.org') AND
         (input.error == 'ERR_CONNECTION_REFUSED' OR
          input.error.contains('Failed to fetch')) AND
         input.retryAttempts < 3
END FUNCTION
```

**Bug #3: UI Overflow Exception**

The bug manifests when screen dimensions fall below 600px height or 400px width, or when the virtual keyboard appears reducing available viewport height by 200-400px. The Stack layout with Column children at line 141 of `home_map_search_screen.dart` has insufficient constraints, causing RenderFlex overflow.

**Formal Specification:**
```
FUNCTION isBugCondition_UIOverflow(input)
  INPUT: input of type LayoutEvent
  OUTPUT: boolean
  
  RETURN (input.viewportHeight < 600 OR input.viewportWidth < 400) AND
         input.location == 'home_map_search_screen.dart:141' AND
         input.layoutType == 'Stack_with_Column' AND
         (input.fixedElementsHeight > input.availableHeight) AND
         NOT input.hasFlexibleChildren
END FUNCTION
```

**Bug #4: Persistent Error Message**

The bug manifests when the user navigates to the Food Map screen and `nearbyListingsStreamProvider` enters error state due to missing Firestore composite index, location provider errors, or stream initialization failures. The error message persists even when data subsequently loads successfully.

**Formal Specification:**
```
FUNCTION isBugCondition_ErrorMessage(input)
  INPUT: input of type StreamState
  OUTPUT: boolean
  
  RETURN input.asyncValue.isError AND
         input.screen == 'home_map_search_screen.dart' AND
         input.line == 257 AND
         (input.errorCause == 'missing_firestore_index' OR
          input.errorCause == 'location_provider_error' OR
          input.errorCause == 'stream_initialization_failed') AND
         (input.hasDataAvailable == true OR
          input.willRecoverWithData == true)
END FUNCTION
```

### Examples

**Bug #1: ViewInsets Assertion Crash**
- User opens OptiMeal on iPhone Safari → taps search bar → keyboard appears → user taps "Done" → keyboard hides → `physicalSize.height` becomes -320 → assertion fails → white screen crash → app requires full page reload
- User on desktop Chrome resizes browser window from 1200x800 to 300x200 → `physicalSize` calculation yields negative values → assertion crash → all UI becomes unresponsive
- User on Android Chrome in portrait mode → rotates to landscape during keyboard visibility → dimension transition triggers negative ViewInsets → app freezes with blank screen

**Bug #2: OSM Tile Loading Failures**
- User navigates to Food Map screen → flutter_map requests tiles from `https://tile.openstreetmap.org/{z}/{x}/{y}.png` → all requests return `ERR_CONNECTION_REFUSED` → map shows blank gray placeholders → no fallback attempted
- Initial tile load takes >5 seconds with no response → no retry logic executes → tiles remain loading indefinitely with spinner overlay
- Network connection drops briefly → 20+ tiles fail → no user-facing error banner appears → user sees broken map without explanation

**Bug #3: UI Overflow Exception**
- User on iPhone SE (320x568) views Food Map → virtual keyboard appears for search bar → available height drops to ~300px → Column children (104px top + map + 64px bottom) overflow → yellow-black stripes appear → console logs "RenderFlex overflowed by 168 pixels"
- Desktop user resizes Chrome window to 400x500 → Stack with unbounded constraints calculates Column children exceed height → overflow indicators render over map → UI appears broken
- Tablet user in split-screen mode → viewport width 380px → horizontal constraints insufficient for map controls + route info chip → widgets render outside visible bounds

**Bug #4: Persistent Error Message**
- User opens Food Map first time → Firestore query with multiple `where` + `orderBy` clauses requires composite index → query fails with "index not found" → stream enters error state → error message "Không tải được dữ liệu. Kiểm tra mạng." displays → user creates index → stream recovers with data BUT error message still shows at bottom while listings display correctly on map above
- Location permission denied → `locationProvider` in error state → `nearbyListingsStreamProvider` uses default Đà Nẵng coordinates → Firestore query succeeds with data → but `listingsAsync.when` evaluates to error case due to location provider cascade → error message appears despite 47 listings visible on map
- Initial stream subscription throws exception during setup → AsyncValue transitions to error → stream subsequently emits valid data → AsyncValue never resets to data state → error message persists entire session

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**

**Native Mobile Platform Behavior:**
- All map functionality on Android (API ≥21) and iOS (≥12.0) using `google_maps_flutter` must continue working without any changes to tile loading, layout constraints, or error handling
- GPS location tracking, marker rendering, and user interaction patterns remain identical on native platforms
- ViewInsets calculations on native platforms use platform channels that already validate dimensions correctly

**Core Map Features:**
- User location marker (blue dot with pulsing beacon) and search radius circle must render on top of tile layer with correct z-index
- Tapping food listing markers opens bottom sheet within 300ms with listing details (title, description, address, quantity, expiration)
- Search bar filtering by title/description with 300ms debounce continues to work
- "My Location" button centers map on GPS coordinates at zoom level 15 within 2 seconds when permission granted
- OpenStreetMap attribution "© OpenStreetMap contributors" with clickable link remains visible at bottom-left
- Route calculation polyline display and distance/time info card remain independent of tile loading status

**Layout and Viewport Handling:**
- On viewports ≥600px height and ≥400px width, all UI components render without overflow using normal layout proportions
- Keyboard appearance on mobile web continues to adjust viewport bottom padding by keyboard height (200-400px) and scroll focused input into view within 300ms
- Browser window resize on desktop to dimensions ≥1024x768 maintains 60fps rendering and completes layout recalculation within 100ms
- When Stack contains sufficient space (height > combined child heights + padding), Column children render with natural/specified sizes without shrinking

**Error Handling:**
- When Firestore stream emits genuine errors (network failure, permission denied) AND no cached data exists, error message "Không tải được dữ liệu. Kiểm tra mạng." displays as appropriate feedback
- If previous successful data exists when new stream subscription fails, system retains previous data in AsyncValue.data state
- GPS permission denied scenario shows GPS warning banner separately at top while listings display normally at bottom with default location

**Scope:**

All inputs and scenarios that do NOT involve the four bug conditions should be completely unaffected by these fixes. This includes:
- Valid ViewInsets calculations with all positive dimensions (no clamping or logging applied)
- Successful tile loading with normal network conditions (no fallback providers invoked)
- Normal viewport sizes that provide sufficient space for all UI elements
- Successful stream initialization with proper Firestore indexes and location permissions

## Hypothesized Root Cause

Based on the bug descriptions and debug analysis, the most likely root causes are:

### Bug #1: ViewInsets Assertion Crash

**1. Flutter SDK Window.dart Calculation Flaw**
   - The Flutter Web engine's `window.dart` module calculates `physicalSize` by subtracting system UI insets from viewport dimensions
   - During keyboard hide transitions on mobile browsers, the browser temporarily reports inconsistent viewport dimensions (keyboard still subtracted but viewport not yet expanded)
   - This race condition produces negative values: `physicalSize.height = viewportHeight - keyboardHeight` where `keyboardHeight > viewportHeight`
   - The ViewInsets constructor has an assertion `assert(_viewInsets.isNonNegative)` that fails in debug/profile modes (which Flutter Web uses)

**2. Missing Validation Before ViewInsets Creation**
   - The SDK code path creates ViewInsets without validating dimension non-negativity first
   - No defensive clamping to `max(0, calculatedValue)` exists before assertion check
   - Production mode would skip assertion but still pass invalid negative values downstream causing undefined layout behavior

### Bug #2: OSM Tile Loading Failures

**1. Missing User-Agent Configuration**
   - The current `TileLayer` configuration uses `userAgentPackageName: 'com.example.optimeal'` which is an Android package identifier
   - OpenStreetMap tile servers may reject or rate-limit requests with invalid user agents for web platforms
   - The correct approach for Flutter Web is to omit `userAgentPackageName` entirely or use a web-appropriate identifier

**2. No Fallback Tile Provider**
   - Current implementation only specifies primary OSM provider: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
   - When OSM servers return connection errors (possibly due to rate limiting, CORS issues, or server downtime), no fallback provider is attempted
   - The `errorTileCallback` is defined but empty: `errorTileCallback: (tile, error, stackTrace) {}` - no recovery logic

**3. Insufficient Retry Logic**
   - Flutter_map's default behavior may not include automatic retries for failed tiles
   - No exponential backoff retry mechanism implemented
   - No maximum retry count enforcement

### Bug #3: UI Overflow Exception

**1. Insufficient Stack Constraints**
   - The Stack widget at line 141 contains a Column with fixed-height elements:
     - `SizedBox(height: 104)` for top spacing
     - `Expanded` child for map area
     - `SizedBox(height: 64)` for bottom spacing
   - When viewport height < (104 + minimum_map_height + 64), the Expanded widget receives negative available space
   - Stack doesn't provide bounded constraints by default in some Flutter Web scenarios

**2. Column Children Don't Adapt to Small Viewports**
   - The fixed-height spacers (104px, 64px) don't scale down for small viewports like iPhone SE (568px total height)
   - When keyboard appears (reduces viewport by ~300px), remaining height ~268px is insufficient for fixed elements + map
   - No `SingleChildScrollView` wrapper exists to handle overflow gracefully

**3. Positioned Widgets Outside Stack Bounds**
   - Multiple Positioned widgets (search bar, GPS warning, route chip, controls) have absolute positioning
   - On small viewports, these may overflow the Stack's calculated bounds
   - No responsive constraints adjust element sizes or positions based on available space

### Bug #4: Persistent Error Message

**1. Missing Firestore Composite Index (PRIMARY CAUSE)**
   - The query in `ListingsFirebaseDataSourceImpl.getNearbyListings`:
     ```dart
     .where('status', isEqualTo: 'available')
     .where('expiresAt', isGreaterThan: nowMs)
     .orderBy('expiresAt')
     .orderBy('createdAt', descending: true)
     ```
   - Requires a composite index on `(status, expiresAt, createdAt)`
   - Without this index, Firestore throws "index not found" error
   - The stream immediately transitions to AsyncValue.error state

**2. Location Provider Error Cascade**
   - `nearbyListingsStreamProvider` watches `locationProvider` which may be in error state (GPS denied, unavailable)
   - Even if Firestore query succeeds with default coordinates, the provider rebuild may retain error state
   - Error state from location provider cascades to listings provider evaluation

**3. No Stream Error Recovery**
   - When stream initialization throws an exception, AsyncValue transitions to error
   - If stream subsequently recovers and emits data, the provider doesn't reset AsyncValue to data state
   - The `listingsAsync.when` always evaluates the error case even when data is available

**4. Incorrect Error Priority Logic**
   - The UI displays error message if `listingsAsync.isError == true`
   - No check for whether data is actually available despite error state
   - Location errors and data errors aren't separated - both show same generic network message

## Correctness Properties

Property 1: Bug Condition - ViewInsets Crash Prevention

_For any_ keyboard hide event or browser resize event that produces negative ViewInsets dimension calculations, the fixed code SHALL clamp all dimensions (top, bottom, left, right) to max(0, calculatedValue) before creating ViewInsets objects, preventing assertion failures and maintaining app responsiveness without requiring page reload.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7**

Property 2: Bug Condition - OSM Tile Loading with Fallback

_For any_ tile load request on Flutter Web that encounters network errors (connection refused, timeout, 5xx errors) from the primary OpenStreetMap provider, the fixed code SHALL retry the request up to 3 times with exponential backoff (1s, 2s, 4s), then attempt loading from fallback provider (OpenTopoMap), then display error placeholder only if all attempts fail, ensuring map remains functional during network issues.

**Validates: Requirements 2.8, 2.9, 2.10, 2.11, 2.12, 2.13, 2.14, 2.15, 2.16, 2.17**

Property 3: Bug Condition - Responsive Layout Without Overflow

_For any_ viewport dimension where height < 600px or width < 400px, or when virtual keyboard reduces available height by 200-400px, the fixed layout SHALL use Flexible/Expanded widgets with proper constraints and optionally wrap content in ScrollView, ensuring no RenderFlex overflow exceptions occur and all UI elements remain accessible on viewports as small as 320x568px (iPhone SE).

**Validates: Requirements 2.18, 2.19, 2.20, 2.21, 2.22, 2.23, 2.24**

Property 4: Bug Condition - Accurate Error State Display

_For any_ scenario where nearbyListingsStreamProvider has valid listings data available (even if location provider is in error state or stream previously encountered errors), the fixed code SHALL display the data state with listing count "Có [N] đơn gần bạn" instead of error message, and SHALL only show "Không tải được dữ liệu. Kiểm tra mạng." when listings data is genuinely unavailable after stream fails to emit data within 10 seconds, separating location errors (GPS warning banner) from data errors (bottom status message).

**Validates: Requirements 2.25, 2.26, 2.27, 2.28, 2.29, 2.30, 2.31, 2.32**

Property 5: Preservation - Native Platform Behavior

_For any_ map operation on native mobile platforms (Android API ≥21, iOS ≥12.0) using google_maps_flutter, the fixed code SHALL produce exactly the same behavior as the original code, preserving GPS tracking, marker interactions, tile loading from Google Maps servers, and layout calculations without applying any web-specific fixes or fallback mechanisms.

**Validates: Requirements 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12**

Property 6: Preservation - Core Map Features on All Platforms

_For any_ user interaction with map features (location marker, search filtering, marker tap, route calculation, attribution display) regardless of platform, the fixed code SHALL maintain existing functionality, timing requirements (e.g., bottom sheet opens within 300ms, location centers within 2s), and visual appearance without degradation or behavioral changes.

**Validates: Requirements 3.13, 3.14, 3.15**

Property 7: Preservation - Normal Viewport Layouts

_For any_ viewport with dimensions ≥600px height and ≥400px width, or scenarios where ViewInsets calculations produce all positive values, or successful tile loading with normal network conditions, the fixed code SHALL render using normal layout constraints without applying clamping, fallback providers, scrolling, or error recovery mechanisms, maintaining original performance and behavior.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.16, 3.17, 3.18, 3.19, 3.20**

Property 8: Preservation - Genuine Error Display

_For any_ genuine error condition (Firestore stream fails with no data available, GPS permission denied with no default location fallback, network completely offline), the fixed code SHALL display appropriate error messages and warning banners as the original code does, providing clear user feedback for unrecoverable failures without hiding legitimate errors.

**Validates: Requirements 3.21, 3.22, 3.23, 3.24, 3.25, 3.26, 3.27**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

#### Bug #1: ViewInsets Crash Prevention

**File**: Create new utility file `lib/core/utils/web_view_insets_patch.dart`

**Purpose**: Monkey-patch Flutter's ViewInsets validation before SDK code runs

**Specific Changes**:

1. **Create ViewInsets Validation Extension**:
   - Implement Dart extension on `ui.ViewInsets` or wrapper class
   - Add static method `safeCreate(top, bottom, left, right)` that validates and clamps dimensions
   - Log warnings to console when clamping occurs: `"ViewInsets dimension clamped: [dimension] from [value] to 0"`

2. **Hook into Flutter Web Window Events**:
   - Use `dart:html` or `dart:js_interop` to intercept keyboard hide and window resize events
   - In event handlers, validate proposed ViewInsets dimensions before Flutter SDK processes them
   - Apply `max(0.0, calculatedValue)` to each dimension

3. **Initialize Patch at App Startup**:
   - Call patch initialization in `main()` before `runApp()`
   - Ensure patch only activates on Flutter Web platform using `kIsWeb` check
   - Add debug assertion to verify patch is active

**File**: `lib/main.dart`

**Changes**:
- Import web_view_insets_patch.dart conditionally: `import 'core/utils/web_view_insets_patch.dart' if (dart.library.html) 'core/utils/web_view_insets_patch.dart';`
- Add initialization at start of `main()`: `if (kIsWeb) { initializeViewInsetsPatch(); }`

**Alternative Approach (if monkey-patching fails)**:

Create a wrapper widget that intercepts MediaQuery and validates viewInsets before propagating to children.

**File**: `lib/core/widgets/safe_view_insets_wrapper.dart`

**Implementation**:
```dart
class SafeViewInsetsWrapper extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    
    // Validate and clamp
    final safeInsets = EdgeInsets.fromLTRB(
      max(0.0, viewInsets.left),
      max(0.0, viewInsets.top),
      max(0.0, viewInsets.right),
      max(0.0, viewInsets.bottom),
    );
    
    if (safeInsets != viewInsets) {
      debugPrint('ViewInsets clamped: $viewInsets → $safeInsets');
    }
    
    return MediaQuery(
      data: mediaQuery.copyWith(viewInsets: safeInsets),
      child: child,
    );
  }
}
```

Wrap `MaterialApp` in `main.dart` with `SafeViewInsetsWrapper`.

#### Bug #2: OSM Tile Loading Fixes

**File**: `lib/features/map_search/presentation/screens/home_map_search_screen.dart`

**Function**: `_buildMap` method (TileLayer configuration)

**Specific Changes**:

1. **Remove Invalid User-Agent**:
   - Remove line: `userAgentPackageName: 'com.example.optimeal',`
   - Add comment: `// Omit userAgentPackageName on web to comply with OSM tile usage policies`

2. **Implement Error Tile Callback**:
   - Replace empty callback: `errorTileCallback: (tile, error, stackTrace) {}`
   - With logging and retry tracking:
     ```dart
     errorTileCallback: (tile, error, stackTrace) {
       debugPrint('Tile load failed: ${tile.coords} - $error');
       ref.read(tileErrorTrackerProvider.notifier).recordError(tile, error);
     }
     ```

3. **Add Fallback Tile Provider**:
   - Replace single TileLayer with conditional multi-provider logic
   - Create `TileLayerOptions` list with primary and fallback providers
   - Implement provider switching based on error rate

**File**: Create new `lib/features/map_search/presentation/providers/tile_provider.dart`

**Purpose**: Manage tile provider fallback and retry logic

**Implementation**:
```dart
enum TileProvider {
  openStreetMap('https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
  openTopoMap('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png');
  
  final String urlTemplate;
  const TileProvider(this.urlTemplate);
}

// StateNotifier to track errors and switch providers
class TileErrorTracker extends StateNotifier<TileErrorState> {
  TileErrorTracker() : super(TileErrorState());
  
  void recordError(TileCoordinates tile, Object error) {
    final newErrorCount = state.errorCount + 1;
    final totalRequests = state.totalRequests + 1;
    
    // Switch to fallback if >20% errors
    if (newErrorCount / totalRequests > 0.2 && 
        state.activeProvider == TileProvider.openStreetMap) {
      state = state.copyWith(
        activeProvider: TileProvider.openTopoMap,
        errorCount: newErrorCount,
        totalRequests: totalRequests,
      );
      debugPrint('Tile provider failover: switched to ${state.activeProvider.name}');
    } else {
      state = state.copyWith(
        errorCount: newErrorCount,
        totalRequests: totalRequests,
      );
    }
  }
  
  void recordSuccess() {
    state = state.copyWith(totalRequests: state.totalRequests + 1);
  }
}
```

4. **Update TileLayer to Use Dynamic Provider**:
   ```dart
   final tileProviderState = ref.watch(tileErrorTrackerProvider);
   
   TileLayer(
     urlTemplate: tileProviderState.activeProvider.urlTemplate,
     subdomains: tileProviderState.activeProvider == TileProvider.openTopoMap 
       ? ['a', 'b', 'c'] 
       : [],
     errorTileCallback: (tile, error, stackTrace) {
       ref.read(tileErrorTrackerProvider.notifier).recordError(tile, error);
     },
     tileBuilder: (context, tileWidget, tile) {
       // Track successful loads
       ref.read(tileErrorTrackerProvider.notifier).recordSuccess();
       return tileWidget;
     },
   )
   ```

5. **Add Error Banner When Many Tiles Fail**:
   - Add state check after TileLayer in Stack children
   - Display banner when `errorCount / totalRequests > 0.2`:
     ```dart
     if (tileProviderState.showErrorBanner)
       Positioned(
         top: 0,
         left: 0,
         right: 0,
         child: _TileLoadErrorBanner(onRetry: () {
           ref.read(tileErrorTrackerProvider.notifier).reset();
         }),
       ),
     ```

#### Bug #3: UI Overflow Prevention

**File**: `lib/features/map_search/presentation/screens/home_map_search_screen.dart`

**Function**: `build` method (Stack and Column layout at line 141)

**Specific Changes**:

1. **Add Responsive Constraints to Stack**:
   - Wrap existing Stack in LayoutBuilder to get constraints:
     ```dart
     LayoutBuilder(
       builder: (context, constraints) {
         final isSmallViewport = constraints.maxHeight < 600 || 
                                 constraints.maxWidth < 400;
         return Stack(...);
       }
     )
     ```

2. **Make Fixed Spacers Responsive**:
   - Replace `const SizedBox(height: 104)` with:
     ```dart
     SizedBox(height: isSmallViewport ? 80 : 104)
     ```
   - Replace `const SizedBox(height: 64)` with:
     ```dart
     SizedBox(height: isSmallViewport ? 48 : 64)
     ```

3. **Add ScrollView for Very Small Viewports**:
   - Wrap Column in conditional ScrollView when height < 500:
     ```dart
     if (constraints.maxHeight < 500)
       SingleChildScrollView(
         child: Column(children: [...]),
       )
     else
       Column(children: [...])
     ```

4. **Add Flexible to Map Area**:
   - Change `Expanded(child: Stack(...))` to:
     ```dart
     Flexible(
       fit: FlexFit.tight,
       child: ConstrainedBox(
         constraints: BoxConstraints(
           minHeight: 200, // Ensure minimum usable map size
         ),
         child: Stack(...),
       ),
     )
     ```

5. **Adjust Positioned Widget Constraints**:
   - Add max-width constraints to search bar, route chip, and controls:
     ```dart
     Positioned(
       top: 12,
       left: 16,
       right: 16,
       child: ConstrainedBox(
         constraints: BoxConstraints(maxWidth: constraints.maxWidth - 32),
         child: MapSearchBar(...),
       ),
     )
     ```

6. **Add Overflow Protection to Bottom Status**:
   - Wrap bottom listing count container in SafeArea:
     ```dart
     Positioned(
       left: 16,
       right: 76,
       bottom: 16,
       child: SafeArea(
         minimum: const EdgeInsets.only(bottom: 8),
         child: Container(...),
       ),
     )
     ```

#### Bug #4: Accurate Error State Display

**File**: `lib/features/listings/data/repositories/listings_repository_impl.dart`

**Function**: `watchNearbyListings` method

**Specific Changes**:

1. **Add Stream Error Handling Wrapper**:
   - Wrap Firestore stream in error recovery transformer:
     ```dart
     return _dataSource
       .watchNearbyListings(
         latitude: latitude,
         longitude: longitude,
         radiusKm: radiusKm,
       )
       .handleError((error, stackTrace) {
         debugPrint('Stream error (will retry): $error');
         if (error.toString().contains('index')) {
           debugPrint('FIRESTORE INDEX REQUIRED - See console for link');
         }
         // Don't propagate error immediately - allow retry
       })
       .timeout(
         const Duration(seconds: 10),
         onTimeout: (sink) {
           sink.addError(Exception('Không tải được dữ liệu sau 10 giây'));
         },
       );
     ```

2. **Add Error Recovery Logic**:
   - Use `asyncMap` to attempt recovery after errors:
     ```dart
     .asyncMap((data) async {
       // Reset error state on successful data
       return data;
     })
     ```

**File**: `lib/features/map_search/presentation/providers/map_search_provider.dart`

**Provider**: `nearbyListingsStreamProvider`

**Specific Changes**:

1. **Separate Location Error from Data Error**:
   - Don't propagate location provider error to listings stream
   - Use default coordinates when location unavailable:
     ```dart
     final lat = locationState.position?.latitude ?? kDefaultCenterLat;
     final lng = locationState.position?.longitude ?? kDefaultCenterLng;
     
     // Don't check locationState.errorMessage - just use fallback coords
     ```

2. **Add AsyncValue Transformation**:
   - After stream provider definition, add transformer:
     ```dart
     final nearbyListingsWithRecoveryProvider = 
       Provider.autoDispose<AsyncValue<List<FoodListing>>>((ref) {
         final asyncValue = ref.watch(nearbyListingsStreamProvider);
         
         return asyncValue.when(
           loading: () => const AsyncValue.loading(),
           error: (error, stack) {
             // Check if we have cached data
             final previousValue = ref.state;
             if (previousValue is AsyncData<List<FoodListing>>) {
               // Return previous data instead of error
               return previousValue;
             }
             return AsyncValue.error(error, stack);
           },
           data: (data) => AsyncValue.data(data),
         );
       });
     ```

**File**: `lib/features/map_search/presentation/screens/home_map_search_screen.dart`

**Function**: `build` method (error display logic at line 257)

**Specific Changes**:

1. **Improve Error Display Condition**:
   - Replace simple `listingsAsync.when` with data availability check:
     ```dart
     child: listingsAsync.when(
       loading: () => const Text('Đang tải đơn thực phẩm...', ...),
       error: (error, stack) {
         // Show error only if no data available
         final hasData = visibleListings.isNotEmpty;
         if (hasData) {
           return Text('Có ${visibleListings.length} đơn gần bạn.', ...);
         }
         
         // Check error type for better message
         if (error.toString().contains('index')) {
           return const Text(
             'Cần cấu hình database index. Xem console.',
             style: TextStyle(fontSize: 12, color: AppColors.warning),
           );
         }
         
         return const Text(
           'Không tải được dữ liệu. Kiểm tra mạng.',
           style: TextStyle(fontSize: 12, color: AppColors.error),
         );
       },
       data: (_) => Text(...),
     )
     ```

2. **Separate Location Error Banner**:
   - GPS warning banner already separate at top - ensure it doesn't affect bottom status
   - Only show location error in banner, not in bottom message

**File**: Create documentation `docs/FIRESTORE_INDEXES.md`

**Purpose**: Document required Firestore composite indexes

**Content**:
```markdown
# Required Firestore Indexes

## food_listings Collection

### Nearby Listings Query Index

**Required for**: `getNearbyListings` and `watchNearbyListings` queries

**Fields**:
- status (Ascending)
- expiresAt (Ascending)  
- createdAt (Descending)

**Collection**: food_listings

**How to create**:
1. Run the app and navigate to Food Map screen
2. Check browser console for error message with Firebase Console link
3. Click the link to auto-create index
4. Wait 2-5 minutes for index to build
5. Refresh the app

**Manual creation**:
1. Open Firebase Console → Firestore → Indexes
2. Click "Create Index"
3. Collection: food_listings
4. Add fields in order:
   - status: Ascending
   - expiresAt: Ascending
   - createdAt: Descending
5. Click "Create"

**Error if missing**:
```
The query requires an index. You can create it here:
https://console.firebase.google.com/...
```
```

**File**: Update `README.md` to reference Firestore indexes documentation

Add section:
```markdown
## Setup

### Firestore Indexes

This app requires composite indexes for efficient queries. See [docs/FIRESTORE_INDEXES.md](docs/FIRESTORE_INDEXES.md) for setup instructions.
```

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach for each bug: first, write tests that demonstrate the bug on unfixed code (exploratory bug condition checking), then verify the fix works correctly and preserves existing behavior (fix checking and preservation checking). This ensures we understand the root cause, validate our fix addresses it, and don't introduce regressions.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate each bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

#### Bug #1: ViewInsets Crash Exploration

**Test Plan**: Create integration tests that simulate keyboard hide and window resize events on Flutter Web test environment. Run these tests on UNFIXED code to observe assertion failures. Use Flutter's `WidgetTester` with web-specific configuration.

**Test Cases**:
1. **Keyboard Hide Crash Test**: Simulate TextField focus → keyboard show → keyboard hide sequence on mobile viewport (375x667). Assert that app crashes with `_viewInsets.isNonNegative` assertion failure (will fail on unfixed code).
2. **Window Resize Crash Test**: Simulate browser window resize from 1200x800 to 300x200. Assert that negative ViewInsets trigger crash (will fail on unfixed code).
3. **Rapid Resize Cycle Test**: Simulate rapid window resize cycles (10 times in 1 second) that may produce race conditions. Assert app remains responsive (will fail on unfixed code).
4. **Keyboard + Rotation Test**: Simulate keyboard visible + device rotation that produces dimension conflicts. Assert no crash occurs (will fail on unfixed code).

**Expected Counterexamples**:
- Tests throw `AssertionError` with message containing "_viewInsets.isNonNegative"
- Browser console logs show negative dimension values before crash
- App becomes unresponsive after event, requiring manual reload
- Possible causes: SDK calculation race condition, missing validation, browser viewport reporting inconsistencies

#### Bug #2: Tile Loading Failure Exploration

**Test Plan**: Create widget tests that mock network responses for tile requests. Simulate connection refused and timeout errors. Run on UNFIXED code to observe failed tile loading without fallback. Use Flutter's `mockito` or `http_mock_adapter`.

**Test Cases**:
1. **Connection Refused Test**: Mock all OSM tile requests to return `ERR_CONNECTION_REFUSED`. Assert that tiles display error placeholders and no fallback provider is attempted (will fail on unfixed code).
2. **Timeout Test**: Mock tile requests to delay 11 seconds (exceeding 10s timeout). Assert that tiles show loading spinner indefinitely (will fail on unfixed code).
3. **Partial Failure Test**: Mock 30% of tiles to fail, 70% succeed. Assert that failed tiles don't trigger fallback provider switch (will fail on unfixed code).
4. **Invalid User-Agent Test**: Mock OSM server response with 403 Forbidden due to invalid user-agent. Assert that requests include `userAgentPackageName: 'com.example.optimeal'` header (will fail on unfixed code - causes actual bug).

**Expected Counterexamples**:
- Tiles remain in loading state indefinitely after connection errors
- No fallback provider switch occurs even with 100% failure rate
- Error callback is invoked but performs no recovery action
- Invalid user-agent causes OSM server rejections
- Possible causes: missing fallback configuration, empty errorTileCallback, invalid web user-agent, no retry logic

#### Bug #3: UI Overflow Exploration

**Test Plan**: Create widget tests with various viewport dimensions using `MediaQuery` overrides. Simulate keyboard appearance by adjusting viewPadding/viewInsets. Run on UNFIXED code to observe RenderFlex overflow exceptions.

**Test Cases**:
1. **Small Viewport Overflow Test**: Render HomeMapSearchScreen with 320x568 viewport (iPhone SE). Assert that no overflow exception occurs (will fail on unfixed code).
2. **Keyboard Appearance Overflow Test**: Render with 375x667 viewport, then simulate keyboard appearing (viewInsets.bottom = 300). Assert that Column layout adapts without overflow (will fail on unfixed code).
3. **Extreme Resize Test**: Render with 400x400 viewport where fixed elements (104 + 64 = 168px) leave only 232px for map. Assert that layout renders without yellow-black stripes (will fail on unfixed code).
4. **Positioned Widget Bounds Test**: Render with 380x600 viewport and measure Positioned widget bounds. Assert that all widgets stay within Stack bounds (may fail on unfixed code).

**Expected Counterexamples**:
- Console logs show "RenderFlex overflowed by N pixels" errors
- Widget tests detect overflow indicators (yellow-black stripes)
- Positioned widgets render outside Stack bounds
- Column children receive negative available space when measured
- Possible causes: fixed-height elements without responsive constraints, Stack with unbounded constraints, no scroll fallback for small viewports

#### Bug #4: Error Message Exploration

**Test Plan**: Create integration tests that simulate Firestore stream states and location provider states. Mock missing index errors and location permission denial. Run on UNFIXED code to observe persistent error messages despite data availability.

**Test Cases**:
1. **Missing Index Error Test**: Mock Firestore stream to throw "index not found" error initially, then emit valid data after 2 seconds. Assert that error message disappears when data arrives (will fail on unfixed code - error persists).
2. **Location Denied with Data Test**: Mock location provider in error state (permission denied) but Firestore stream returns valid listings with default coordinates. Assert that bottom status shows listing count, not error message (will fail on unfixed code - shows error).
3. **Stream Recovery Test**: Mock stream initialization exception followed by successful data emission. Assert that AsyncValue transitions from error to data state (will fail on unfixed code - stays in error).
4. **Cascading Error Test**: Mock both location provider and listings stream in error state initially, then location recovers. Assert that error display logic prioritizes listings data availability over location state (will fail on unfixed code - logic conflated).

**Expected Counterexamples**:
- Error message "Không tải được dữ liệu. Kiểm tra mạng." displays even when `visibleListings.length > 0`
- AsyncValue.error persists even after stream emits data events
- Location provider error causes listings error message despite successful data load
- Console shows Firestore "index not found" error with link to create index
- Possible causes: missing Firestore composite index, no stream error recovery, location/data error cascade, AsyncValue not reset after recovery

### Fix Checking

**Goal**: Verify that for all inputs where each bug condition holds, the fixed functions produce the expected behavior.

#### Bug #1: ViewInsets Crash Prevention

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition_ViewInsets(input) DO
  result := handleKeyboardOrResize_fixed(input)
  ASSERT result.viewInsets.top >= 0
  ASSERT result.viewInsets.bottom >= 0
  ASSERT result.viewInsets.left >= 0
  ASSERT result.viewInsets.right >= 0
  ASSERT result.appStillResponsive == true
  ASSERT result.noAssertionError == true
END FOR
```

**Test Cases**:
- Test keyboard hide on mobile viewports → assert app stays responsive, ViewInsets all ≥0
- Test window resize to 300x200 → assert no crash, dimensions clamped to 0 if negative
- Test rapid resize cycles → assert no exceptions thrown, UI updates smoothly
- Verify console warning logs when clamping occurs

#### Bug #2: OSM Tile Loading with Fallback

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition_TileLoading(input) DO
  result := loadTile_fixed(input)
  ASSERT result.retryAttempts <= 3
  ASSERT result.fallbackAttempted == true IF primary_failed
  ASSERT result.errorPlaceholderDisplayed == true IF all_failed
  ASSERT result.userAgentValid == true FOR web_platform
END FOR
```

**Test Cases**:
- Mock OSM connection errors → assert 3 retry attempts with exponential backoff
- Assert fallback provider (OpenTopoMap) attempted after primary fails
- Assert error banner displayed when >20% tiles fail
- Verify user-agent omitted or set to "OptiMeal-Web" on Flutter Web
- Verify successful tiles render normally without fallback

#### Bug #3: Responsive Layout Without Overflow

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition_UIOverflow(input) DO
  result := renderLayout_fixed(input)
  ASSERT result.overflowDetected == false
  ASSERT result.allWidgetsWithinBounds == true
  ASSERT result.minMapHeightMaintained >= 200px
  ASSERT result.scrollableIfNeeded == true IF height < 500px
END FOR
```

**Test Cases**:
- Render with 320x568 viewport → assert no overflow exceptions logged
- Simulate keyboard appearing (300px reduction) → assert layout adapts with flexible elements
- Render with 400x400 viewport → assert scroll view enabled or fixed elements shrink
- Verify minimum map height 200px maintained even on smallest viewports
- Verify Positioned widgets constrained within Stack bounds

#### Bug #4: Accurate Error State Display

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition_ErrorMessage(input) DO
  result := displayStreamState_fixed(input)
  ASSERT result.showsLoadingFirst == true
  ASSERT result.showsErrorOnlyIfNoData == true
  ASSERT result.separatesLocationError == true
  ASSERT result.recoversFromStreamError == true IF data_available
END FOR
```

**Test Cases**:
- Mock missing index error then data emission → assert error message disappears when data arrives
- Mock location denied + successful listings → assert bottom shows listing count, top shows GPS warning
- Mock stream initialization error + recovery → assert AsyncValue transitions to data state
- Mock both errors then location recovery → assert listings data displayed if available
- Verify error message only shows when `visibleListings.isEmpty`

### Preservation Checking

**Goal**: Verify that for all inputs where the bug conditions do NOT hold, the fixed functions produce the same result as the original functions.

**Pseudocode:**
```
FOR ALL input WHERE NOT (
  isBugCondition_ViewInsets(input) OR
  isBugCondition_TileLoading(input) OR
  isBugCondition_UIOverflow(input) OR
  isBugCondition_ErrorMessage(input)
) DO
  ASSERT fixedCode(input) = originalCode(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs
- The input domains are large: viewport dimensions, ViewInsets values, network conditions, stream states

**Test Plan**: Observe behavior on UNFIXED code first for normal scenarios, then write property-based tests capturing that behavior and verify fixed code maintains it.

**Test Cases**:

1. **Native Mobile Platform Preservation**: Run full test suite on Android emulator (API 30) and iOS simulator (iOS 15). Verify all 47 existing tests pass without modification. Assert google_maps_flutter used instead of flutter_map, ViewInsets calculations use platform channels, layout constraints work normally.

2. **Large Viewport Web Preservation**: Render on Flutter Web with 1920x1080 viewport. Assert layout identical to original, no clamping applied, no fallback providers invoked, normal error handling.

3. **Successful Tile Loading Preservation**: Mock all tile requests returning success within 2 seconds. Assert only OSM provider used, no fallback attempted, no error tracking state updated, tiles render identically to original.

4. **Valid ViewInsets Preservation**: Simulate keyboard events that produce all positive ViewInsets (top=20, bottom=300, left=0, right=0). Assert no clamping applied, no warning logs emitted, MediaQuery values identical to original.

5. **Genuine Error Display Preservation**: Mock network completely offline (no Firestore connection, no tile loading). Assert error messages display as original code, no false positives from recovery logic.

6. **Map Feature Interaction Preservation**: Test user location marker display, search filtering, marker tap → bottom sheet, route calculation, attribution display. Assert all timing requirements met (300ms, 2s), visual appearance unchanged, no behavioral regressions.

7. **Performance Preservation**: Measure frame render times on 60fps target. Assert fixed code maintains ≥55fps average on desktop browsers with 1024x768 viewport during pan/zoom operations.

### Unit Tests

**Bug #1: ViewInsets Validation**
- Test `safeCreate` method with negative values returns clamped EdgeInsets with all dimensions ≥0
- Test console warning logs emitted with correct format when clamping occurs
- Test patch initialization only activates on `kIsWeb == true`
- Test MediaQuery wrapper correctly propagates clamped viewInsets to descendants

**Bug #2: Tile Provider Management**
- Test `TileErrorTracker.recordError` increments error count and switches provider when threshold exceeded
- Test `TileProvider.urlTemplate` returns correct URLs for OSM and OpenTopoMap
- Test error banner displays when error rate >20% and hides when <15%
- Test successful tile loads reset error rate over time

**Bug #3: Responsive Layout Constraints**
- Test `isSmallViewport` flag correctly identifies viewports <600px height or <400px width
- Test fixed spacer heights adjust from 104→80 and 64→48 on small viewports
- Test `SingleChildScrollView` wrapper applied when viewport height <500px
- Test minimum map height constraint enforced at 200px

**Bug #4: Error State Logic**
- Test `nearbyListingsWithRecoveryProvider` returns previous data when new error occurs
- Test error display shows loading first, then error only if no data available
- Test location error displays in GPS banner, not bottom status message
- Test stream timeout after 10 seconds produces appropriate error message
- Test Firestore index error displays specific message mentioning console

### Property-Based Tests

**Multi-Viewport Layout Properties**:
- Generate random viewport dimensions (width: 320-2560, height: 568-1440)
- For each dimension, render HomeMapSearchScreen and assert:
  - No RenderFlex overflow exceptions thrown
  - All Positioned widgets remain within Stack bounds
  - Map area height ≥200px or ScrollView enabled
  - UI elements maintain minimum touch target size 48x48px

**ViewInsets Validation Properties**:
- Generate random ViewInsets dimensions (top, bottom, left, right: -500 to +500)
- For each combination, pass through SafeViewInsetsWrapper and assert:
  - All output dimensions ≥0
  - If input had negative values, warning logged
  - If input had all positive values, output equals input exactly
  - MediaQuery descendants receive valid EdgeInsets

**Tile Loading Retry Properties**:
- Generate random network error scenarios (connection refused, timeout, 500/503 errors, success rates 0-100%)
- For each scenario, load map tiles and assert:
  - Each failed tile retried up to 3 times
  - Fallback provider attempted when primary error rate >20%
  - Error placeholders displayed only after all retries + fallback exhausted
  - Successful tiles render immediately without retries

**Stream Error Recovery Properties**:
- Generate random stream event sequences (error→data, data→error→data, loading→error→data, multiple errors→data)
- For each sequence, feed to nearbyListingsStreamProvider and assert:
  - Final AsyncValue state matches last event type (error or data)
  - If sequence ends with data, error message not displayed
  - If sequence has errors but data available, data takes priority
  - If sequence has only errors with no data, error message displayed

### Integration Tests

**Full Web App Flow with All Bugs Fixed**:
1. Launch app on Flutter Web with 375x667 viewport (iPhone size)
2. Navigate to Food Map screen → assert tiles load from OSM within 5 seconds
3. Tap search bar → keyboard appears → type query → keyboard hides → assert no crash, app responsive
4. Resize browser window to 320x568 → assert layout adapts without overflow
5. Mock network offline → assert error banner displays with retry button
6. Click retry, restore network → assert tiles reload successfully
7. Grant GPS permission → assert location marker displays, radius circle renders
8. Deny GPS permission → assert GPS warning banner at top, listings still display at bottom with default location
9. Create Firestore index via console link → refresh app → assert error message disappears, listing count displays

**Native Platform Regression Test**:
1. Run same test suite on Android emulator
2. Assert google_maps_flutter used for tiles (not flutter_map)
3. Assert no web-specific patches applied
4. Assert all 47 existing tests pass unchanged
5. Verify performance metrics maintained (app startup <3s, map render <1s)

**Cross-Browser Compatibility Test**:
1. Run app on Chrome, Firefox, Safari, Edge (all latest versions)
2. Test keyboard hide events on each browser → assert no crashes
3. Test window resize on each browser → assert responsive layout works
4. Test tile loading on each browser → assert OSM tiles load or fallback succeeds
5. Verify console logs formatted correctly on each browser's dev tools
