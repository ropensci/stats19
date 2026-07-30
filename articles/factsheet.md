# Reproducing Reported road casualties in Great Britain: pedestrian factsheet

> **Note:** This vignette is not evaluated during package checks to
> reduce build time and dependencies.
>
> **See rendered results online:**
>
> - [2024 Pedestrian
>   Factsheet](https://rpubs.com/Blaise/stats19_pfs_2024)
> - [2023 Pedestrian
>   Factsheet](https://rpubs.com/Blaise/stats19_pfs_2023)
>
> To reproduce the results yourself, download the source code of this
> vignette and set `eval=TRUE` in the knitr options, or view the
> discussion in [GitHub issue
> \#240](https://github.com/ropensci/stats19/issues/240).

## 1. Main findings

Between 2004 and 2024:

- fatalities were down 39% from 677 to 409
- serious injuries (adjusted) decreased by 48%\
- pedestrian traffic (distance walked) decreased by 13%

Averaged over the period 2020 to 2024:

- an average of 8 pedestrians died and 115 were seriously injured
  (adjusted) per week in reported road collisions

- a majority of pedestrian fatalities (58%) do not occur at or within
  20m of a junction compared to 42% of all seriously injured (adjusted)
  casualties

- 66% of pedestrian fatalities were in collisions involving a single car

- 33% of pedestrian fatalities occurred on rural roads compared to 14%
  of all pedestrian casualties

- 65% of pedestrian killed or seriously injured (KSI) (adjusted)
  casualties were male

The most common contributory factor allocated to pedestrians *no
contributory factors included in the public data*

## 2. Pedestrian traffic and reported casualties

In 2024, 409 pedestrians were killed in Great Britain, whilst 5965 were
reported to be seriously injured and 13381 slightly injured.

Table 1 and Chart 1 show that pedestrian traffic (measured by distance
walked) has decreased between 2004 and 2024 whilst fatalities, serious
and slight injuries have fallen.

Between 2023 and 2024, pedestrian fatalities decreased by 3% while
pedestrian traffic (distance walked) increased by 1%.

## 3. How far do pedestrians travel?

The National Travel Survey (NTS) which provides the [number of trips and
average distance
travelled](https://www.gov.uk/government/statistical-data-sets/nts03-modal-comparisons)
(NTS0303) by person per year for English residents. This is used to
derive casualty rates per mile travelled for pedestrians, which also use
the Great Britain [population
figure](https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatestimeseriesdataset/current/pop.csv)
to estimate total distance walked each year.

## 4. Casualty rates per mile travelled

The pedestrian casualty rate has fallen for all severities in 2024
compared to 2004.

The overall casualty rate decreased by 53%. The fatality rate decreased
by 30% compared to a 41% reduction for serious injuries and a 57%
reduction for slight injuries.

## 5. Sex and age comparisons

Between 2020 and 2024, 65% of pedestrian casualties were male and 35%
female.

There are 1.9 times more male than female pedestrian casualties overall.
This compares to 2.3 more for 30-39, 1.5 more for 0-11 and 0.9 more for
70+ - the only age group in which female casualties outnumber males.

## 6. Which vehicles are involved in collisions with pedestrians?

Between 2020 and 2024, most pedestrian fatalities occurred in 1 vehicle
collisions involving a car (275).

However, the highest proportion of casualties from single vehicle
collisions involve 1 heavy goods vehicle (4.8%). The second highest
proportion (3.3%) occurred in collisions when 3 or more other vehicles
involved.

## 7. Time of day of collisions

The weekday peak time for pedestrian KSIs is from 3pm to 6pm. By
contrast, the peak is from 1am to 9pm at weekends.

## 8. What type of road?

Chart 5 shows that between 2020 and 2024, 63% of pedestrian fatalities
occurred on urban roads compared to 85% of all pedestrian casualties. 4%
of pedestrian fatalities occurred on motorways. This would be people
outside their vehicles whether they are moving at the time or not.

In this report, urban roads are defined as those within an area of
population of 10,000 or more in England and Wales or more than 3,000 in
Scotland - roads outside of these areas are classified as rural
<https://www.gov.uk/government/publications/road-length-statistics-information/road-lengths-in-great-britain-statistics-notes-and-definitions>.

## 9. Vehicle movement on the road

A majority of pedestrian fatalities( 58 %) occur not at junction or
within 20 metres compared to 42 % of serious injuries (adjusted).
However, 29 % of fatalities occur at a junction compared to 43 % of
serious injuries (adjusted).

Sections 10 not reproducible as data is not public and sections 11 and
14 are simply explanatory text.

This document is also useful for understanding the methodology behind
the categories
<https://assets.publishing.service.gov.uk/media/68373a464115cfe5bfaa2cd4/STATS20_2024_specification.pdf>
