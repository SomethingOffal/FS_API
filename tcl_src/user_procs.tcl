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
#           Description:  This file contains most of the procs that access the 
#               User Status tab.
#
# -------------------------------------------------------------------------------
# for reloading / sourcing more than once. ...
#set fts [font names]
#set is_f [lsearch $fts font_info_txt]
#if {$is_f  >= 0} {
#    font delete font_info_txt font_info_res
#}
#font create font_info_txt -family Helvetica -size 8
#font create font_info_res -family Helvetica -size 11 -weight bold

package require csv

# #######################################
#   extract the clock value from the
#    farsite time string passed
proc get_time_val {tim} {
    #puts $tim
    set stim [split $tim "T"]
    set mdate [lindex $stim 0]
    set mtime [lindex [split [lindex $stim 1] "."] 0]
    set ttime $mdate
    append ttime ",$mtime"
#    set timed [clock scan $ttime -format {%Y-%m-%d,%H:%M:%S} -timezone .015]
    set timed [clock scan $ttime -format {%Y-%m-%d,%H:%M:%S}]
        
    return $timed
}

# #################################
#   pad a string with passed value  space by default.
proc pad_str {str len {pad " "}} {
    set rtn $str
    set slen [string length $str]
    
    for {set i $slen} {$i <= $len} {incr i} {
        set rtn [append rtn $pad]
    }
    return $rtn
}

# ############################################
#   get the list of materials and quantity
#      return list of list  {code name Quant market}
proc get_uzr_mats_inv {} {
    set header [split [lindex $ulsts::ureso_lst 0] ","]
    #foreach h $header {
    #    puts $h
    #}
    set ridx [lsearch -exact $header resourceId]
    set dlst [lrange $ulsts::ureso_lst 1 end]
    set rtn {}
    foreach m $dlst {
        # user info
        set sm [split $m ","]
        #general info
        set mat [get_mat_code [lindex $sm $ridx]]
        # Access the returned data code and name.
        set mat1 [lindex [lindex $mat 0] 1]
        set ttxt [lindex $mat1 0]
        append ttxt " " [lindex $mat1 1]
        set ttxt [pad_str $ttxt 20]
        append ttxt "Quant: " [lindex $sm 3]  
        set ttxt [pad_str $ttxt 36]
        append ttxt "Loc: " [lindex $sm 6]
        set rtn [lappend rtn $ttxt]
        #puts $ttxt
    }
    return $rtn
}
# ##############################################
#   load the user info
#
proc load_uzr_info {} {
    
    set ulsts::sec_lst {}
    set ulsts::secd_lst {}
    set ulsts::ship_lst {}
    set ulsts::shipd_lst {}
    set ulsts::acc_lst {}
    set ulsts::bp_lst {}
    
    
    set idx 0
    foreach f $dfiles::uflst {
        if {[file exists $f] == 1 } {
            set fh [open "$f" "r"]
            set tlst {}
            while {![eof $fh]} {
                set s [gets $fh]
                if {$s == ""} {continue}
                set tlst [lappend tlst $s]
            }
            #puts $tlst
            switch $idx {
                0 {
                    foreach i $tlst {
                        set ulsts::sec_lst [lappend ulsts::sec_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                1 {
                    foreach i $tlst {
                        set ulsts::secd_lst [lappend ulsts::secd_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                2 {
                    foreach i $tlst {
                        set ulsts::ship_lst [lappend ulsts::ship_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                3 {
                    foreach i $tlst {
                        set ulsts::shipd_lst [lappend ulsts::shipd_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                4 {
                    foreach i $tlst {
                        set ulsts::acc_lst [lappend ulsts::acc_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                5 {
                    foreach i $tlst {
                        set ulsts::bp_lst [lappend ulsts::pb_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                6 {
                    foreach i $tlst {
                        set ulsts::mod_lst [lappend ulsts::mod_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                7 {
                    foreach i $tlst {
                        set ulsts::ureso_lst [lappend ulsts::ureso_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                8 {
                    foreach i $tlst {
                        set ulsts::comps_lst [lappend ulsts::comps_lst $i]
                    }
                    set dfiles::info_lsts [lappend dfiles::info_lsts $tlst]
                }
                default {puts "Error File index out side  range."}
            }
            incr idx
        }
    }
    
    #foreach s $dfiles::info_lsts {
    #    puts $s
    #}
    
}

# ############################################
#  fill the planet list box
proc fill_planet_listbox {fr} {
    
    $fr delete 0 end
    update
    set header [lindex $ulsts::sec_lst 0]
    set sheader [csv::split -alternate $header]
    #foreach s $sheader {
    #    puts $s
    #}
    set pidx [lsearch $sheader "planet.name"]
    #puts $pidx
    set dlst [lrange $ulsts::sec_lst 1 end]
    set idx 0
    set tlst {}
    foreach p $dlst {
        set pid [lindex [csv::split -alternate $p] $pidx]
        if {[lsearch $tlst $pid] >= 0} {
            continue
        } else {
            if {$pid < 0} {
                continue
            } else {
                set tlst [lappend tlst $pid]
                $fr insert end $pid
            }
        }
    }
}

# ############################################
#   fill sector list box
proc fill_sector_listbox {fr} {
    
    $fr delete 0 end
    update
    set header [lindex $ulsts::sec_lst 0]
    set sheader [csv::split -alternate $header]
    # get some indexs
    set sidx [lsearch -exact $sheader "name"]
    set rsidx [lsearch -exact $sheader "resources.spots"]
    set rdidx [lsearch -exact $sheader "resources.deposits"]
    set rsize [lsearch -exact $sheader "size"]
    # get data section.
    set dlst [lrange $ulsts::sec_lst 1 end]
    set idx 0
    foreach s $dlst {
        set pid [lindex [csv::split -alternate $s] $sidx]
        #  skip if blank
        if {$pid < 0} {
            continue
        } else {
            $fr insert end $pid
            # update user info as we go by
            set sz [lindex [csv::split -alternate $s] $rsize]
            switch $sz {
                "L" {incr refine::lsec_cnt}
                "M" {incr refine::msec_cnt}
                "S" {incr refine::ssec_cnt}
                default {"Error:  unknown size from sec_lst"}
            }
            # create list of mineable materials
            set tlst {}
            set tres [string trim [lindex [csv::split -alternate $s] $rsidx] "\[\]"]
            set tres [split $tres ","]
            foreach r $tres {
                set is_on [lsearch $ulsts::mine_reso_lst [string trim $r]]
                if {$is_on < 0} {
                    set ulsts::mine_reso_lst [lappend ulsts::mine_reso_lst [string trim $r]]
                }
            }
            #puts "Spots: $tres"
            set tres [string trim [lindex [csv::split -alternate $s] $rdidx] "\[\]"]
            set tres [split $tres ","]
            foreach r $tres {
                set is_on [lsearch $ulsts::mine_reso_lst [string trim $r]]
                if {$is_on < 0} {
                    set ulsts::mine_reso_lst [lappend ulsts::mine_reso_lst [string trim $r]]
                }
            }
            #puts "deposits: $tres"
        }
    }
    set ulsts::mine_reso_lst [lsort -integer $ulsts::mine_reso_lst]
    #puts $ulsts::mine_reso_lst
}

# ############################################
#   fill base list box
proc fill_base_listbox {fr} {
    
    $fr delete 0 end
    update
    set warn_cycs 2
    set header [lindex $ulsts::secd_lst 0]
    set sheader [csv::split -alternate $header]
    #foreach s $sheader {
    #    puts $s
    #}
    set sidx [lsearch -exact $sheader "Full_Name"]
    set iidx [lsearch -exact $sheader "id"]
    set cycs [lsearch -exact $sheader "productionCyclesLeft"]
    #puts $cycs
    set dlst [lrange $ulsts::secd_lst 1 end]
    set idx 0
    foreach s $dlst {
        if {$s == ""} {
            continue
        }
        set pid [lindex [csv::split -alternate $s] $sidx]
        append pid ":[lindex [csv::split -alternate $s] $iidx]"
        if {$pid < 0} {
            continue
        } else {
            #  count mining facilities.
            incr refine::mine_cnt
            # put up in list depending on status.
            set cy [lindex [csv::split -alternate $s] $cycs]
            if {$cy == 0} {
                $fr insert end $pid
                $fr itemconfigure end  -background pink1
            }
        }
    }
    foreach s $dlst {
        if {$s == ""} {
            continue
        }
        set pid [lindex [csv::split -alternate $s] $sidx]
        append pid ":[lindex [csv::split -alternate $s] $iidx]"
        if {$pid < 0} {
            continue
        } else {
            #  count mining facilities.
            incr refine::mine_cnt
            # put up in list depending on status.
            set cy [lindex [csv::split -alternate $s] $cycs]
            if {$cy < $warn_cycs} {
                $fr insert end $pid
                $fr itemconfigure end -background orange1
            }
        }
    }
    foreach s $dlst {
        if {$s == ""} {
            continue
        }
        set pid [lindex [csv::split -alternate $s] $sidx]
        append pid ":[lindex [csv::split -alternate $s] $iidx]"
        if {$pid < 0} {
            continue
        } else {
            #  count mining facilities.
            incr refine::mine_cnt
            # put up in list depending on status.
            set cy [lindex [csv::split -alternate $s] $cycs]
            if {$cy >= $warn_cycs} {
                $fr insert end $pid
                $fr itemconfigure end -background lightgreen
            }
        }
    }
}




# ############################################
#   fill sector list box
proc fill_ship_listbox {fr} {
    
    $fr delete 0 end
    update
    set header [lindex $ulsts::ship_lst 0]
    set sheader [csv::split -alternate $header]
    #foreach s $sheader {
    #    puts $s
    #}
    set IDidx [lsearch -exact $sheader "id"]
    set sidx [lsearch -exact $sheader "original.name"]
    set dlst [lrange $ulsts::ship_lst 1 end]
    set idx 0
    set dis_lst {}
    foreach s $dlst {
        set pid [lindex [csv::split -alternate $s] $sidx]
        if {$pid < 0} {
            continue
        } else {
            set tstr "$pid"
            append tstr ">[lindex [csv::split -alternate $s] $IDidx]"
            set dis_lst [lappend dis_lst $tstr]
        }
    }
    
    set dis_lst_sort [lsort $dis_lst]
    foreach s $dis_lst_sort {
        $fr insert end $s
    }
}

# ######################################
#  fill inventory list box with selections.
proc fill_inv_mods_listbox {fr} {
    $fr delete 0 end
    update
    set header [lindex $ulsts::mod_lst 0]
    set sheader [csv::split -alternate $header]
    set IDidx [lsearch -exact $sheader "id"]
    set name_idx [lsearch $sheader "original.name"]
    
    #foreach s $sheader {
    #    if {[string first "id" $s] >= 0} {
    #        #puts $s
    #    }
    #    if {[string first "ID" $s] >= 0} {
    #        #puts $s
    #    }
    #}
    
    # list of module ids on ships.
    set mheader [lindex $ulsts::shipd_lst 0]
    #puts $mheader
    set smheader [split $mheader ","]
    set sm_id_idx [lsearch $smheader "module.id"]
    #puts $sm_id_idx

    set mdlst [lrange $ulsts::shipd_lst 1 end]
    set sm_id_lst []
    foreach m $mdlst {
        set sm [split $m ","]
        if {[lindex $sm $sm_id_idx] != ""} {
            set tmp [split [lindex $sm $sm_id_idx] "."]
            set sm_id_lst [lappend sm_id_lst [lindex $tmp 0]]
        }
    }
    
    
    #foreach i $sm_id_lst {
    #    puts $i
    #}


    set dlst [lrange $ulsts::mod_lst 1 end]
    set name_len 0
    foreach m $dlst {
        set sm [split $m ","]
        set mname [lindex $sm $name_idx]
        set nlen [string length $mname]
        if {$nlen > $name_len} {
            set name_len $nlen
        }
    }
    
    foreach m $dlst {
        if {$m == ""} {break}
        set sm [split $m ","]
        #puts $sm
        set name [pad_str [lindex $sm $name_idx] $name_len]
        #puts $name
        #puts $name_idx
        set id [lindex $sm $IDidx]
        set mstr $name
        append mstr "id:$id"
        set is_eq [lsearch $sm_id_lst $id]
        $fr insert end $mstr
        if {$is_eq >= 0} {
            $fr itemconfigure end -background #ffe8e8
        }
    }
}
# #############################################
#   show the base details in the canvas passed
proc show_base_details {wid} {
    set sel_idx [$wid curselection]
    
    set base [$wid get $sel_idx]
    #puts $base
    set sbase [split $base ":"]
    set bid [lindex $sbase 1]
    set base [lindex $sbase 0]
    #  Clean up.
    $uwids::bcanv delete all
    
    set header [lindex $ulsts::secd_lst 0]
    set sheader [csv::split -alternate $header]
    #puts $sheader
    set pidx [lsearch $sheader "name"]
    set dlst [lrange $ulsts::secd_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [csv::split -alternate $i]
        if {[lsearch $si $base] >= 0 && [lsearch $si $bid] >= 0 &&$found == 0} {
            set idx 0
            set found 1
            foreach h $sheader {
                if {[string first "planet" $h] >= 0} {
                    incr idx
                    continue
                }
                $uwids::bcanv create text $lx $ly -anchor e -text "$h:"
                #  if the start time
                if {[string first "productionStart" $h] >= 0 } {
                    set cleft [lindex $si [lsearch $sheader "productionCyclesLeft"]]
                    if {$cleft == 0} {
                        #set hidx 0
                        #foreach h $sheader {
                        #    puts "$h:  [lindex $si $hidx]"
                        #    incr hidx
                        #}
                        #puts $header
                        #puts "Says  0 left for $si"
                        break
                    }
                    #puts "cycles left:  $cleft"
                    #puts "Start production:  [lindex $si $idx]"
                    set stim [get_time_val [lindex $si $idx]]
                    #puts $stim
                # if the end time
                } elseif { [string first "productionEnd" $h] >= 0 } {
                    set rlst {}
                    set cinfo {}
                    #puts "Sending end time value: [lindex $si $idx]"
                    set etim [get_time_val [lindex $si $idx]]
                    set rlst [get_reso [lindex $si [lsearch $sheader "productionData.resourceId"]]]
                    if {$rlst == {}} {
                        #puts "Try  comp"
                        #puts $header
                        set cinfo [get_comp_info [lindex $si [lsearch $sheader "productionData.componentId"]]]
                        #puts $cinfo
                    }
                    if {$rlst != {}} {
                        set rid [lindex $rlst 0]
                        set ridx [lsearch -index 0 $far_db::mine_lst $rid]
                        set rinfo [lindex $far_db::mine_lst $ridx]
                        #puts $rinfo
                        set cyc_dur [lindex [lindex $rinfo 1] 0]
                    } elseif {$cinfo != {}} {
                        set cid [lindex $cinfo 0]
                        set cidx [lsearch -index 0 $far_db::compmain_lst $cid]
                        set cdets [lindex $far_db::compmain_lst $cidx]
                        set cyc_dur [lindex [lindex $cdets 1] 0]
                        #puts "The component details: $cdets"
                        #puts ""
                        #far_db::compmain_lst
                    } else {
                        puts "Error:  info not matching expected"
                        return
                    }
                    set tim_left [expr {$cyc_dur * $cleft}]
                    #puts "seconds left: $tim_left"
                    #puts $etim
                    set ddone [expr {int($etim + $tim_left)}]
                    set done_time [clock format $ddone -format {%Y-%m-%d %H:%M:%S} -timezone :America/New_York]
                    #puts "Date done :  $done_time"
                }
                if {[string first "\]" [lindex $si $idx]] >= 0 || $h == "productionData.resourceId"} {
                    set lstr [string trim [lindex $si $idx] "\[\]"]
                    set slstr [split $lstr ","]
                    set rcnt 0
                    foreach r $slstr {
                        set rids [lsearch -index 0 $far_db::res_lst [string trim $r]]
                        if {$rids >= 1} {
                            set res [lindex [lindex $far_db::res_lst $rids] 1]
                            set rcol [lindex $res 4];  ##  the color
                            set rnm [lindex $res 0];   ## the name
                            $uwids::bcanv create rectangle $vx [expr {$vy-7}] [expr {$vx+60}] [expr {$vy+10}]  -fill $rcol
                            $uwids::bcanv create text [expr {$vx+6}] [expr {$vy+2}] -anchor w -text $rnm -fill white -font font_info_txt
                            if {$rcnt < 2} {
                                incr vx 64
                                incr rcnt
                            } else {
                                set vx 200
                                incr vy 20
                                incr ly 20
                                set rcnt 0
                            }
                        }
                    }
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    $uwids::bcanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                }
            }
        }
    }    
        
    incr vy 20
    set tf black
    #puts $cleft
    if {$cleft == 0} {
        set tf red
        $uwids::bcanv create text $vx $vy -anchor c -text "Finished Production :" -font font_info_res -fill red
    } elseif {$cleft < 2} {
        $uwids::bcanv create text $vx $vy -anchor c -text "Close to Production End :" -font font_info_res
        set tf orange
        incr vy 20
        $uwids::bcanv create text $vx $vy -anchor c -text $done_time -font font_info_res -fill $tf
    } else {
        $uwids::bcanv create text $vx $vy -anchor c -text "Current production ends on :" -font font_info_res
        incr vy 20
        $uwids::bcanv create text $vx $vy -anchor c -text $done_time -font font_info_res -fill $tf
    }
    incr vy 20
}

# #############################################
#   show the sector details in the canvas passed
proc show_sector_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set sec [$wid get $sel_idx]
    #puts $sec
    #  Clean up.
    $uwids::scanv delete all
    
    set header [lindex $ulsts::sec_lst 0]
    set sheader [csv::split -alternate $header]
    #puts $sheader
    set pidx [lsearch $sheader "name"]
    set dlst [lrange $ulsts::sec_lst 1 end]
    
    #puts $pidx
    #puts $dlst
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [csv::split -alternate $i]
        if {[lsearch $si $sec] >= 0 && $found == 0} {
            #puts "found [lindex $si $pidx]"        
            set idx 0
            set found 1
            foreach h $sheader {
                if {[string first "planet." $h] >= 0} {
                    incr idx
                    continue
                }
                $uwids::scanv create text $lx $ly -anchor e -text "$h:"
                if {[string first "\]" [lindex $si $idx]] >= 0} {
                    set lstr [string trim [lindex $si $idx] "\[\]"]
                    set slstr [split $lstr ","]
                    #puts $lstr
                    #puts $slstr
                    #set xrst $vx
                    set rcnt 0
                    foreach r $slstr {
                        #puts $r
                        set rids [lsearch -index 0 $far_db::res_lst [string trim $r]]
                        if {$rids >= 1} {
                            set res [lindex [lindex $far_db::res_lst $rids] 1]
                            #puts $res
                            set rcol [lindex $res 4];  ##  the color
                            #puts $rcol
                            set rnm [lindex $res 0];   ## the name
                            #puts $rnm
                            $uwids::scanv create rectangle $vx [expr {$vy-7}] [expr {$vx+60}] [expr {$vy+10}]  -fill $rcol
                            $uwids::scanv create text [expr {$vx+6}] [expr {$vy+2}] -anchor w -text $rnm -fill white -font font_info_txt
                            if {$rcnt < 2} {
                                incr vx 64
                                incr rcnt
                            } else {
                                set vx 200
                                incr vy 20
                                incr ly 20
                                set rcnt 0
                            }
                            #incr ly 20
                        }
                    }
                    #$uwids::pcanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    $uwids::scanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                }
            }
        }
    }    
}

# #############################################
#   show the planet details in the canvas passed
proc show_planet_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set plnt [$wid get $sel_idx]
    if {$plnt == {}} {
        return
    }
    #puts $plnt
    #  Clean up.
    $uwids::pcanv delete all
    #$uwids::pcanv create text 50 50 -text "Primary"
    set header [lindex $ulsts::sec_lst 0]
    set sheader [csv::split -alternate $header]
    #set pidx [lsearch $sheader "planet.name"]
    set dlst [lrange $ulsts::sec_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [csv::split -alternate $i]
        if {[lsearch $si $plnt] >= 0 && $found == 0} {
            #puts "found [lindex $si $pidx]"        
            set idx 0
            set found 1
            foreach h $sheader {
                if {[string first "planet." $h] < 0} {
                    incr idx
                    continue
                }
                # strip the planet. from header name.
                set h [string replace $h 0 6 ""]
                $uwids::pcanv create text $lx $ly -anchor e -text "$h:"
                if {[llength [split [lindex $si $idx] ","]] > 1} {
                    set lstr [string trim [lindex $si $idx] "\[\]"]
                    set slstr [split $lstr ","]
                    #puts $slstr
                    #set xrst $vx
                    set rcnt 0
                    foreach r $slstr {
                        #puts $r
                        set rids [lsearch -index 0 $far_db::res_lst [string trim $r]]
                        if {$rids >= 1} {
                            set res [lindex [lindex $far_db::res_lst $rids] 1]
                            #puts $res
                            set rcol [lindex $res 4];  ##  the color
                            #puts $rcol
                            set rnm [lindex $res 0];   ## the name
                            #puts $rnm
                            $uwids::pcanv create rectangle $vx [expr {$vy-7}] [expr {$vx+60}] [expr {$vy+10}]  -fill $rcol
                            $uwids::pcanv create text [expr {$vx+6}] [expr {$vy+2}] -anchor w -text $rnm -fill white -font font_info_txt
                            if {$rcnt < 2} {
                                incr vx 64
                                incr rcnt
                            } else {
                                set vx 200
                                incr vy 20
                                incr ly 20
                                set rcnt 0
                            }
                            #incr ly 20
                        }
                    }
                    #$uwids::pcanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    $uwids::pcanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                }
            }
        }
    }
}

# #############################################
#   show the sector details in the canvas passed
proc show_ship_module_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set sec [$wid get $sel_idx]
    #puts $sec
    #  Clean up.
    $uwids::shicanv delete all
    update
    
    set header [lindex $ulsts::mod_lst 0]
    set sheader [csv::split -alternate $header]
    #  lame search, need to get module ID and match from list.  <<<<<  TBD
    set name_idx [lsearch $sheader "original.name"]
    set dlst [lrange $ulsts::mod_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [split $i ","]
        #puts $si
        set name [lindex $si $name_idx]
        set mtxt [string first $name $sec]
        #puts $mtxt
        if {$mtxt > 0} {
            #puts "found [lindex $si $pidx]"        
            set idx 0
            set found 1
            foreach h $sheader {
                if {$h == "userId"} {
                    continue
                }
                ## skip fields with 0 or no content.  may need refinement.
                if {[lindex $si $idx] != "0" && [lindex $si $idx] != ""} {
                    #puts [lindex $si $idx]
                    $uwids::shicanv create text $lx $ly -anchor e -text "$h:"
                    $uwids::shicanv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    incr idx
                }
            }
            break
        }
    }    
}

# #############################################
#   show the inventory module details in the canvas passed
proc show_inv_module_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set mod [$wid get $sel_idx]
    set smod [split $mod ":"]
    set this_mod_id [lindex $smod end]
    set this_name [string trim [lindex $smod 0] "id "]
    #puts $sec
    #  Clean up.
    $uwids::inv_mod_canv delete all
    update
    
    set header [lindex $ulsts::mod_lst 0]
    set sheader [csv::split -alternate $header]
    #  lame search, need to get module ID and match from list.  <<<<<  TBD
    set name_idx [lsearch $sheader "id"]
    set dlst [lrange $ulsts::mod_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    foreach i $dlst {
        set si [split $i ","]
        #puts $si
        set name [lindex $si $name_idx]
        if {$name == $this_mod_id} {
            #puts "found [lindex $si $pidx]"        
            set idx 0
            set found 1
            $uwids::inv_mod_canv create text $lx $ly -text $this_name -font font_info_res
                    incr ly 20
                    incr vy 20
            foreach h $sheader {
                if {$h == "userId"} {
                    continue
                }
                ## skip fields with 0 or no content.  may need refinement.
                if {[lindex $si $idx] != "0" && [lindex $si $idx] != ""} {
                    #puts [lindex $si $idx]
                    $uwids::inv_mod_canv create text $lx $ly -anchor e -text "$h:"
                    $uwids::inv_mod_canv create text $vx $vy -anchor w -text [lindex $si $idx]
                    incr idx
                    incr ly 20
                    incr vy 20
                    set vx 200
                } else {
                    incr idx
                }
            }
            break
        }
    }    
}

# #############################################
#  generate a container group.
#   fr   frame to build in
#   title   Text titleof box
#   lstbx   the list box of items
#   canv    the canvas to display info
#   rtn     the return of the created items.
proc gen_info_container {fr title lstbx canv} {
    set l1 [label $fr.lb1 -text $title]
    pack $l1
    set lstbx [listbox $fr.lsb1 -borderwidth 4 -relief sunken -width 36 -height 10  -font font_info_cou]
    set canv [canvas $fr.pc1 -borderwidth 4 -relief sunken  -width 400 -height 500  -yscrollincrement 1]
    $canv configure -scrollregion {0 0 400 900}
    bind $canv <MouseWheel> {scrol_canv %W %D}
    pack $lstbx
    pack $canv
    pack $fr -side left -fill y -expand 1
    set rtn $lstbx
    set rnt [lappend rtn $canv]
    return $rtn
}


# #############################################
#   show the planet details in the canvas passed
proc show_ship_details {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set ship [$wid get $sel_idx]
    if {$ship == {}} {
        return
    }
    #puts $ship
    #  Clean up.
    $uwids::shcanv delete all
    #  header info
    set header [lindex $ulsts::ship_lst 0]
    set sheader [csv::split -alternate $header]
    # get some ship info indexs
    set shipID [lsearch -exact $sheader "id"]
    set sidx [lsearch -exact $sheader "original.name"]
    set iidx [lsearch -exact $sheader "combinedTextureName"]
    set sid [lindex $sheader $sidx]
    append sid "-[lindex $sheader $sidx]"
    set dlst [lrange $ulsts::ship_lst 1 end]
    
    set lx 180
    set ly 20
    set vx 200
    set vy 20
    set found 0
    set cship_id "xxx"
    foreach i $dlst {
        set si [split $i ","]
        set styp [lindex $si $sidx]
        append styp ">[lindex $si $shipID]"
        
        if {$styp != $ship} {
            continue
        }
        ## get the ship ID
        set cship_id [lindex $si $shipID]
        set idx 0
        set found 1
        foreach h $sheader {
            #  put down text
            if {$h == "userId"} {
                continue
            }
            $uwids::shcanv create text $lx $ly -anchor e -text "$h:"
            $uwids::shcanv create text $vx $vy -anchor w -text [lindex $si $idx]
            incr idx
            incr ly 20
            incr vy 20
            set vx 200
        }
    }
    
    ##  now get the modules for this shipe and display.
    set mheader [lindex $ulsts::shipd_lst 0]
    set mdlst [lrange $ulsts::shipd_lst 1 end]
    # get some indexs from the header.
    set smheader [csv::split -alternate $mheader]
    set name_idx [lsearch $smheader "module.original.name"]
    set mod_slot [lsearch $smheader "slot"]
    set mod_place [lsearch $smheader "place"]
    
    ## from the list of modules get the ones for this ship.
    $uwids::module_lsb delete 0 end
    set mods_lst []
    foreach m $mdlst {
        set sm [split $m ","]
        set slot [lindex $sm $mod_slot]
        set place [lindex $sm $mod_place]
        set id [lindex $sm 0]
        set this_name [lindex $sm $name_idx]
        #if module and ship id match
        if {$id == $cship_id} {
            set mods_lst [lappend mods_lst $m]
            # Add this to the ship equipted modules list box
            $uwids::module_lsb insert end "S:$slot:$place - $this_name"
        }
    }
    $uwids::shicanv delete all

}
# ##############################################
#  create Views of user data
#   planets
#   sectors
#   installations
#   ships
#   blue prints
proc generate_view {} {
    # delete everything if it exists.
    if {[winfo exists $uzr::user_note_frame] == 1} {
        set info_cont [winfo children $uzr::user_note_frame]
        #puts $info_cont
        foreach w $info_cont {
            destroy $w
        }
    }
    ##  note book for user sections
    set uzr_tbs [ttk::notebook $uzr::user_note_frame.note -height 1100]
    pack $uzr_tbs -anchor w -fill both -expand 1
    set mfr $uzr_tbs.t1
    set shipfr $uzr_tbs.t2
    set bpfr $uzr_tbs.t3
#    $uzr_tbs add [frame $mfr -borderwidth 4 -relief sunken] -text "\[ Resources \]" -bordercolor brown -tabmargins 3 -padding {5 5 5 5}
#    $uzr_tbs add [frame $shipfr -borderwidth 4 -relief sunken] -text "\[ Ships \]" -bordercolor brown -padding {5 5 5 5}
    $uzr_tbs add [frame $mfr -borderwidth 4 -relief sunken] -text "\[ Resources \]" -padding {5 5 5 5}
    $uzr_tbs add [frame $shipfr -borderwidth 4 -relief sunken] -text "\[ Ships \]" -padding {5 5 5 5}
    $uzr_tbs add [frame $bpfr -borderwidth 4 -relief sunken] -text "\[ Blue Prints \]" -padding {5 5 5 5}
    
    ###########################################################
    ##  planet info
    set pfr [ttk::frame $mfr.pl1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $pfr "Planets" $uwids::planet_lsb $uwids::pcanv]
    #pack $pfr -anchor w -fill y
    set uwids::planet_lsb [lindex $wids 0]
    set uwids::pcanv [lindex $wids 1]

    bind $uwids::planet_lsb <ButtonRelease-1> { show_planet_details %W}
    bind $uwids::planet_lsb <KeyRelease> { show_planet_details %W}
    
    fill_planet_listbox $uwids::planet_lsb
    
    # #########################################################
    ##  Sector info
    set sfr [ttk::frame $mfr.sl1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $sfr "Sectors" $uwids::sector_lsb $uwids::scanv]
    #pack $sfr -side left -fill y
    set uwids::sector_lsb [lindex $wids 0]
    set uwids::scanv [lindex $wids 1]

    bind $uwids::sector_lsb <ButtonRelease-1> { show_sector_details %W}
    bind $uwids::sector_lsb <KeyRelease> { show_sector_details %W}
    
    fill_sector_listbox $uwids::sector_lsb
    
    # #########################################################
    ##  installation (bases) info
    set ifr [ttk::frame $mfr.il1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $ifr "Installations" $uwids::base_lsb $uwids::bcanv]
    set uwids::base_lsb [lindex $wids 0]
    set uwids::bcanv [lindex $wids 1]

    bind $uwids::base_lsb <ButtonRelease-1> { show_base_details %W}
    bind $uwids::base_lsb <KeyRelease> { show_base_details %W}
    
    fill_base_listbox $uwids::base_lsb
    
    ##########################################################
    ##  Ship info
    set shfr [ttk::frame $uzr_tbs.t2.il1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $shfr "Ships" $uwids::ship_lsb $uwids::shcanv]
    set uwids::ship_lsb [lindex $wids 0]
    set uwids::shcanv [lindex $wids 1]
    $uwids::shcanv configure -scrollregion {0 0 400 1800}


    bind $uwids::ship_lsb <ButtonRelease-1> { show_ship_details %W}
    bind $uwids::ship_lsb <KeyRelease> { show_ship_details %W}
    
    fill_ship_listbox $uwids::ship_lsb
    
    ##########################################################
    ##  Ship Modules info
    set shifr [ttk::frame $uzr_tbs.t2.sil1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $shifr "Ships Equiped Modules" $uwids::module_lsb $uwids::shicanv]
    set uwids::module_lsb [lindex $wids 0]
    set uwids::shicanv [lindex $wids 1]

    bind $uwids::module_lsb <ButtonRelease-1> { show_ship_module_details %W}
    bind $uwids::module_lsb <KeyRelease> { show_ship_module_details %W}
        
     ##########################################################
    ##  Inventory Modules info
    set imfr [ttk::frame $uzr_tbs.t2.iml1 -borderwidth 4 -relief sunken]
    set wids [gen_info_container $imfr "Inventory Modules" $uwids::inv_module_lsb $uwids::inv_mod_canv]
    set uwids::inv_module_lsb [lindex $wids 0]
    set uwids::inv_mod_canv [lindex $wids 1]
    $uwids::inv_module_lsb configure -width 40

    bind $uwids::inv_module_lsb <ButtonRelease-1> { show_inv_module_details %W}
    bind $uwids::inv_module_lsb <KeyRelease> { show_inv_module_details %W}
    
    fill_inv_mods_listbox $uwids::inv_module_lsb
        
}

# #################################################
#   backup current files before downloading
#    if enabled.
proc uzr_history_add {} {
    ## return if history logging not enabled.
    if {$uzr::bkup_en == 0} {
        return
    }
    puts "Updating history ..."
    if {[file exists "user_history"] == 1 && [file isdirectory "user_history"] == 1} {
        set time [clock seconds]
        set time [clock format $time -format {%Y-%m-%dh%Hm%Ms%S} -timezone :America/New_York]
        file mkdir "user_history/$time"
        
    } else {
        file mkdir "user_history"
        set time [clock seconds]
        set time [clock format $time -format {%Y-%m-%dh%Hm%Ms%S} -timezone :America/New_York]
        file mkdir "user_history/$time"
        
    }
    
    file copy "../Account.csv" "user_history/$time/Account.csv"
    file copy "../Blueprints.csv" "user_history/$time/Blueprints.csv"
    file copy "../Modules.csv" "user_history/$time/Modules.csv"
    file copy "../Sectors.csv" "user_history/$time/Sectors.csv"
    file copy "../Sectors_Bases_Detail.csv" "user_history/$time/Sectors_Bases_Detail.csv"
    file copy "../Ships.csv" "user_history/$time/Ships.csv"
    file copy "../Ships_Slot_Detail.csv" "user_history/$time/Ships_Slot_Detail.csv"
    
    return
}

# ###############################
#   get user info from the web
proc get_uzr_info {} {
    puts "Getting user info ..."
    set hdict [dict create accept application/json content-type application/json]
    http::register https 443 [list ::tls::socket -autoservername true]
    #puts "$uzr::email  $uzr::pw"
    set url "https://farsite.online/api/1.0/auth/signin"
    set login [::http::formatQuery email $uzr::email password $uzr::pw ]
    set log [http::geturl $url -query $login]

    set stat [http::status $log]
    puts $stat
    
    set auth_dic [json::json2dict [http::data $log]]
    set token [dict get $auth_dic accessToken]
    #puts $token
    http::cleanup $log
    set header "Authorization "
    append header $token
    
    set url "https://farsite.online/api/1.0/users/"
    set acc [::http::formatQuery Authorization $token]
    puts $acc
    return
    set lacc [http::geturl $url -query $acc]
    set stat [http::status $lacc]
    puts $stat
    
    set met [http::meta $lacc]
    set dat [http::data $lacc]
    puts $met
    puts $dat
    
    return

    #uzr_history_add
    set status 0
    set uid 664409
    #puts $uzr::email
    #httpcopy "https://farsite.online/api/1.0/universe/sectors/$uid" "uzr_sectors.txt"
#account_info_dict['Sectors'] = api_get_request('https://farsite.online/api/1.0/universe/sectors/my')
    httpcopy "https://farsite.online/api/1.0/ships/$uid/list" "uzr_ships.txt"
    httpcopy "https://farsite.online/api/1.0/blueprints/$uid/list" "uzr_blueprints.txt"
    httpcopy "https://farsite.online/api/1.0/modules/$uid/list" "uzr_modules.txt"
    httpcopy "https://farsite.online/api/1.0//components/$uid/list" "uzr_components.txt"
    httpcopy "https://farsite.online/api/1.0/accessories/$uid/list" "uzr_accessories.txt"
    httpcopy "https://farsite.online/api/1.0/resources/$uid/list" "uzr_resources.txt"
    #httpcopy "https://farsite.online/api/1.0/storage/$uid/list" "uzr_storage.txt"
    #if {[catch {exec python ../inventory_scrape.py $uzr::email $uzr::pw} results options]} {
    #    set details [dict get $options -errorcode]
    #    if {[lindex $details 0] eq "CHILDSTATUS"} {
    #        set status [lindex $details 2]
    #    } else {
    #        # Some other error; regenerate it to let caller handle
    #        return -options $options -level 0 $results
    #    }
    #}
    
    #puts "TCL  got back:  $results"
    #puts $details
    #puts $status
    #puts "Options $options"
    #load_uzr_info
    #generate_view
}

proc fill_uzr_comps {} {
    if {$ulsts::mine_reso_lst == {}} {
        puts "Error:  User must load user data before this function will work"
        return
    }
    
    if {$comp::show_uzr_comps == 1} {
        set comp::show_uzr_txt "Show All"
        load_comp_list $far_db::comps_lst
        return
    } else {
        set comp::show_uzr_txt "Show Buildable"
    }
    
    if {$ulsts::comp_build_lst != {}} {
        load_comp_list $ulsts::comp_build_lst
        return
    }
    
    set lst {}
    ##  get a list of all resources user can mine
    #puts $ulsts::mine_reso_lst
    foreach r $ulsts::mine_reso_lst {
        set tlst {}
        set tlst [get_reso_chain $r tlst]
        #puts $r
        if {$tlst == {}} {
            set lst [lappend lst $r]
        } else {
            set lst [lappend lst $r]
            foreach o $tlst {
                set m [lindex [split [lindex $o 1] " "] 0]
                #puts $m
                if {[lsearch -integer $lst $m] < 0} {
                    set lst [lappend lst [lindex $m 0]]
                }
            }
        }
    }
    ##  no mining  return.
    if {$lst == {}} {
        return
    }
    set ulsts::mine_reso_lst [lsort -integer $lst]
#    set dlst [lrange $comp_spec 1 end]
    # find all the components that match available resources.
    set uzr_cmp_lst {}
    set lastr ""
    set clst {}
    set dlst [lrange $far_db::compres_lst 1 end]
    #  for all items in the component resource list
    foreach r $dlst {
        set resd [split [lindex $r 1] " "]
        set cmp [string trim [lindex $r 0]]
        #puts $resd
        if {$cmp == $lastr} {
            set clst [lappend clst [lindex $resd 0]]
            puts "Add resource to comp list: [lindex $resd 0]"
        } else {
            if {$lastr == ""} {
                puts "Very first $cmp"
                set lastr $cmp
                set clst [lappend clst $cmp]
            } else {
                puts "new comp found : $cmp"
                set clst [lappend clst [lindex $resd 0]]
                #puts $lastr
                #puts $clst
                #puts $ulsts::mine_reso_lst
                set found 1
                if {$clst != {}} {
                    foreach c $clst {
                        set found [lsearch $ulsts::mine_reso_lst $c]
                        #puts ""
                        if {$found < 0} {
                            set lastr $cmp
                            set clst {}
                            break
                        }
                    }
                    if {$found >= 0} {
                        #puts "Found:  [lindex $ulsts::mine_reso_lst $found] \n was found    Looking for:  $c"
                        foreach c $far_db::comps_lst {
                            set id [lindex $c 0]
                            if {$id == $lastr} {
                                set ulsts::comp_build_lst [lappend ulsts::comp_build_lst $c]
                                #puts $c
                            }
                        }
                        #set uc [lsearch $far_db::comps_lst $res]
                        #set cmp [lindex $far_db::comps_lst $uc]
                        #puts $cmp
                        #set ulsts::comp_build_lst [lappend ulsts::comp_build_lst $r]
                        #puts "Resource found:  $res"
                    }
                }
                set lastr $cmp
                set clst {}
                #set clst [lappend clst [lindex $resd 0]]
            }
        }
        
    }

    load_comp_list $ulsts::comp_build_lst
    
    puts $lst
}