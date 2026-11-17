# Changelog

## v2.0

The library was rewritten around a single line-by-line parser. The API is the same, but please check **Behavior changes** below.

### Fixed
- `IniClose` could empty a file you had only read, or overwrite it with the contents of another file.
- `IniClose` didn't actually close the file.
- The library kept files open between calls, so programs using fixed file numbers (`OPEN ... AS #1`) could crash with "File already open".
- `IniDeleteSection file$, ""` deleted the first characters of the file when there were no global keys.
- Values containing `;`, `'` or `"` didn't read back as written.
- Values containing line breaks could add new sections and keys to the file. They're now rejected (error 25).
- A comment containing `[` inside a section hid the keys that followed it.
- Keys indented with tabs, or with tabs around `=`, weren't found.
- `IniSortSection` was case-sensitive and put `a2` before `a`. It also crashed on empty sections.
- `IniMoveKey` deleted the key when moving it to its own section.
- Read-only files couldn't be read.
- A failed save could be reported as "New section created; existing key moved".
- Pending changes (`IniDisableAutoCommit`) were lost when switching to another file.
- The library changed the caller's `file$` variable in some cases.
- `iniman` returned non-zero exit codes on success, zero on errors, and always added `.ini` to the file name when writing.

### Added
- File errors are reported as error 26 (write) or 27 (read) instead of stopping the program, when `ini.bi` is included and QB64-PE is 3.14.1 or newer.
- Files are saved through a temporary file, so a failed save never leaves a half-written file behind. Read-only files are never replaced.
- `IniIsError%%`, `IniResetIteration`.
- Lines starting with `#` are comments.
- Inside quoted values, `""` stands for one quotation mark.
- Updating a key keeps its spelling, indentation and inline comment.
- Regression tests and a GitHub Actions workflow.

### Behavior changes
- `IniNextSection$` now works like sequential `ReadSetting$`: it returns one section per call, then `""` with `IniCODE = 24`. Before, the last section came together with code 24. Loops that print first and check the code afterwards will now print an extra empty line; check the code before using the result (see README).
- Sequential reading picks up where it left off even after the file changes, and `IniResetIteration` starts it over.
- New global keys go after the existing global keys (before, they went to the top of the file).
- `IniSortSection` keeps comments and blank lines in place and sorts global keys when `section$` is `""`.
- Section names are trimmed inside the brackets, so `[ general ]` matches `general`.
- Keys may contain `[` and `]` (but not start with `[`).
- Internal variables were renamed with an `Ini` prefix; `LoadedFiles$`, `currentIniFileName$`, `currentIniFileLOF`, `IniSectionData$`, `IniPosition` and `IniNewFile$` no longer exist. `IniNextKey$` was removed.
