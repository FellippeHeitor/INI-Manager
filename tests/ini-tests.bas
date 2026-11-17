'INI Manager regression tests
'Run from the tests folder. Exit code = number of failed checks.
$CONSOLE:ONLY
OPTION _EXPLICIT
'$include:'../ini.bi'

DIM SHARED Passed&, Failed&, LastErr&
DIM SHARED LF$, CRLF$, T$
DIM a$, b$, f$, i&, n&, s$

LF$ = CHR$(10): CRLF$ = CHR$(13) + CHR$(10)
T$ = "_tmp/"

ON ERROR GOTO UnexpectedError 'also proves the library keeps the caller's handler

IF NOT _DIREXISTS("_tmp") THEN MKDIR "_tmp"

'------------------------------------------------------------ file safety
Section "IniClose after reading leaves the file untouched"
WriteRaw T$ + "close1.ini", "[a]" + LF$ + "k=1" + LF$
a$ = ReadSetting$(T$ + "close1.ini", "a", "k")
IniClose
Check "content", ReadRaw$(T$ + "close1.ini"), "[a]" + LF$ + "k=1" + LF$

Section "IniClose never writes one file's content into another"
WriteRaw T$ + "close2a.ini", "[a]" + LF$ + "k=1" + LF$
WriteRaw T$ + "close2b.ini", "[b]" + LF$ + "z=9" + LF$
WriteSetting T$ + "close2a.ini", "a", "k", "2"
a$ = ReadSetting$(T$ + "close2b.ini", "b", "z")
IniClose
Check "a updated", ReadRaw$(T$ + "close2a.ini"), "[a]" + LF$ + "k=2" + LF$
Check "b untouched", ReadRaw$(T$ + "close2b.ini"), "[b]" + LF$ + "z=9" + LF$

Section "No file handles are kept open"
WriteSetting T$ + "handles.ini", "s", "k", "v"
a$ = ReadSetting$(T$ + "handles.ini", "s", "k")
LastErr& = 0
OPEN T$ + "user.txt" FOR OUTPUT AS #1
PRINT #1, "hello";
CLOSE #1
CheckN "OPEN AS #1 works", LastErr&, 0

Section "IniDeleteSection on a missing global section"
WriteRaw T$ + "delglob.ini", "[a]" + LF$ + "k=1" + LF$
IniDeleteSection T$ + "delglob.ini", ""
CheckN "code", IniCODE, 14
Check "content", ReadRaw$(T$ + "delglob.ini"), "[a]" + LF$ + "k=1" + LF$

Section "Write errors are reported, not fatal"
LastErr& = 0
WriteSetting T$ + "no/such/folder/x.ini", "s", "k", "v"
CheckN "code", IniCODE, 26
CheckN "no runtime error", LastErr&, 0
CheckN "temp file cleaned", _FILEEXISTS(T$ + "no/such/folder/x.ini.inimgr.tmp"), 0
$IF WIN THEN
$ELSE
    Section "Read-only file"
    WriteRaw T$ + "ro.ini", "[s]" + LF$ + "k=1" + LF$
    SHELL _HIDE "chmod 444 " + T$ + "ro.ini"
    a$ = ReadSetting$(T$ + "ro.ini", "s", "k")
    Check "readable", a$, "1"
    WriteSetting T$ + "ro.ini", "s", "k", "2"
    CheckN "write refused", IniCODE, 26
    Check "memory still matches disk", ReadSetting$(T$ + "ro.ini", "s", "k"), "1"
    Check "file unchanged", ReadRaw$(T$ + "ro.ini"), "[s]" + LF$ + "k=1" + LF$
    SHELL _HIDE "chmod 644 " + T$ + "ro.ini"
$END IF

Section "Caller's file$ variable is not modified"
WriteRaw T$ + "argmut.ini", "[s]" + LF$ + "k=1" + LF$
a$ = ReadSetting$(T$ + "argmut.ini", "s", "k")
f$ = ""
IniSetForceReload -1
a$ = ReadSetting$(f$, "s", "k")
WriteSetting f$, "s", "k", "3"
IniSetForceReload 0
Check "f$", f$, ""

'------------------------------------------------------------ values
Section "Values read back exactly as written"
RoundTrip "a;b"
RoundTrip "it's"
RoundTrip "say " + CHR$(34) + "hi" + CHR$(34) + " now"
RoundTrip CHR$(34) + "quoted" + CHR$(34)
RoundTrip "a" + CHR$(34) + "b"
RoundTrip "tab" + CHR$(9) + "inside"
RoundTrip "[1, 2]"
RoundTrip "#ff0000"
RoundTrip "x=y"
WriteSetting T$ + "values.ini", "s", "spaces", "   padded   "
Check "outer spaces trimmed", ReadSetting$(T$ + "values.ini", "s", "spaces"), "padded"
WriteSetting T$ + "values.ini", "s", "num", STR$(42)
Check "STR$() number", ReadSetting$(T$ + "values.ini", "s", "num"), "42"
WriteSetting T$ + "values.ini", "s", "empty", ""
a$ = ReadSetting$(T$ + "values.ini", "s", "empty")
CheckN "empty value code", IniCODE, 2

Section "Line breaks in values are rejected"
b$ = ReadRaw$(T$ + "values.ini")
WriteSetting T$ + "values.ini", "s", "inj", "x" + LF$ + "[admin]" + LF$ + "role=root"
CheckN "code", IniCODE, 25
Check "file unchanged", ReadRaw$(T$ + "values.ini"), b$

Section "Reading values"
WriteRaw T$ + "read.ini", "top=[1,2]" + LF$ + "# hash comment" + LF$ + LF$ + "[S]" + LF$ + "a=1" + LF$ + "; see [notes]" + LF$ + "b=2" + LF$ + "q=" + CHR$(34) + "a;b" + CHR$(34) + " ; c" + LF$ + "  c" + CHR$(9) + "=" + CHR$(9) + "3 ; three" + LF$ + CHR$(9) + "d=4" + LF$ + "basic=5 'five" + LF$ + "dq=" + CHR$(34) + "x" + CHR$(34) + CHR$(34) + "y" + CHR$(34) + LF$
Check "global value with brackets", ReadSetting$(T$ + "read.ini", "", "top"), "[1,2]"
Check "key after comment with [", ReadSetting$(T$ + "read.ini", "s", "b"), "2"
Check "quoted value with ;", ReadSetting$(T$ + "read.ini", "s", "q"), "a;b"
Check "tabs around =", ReadSetting$(T$ + "read.ini", "s", "c"), "3"
Check "tab indentation", ReadSetting$(T$ + "read.ini", "s", "d"), "4"
Check "doubled quotes", ReadSetting$(T$ + "read.ini", "s", "dq"), "x" + CHR$(34) + "y"
Check "basic comment off", ReadSetting$(T$ + "read.ini", "s", "basic"), "5 'five"
IniAllowBasicComments = -1
Check "basic comment on", ReadSetting$(T$ + "read.ini", "s", "basic"), "5"
IniAllowBasicComments = 0
Check "case-insensitive", ReadSetting$(T$ + "read.ini", "[s]", "A"), "1"
Check "IniLastSection$ as in file", IniLastSection$, "[S]"
a$ = ReadSetting$(T$ + "read.ini", "s", "nope")
CheckN "missing key", IniCODE, 3
a$ = ReadSetting$(T$ + "read.ini", "nope", "a")
CheckN "missing section", IniCODE, 14
a$ = ReadSetting$(T$ + "read.ini", "s", "# hash comment")
CheckN "comment is not a key", IniCODE, 12
a$ = ReadSetting$(T$ + "missing.ini", "s", "a")
CheckN "missing file", IniCODE, 1
WriteRaw T$ + "empty.ini", "  " + LF$
a$ = ReadSetting$(T$ + "empty.ini", "s", "a")
CheckN "empty file", IniCODE, 17

'------------------------------------------------------------ writing
Section "Updating keeps spelling, spacing and comments"
WriteRaw T$ + "upd.ini", "[db]" + LF$ + "  Port = 143 ; careful" + LF$ + "name=" + CHR$(34) + "a b" + CHR$(34) + " ; n" + LF$
WriteSetting T$ + "upd.ini", "DB", "port", "8080"
CheckN "code", IniCODE, 4
WriteSetting T$ + "upd.ini", "db", "name", "x"
Check "content", ReadRaw$(T$ + "upd.ini"), "[db]" + LF$ + "  Port = 8080 ; careful" + LF$ + "name=x ; n" + LF$
WriteSetting T$ + "upd.ini", "db", "name", "x"
CheckN "same value", IniCODE, 8

Section "New keys and sections"
WriteRaw T$ + "add.ini", "[a]" + LF$ + "x=1" + LF$ + LF$ + "; about b" + LF$ + "[b]" + LF$ + "y=2"
WriteSetting T$ + "add.ini", "a", "x2", "1"
CheckN "existing section code", IniCODE, 7
WriteSetting T$ + "add.ini", "b", "y2", "2"
WriteSetting T$ + "add.ini", "c", "z", "3"
CheckN "new section code", IniCODE, 9
WriteSetting T$ + "add.ini", "", "g", "0"
CheckN "global code", IniCODE, 5
WriteSetting T$ + "add.ini", "", "g2", "0"
Check "content", ReadRaw$(T$ + "add.ini"), "g=0" + LF$ + "g2=0" + LF$ + LF$ + "[a]" + LF$ + "x=1" + LF$ + "x2=1" + LF$ + LF$ + "; about b" + LF$ + "[b]" + LF$ + "y=2" + LF$ + "y2=2" + LF$ + LF$ + "[c]" + LF$ + "z=3" + LF$

Section "New file"
WriteSetting T$ + "new.ini", "general", "version", "2"
CheckN "code", IniCODE, 11
$IF WIN THEN
    Check "content", ReadRaw$(T$ + "new.ini"), "[general]" + CRLF$ + "version=2" + CRLF$
$ELSE
    Check "content", ReadRaw$(T$ + "new.ini"), "[general]" + LF$ + "version=2" + LF$
$END IF

Section "CRLF files stay CRLF"
WriteRaw T$ + "crlf.ini", "[a]" + CRLF$ + "x=1" + CRLF$
WriteSetting T$ + "crlf.ini", "a", "x", "2"
WriteSetting T$ + "crlf.ini", "a", "y", "3"
WriteSetting T$ + "crlf.ini", "b", "z", "4"
Check "content", ReadRaw$(T$ + "crlf.ini"), "[a]" + CRLF$ + "x=2" + CRLF$ + "y=3" + CRLF$ + CRLF$ + "[b]" + CRLF$ + "z=4" + CRLF$
Check "read", ReadSetting$(T$ + "crlf.ini", "a", "y"), "3"

Section "Deleting"
WriteRaw T$ + "del.ini", "[a]" + LF$ + "x=1" + LF$ + "y=2" + LF$ + LF$ + "[b]" + LF$ + "z=3" + LF$ + LF$ + "; about c" + LF$ + "[c]" + LF$ + "w=4" + LF$ + LF$
IniDeleteKey T$ + "del.ini", "a", "X"
CheckN "key code", IniCODE, 19
IniDeleteKey T$ + "del.ini", "a", "nope"
CheckN "missing key", IniCODE, 3
IniDeleteSection T$ + "del.ini", "b"
CheckN "section code", IniCODE, 13
Check "middle section", ReadRaw$(T$ + "del.ini"), "[a]" + LF$ + "y=2" + LF$ + LF$ + "; about c" + LF$ + "[c]" + LF$ + "w=4" + LF$ + LF$
IniDeleteSection T$ + "del.ini", "c"
Check "last section", ReadRaw$(T$ + "del.ini"), "[a]" + LF$ + "y=2" + LF$ + LF$ + "; about c" + LF$

Section "Sorting"
WriteRaw T$ + "sort.ini", "[s]" + LF$ + "; header" + LF$ + "b=3" + LF$ + "a2=2" + LF$ + "B2=4" + LF$ + "a=" + CHR$(34) + "x y" + CHR$(34) + " ; c" + LF$ + "[t]" + LF$ + "k=1"
IniSortSection T$ + "sort.ini", "s"
CheckN "code", IniCODE, 22
Check "content", ReadRaw$(T$ + "sort.ini"), "[s]" + LF$ + "; header" + LF$ + "a=" + CHR$(34) + "x y" + CHR$(34) + " ; c" + LF$ + "a2=2" + LF$ + "b=3" + LF$ + "B2=4" + LF$ + "[t]" + LF$ + "k=1"
IniSortSection T$ + "sort.ini", "s"
CheckN "already sorted", IniCODE, 23
WriteRaw T$ + "sort2.ini", "[empty]" + LF$ + "[t]" + LF$ + "k=1" + LF$
IniSortSection T$ + "sort2.ini", "empty"
CheckN "empty section", IniCODE, 23

Section "Moving"
WriteRaw T$ + "move.ini", "[a]" + LF$ + "k=v w" + LF$ + "[b]" + LF$ + "j=1" + LF$
IniMoveKey T$ + "move.ini", "a", "k", "b"
CheckN "code", IniCODE, 20
Check "content", ReadRaw$(T$ + "move.ini"), "[a]" + LF$ + "[b]" + LF$ + "j=1" + LF$ + "k=" + CHR$(34) + "v w" + CHR$(34) + LF$
IniMoveKey T$ + "move.ini", "b", "k", "B"
CheckN "same section", IniCODE, 8
Check "key kept", ReadSetting$(T$ + "move.ini", "b", "k"), "v w"
IniMoveKey T$ + "move.ini", "a", "nope", "b"
CheckN "missing key", IniCODE, 3

Section "IniDisableAutoCommit"
WriteRaw T$ + "batch.ini", "[s]" + LF$ + "k=1" + LF$
WriteRaw T$ + "batch2.ini", "[s]" + LF$ + "k=1" + LF$
IniDisableAutoCommit = -1
WriteSetting T$ + "batch.ini", "s", "k", "2"
WriteSetting T$ + "batch.ini", "s", "j", "3"
Check "not on disk yet", ReadRaw$(T$ + "batch.ini"), "[s]" + LF$ + "k=1" + LF$
Check "visible in memory", ReadSetting$(T$ + "batch.ini", "s", "k"), "2"
IniCommit
Check "committed", ReadRaw$(T$ + "batch.ini"), "[s]" + LF$ + "k=2" + LF$ + "j=3" + LF$
WriteSetting T$ + "batch.ini", "s", "k", "5"
a$ = ReadSetting$(T$ + "batch2.ini", "s", "k") 'switching files saves pending changes
Check "saved on file switch", ReadSetting$(T$ + "batch.ini", "s", "k"), "5"
WriteSetting T$ + "batch.ini", "s", "k", "6"
IniClose
Check "saved on IniClose", ReadRaw$(T$ + "batch.ini"), "[s]" + LF$ + "k=6" + LF$ + "j=3" + LF$
IniDisableAutoCommit = 0

Section "IniForceReload"
WriteRaw T$ + "reload.ini", "[s]" + LF$ + "k=1" + LF$
a$ = ReadSetting$(T$ + "reload.ini", "s", "k")
WriteRaw T$ + "reload.ini", "[s]" + LF$ + "k=2" + LF$
Check "cached", ReadSetting$(T$ + "reload.ini", "s", "k"), "1"
IniSetForceReload -1
Check "reloaded", ReadSetting$(T$ + "reload.ini", "s", "k"), "2"
IniSetForceReload 0

'------------------------------------------------------------ iteration
Section "Reading all keys"
WriteRaw T$ + "iter.ini", "; file comment" + LF$ + "g=0" + LF$ + "[database]" + LF$ + "; use IP address" + LF$ + "; really" + LF$ + "server=1.2.3.4" + LF$ + "port=143 ; ok" + LF$ + LF$ + "[owner]" + LF$ + "name=" + CHR$(34) + "John Doe" + CHR$(34) + LF$
s$ = ""
DO
    a$ = ReadSetting$(T$ + "iter.ini", "", "")
    IF IniCODE = 10 OR IniIsError%% THEN EXIT DO
    s$ = s$ + IniLastSection$ + IniLastKey$ + "=" + a$ + "|"
LOOP
Check "whole file", s$, "[]g=0|[database]server=1.2.3.4|[database]port=143|[owner]name=John Doe|"
CheckN "end code", IniCODE, 10
s$ = ""
DO
    a$ = ReadSetting$(T$ + "iter.ini", "database", "")
    IF IniCODE = 10 OR IniIsError%% THEN EXIT DO
    s$ = s$ + IniLastKey$ + "|"
LOOP
Check "one section", s$, "server|port|"
a$ = ReadSetting$(T$ + "iter.ini", "database", "")
a$ = ReadSetting$(T$ + "iter.ini", "database", "")
CheckN "restarts after end", IniCODE, 0
Check "restarts after end, key", IniLastKey$, "port"
IniResetIteration
a$ = ReadSetting$(T$ + "iter.ini", "database", "")
Check "IniResetIteration", IniLastKey$, "server"
WriteSetting T$ + "iter.ini", "database", "server", "5.6.7.8"
a$ = ReadSetting$(T$ + "iter.ini", "database", "")
Check "continues after a write", IniLastKey$, "port"
a$ = ReadSetting$(T$ + "iter.ini", "nope", "")
CheckN "missing section", IniCODE, 14

Section "Listing sections"
s$ = ""
DO
    a$ = IniNextSection$(T$ + "iter.ini")
    IF IniCODE = 24 OR IniIsError%% THEN EXIT DO
    s$ = s$ + a$ + "|"
LOOP
Check "all sections", s$, "[database]|[owner]|"
CheckN "end returns empty", LEN(a$), 0
a$ = IniNextSection$(T$ + "iter.ini")
Check "starts over", a$, "[database]"
IniResetIteration

'------------------------------------------------------------ done
IniClose
KILL T$ + "*"
RMDIR "_tmp"

PRINT
PRINT Passed&; "passed,"; Failed&; "failed"
SYSTEM Failed&

UnexpectedError:
LastErr& = ERR
PRINT "  UNEXPECTED RUNTIME ERROR"; ERR; "on line"; _ERRORLINE
Failed& = Failed& + 1
RESUME NEXT

SUB Section (title$)
    PRINT
    PRINT title$
END SUB

SUB Check (title$, got$, expected$)
    IF got$ = expected$ THEN
        Passed& = Passed& + 1
    ELSE
        Failed& = Failed& + 1
        PRINT "  FAIL: "; title$
        PRINT "    expected: "; Visible$(expected$)
        PRINT "    got:      "; Visible$(got$)
    END IF
END SUB

SUB CheckN (title$, got&, expected&)
    Check title$, LTRIM$(STR$(got&)), LTRIM$(STR$(expected&))
END SUB

SUB RoundTrip (v$)
    WriteSetting T$ + "values.ini", "s", "k", v$
    Check "round trip " + Visible$(v$), ReadSetting$(T$ + "values.ini", "s", "k"), v$
END SUB

FUNCTION Visible$ (s$)
    DIM i&, c%, r$
    FOR i& = 1 TO LEN(s$)
        c% = ASC(s$, i&)
        SELECT CASE c%
            CASE 10: r$ = r$ + "\n"
            CASE 13: r$ = r$ + "\r"
            CASE 9: r$ = r$ + "\t"
            CASE ELSE: r$ = r$ + CHR$(c%)
        END SELECT
    NEXT
    Visible$ = "[" + r$ + "]"
END FUNCTION

SUB WriteRaw (f$, content$)
    DIM n&
    IF _FILEEXISTS(f$) THEN KILL f$
    n& = FREEFILE
    OPEN f$ FOR BINARY AS #n&
    PUT #n&, 1, content$
    CLOSE #n&
END SUB

FUNCTION ReadRaw$ (f$)
    DIM n&, s$
    n& = FREEFILE
    OPEN f$ FOR BINARY ACCESS READ AS #n&
    s$ = SPACE$(LOF(n&))
    GET #n&, 1, s$
    CLOSE #n&
    ReadRaw$ = s$
END FUNCTION

'$include:'../ini.bm'
