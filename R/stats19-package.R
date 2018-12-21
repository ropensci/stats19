.onAttach = function(libname, pkgname) {
  msg = paste0 (
      "Data provided under the conditions of the Open Government License.\n",
      "If you use data from this package, ",
      "mention the source\n(UK Department for Transport), cite the package, and link to:\n",
      "www.nationalarchives.gov.uk/doc/open-government-licence/version/3/."
    )
  packageStartupMessage (msg)
}
