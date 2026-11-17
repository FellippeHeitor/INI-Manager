'iniman - command line utility to view/edit .ini files
'based on INI Manager - Fellippe Heitor, 2017-2026 - @fellippeheitor
'
'Exit codes: 0 = success, 1 = bad usage or file not found,
'            otherwise the IniCODE of the failed operation (see IniINFO$)
OPTION _EXPLICIT

$CONSOLE:ONLY
_DEST _CONSOLE

'$include:'ini.bi'

DIM SHARED file$
DIM a$, s$, cmd$

IF _COMMANDCOUNT = 0 THEN Usage 1
cmd$ = LCASE$(COMMAND$(1))
IF cmd$ = "/?" OR cmd$ = "-?" OR cmd$ = "-help" OR cmd$ = "/help" OR cmd$ = "--help" OR cmd$ = "-h" THEN Usage 0

file$ = COMMAND$(1)

SELECT CASE LCASE$(COMMAND$(2))
    CASE "", "-read", "read", "-r", "r"
        checkFile
        IF _COMMANDCOUNT = 4 THEN
            a$ = ReadSetting$(file$, COMMAND$(3), COMMAND$(4))
            IF NOT IniIsError%% THEN PRINT a$
        ELSEIF _COMMANDCOUNT <= 3 THEN
            DO
                a$ = ReadSetting$(file$, COMMAND$(3), "")
                IF IniIsError%% OR IniCODE = 10 THEN EXIT DO
                PRINT IniLastSection$; " "; IniLastKey$; "="; a$
            LOOP
        ELSE
            Usage 1
        END IF
    CASE "-write", "write", "-w", "w"
        IF _COMMANDCOUNT < 4 OR _COMMANDCOUNT > 5 THEN Usage 1
        resolveNewFile
        WriteSetting file$, COMMAND$(3), COMMAND$(4), COMMAND$(5)
        IF NOT IniIsError%% THEN PRINT ReadSetting$(file$, COMMAND$(3), COMMAND$(4))
    CASE "-delete", "delete", "-d", "d"
        checkFile
        IF _COMMANDCOUNT = 3 THEN
            IniDeleteSection file$, COMMAND$(3)
        ELSEIF _COMMANDCOUNT = 4 THEN
            IniDeleteKey file$, COMMAND$(3), COMMAND$(4)
        ELSE
            Usage 1
        END IF
    CASE "-sort", "sort", "-s", "s"
        checkFile
        IF _COMMANDCOUNT <> 3 THEN Usage 1
        IniSortSection file$, COMMAND$(3)
    CASE "-move", "move", "-m", "m"
        checkFile
        IF _COMMANDCOUNT <> 5 THEN Usage 1
        IniMoveKey file$, COMMAND$(3), COMMAND$(4), COMMAND$(5)
    CASE "-sections", "sections", "-se", "se"
        checkFile
        IF _COMMANDCOUNT <> 2 THEN Usage 1
        DO
            s$ = IniNextSection$(file$)
            IF IniIsError%% OR IniCODE = 24 THEN EXIT DO
            PRINT s$
        LOOP
    CASE ELSE
        Usage 1
END SELECT

IF IniIsError%% THEN
    PRINT IniINFO$
    SYSTEM IniCODE
END IF
SYSTEM 0

SUB Usage (exitCode)
    PRINT "iniman - INI manager"
    PRINT "by Fellippe Heitor, 2017-2026"
    PRINT
    PRINT "Usage:"
    PRINT
    PRINT "    iniman file.ini -read      [section [key]]"
    PRINT "                    -write     section key [value]"
    PRINT "                    -move      source_section key destination_section"
    PRINT "                    -delete    section [key]"
    PRINT "                    -sort      section"
    PRINT "                    -sections"
    PRINT
    PRINT "Use "; CHR$(34); CHR$(34); " as the section name for keys outside any section."
    PRINT "If a section or key name contains spaces, enclose it in quotation marks."
    PRINT
    PRINT "Exit code: 0 on success, 1 for bad usage or file not found,"
    PRINT "otherwise the INI Manager error code."
    SYSTEM exitCode
END SUB

SUB checkFile
    'Accepts the file name with or without the .ini extension
    IF _FILEEXISTS(file$) THEN EXIT SUB
    IF _FILEEXISTS(file$ + ".ini") THEN file$ = file$ + ".ini": EXIT SUB
    PRINT "File not found."
    SYSTEM 1
END SUB

SUB resolveNewFile
    'Existing files are used as named; new files get .ini if they have no extension
    DIM i&
    IF _FILEEXISTS(file$) THEN EXIT SUB
    IF _FILEEXISTS(file$ + ".ini") THEN file$ = file$ + ".ini": EXIT SUB
    i& = _INSTRREV(file$, ".")
    IF i& < _INSTRREV(file$, "/") OR i& < _INSTRREV(file$, "\") OR i& = 0 THEN file$ = file$ + ".ini"
END SUB

'$include:'ini.bm'
