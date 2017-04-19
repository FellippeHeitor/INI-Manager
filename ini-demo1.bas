'INI Manager - demo 1
'
'syntax: WriteSetting file$, section$, key$, value$

'write a new key/value pair to an .ini file or update an existing
'if the file doesn't exist, it'll be created.
'----------------------------------------------------------------

'(brackets in section names are optional; will be added automatically anyway)
WriteSetting "test.ini", "[general]", "version", "Beta 2"

'subsequent calls don't need to mention the file again
WriteSetting "", "general", "date", DATE$
WriteSetting "", "general", "time", TIME$
WriteSetting "", "credits", "author", "Fellippe Heitor"
WriteSetting "", "contact", "email", "fellippe@qb64.org"
WriteSetting "", "contact", "twitter", "@FellippeHeitor"

PRINT "File created/updated. I'll wait for you to check it with your editor of choice."
PRINT "Hit any key to continue..."
a$ = INPUT$(1)

WriteSetting "", "general", "version", "Beta 2 - check the repo"

PRINT "File updated again. Go check it if you will."
END

'$include:'ini.bm'
