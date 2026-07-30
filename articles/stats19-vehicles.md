# Researching vehicles involved in collisions with STATS19 data

``` r

library(stats19)
library(dplyr)
```

## Vehicle level variables in the STATS19 datasets

Of the three dataset types in STATS19, the vehicle tables are perhaps
the most revealing yet under-explored. They look like this:

``` r

v = get_stats19(year = 2022, type = "vehicle")
names(v)
v
```

We will categorise the vehicle types to simplify subsequent results:

``` r

v = v %>% mutate(vehicle_type2 = case_when(
  grepl(pattern = "motorcycle", vehicle_type, ignore.case = TRUE) ~ "Motorbike",
  grepl(pattern = "Car", vehicle_type, ignore.case = TRUE) ~ "Car",
  grepl(pattern = "Bus", vehicle_type, ignore.case = TRUE) ~ "Bus",
  grepl(pattern = "cycle", vehicle_type, ignore.case = TRUE) ~ "Cycle",
  # grepl(pattern = "Van", vehicle_type, ignore.case = TRUE) ~ "Van",
  grepl(pattern = "Goods", vehicle_type, ignore.case = TRUE) ~ "Goods",
  
  TRUE ~ "Other"
))
# barplot(table(v$vehicle_type2))
```

All of these variables are of potential interest to road safety
researchers. Let’s take a look at summaries of a few of them:

``` r

table(v$vehicle_type2)
summary(v$age_of_driver)
summary(v$engine_capacity_cc)
table(v$propulsion_code)
summary(v$age_of_vehicle)
```

The output shows vehicle type (a wide range of vehicles are
represented), age of driver (with young and elderly drivers often seen
as more risky), engine capacity and populsion (related to vehicle type
and size) and age of vehicle. In addition to these factors appearing in
prior road safety research and debate, they are also things that policy
makers can influence, e.g by:

- Encouraging modal shift away more dangerous modes and towards safer
  modes
- Incentivising people in particular risk categories to use safer modes
- Encouraging use of certain (safer) kinds of vehicle, e.g. with tax
  policies

## Relationships between vehicle type and crash severity

To explore the relationship between vehicles and crash severity, we must
first join on the ‘accidents’ table:

``` r

a = get_stats19(year = 2022, type = collision)
va = dplyr::inner_join(v, a)
```

Now we have additional variables available to us:

``` r

dim(v)
dim(va)
names(va)
```

Let’s see how crash severity relates to the variables of interest
mentioned above:

``` r

xtabs(~vehicle_type2 + accident_severity, data = va) %>% prop.table()
xtabs(~vehicle_type2 + accident_severity, data = va) %>% prop.table() %>% plot()
```

As expected, crashes involving large vehicles such as buses and good
vehicles tend to be more serious (involve proportionally more deaths)
than crashes involving smaller vehicles.

To focus only on cars, we can filter the `va` table as follows:

``` r

vac = va %>% filter(vehicle_type2 == "Car")
```

The best proxy we have for car type in the open STATS19 data (there are
non-open versions of the data with additional columns) is engine
capacity, measured in cubic centimetres (cc). The distribution of engine
cc’s in the cars dataset created above is shown below.

``` r

summary(vac$engine_capacity_cc)
```

The output shows that there are some impossible values in the data,
likely due to recording error. Very few cars have an engine capacity
above 5 litres (5000 cc) and we can be confident that none have an
engine capacity below 300 cc. We’ll identify these records and remove
them as follows:

We have set the anomolous vehicle size data to NA meaning it will not be
used in the subsequent analysis.
