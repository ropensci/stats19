# junction_status() resolves the overlap in junction_detail code 0, which
# covers roundabouts, mini-roundabouts and slip roads as well as genuine
# non-junction collisions (#328). Cases below follow the cross-tab in the
# issue: historic codes 1, 2, 3, 5, 6, 7, 8, 9 are junctions, historic 0 is
# not, and -1/99 are unknown so the new junction_detail/road_type pair takes
# over.

junction_cases = tibble::tribble(
  ~label,                                    ~junction_detail, ~junction_detail_historic, ~road_type, ~expected,
  "historic not junction",                   0,                0,                         6,          "not junction",
  "historic roundabout",                     0,                1,                         1,          "junction",
  "historic mini-roundabout",                0,                2,                         6,          "junction",
  "historic T or staggered",                 13,               3,                         6,          "junction",
  "historic slip road",                      0,                5,                         7,          "junction",
  "historic crossroads",                     16,               6,                         6,          "junction",
  "historic more than 4 arms",               17,               7,                         6,          "junction",
  "historic private drive",                  18,               8,                         6,          "junction",
  "historic other junction",                 19,               9,                         6,          "junction",
  "historic unknown (-1), new roundabout",   0,                -1,                        1,          "junction",
  "historic unknown (-1), new slip road",    0,                -1,                        7,          "junction",
  "historic unknown (-1), new not junction", 0,                -1,                        6,          "not junction",
  "historic unknown (99), new junction",     13,               99,                        6,          "junction",
  "historic unknown (-1), new unknown (-1)", -1,               -1,                        6,          NA_character_,
  "historic unknown (-1), new unknown (99)", 99,               -1,                        6,          NA_character_,
  "historic unknown (-1), mini-roundabout not recoverable via road_type", 0, -1,           6,          "not junction",
  "missing junction_detail and historic",    NA,               NA,                        NA,         NA_character_,
)

test_that("junction_status classifies the code combinations from the issue", {
  result = junction_status(
    junction_detail = junction_cases$junction_detail,
    junction_detail_historic = junction_cases$junction_detail_historic,
    road_type = junction_cases$road_type
  )
  expect_equal(result, junction_cases$expected)
})

test_that("junction_status works on 2024-style rows (historic = -1 throughout)", {
  # From 2024 onwards junction_detail_historic is -1 for every row, so
  # classification falls back to junction_detail and road_type for all of them.
  junction_detail = c(0, 0, 13, 16, 0, -1)
  junction_detail_historic = rep(-1, length(junction_detail))
  road_type = c(1, 7, 6, 6, 6, 6)

  expect_equal(
    junction_status(junction_detail, junction_detail_historic, road_type),
    c("junction", "junction", "junction", "junction", "not junction", NA_character_)
  )
})

test_that("junction_status defaults to junction_detail/road_type when historic is absent", {
  expect_equal(
    junction_status(junction_detail = c(0, 0, 13), road_type = c(1, 6, 6)),
    c("junction", "not junction", "junction")
  )
})

test_that("junction_status defaults to 'not junction' for code 0 when road_type is absent", {
  expect_equal(
    junction_status(junction_detail = c(0, 13, -1)),
    c("not junction", "junction", NA_character_)
  )
})

test_that("junction_status gives the same answer for raw codes and formatted labels", {
  raw = data.frame(
    collision_index = as.character(seq_len(nrow(junction_cases))),
    junction_detail = junction_cases$junction_detail,
    junction_detail_historic = junction_cases$junction_detail_historic,
    road_type = junction_cases$road_type,
    stringsAsFactors = FALSE
  )

  formatted = format_stats19(raw, type = "Collision")

  # junction_detail_historic must survive formatting: it is needed by
  # junction_status() and the generic historic-column merge would otherwise
  # silently drop it (see the comment in format_stats19()).
  expect_true("junction_detail_historic" %in% names(formatted))

  from_raw = junction_status(
    raw$junction_detail, raw$junction_detail_historic, raw$road_type
  )
  from_formatted = junction_status(
    formatted$junction_detail, formatted$junction_detail_historic, formatted$road_type
  )

  expect_equal(from_formatted, from_raw)
  expect_equal(from_raw, junction_cases$expected)
})

test_that("junction_status works when raw codes are read as character", {
  # e.g. DfT CSVs read with all_varchar = TRUE, or format = FALSE with
  # engines that don't type the columns.
  expect_equal(
    junction_status(c("0", "0", "13"), c("0", "1", "3"), c("6", "6", "6")),
    c("not junction", "junction", "junction")
  )

  expect_equal(
    junction_status(
      junction_detail = as.character(junction_cases$junction_detail),
      junction_detail_historic = as.character(junction_cases$junction_detail_historic),
      road_type = as.character(junction_cases$road_type)
    ),
    junction_cases$expected
  )
})
