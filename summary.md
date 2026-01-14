# Summary of Changes

Added two new functions to clean vehicle make and model data: `clean_make()` and `clean_model()`.

## clean_make()

Cleans vehicle make names, standardizing common abbreviations and correcting misspellings.

**Examples:**

| Input | Output |
|-------|--------|
| "VW" | "Volkswagen" |
| "Volksw" | "Volkswagen" |
| "Merc" | "Mercedes" |
| "oda" | "Skoda" |
| "unknown" | "Unknown" |
| "GM" | "GM" |

## clean_model()

Standardizes vehicle model names to title case.

**Examples:**

| Input | Output |
|-------|--------|
| "FIESTA" | "Fiesta" |
| "ka" | "Ka" |

## Testing

New tests added in `tests/testthat/test-clean.R` cover these cases and pass.
