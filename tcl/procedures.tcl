set RED "\033\[1;31m"
set GREEN "\033\[1;32m"


proc putcolors { someText color } {

        set RESET "\033\[0m"

        puts "${color}\[MEEP\]\ ${someText}${RESET}"

}

proc putmeeps { someText } {        

        puts "\[MEEP\]\ ${someText}"

}
