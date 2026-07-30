# Match STATS19 collisions with TAG (RAS4001) cost estimates

Downloads and processes the UK Department for Transport **TAG Data
Book** table **RAS4001**, and joins estimated collision costs to STATS19
data.

Three matching modes are available:

- `"severity"` — cost varies only by collision severity

- `"severity_road"` — cost varies by severity *and* road type

- `"severity_road_bua"` — cost varies by severity & road type, where
  road type is determined using **ONS Built-Up Area (BUA)** polygons
  (2022)

BUA polygons are downloaded automatically from:
<https://open-geography-portalx-ons.hub.arcgis.com/api/download/v1/items/ad30b234308f4b02b4bb9b0f4766f7bb/geoPackage?layers=0>

Optionally, total costs may be summarised by severity and/or road type.

## Usage

``` r
match_tag(
  crashes,
  shapes_url =
    paste0("https://open-geography-portalx-ons.hub.arcgis.com/api/download/v1/",
    "items/ad30b234308f4b02b4bb9b0f4766f7bb/geoPackage?layers=0"),
  costs_url = paste0("https://assets.publishing.service.gov.uk/media/",
    "68d421cc275fc9339a248c8e/ras4001.ods"),
  match_with = "severity",
  include_motorway_bua = FALSE,
  summarise = FALSE
)
```

## Arguments

- crashes:

  A STATS19 collision data frame. May be `sf` or non-`sf`, but spatial
  geometry is required when using `"severity_road_bua"`.

- shapes_url:

  URL to download the ONS Built-Up Areas geopackage. Defaults to the
  official ONS 2022 dataset.

- costs_url:

  URL to download the TAG Data Book **RAS4001** table (ODS format).
  Defaults to the Department for Transport asset link.

- match_with:

  Character string specifying the matching mode. One of:

  - `"severity"`

  - `"severity_road"`

  - `"severity_road_bua"`

  The default uses
  `match_with = c("severity", "severity_road", "severity_road_bua")`, so
  users get tab-completion and help in RStudio.

- include_motorway_bua:

  Logical; if `TRUE`, motorways inside a built-up area polygon are
  treated as `"built_up"` rather than `"Motorway"`.

- summarise:

  Logical; if `TRUE`, returns a summary table of total costs (in
  millions) grouped by severity and/or road type.

## Value

A data frame (or `sf` object if input is `sf`) with added columns for
estimated collision costs. If `summarise = TRUE`, a summary table of
total costs (in millions) is returned.

## Details

The function:

1.  Downloads and parses **RAS4001** cost tables

2.  Computes road type using STATS19 fields or optional BUA polygons

3.  Joins appropriate cost estimates

4.  Optionally aggregates totals

When `crashes` is an `sf` object and `summarise = TRUE`, geometry is
automatically dropped.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Simple severity-based matching
  match_tag(stats19_df, match_with = "severity")

  # Severity + road type
  match_tag(stats19_df, match_with = "severity_road")

  # Using ONS Built-Up Areas, with motorway override
  match_tag(
    stats19_df,
    match_with = "severity_road_bua",
    include_motorway_bua = TRUE
  )

  # Summarised totals
  match_tag(stats19_df, match_with = "severity", summarise = TRUE)
} # }
```
