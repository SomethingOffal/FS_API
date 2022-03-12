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
# -------------------------------------------------------------------------------
#  Packages
package require Ttk
package require Tk
# #############################
bind . <F12> {catch {console show}}

proc csv2tlst {fh} {
    # get the header of the csv file
    set header [gets $fh]
    # set up variables
    set res_lst {}
    #  set up the header at index zero, with ID of zero
    set lheader [lappend lheader "0"]
    set sheader [split $header "," ]
    set header_lst {}
    foreach sh $sheader {
        set header_lst [lappend header_lst $sh]
    }
    set lheader [lappend lheader $header_lst]
    set res_lst [lappend res_lst $lheader]
    ##  get the rest of the file.
    while {![eof $fh]} {
        set tl [gets $fh]
        if {$tl == ""} {
            continue
        }
        set stl [split $tl ","]
        set tlst [lindex $stl 0]
        set idx 1
        set dlst {}
        while {$idx < [llength $stl]} {
            set dlst [lappend dlst [lindex $stl $idx]]
            incr idx
        }
        set tlst [lappend tlst $dlst]
        set res_lst [lappend res_lst $tlst]
    }
    # return the converted list.
    return $res_lst
}

set fo [open "C:/work/Farsite/FS_API/tcl_src/tcl_db.tcl" "w"]
set fh [open "C:/work/Farsite/FS_API/Resources.csv" "r"]
set res_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/refinery_outputs.csv" "r"]
set refo_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/refinery_main_requirements.csv" "r"]
set refreq_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/mining_requirements.csv" "r"]
set mine_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/component_resource_requirements.csv" "r"]
set compres_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/component_main_requirements.csv" "r"]
set compmain_lst [csv2tlst $fh]
close $fh
set fh [open "C:/work/Farsite/FS_API/components.csv" "r"]
set comps_lst [csv2tlst $fh]
close $fh

puts $fo "#! /usr/bin/env wish"
puts $fo "# -------------------------------------------------------------------------------"
puts $fo "# -------------------------------------------------------------------------------"
puts $fo "# --                     Copyright 2022 Sckoarn"
puts $fo "# --                        All Rights Reserved"
puts $fo "#"
puts $fo "#           This program is free software; you can redistribute it and/or modify"
puts $fo "#               it under the following terms:"
puts $fo "#               1) reproduction of this code shall include this header."
puts $fo "#               2) This program is distributed in the hope that it will be useful,"
puts $fo "#               but WITHOUT ANY WARRANTY; without even the implied warranty of"
puts $fo "#               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."
puts $fo "#               3)  You may NOT sell this code, or any part there of."  
puts $fo "#  *** This is a generated file, see make_tcl_lists.tcl for the details   ***"
puts $fo "# -------------------------------------------------------------------------------"
puts $fo ""

puts $fo "namespace eval far_db \{"
puts $fo "    set res_lst \{\}"
puts $fo "    set refo_lst \{\}"
puts $fo "    set refreq_lst \{\}"
puts $fo "    set mine_lst \{\}"
puts $fo "    set compres_lst \{\}"
puts $fo "    set compmain_lst \{\}"
puts $fo "    set comps_lst \{\}"
puts $fo "\}"
puts $fo ""

puts $fo "set far_db::res_lst \{ $res_lst \}"
puts $fo ""
puts $fo "set far_db::refo_lst \{ $refo_lst \}"
puts $fo ""
puts $fo "set far_db::refreq_lst \{ $refreq_lst \}"
puts $fo ""
puts $fo "set far_db::mine_lst \{ $mine_lst \}"
puts $fo ""
puts $fo "set far_db::compres_lst \{ $compres_lst \}"
puts $fo ""
puts $fo "set far_db::compmain_lst \{ $compmain_lst \}"
puts $fo ""
puts $fo "set far_db::comps_lst \{ $comps_lst \}"
puts $fo ""

close $fo

exit
