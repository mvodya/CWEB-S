' Clandestine WEB Server
' CWEB-S by Markus
' https://github.com/Limitedparty/CWEB-S

port$ = "83" ' Server port (default - 80)

_TITLE "CWEB-Server"
COLOR 15

$SCREENHIDE
$CONSOLE
_DEST _CONSOLE

PRINT "CWEB-";: COLOR 12: PRINT "S";: COLOR 15: PRINT " host starting..."

e$ = CHR$(13) + CHR$(10) ' end of line characters

host = _OPENHOST("TCP/IP:" + port$)

IF host THEN
    COLOR 10: PRINT "Server started!";: COLOR 15: PRINT " Listening connections on port " + port$: PRINT ""
    DO
        client = _OPENCONNECTION(host)
        IF client THEN
            COLOR 10: PRINT "Client connected!";: COLOR 15: PRINT " Send data..."
            header$ = ""
            html$ = ""
            path$ = "web"
            type$ = "text/plain"

            GET #client, , getdata$
            PRINT getdata$
            getdata$ = LTRIM$(getdata$)
            l$ = LEFT$(getdata$, INSTR(getdata$, " ") - 1)
            r$ = RIGHT$(getdata$, LEN(getdata$) - LEN(l$))
            m$ = LEFT$(LTRIM$(r$), INSTR(LTRIM$(r$), " ") - 1)
            h$ = LTRIM$(RIGHT$(LTRIM$(r$), LEN(LTRIM$(r$)) - LEN(m$)))
            ' l - m - h

            PRINT "Requested: " + m$
            IF m$ = "/" OR m$ = "" THEN
                path$ = path$ + "/index.html"
            ELSE
                path$ = path$ + m$
            END IF

            filetype$ = RIGHT$(path$, LEN(path$) - INSTR(path$, "."))
            SELECT CASE filetype$
                CASE "html": type$ = "text/html"
                CASE "htm": type$ = "text/html"
                CASE "css": type$ = "text/css"
            END SELECT
            PRINT filetype$


            IF _FILEEXISTS(path$) THEN
                PRINT "OK. Start reading..."
                OPEN path$ FOR INPUT AS #1
                lines = 0
                DO UNTIL EOF(1)
                    LINE INPUT #1, s$
                    html$ = html$ + s$ + e$
                    lines = lines + 1
                LOOP
                CLOSE #1
                header$ = "HTTP/1.1 200 OK" + e$ + "Server: CWEB-S" + e$ + "Content-Language: ru" + e$ + "Content-Type: " + type$ + "; charset=utf-8" + e$ + "Content-Length: " + STR$(LEN(html$)) + e$ + "Connection: close" + e$ + e$ + html$
            ELSE
                PRINT "Error 404. File Not found."
                header$ = "HTTP/1.1 404 OK" + e$ + "Server: CWEB-S" + e$ + "Content-Language: ru" + e$ + "Content-Type: text/html; charset=utf-8" + e$ + "Content-Length: 3" + e$ + "Connection: close" + e$ + e$ + "404"
            END IF

            PRINT "Send aswer.": PRINT ""
            PUT #client, , header$
            CLOSE client
        END IF
        _DELAY 0.01 ' reduce CPU usage
    LOOP
ELSE
    COLOR 12: PRINT "ERROR!";: COLOR 15: PRINT " server can't start on port " + port$
END IF
