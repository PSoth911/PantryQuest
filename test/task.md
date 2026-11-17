# Epic 5: Test Layer - Tracking & Task List

> **Repository**: [PSoth911/PantryQuest](https://github.com/PSoth911/PantryQuest)  
> **Branch**: `continues/remain-test`  
> **Epic**: [Issue #51 - Epic 5: Test Layer](https://github.com/PSoth911/PantryQuest/issues/51)  
> **Target Directory**: `pantry_quest/test/service/`

---

## 📋 Epic Acceptance Criteria

- [ ] **Coverage Quality**: Normal, invalid, and boundary/special scenarios are covered for all services.
- [ ] **Test Count**: At least 5 test cases exist for each service, covering both successful and unsuccessful operations.
- [ ] **Data Integrity**: Business rules and data integrity are properly verified.
- [ ] **Zero Logic Degradation**: Failing tests are fixed without altering production business logic merely to pass.
- [ ] **Independence**: All tests are self-contained, independent, and repeatable.
- [ ] **Green Test Suite**: `flutter test` passes 100% cleanly across all test files.
- [ ] **Documentation**: Execution results documented for closing issues #51–#56.

---

## 🛠️ Phase 1: Environment & Compile Fixes

- [x] **Task 1.1: Normalize Test Package Imports**
  - Replace all relative `../../lib/...` imports with `package:pantry_quest/...` in all test files to prevent Dart duplicate-type mismatch errors.
- [x] **Task 1.2: Remove Incompatible VM Import**
  - Remove `import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';` from `pantry_quest/test/service/cooking_record_service_test.dart`.
- [x] **Task 1.3: Fix Widget Test Suite Failure**
  - Update or resolve `pantry_quest/test/widget_test.dart` so `flutter test` runs without default counter template failures.

---

## 🍳 Phase 2: Unit Tests for `CookingRecordService`
> **GitHub Issue**: [#54 Write Unit Tests for CookingRecordService](https://github.com/PSoth911/PantryQuest/issues/54)  
> **File**: `pantry_quest/test/service/cooking_record_service_test.dart`  
> **Service**: `pantry_quest/lib/service/cooking_record_service.dart`

- [x] **Task 2.1: Normal Scenarios**
  - [x] Add a valid cooking record (`addCookingRecord`).
  - [x] Retrieve all cooking records (`getAllCookingRecords`).
  - [x] Retrieve a cooking record by ID (`getCookingRecordById`).
  - [x] Delete a cooking record by ID (`deleteCookingRecord`).
- [x] **Task 2.2: Invalid Scenarios**
  - [x] Reject duplicate record IDs with `StateError`.
  - [x] Reject record with empty `id` (`ArgumentError`).
  - [x] Reject record with empty `recipeId` (`ArgumentError`).
  - [x] Reject record with empty `recipeName` (`ArgumentError`).
- [x] **Task 2.3: Boundary / Special Scenarios**
  - [x] Return `null` when querying a non-existent ID.
  - [x] Return `false` when deleting a non-existent ID.
  - [x] Return an empty unmodifiable list when no records exist.

---

## 🍲 Phase 3: Unit Tests for `CookingService`
> **GitHub Issue**: [#55 Write Unit Tests for CookingService](https://github.com/PSoth911/PantryQuest/issues/55)  
> **File**: `pantry_quest/test/service/cooking_service_test.dart`  
> **Service**: `pantry_quest/lib/service/cooking_service.dart`

- [x] **Task 3.1: Normal Scenarios**
  - [x] Successfully record meal when recipe exists and pantry stock is sufficient (`recordMeal`).
  - [x] Verify pantry quantities are deducted properly.
  - [x] Verify cooking record is stored in `CookingRecordService`.
  - [x] Verify returned `CookingRecord` properties (id, recipeId, recipeName, cookedAt).
- [x] **Task 3.2: Invalid Scenarios**
  - [x] Reject empty or whitespace record ID (`ArgumentError`).
  - [x] Reject non-existing recipe ID (`StateError`).
  - [x] Reject duplicate cooking record ID (`StateError`).
  - [x] Reject meal recording when pantry stock is insufficient (`StateError`).
- [x] **Task 3.3: Boundary / Special Scenarios**
  - [x] Support exact quantity availability (pantry stock matches recipe requirement exactly).
  - [x] Atomicity: Leave pantry stock unchanged when recording fails.
  - [x] Atomicity: Create no cooking record when deduction or recipe validation fails.

---

## 🥫 Phase 4: Unit Tests for `PantryService`
> **GitHub Issue**: [#52 Write Unit Tests for PantryService](https://github.com/PSoth911/PantryQuest/issues/52)  
> **File**: `pantry_quest/test/service/pantry_service_test.dart`  
> **Service**: `pantry_quest/lib/service/pantry_service.dart`

- [ ] **Task 4.1: Normal Scenarios**
  - [x] Add a valid pantry item (`addItem`).
  - [x] Retrieve all pantry items (`getAllItems`).
  - [ ] Update an existing pantry item (`updateItem`).
  - [ ] Delete an existing pantry item (`deleteItem`).
  - [ ] Calculate available ingredient quantity (`getAvailableQuantity`).
- [ ] **Task 4.2: Invalid Scenarios**
  - [x] Reject duplicate item IDs (`StateError`).
  - [x] Reject item with empty name (`ArgumentError`).
  - [x] Reject item with zero or negative quantity (`ArgumentError`).
  - [ ] Reject updating a non-existent item (returns `false`).
  - [ ] Reject updating with invalid quantity/data (`ArgumentError`).
- [ ] **Task 4.3: Boundary / Special Scenarios**
  - [x] Accept item expiring today but reject expired yesterday.
  - [ ] Support null expiry dates (non-perishable items like salt or sugar).
  - [ ] Identify items expiring within 3 days (`getAllExpiredSoon` / `isExpiringSoon`).
  - [ ] Exclude expired ingredients from available quantities (`getAvailableQuantity`).
  - [ ] FEFO deduction: Deduct from batches closest to expiration first (`deductIngredients`).
  - [ ] Atomic deduction: Avoid partial deduction when any ingredient stock is insufficient.

---

## 📖 Phase 5: Unit Tests for `RecipeService`
> **GitHub Issue**: [#53 Write Unit Tests for RecipeService](https://github.com/PSoth911/PantryQuest/issues/53)  
> **File**: `pantry_quest/test/service/recipe_service_test.dart`  
> **Service**: `pantry_quest/lib/service/recipe_service.dart`

- [ ] **Task 5.1: Normal Scenarios**
  - [x] Add a valid recipe (`addRecipe`).
  - [x] Retrieve all recipes (`getAllRecipes`).
  - [ ] Retrieve recipe by ID (`getRecipeById`).
  - [ ] Update an existing recipe (`updateRecipe`).
  - [ ] Delete an existing recipe (`deleteRecipe`).
  - [ ] Identify a recipe that can be prepared (`isRecipeAvailable`).
  - [ ] Calculate missing ingredients (`getMissingIngredients`).
- [ ] **Task 5.2: Invalid Scenarios**
  - [x] Reject recipe with empty name (`ArgumentError`).
  - [x] Reject recipe with duplicate ID (`StateError`).
  - [x] Reject recipe with ingredient quantity <= 0 (`ArgumentError`).
  - [ ] Reject recipe with empty ingredients list (`ArgumentError`).
  - [ ] Reject updating a non-existent recipe (returns `false`).
- [ ] **Task 5.3: Boundary / Special Scenarios**
  - [ ] Aggregate duplicate ingredient lines in a single recipe (`_aggregateIngredients`).
  - [ ] Handle empty pantry (all ingredients reported as missing).
  - [ ] Exact quantity availability (pantry has exactly what recipe needs).
  - [ ] Case-insensitive matching of ingredient names.

---

## 🔍 Phase 6: Suite Validation & Documentation
> **GitHub Issue**: [#56 Review Test Coverage and Validate the Test Layer](https://github.com/PSoth911/PantryQuest/issues/56)

- [ ] **Task 6.1: Run Full Test Suite**
  - Execute `flutter test` across all unit tests and verify 0 failures.
- [ ] **Task 6.2: Verify Scenario Coverage**
  - Confirm every service has at least 5 test cases covering Normal, Invalid, and Boundary scenarios.
- [ ] **Task 6.3: Confirm Test Independence**
  - Verify tests do not rely on execution order or shared mutable global state.
- [ ] **Task 6.4: Document Execution Results**
  - Compile output summary to close GitHub issues #51 through #56.
