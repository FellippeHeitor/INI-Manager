'INI Manager - demo 3
'
'You can read all keys/values from an .ini file by calling
'ReadSetting with an empty key$ value.
'
DO
    a$ = ReadSetting$("test.ini", "")

    IF IniCODE = 1 THEN PRINT IniINFO$: END 'IniCODE = 1 -> File not found
    IF IniCODE = 10 THEN EXIT DO 'IniCODE = 10 -> No more keys found

    COLOR 7
    PRINT IniFoundSection$;
    COLOR 15: PRINT IniLastKey$;
    COLOR 4: PRINT "=";
    COLOR 2: PRINT a$
LOOP
PRINT "End of file."

'$include:'ini.bm'
