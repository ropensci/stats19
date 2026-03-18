# Summary of Changes

Added functionality to extract and clean vehicle make and model data.

## New Functions

### `extract_make_stats19(generic_make_model)`

Extracts the make from a generic make/model string, handling multi-word makes (e.g., "LAND ROVER", "ALFA ROMEO").

### `clean_make(make, extract_make = TRUE)`

Cleans vehicle make names. 
- By default (`extract_make = TRUE`), it first calls `extract_make_stats19()` on the input.
- Standardizes common abbreviations (e.g., "VW" -> "Volkswagen").
- Corrects misspellings and synonyms.
- Handles case sensitivity (keeps "GM", "BMW" etc. uppercase, others Title Case).

**Examples:**

| Input | Output |
|-------|--------|
| "FORD FIESTA" | "Ford" |
| "LAND ROVER DISCOVERY" | "Land Rover" |
| "VW GOLF" | "Volkswagen" |
| "unknown" | "Unknown" |

### `clean_model(model)`

Standardizes vehicle model names to title case.

**Examples:**

| Input | Output |
|-------|--------|
| "FIESTA" | "Fiesta" |

## Testing

Tests in `tests/testthat/test-clean.R` cover:
- Basic cleaning (VW -> Volkswagen).
- Multi-word extraction (LAND ROVER DISCOVERY -> LAND ROVER).
- Integrated extraction and cleaning.
- Case preservation for acronyms.