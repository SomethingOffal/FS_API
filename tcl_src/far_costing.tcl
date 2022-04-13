#! /usr/bin/env wish
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# --                     Copyright 2022 Sckoarn
# --                        All Rights Reserved
#
#           This program is free software; you can redistribute it and/or modify
#               it under the following terms:
#               1) reproduction of this code shall include this header.
#               2) This program is distributed in the hope that it will be useful,
#               but WITHOUT ANY WARRANTY; without even the implied warranty of
#               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#               3)  You may NOT sell this code, or any part there of.  
#
#           Description:  global name spaces
#
# -------------------------------------------------------------------------------

# #######################################################
#   Refining costing dump.
proc show_costing {} {

    # if costing window exists destroy it
    if {[winfo exists .cost]} {
        destroy .cost
    }
    toplevel .cost
    wm title .cost "Costing Window"
    
    
}