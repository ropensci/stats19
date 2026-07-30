.onAttach = function(libname, pkgname) {
  msg = paste0(
    "Data provided under OGL v3.0.\n",
    "To cite stats19 in publications: Lovelace et al. (2019) JOSS <doi:10.21105/joss.01181>.\n",
    "Run citation(\"stats19\") for BibTeX entry."
  )
  packageStartupMessage(msg)
}
