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
#  *** This is a generated file, see make_tcl_lists.tcl for the details   ***
# -------------------------------------------------------------------------------

# Create a menu
set m [menu .popupMenu]

bind . <ButtonPress-3> "+select_2 %W %X %Y"

proc select_2 {wid x y} {
    global m
    if {[string first ".note.base.f2.cfr" $wid] == 0 ||
        [string first ".note.base.f2.cdfr" $wid] == 0} {
        set swid [split $wid "."]
        set lb [lindex $swid end]
        #puts $lb
        $m delete 0 end
        $m add command -label "Show Costing" -command "show_costing $wid"
        tk_popup $m $x $y
        #show_costing $wid
    }
}
