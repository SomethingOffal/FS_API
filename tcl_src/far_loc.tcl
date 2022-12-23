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
#           Description:  This file contains all static GUI elements.  Many others
#               are created in other files but they are dynamic, elements here are
#               static.
#
# -------------------------------------------------------------------------------

#  Packages
package require Ttk
package require Tk
package require http 2.0
package require tls 1.7
package require base64 ;# tcllib
package require json 1.3.4

package require sqlite3

proc percent2rgb {r g b} {
    # map 0..100 to a red-yellow-green sequence
    set red [expr {int($r * 2.55)}]
    set green [expr {int($g * 2.55)}]
    set blue [expr {int($b * 2.55)}]
    #set n     [expr {$n < 0? 0: $n > 100? 100: $n}]
    #set red   [expr {$n > 75? 60 - ($n * 15 / 25) : 15}]
    #set green [expr {$n < 50? $n * 15 / 50 : 15}]
    return [format "#%2x%2x%2x" $red $green $blue]
 } ;

# #############################################
#   extract the ship data from html line
proc get_ship_dat {ln} {
    
    set lst0 {id}
#    set lst1 {owner username}
    set lst1 {username}
    set lst2 {id type name size}
    set lst4 {starId flightType x y z newX newY newZ flightStart flightEnd}
    
    set cat_lst [split $ln "\}"]
    set sstr ""
    
    set of [open "stit.txt" "w"]
    foreach c $cat_lst {
        puts $of $c
    }
    close $of
    
    #set slst0 [split [lindex $cat_lst 0] ","]
    #foreach i $slst0 {
    #    set si [split $i ":"]
    #    set skey [string trim [lindex $si 0] "\""]
    #    foreach k $lst0 {
    #        if {$skey == $k} {
    #            set s1 [lindex $si end]
    #            set val [string trim $s1 "\""]
    #            append sstr " $val"
    #            break
    #        }
    #    }
    #}
    #
    set slst1 [split [lindex $cat_lst 2] ","]
    foreach i $slst1 {
        #puts $i
        set si [split $i ":"]
        set skey [string trim [lindex $si 0] "\""]
        foreach k $lst1 {
            if {$skey == $k} {
                set s1 [lindex $si end]
                set val [string trim $s1 "\""]
                append sstr "$val "
                break
            }
        }
    }
    #puts $sstr
    #
    #set slst2 [split [lindex $cat_lst 4] ","]
    #foreach i $slst2 {
    #    set si [split $i ":"]
    #    set skey [string trim [lindex $si 0] "\""]
    #    foreach k $lst2 {
    #        if {$skey == $k} {
    #            set s1 [lindex $si end]
    #            set val [string trim $s1 "\""]
    #            append sstr " $val"
    #            break
    #        }
    #    }
    #}
    
    set slst4 [split [lindex $cat_lst 5] ","]
    foreach i $slst4 {
        set si [split $i ":"]
        #puts $of $si
        if {[llength $si] > 2} {
            set si [lrange $si 1 end]
        #puts $of $si
        }
        set skey [string trim [lindex $si 0] "\{\""]
        foreach k $lst4 {
            if {$skey == $k} {
                set s1 [lindex $si end]
                set val [string trim $s1 "\""]
                append sstr "$val "
                break
            }
        }
    }
    
    return $sstr
}


proc draw_location {sr} {

    set x [lindex $sr 3]
    set nx [lindex $sr 6]
    #puts "$x $nx"
    
    set dlst {}
    if {$x != $nx} {
        set floc::in_flight 1
        #puts "x says I am in flight"
    } else {
        set floc::in_flight 0
        #puts "x says I am still"
    }
    update
    
    set reps [$floc::reps_en get]
    if {$reps != 0 } {
        ##  if currently in flight
        #puts "Reps is: $reps"
        if {$floc::in_flight == 1} {
            #puts "I am in flight"
            if {$floc::was_flight == 0} {
                #puts "but was not in flight last scan"
                set floc::rep_lst [linsert $floc::rep_lst 0 $sr]
                set dlst $floc::rep_lst
                set floc::was_flight 1
            } else {
                set dlst [lreplace $floc::rep_lst 0 0 $sr]
            }
        ##  if  was in flight
        } elseif {$floc::was_flight == 1} {
            #puts "I was in flight"
            set floc::rep_lst [lreplace $floc::rep_lst 0 0 $sr]
            set floc::was_flight 0
            set dlst $floc::rep_lst
        ##   sitting still
        } else {
            #puts "I am sitting still"
            if {[llength $floc::rep_lst] > $reps} {
                set floc::rep_lst [lrange $floc::rep_lst 0 $reps-1]
            }
            set dlst $floc::rep_lst
        }
    } else {
        set dlst [lappend dlst $sr]
    }
    
    #puts [llength $floc::rep_lst]
    #foreach d $dlst {
    #    puts $d
    #}
    
    set dlst [lappend dlst $sr]
    
    set cx [lindex $uzr::canv_cent 0]
    set cy [lindex $uzr::canv_cent 1]
    set last_loc {}
    set idx 0
    set dlst_len [llength $dlst]
    
    foreach sl $dlst {
        set pname [lindex $sl 0]
        set x [lindex $sl 3]
        set y [lindex $sl 4]
        set z [lindex $sl 5]
        set nx [lindex $sl 6]
        set ny [lindex $sl 7]
        set nz [lindex $sl 8]
        
        # adjust the size and center.
        set x [expr {int($x / $floc::scale_down) + $cx}]
        set z [expr {int($z / $floc::scale_down) + $cy}]
        set nx [expr {int($nx / $floc::scale_down) + $cx}]
        set nz [expr {int($nz / $floc::scale_down) + $cy}]
        set rad 10
#        set rad [expr {int($rad / $scale_down)}]
        set c $x
        set c [lappend c $z]
        #  draw current location.
        #  if current and next are not the same show where going.
        if {$idx == 0} {
            $uzr::univ_canv create text $x [expr {$z + 20}] -text $pname -font font_info_txt -fill [percent2rgb 60 65 10]
        }
        if {$x != $nx} {
            draw_cir $uzr::univ_canv $c 25 "" #00ff8e
            $uzr::univ_canv create line $x $z $nx $nz -arrow last -fill #00ff00
            set last_loc {}
            draw_cir $uzr::univ_canv $c $floc::g1 "" [percent2rgb 30 30 30]
            draw_cir $uzr::univ_canv $c $floc::g2 "" [percent2rgb 40 40 40]
            draw_cir $uzr::univ_canv $c $floc::g3 "" [percent2rgb 20 50 10]
            set c $nx
            set c [lappend c $nz]
            draw_cir $uzr::univ_canv $c 25 "" #00ff0e
        } else {
            ## draw current location  stopped.
            draw_cir $uzr::univ_canv $c 25 "" #ae4e0e
            if {$floc::g1_en == 1} {draw_cir $uzr::univ_canv $c $floc::g1 "" [percent2rgb 30 30 30]}
            if {$floc::g2_en == 1} {draw_cir $uzr::univ_canv $c $floc::g2 "" [percent2rgb 40 40 40]}
            if {$floc::g3_en == 1} {draw_cir $uzr::univ_canv $c $floc::g3 "" [percent2rgb 55 45 15]}
        }
        #
        if {$last_loc == {}} {
            set last_loc $c
        } elseif {$idx < [expr {$dlst_len - 1}]} {
            $uzr::univ_canv create line $x $z [lindex $last_loc 0] [lindex $last_loc 1] -arrow last -arrowshape {8 16 6} -fill #00af20
            set last_loc $c
        }
        incr idx
    }
    
}


# -------------------------------------------------------------------------
# Fetch the target page and cope with HTTP problems. This
# deals with server errors and proxy authentication failure
# and handles HTTP redirection.
#
proc fetchurl {url} {
    set html ""
    set err ""
    http::register https 443 [list ::tls::socket -autoservername true]
    set tok [http::geturl $url -timeout 30000]
    if {[string equal [http::status $tok] "ok"]} {
        if {[http::ncode $tok] >= 500} {
            set err "server error: [http::code $tok]"
        } elseif {[http::ncode $tok] >= 400} {
            set err "authentication error: [http::code $tok]"
        } elseif {[http::ncode $tok] >= 300} {
            upvar \#0 $tok state
            array set meta $state(meta)
            if {[info exists meta(Location)]} {
                return [fetchurl $meta(Location)]
            } else {
                set err [http::code $tok]
            }
        } else {
            set html [http::data $tok]
        }
    } else {
        set err [http::error $tok]
    }
    http::cleanup $tok

    if {[string length $err] > 0} {
        Error $err
    }
    return $html
}


# ###############################################################
#   dump the url to a file.
proc httpship { url file {chunk 4096} } {
    http::register https 443 [list ::tls::socket -autoservername true]
    set out [open $file w]
    set token [::http::geturl $url -channel $out \
            -progress httpCopyShip -blocksize $chunk]
    close $out

    # This ends the line started by httpCopyProgress
    puts stderr ""

    upvar #0 $token state
    set max 0
    puts $token
    foreach {name value} $state(meta) {
        if {[string length $name] > $max} {
            set max [string length $name]
        }
        if {[regexp -nocase ^location$ $name]} {
            # Handle URL redirects
            puts stderr "Location:$value"
            return [httpship [string trim $value] $file $chunk]
        }
    }
    incr max
    #foreach {name value} $state(meta) {
    #    puts [format "%-*s %s" $max $name: $value]
    #}

    return $token
}

proc httpCopyShip {args} {
    puts -nonewline stderr .
    flush stderr
}


proc locate_ship {} {
    set sid [$floc::s_ent get]
    #puts $sid
    set surl "https://farsite.online/api/1.0/ships/$sid"
    set ln [fetchurl $surl]
    #puts $ln
    set sstr [get_ship_dat $ln]
    #puts "'$sstr'"
    set sr [string trim [split $sstr] " "]
    set sid [lindex $sr 1]
    #puts $sid
    if {$floc::last_sys != $sid} {
        set floc::rep_lst {}
        set floc::last_sys $sid
    }
    
    draw_planet_view $sid
    ## draw the ship location and scan range
    draw_location $sr

}


proc tracking {} {
    if {$floc::trak == 0} {
        set floc::trak 1
        ::every::schedule [expr {$floc::tr_inter * 1000}] locate_ship
        $floc::trak_btn configure -text "Tracking"
        $floc::trak_btn configure -bg #40a040
    } else {
        ::every::cancel locate_ship
        set floc::trak 0
        $floc::trak_btn configure -text "Track"
        $floc::trak_btn configure -bg #a04040
    }
}

