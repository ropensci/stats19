devtools::load_all()
a_new = get_stats19(year = 1979, type = "collision", data_dir = tempdir())

a = read_collisions(year = 1979)
