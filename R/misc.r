# When the package loads
.onAttach <- function (libname, pkgname) {
  # Redefine the 'stata' engine
  knitr::knit_engines$set(stata=stata_engine)

  # Find the Stata executable
  # (find_stata() sets the engine.path chunk option and messages
  #  if no executable is found)
  stataexe <- find_stata()

  # Optimize chunk options
  knitr::opts_chunk$set(error=TRUE, cleanlog=TRUE, comment=NA, noisy=FALSE)

  # Hook to place collected chunk contents in a profile.do file
  stata_collectcode(stataexe)

  packageStartupMessage("The 'stata' engine is ready to use.")
}
