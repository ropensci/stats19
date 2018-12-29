.onAttach = function(libname, pkgname) {
  msg = paste0(
      "Data provided under OGL v3.0. Cite the source and link to:\n",
      "www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"
    )
  packageStartupMessage(msg)
}
