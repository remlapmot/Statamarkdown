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
