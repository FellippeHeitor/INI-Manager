'INI Manager - demo 2
'
'syntax: var$ = ReadSetting(file$, key$)
'
'An empty result can mean that the key wasn't found
'or that it was empty, as in the example:
'
'    [section]
'    key1=value1
'    key2=
'
'To know what happened, use the global variables IniCODE and IniINFO$
'Reference:
'
'   0 = Read operation successful
'   1 = File not found
'   2 = Empty value
'   3 = Key not found
'   4 = Key updated successfully
'   5 = Orphan key created (outside existing sections)
'   6 = Key updated and moved to new section
'   7 = Key created in existing section
'   8 = Same value passed; no changes applied
'   9 = New section created; key either moved or created
'
'You can also check what type of data was fetched using the variable
'IniDataType. It'll return IniNUMERIC or IniTEXT

PRINT "Analyzing file test.ini"
DO
    INPUT ; "Key to read (nothing to quit): ", key$
    IF LEN(LTRIM$(RTRIM$(key$))) THEN
        a$ = ReadSetting$("test.ini", key$)
        IF IniCODE THEN
            PRINT
            COLOR 15, 4
            PRINT "RETURN CODE: "; IniCODE, IniINFO$
            COLOR 7, 0
        ELSE
            PRINT " = ";
            COLOR 15, 2: PRINT a$: COLOR 7, 0
            IF LEN(IniFoundSection$) THEN PRINT "(found in section " + IniFoundSection$ + ")";
            IF IniDataType = IniNUMERIC THEN 'numeric value
                PRINT " (numeric value)"
            ELSEIF IniDataType = IniTEXT THEN
                PRINT " (text)"
            END IF
        END IF
    ELSE
        PRINT "No input."
        END
    END IF
    PRINT
LOOP

'$include:'ini.bm'
