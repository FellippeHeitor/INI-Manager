# INI-Manager
Library for QB64 for reading from/writing to INI configuration files.

## .ini format
INI files are used to store data required for a program's operation. Modern Windows apps use the Registry to store and retrieve information. However, the .ini method works across platforms and is easy to mantain, besides being human-readable.

### Sample file
Sections are defined by enclosing the section title in [brackets]. Keys are assigned values using the equal sign (Key1=Value1). Quotation marks are allowed to delimit text, but not required. Comments can be added in the beginning of lines or after values, and are started by a semicolon. BASIC-style comments are also allowed, marked with an apostrophe ('):

    ; last modified 1 April 2001 by John Doe
    [owner]
    name="John Doe"
    organization=Acme Widgets Inc. 'we may need to change this later

    [database]
    ; use IP address in case network name resolution is not working
    server=192.0.2.62     
    port=143 ; change responsibly, be careful with conflicts
    file="payroll.dat"


More info at https://en.wikipedia.org/wiki/INI_file

## Library methods

    WriteSetting file$, section$, key$, value$

* file$ = the file name to write to. Can handle multiple .ini files at once. To work with a single file, you only need to pass file$ in the first write operation.
* section$ = the [section] in the ini file where the new key$ will be added or where to move an existing key$.
* key$ = the unique identifier of the value you wish to store.
* value$ = the value to be stored. Numeric values must be converted to strings with STR$() first.

    result$ = ReadSetting$(file$, key$)
    
* result$ = the variable where you'll store the value$ obtained from the file$.
* file$ = the file name to be parsed. To work with a single file, you only need to pass file$ in the first read operation.
* key$ = the key in the file whose value you want to read.
