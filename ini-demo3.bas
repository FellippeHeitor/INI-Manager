'INI Manager - demo 3
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
'  10 = No more keys (when you fetch keys sequentially by passing "")
'
'You can also check what type of data was fetched using the variable
'IniDataType. It'll return IniNUMERIC or IniTEXT

PRINT "Analyzing file test.ini"
DO
    r = CSRLIN: c = POS(1)
    LOCATE 25, 1: COLOR 0, 7: PRINT SPACE$(80);: LOCATE 25, 2: PRINT "(no input to quit; = to list all key/value pairs";: COLOR 7, 0
    LOCATE r, c
    INPUT ; "Key to read: ", key$
    IF key$ = "=" THEN
        'list all key/value pairs
        CLS
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
    ELSEIF LEN(LTRIM$(RTRIM$(key$))) > 0 THEN
        a$ = ReadSetting$("test.ini", key$)
        IF IniCODE THEN
            PRINT
            COLOR 15, 4
            PRINT "RETURN CODE: "; IniCODE, IniINFO$
            COLOR 7, 0
        ELSE
            PRINT " = ";
            COLOR 0, 2: PRINT a$;: COLOR 7, 0: PRINT
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
