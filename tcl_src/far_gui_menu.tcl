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
#           Description: This file contains menue for the tool
#               
#
# -------------------------------------------------------------------------------

set mbar [menu .mu]
. configure -menu .mu
menu $mbar.f1
$mbar add cascade -menu $mbar.f1 -label File -underline 0
$mbar.f1 add command -label Exit -command {user_exit} -background #ffcccc

menu $mbar.f2
$mbar add cascade -menu $mbar.f2 -label Dev -underline 0
$mbar.f2 add command -label "Source User" -command {source "$sys::cdir/user_procs.tcl"} -background #ffffff
$mbar.f2 add command -label "Source Far" -command {source "$sys::cdir/far_procs.tcl"} -background #ffffff
$mbar.f2 add command -label "Source Menue" -command {source "$sys::cdir/far_gui_menu.tcl"} -background #ffffff
