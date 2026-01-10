# AI Ruchi - Backend API Requirements

**Document Version:** 1.0  
**Date:** January 10, 2026  
**Purpose:** Required backend API changes for AI Ruchi mobile app updates

---

## 1. API Endpoints Affected

| Endpoint | Method |
|----------|--------|
| `/api/recipe/generate` | POST |
| `/api/recipe/generate-from-image` | POST |

---

## 2. Request Schema Updates

### 2.1 Add `servings` Parameter

The `preferences` object now includes a `servings` field.

**Current Request:**
```json
{
  "ingredients": ["2 eggs", "1 cup flour"],
  "provider": "openai",
  "preferences": {
    "cuisine": "Italian",
    "dietary": "vegetarian"
  }
}
```

**Updated Request:**
```json
{
  "ingredients": ["2 eggs", "1 cup flour"],
  "provider": "openai",
  "preferences": {
    "cuisine": "Italian",
    "dietary": "vegetarian",
    "servings": 4
  }
}
```

**Field Details:**
| Field | Type | Range | Default | Required |
|-------|------|-------|---------|----------|
| servings | integer | 1-20 | 4 | No |

**Logic:**
- Scale ingredient quantities proportionally based on servings
- Adjust cooking times if serving size significantly differs from base recipe

---

## 3. Response Schema Updates

### 3.1 Add `removedIngredients` Array

For image-based recipe generation, return ingredients that were filtered out based on user preferences.

**Updated Response:**
```json
{
  "success": true,
  "extractedIngredients": ["chicken", "garlic", "onion"],
  "removedIngredients": [
    {
      "name": "butter",
      "reason": "Removed due to dairy-free dietary preference",
      "category": "dietary_conflict"
    },
    {
      "name": "cream",
      "reason": "Removed due to dairy-free dietary preference",
      "category": "dietary_conflict"
    }
  ],
  "analysisNote": "Recipe adapted for dairy-free diet. Replaced cream with coconut cream.",
  "recipe": { ... }
}
```

**RemovedIngredient Object:**
| Field | Type | Description |
|-------|------|-------------|
| name | string | Ingredient name that was removed |
| reason | string | Human-readable explanation |
| category | string | One of: `dietary_conflict`, `allergen`, `health_concern`, `preference_mismatch` |

**Category Values:**
- `dietary_conflict` - Conflicts with user's dietary preference (e.g., meat for vegetarian)
- `allergen` - Common allergen detected (future enhancement)
- `health_concern` - High sodium/sugar for health-conscious users (future)
- `preference_mismatch` - Doesn't match cuisine type

### 3.2 Add `analysisNote` Field

| Field | Type | Description |
|-------|------|-------------|
| analysisNote | string (nullable) | Note explaining ingredient substitutions made |

---

## 4. Instruction Vocabulary Enhancement

### 4.1 Requirement

Instructions should be more detailed and beginner-friendly with:
- Clear step-by-step language
- Explicit time mentions (parseable format)
- Precise temperatures
- Visual completion cues

### 4.2 Current vs Improved

**Current:**
```
"Cook for 5-7 mins until done."
```

**Improved:**
```
"Heat a large non-stick skillet over medium heat for approximately 2 minutes until evenly hot. Add the marinated chicken pieces in a single layer, ensuring they do not overlap. Cook undisturbed for 5 to 7 minutes, allowing the underside to develop a golden-brown crust. The chicken is ready to flip when the edges appear opaque and the bottom releases easily from the pan."
```

### 4.3 Time Format Guidelines

- Use full words: "5 minutes", "1 hour 30 minutes"
- Avoid abbreviations in instructions: prefer "minutes" over "mins"
- For ranges, use "to": "5 to 7 minutes"
- Always include units

---

## 5. Servings-Based Scaling Logic

When `servings` parameter is provided:

1. Parse base recipe for default serving size
2. Calculate scaling factor: `factor = requested_servings / base_servings`
3. Multiply all ingredient quantities by factor
4. Round to practical measurements (e.g., 2.3 eggs → 2 eggs)
5. Adjust cooking vessel sizes in instructions if needed
6. Note any timing adjustments for significantly different quantities

**Example:**
- Base: 2 eggs for 4 servings
- Request: 6 servings
- Factor: 1.5
- Result: 3 eggs for 6 servings

---

## 6. Summary of Changes

| Change | Type | Priority |
|--------|------|----------|
| Add `servings` to preferences | Request | High |
| Return `removedIngredients` array | Response | Medium |
| Return `analysisNote` field | Response | Medium |
| Enhanced instruction vocabulary | AI Prompt | Medium |
| Servings-based quantity scaling | Logic | High |

---

## 7. Contact

For questions about these requirements, contact the mobile development team.
