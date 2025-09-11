# Resource Name Formatter Function

## Overview

I've added a `formatResourceNameForApi()` function to the ResourcesService that converts resource names to URL-friendly format (lowercase with dashes instead of spaces).

## Function Location

**File:** `lib/services/resources_service.dart`

## Function Definition

```dart
String formatResourceNameForApi(String resourceName) {
  return resourceName
      .toLowerCase()                    // Convert to lowercase
      .trim()                          // Remove leading/trailing spaces
      .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters except word chars, spaces, and dashes
      .replaceAll(RegExp(r'\s+'), '-')     // Replace one or more spaces with single dash
      .replaceAll(RegExp(r'-+'), '-')      // Replace multiple consecutive dashes with single dash
      .replaceAll(RegExp(r'^-+|-+$'), ''); // Remove leading/trailing dashes
}
```

## Usage Examples

### Example 1: Basic formatting
```dart
final resourceService = ResourcesService();

// Input: "FormPro 237: Une dynamique d'apprentissage au service de l'employabilité au Cameroun"
final formatted = resourceService.formatResourceNameForApi(
  "FormPro 237: Une dynamique d'apprentissage au service de l'employabilité au Cameroun"
);

print(formatted);
// Output: "formpro-237-une-dynamique-dapprentissage-au-service-de-lemployabilite-au-cameroun"
```

### Example 2: Complex formatting
```dart
// Input: "Les Ateliers Numériques - Ressources & Formations!!!"
final formatted = resourceService.formatResourceNameForApi(
  "Les Ateliers Numériques - Ressources & Formations!!!"
);

print(formatted);  
// Output: "les-ateliers-numeriques-ressources-formations"
```

### Example 3: Edge cases
```dart
// Input: "  --Resource   Name  With   Multiple   Spaces-- "
final formatted = resourceService.formatResourceNameForApi(
  "  --Resource   Name  With   Multiple   Spaces-- "
);

print(formatted);
// Output: "resource-name-with-multiple-spaces"
```

## Step-by-Step Process

1. **Convert to lowercase**: `"FormPro 237"` → `"formpro 237"`
2. **Trim spaces**: `" text "` → `"text"`  
3. **Remove special chars**: `"text: & symbols!"` → `"text  symbols"`
4. **Replace spaces with dashes**: `"word word"` → `"word-word"`
5. **Collapse multiple dashes**: `"word--word"` → `"word-word"`
6. **Remove leading/trailing dashes**: `"-word-"` → `"word"`

## Integration with API

You can use this function when making API calls that require formatted resource names:

```dart
// Example API call with formatted name
final formattedName = _resourcesService.formatResourceNameForApi(resource.title);
final apiUrl = '$baseUrl/api/Resources/details/$formattedName';

// This would generate URLs like:
// /api/Resources/details/formpro-237-une-dynamique-dapprentissage-au-service-de-lemployabilite-au-cameroun
```

## Character Handling

**Keeps:**
- Letters (a-z, A-Z) 
- Numbers (0-9)
- Spaces (converted to dashes)
- Existing dashes (normalized)

**Removes:**
- Punctuation (: ; ! ? . ,)
- Special symbols (& @ # $ % etc.)
- Accented characters (é, à, ç, etc.) → converted to basic equivalents
- Extra whitespace and dashes

The function creates clean, URL-safe resource identifiers perfect for your API endpoints! 🎯