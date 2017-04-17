'INI Manager - demo 3
'
'You can read all keys/values from an .ini file by calling
'ReadSetting with an empty key$ value.
'
DO
    a$ = ReadSetting$("test.ini", "")

    IF IniCODE = 1 THEN PRINT IniINFO$: EXIT DO 'IniCODE = 1 -> File not found
    IF a$ = "" THEN EXIT DO

    COLOR 7
    PRINT IniFoundSection$;
    COLOR 15: PRINT IniLastKey$;
    COLOR 4: PRINT "=";
    COLOR 2: PRINT a$
LOOP

'$include:'ini.bm'
