# INI-Manager

Library for QB64-PE for reading from and writing to INI configuration files.

## Getting started

    OPTION _EXPLICIT          ' optional
    '$include:'ini.bi'        ' recommended (see below)

    WriteSetting "config.ini", "window", "width", "800"
    PRINT ReadSetting$("config.ini", "window", "width")

    '$include:'ini.bm'

* `ini.bm` goes at the **end** of your program. It is always required.
* `ini.bi` goes at the **top** of your program. It is required with `OPTION _EXPLICIT`, and with QB64-PE 3.14.1 or newer it lets the library report file errors (read-only file, missing folder, locked file...) through `IniCODE` instead of stopping your program with a runtime error. Your own `ON ERROR` handler is kept.

## .ini format

INI files store the settings a program needs. They work across platforms, are easy to maintain and can be read and edited by people.

    ; last modified 1 April 2001 by John Doe
    [owner]
    name="John Doe"
    organization=Acme Widgets Inc. 'we may need to change this later

    [database]
    ; use IP address in case network name resolution is not working
    server=192.0.2.62
    port=143 ; change responsibly, be careful with conflicts
    file="payroll.dat"

* Sections are written as `[section name]`. Keys that come before the first section are *global* keys; use `""` as their section name.
* Keys are assigned with `key=value`. Spaces and tabs around keys and values are ignored. Section and key names are case-insensitive.
* Lines starting with `;` or `#` are comments. Inline comments start with `;`. BASIC-style comments with `'` are also accepted after values if you set `IniAllowBasicComments = -1`. Lines starting with `'` are always comments.
* Values can be put in quotation marks. Everything between the quotes is taken literally, including `;`, `'` and leading/trailing spaces. Write `""` for a quotation mark inside a quoted value: `title="Say ""hi"""`.
* You never need to add quotes yourself: `WriteSetting` adds them (and doubles inner quotes) whenever the value wouldn't read back exactly as written.
* Files with Windows (CRLF) or Unix (LF) line endings are both supported, and the file's own line endings are kept when it is changed. New files use the platform's line endings.

More info at <https://en.wikipedia.org/wiki/INI_file>

## Library methods

After every call, `IniCODE` holds a status code (see the table below), `IniINFO$` describes it, and `IniIsError%%` tells you whether it was an error. `IniLastSection$` and `IniLastKey$` hold the section (as `[name]`) and key of the last operation.

The file name only needs to be passed once: pass `""` in later calls to keep using the same file. Switching between several files is fine.

### Writing

    WriteSetting file$, section$, key$, value$

Writes a new setting to a file, or updates an existing one. The file is created if it doesn't exist.

* `section$` = the section where `key$` goes, with or without brackets. `""` writes a global key.
* `key$` = the setting's name. Keys must be unique within a section, but the same key can exist in different sections.
* `value$` = the value to store. Numbers must be converted to strings first, for example with `STR$()` (leading/trailing spaces are removed). Values can't contain line breaks (error 25).

When an existing key is updated, its spelling, indentation and inline comment are kept. New keys are added after the last key of their section, and new sections are added at the end of the file.

### Reading

    result$ = ReadSetting$(file$, section$, key$)

Returns the value of `key$` in `section$`. An empty result can mean an empty value (`IniCODE = 2`) or an error such as a missing key (`IniCODE = 3`), so check `IniCODE` when it matters.

**Reading keys in sequence:** leave `key$` empty to get the keys of `section$` one by one. With both `section$` and `key$` empty, you get every key in the file. Check `IniLastSection$` and `IniLastKey$` to see which key was returned. When there are no more keys, `ReadSetting$` returns `""` with `IniCODE = 10`, and the next call starts over.

    DO
        value$ = ReadSetting$("config.ini", "", "")
        IF IniCODE = 10 OR IniIsError%% THEN EXIT DO
        PRINT IniLastSection$; " "; IniLastKey$; "="; value$
    LOOP

**Listing sections:**

    DO
        s$ = IniNextSection$("config.ini")
        IF IniCODE = 24 OR IniIsError%% THEN EXIT DO
        PRINT s$
    LOOP

`IniNextSection$` returns sections as `[name]`. After the last one it returns `""` with `IniCODE = 24`, and the next call starts over.

    IniResetIteration

If you leave a loop early, call `IniResetIteration` so the next loop starts from the beginning again.

### Deleting

    IniDeleteSection file$, section$

Deletes a whole section. Comments right before the next section are kept, since they usually describe that section. With `section$ = ""`, deletes all global keys.

    IniDeleteKey file$, section$, key$

Deletes a key from a section.

### Other methods

    IniSortSection file$, section$

Sorts the keys of a section alphabetically (case-insensitive). Comments and blank lines stay where they are.

    IniMoveKey file$, section$, key$, newSection$

Moves `key$` from `section$` to `newSection$`.

    IniClose

Saves any pending changes and forgets the current file. The next call must pass a file name again.

    IniCommit

Saves pending changes to disk. Only needed when `IniDisableAutoCommit` is set (see below).

    IniSetForceReload state

With `state` true (-1), the file is read from disk again on every call, so changes made by other programs are picked up. By default, the file is read once and kept in memory.

    result$ = IniINFO$
    IF IniIsError%% THEN ...

`IniINFO$` describes the last status code. `IniIsError%%` returns -1 (true) if the last operation failed.

### Settings

You can set these variables directly, or use the matching sub (`state` is true (-1) or false (0)).

| Variable | Sub | Default | Effect |
| --- | --- | --- | --- |
| `IniDisableAutoCommit` | `IniSetAutoCommit state` | 0 (auto commit on) | When -1, changes are kept in memory until you call `IniCommit` or `IniClose`, or switch to another file. Useful for many changes in a row. |
| `IniAllowBasicComments` | `IniSetAllowBasicComments state` | 0 | When -1, `'` starts an inline comment after a value. |
| `IniForceReload` | `IniSetForceReload state` | 0 | When -1, the file is read from disk on every call. |
| `IniDisableAddQuotes` | `IniSetAddQuotes state` | 0 (add quotes on) | When -1, values with spaces are written without quotation marks (`path=C:\Program Files\x.bas`). Values that need quotes to read back correctly (with `;`, `'` or a leading `"`) still get them. |

Note that `IniSetAutoCommit` and `IniSetAddQuotes` take the opposite of the variable they set: `IniSetAutoCommit -1` sets `IniDisableAutoCommit = 0`.

## Status codes

| Code | Meaning |
| --- | --- |
| 0 | Operation successful |
| 1 | ERROR: File not found |
| 2 | Empty value |
| 3 | ERROR: Key not found |
| 4 | Key updated |
| 5 | Global key created |
| 7 | Key created in existing section |
| 8 | No changes applied (same value, or a key moved to its own section) |
| 9 | New section created; key created |
| 10 | No more keys |
| 11 | File created; new key added |
| 12 | ERROR: Invalid key (empty, contains `=`, or starts with `;` `#` `'` `[`) |
| 13 | Section deleted |
| 14 | ERROR: Section not found |
| 15 | ERROR: Invalid section (contains `[` or `]`) |
| 17 | ERROR: Empty file |
| 18 | ERROR: No file open |
| 19 | Key deleted |
| 20 | Key moved |
| 21 | ERROR: Invalid file name/path |
| 22 | Section sorted |
| 23 | No changes applied; section already sorted |
| 24 | No more sections |
| 25 | ERROR: Invalid value (line breaks are not allowed) |
| 26 | ERROR: Could not write file |
| 27 | ERROR: Could not read file |

Codes 26 and 27 need `ini.bi` and QB64-PE 3.14.1 or newer. Without them, file errors stop the program with a runtime error.

## iniman

`iniman.bas` is a command-line tool built on the library:

    iniman file.ini -read      [section [key]]
                    -write     section key [value]
                    -move      source_section key destination_section
                    -delete    section [key]
                    -sort      section
                    -sections

The exit code is 0 on success, 1 for bad usage or a missing file, and otherwise the INI Manager error code.

## Tests

    tests/run-tests.sh /path/to/qb64pe

Compiles the demos, `iniman` and the regression tests in `tests/ini-tests.bas`, then runs them. The same script runs on GitHub Actions for every push and pull request.

Check the sample programs (`ini-demo1.bas` to `ini-demo3.bas`) for more usage examples.
