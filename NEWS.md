# Statamarkdown (development version)

* Switch from including the html docs files to including them within the package as precomputed vignettes using Quarto.
* Tweak helpfile examples such that they run within RStudio.
* Add markdown to Suggests dependencies because it is needed for a code path within spinstata (in fact the one in that helpfile).
* Guard two of the helpfile examples for the presence of the rmarkdown package.
* Only activate nocommands, nooutput and quietly when set to `TRUE`
* Add some tests
* Convert documentation to use roxygen2

# Statamarkdown 0.9.7

* Fixed loss of all chunk output when the Stata log does not contain an "end of do-file" line.
* `spinstata()` no longer overwrites its input file; a `statafile` without a `.do` extension is now an error, and the extension check is case-insensitive.
* Fixed a crash in the `collectcode` chunk option when `engine.path` is given as a plain string rather than a list.
* The cleanup of the temporary `profile.do` created by `collectcode` now locates the `knitr::knit()` call on the call stack instead of assuming a hardcoded stack depth, making it robust to changes in knitr's internals, child documents, and different ways of invoking knitr.
* `cleanlog=TRUE` now removes all lines of multi-line loop commands and wrapped (continued) command lines from the output.
* `cleanlog=TRUE` no longer deletes genuine output lines that begin with a decimal point.
* Fixed `spinstata()` block tracking when a marked-up block starts and ends on the same line.
* Fixed an error in `spinstata()` on R >= 4.3 when producing `Rnw` or `Rtex` output.
* `find_stata()` on Windows now stops searching as soon as an executable is found, and the non-existent "StataNow19" directory stub has been removed from the search.
* Removed a duplicated "No Stata executable found" startup message when attaching the package without Stata installed.
* Minor performance improvements: the Stata executable is located once at package load, and per-chunk processing avoids repeated system calls and redundant vector allocations.
* Change of maintainer to Tom Palmer. Many thanks to Doug Hemken for creating and maintaining this amazing package.
* Add the precomputed vignettes to the distributed CRAN package

# Statamarkdown 0.9.6

* `find_stata()` now searches `/Applications/StataNow` on macOS, the StataNow directories on Windows, and two additional installation directories on Linux.
* Fixed bugs in the Windows directory search.
* Fixed help file cross-reference links for the new CRAN standard.

# Statamarkdown 0.9.4

* Updated `find_stata()` for Stata 19 and the SSCC installation path.

# Statamarkdown 0.9.3

* GitHub-only release, not published on CRAN.
* Updated `find_stata()` for Stata 19.

# Statamarkdown 0.9.2

* Cleaner Stata log output, and the log cleanup now accounts for unset chunk options.
* Fixed the `collectcode` chunk option for knitr >= 1.45.
* Package setup switched from `.onAttach()` to `.onLoad()`.
* Cleaned up package dependencies and other CRAN submission issues.

# Statamarkdown 0.8.0

* Thoroughly reworked engine output processing and package loading.
* Edited the vignettes.

# Statamarkdown 0.7.4

* Fixed handling of Stata executable paths containing spaces on macOS and Unix.
* Updated the required knitr version.

# Statamarkdown 0.7.3

* GitHub-only release, not published on CRAN.
* Updated `find_stata()` for Stata 18.
* Improved the help file examples, in particular for `spinstata()`.
* Changed the vignette rendering, and pointed the README to CRAN.

# Statamarkdown 0.7.2

* Better removal of the "Running .../profile.do" line from the log for long installation paths.
* Added further Unix installation paths to `find_stata()`, suggested by Tom Palmer.

# Statamarkdown 0.7.1

* GitHub-only release, not published on CRAN.
* Improved the `find_stata()` directory search on Linux, using `Sys.which()`.

# Statamarkdown 0.7.0

* GitHub-only release, not published on CRAN.
* Updated `find_stata()` for Stata 17, with macOS fixes.
* Fixed a problem with factor variable names.

# Statamarkdown 0.6.0

* GitHub-only release, not published on CRAN.
* Cleaned up messages in "notebook" mode.
* Fixed a macOS path problem, and added StataIC to the macOS search.
* Fixed log cleanup of the "Running ..." line for Stata 16, and the `eval` chunk option.
* Prebuilt the vignettes for the binary version of the package.
* Added Philipp Lepert as a contributor.

# Statamarkdown 0.4.4

* GitHub-only release, not published on CRAN.
* First tagged release: a knitr language engine for Stata with cleaned log output, the `collectcode` chunk option for linking code blocks, `spinstata()` for spinning specially marked-up Stata do-files into reports, and `find_stata()` to locate the Stata executable on Windows, macOS, and Linux.
