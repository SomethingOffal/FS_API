#! /usr/bin/env wish

package require http 2.0
package require tls 1.7
package require base64 ;# tcllib
package require Tk
package require Ttk
package require json 1.3.4

package require sqlite3

#http::register https 443 [list ::tls::socket -autoservername true]

namespace eval uzr {
    set name ""
    set pass ""
    set log_tok ""
}

namespace eval uni {
    set star_lst {}
    set planet_lst {}
    set gate_lst {}
}

namespace eval bp {
    set src "../BOM_SWIMLANE72.csv"
    set bp_lst {}
}

# ####################################################
#   extract BP  from  swimlane dump.
proc get_bp_lst {} {
    set fh [open $bp::src "r"]
    set fdat [read $fh]
    set fdat [split $fdat "\n"]
    
    set idx 0
    set header [lindex $fdat 0]
    set sheader [split $header ";"]
    set bid [lsearch $sheader "blue_id"]
    set bn [lsearch $sheader "blue_name"]
    set bcid [lsearch $sheader "component_id"]
    set cname [lsearch $sheader "component_name"]
    set ccode [lsearch $sheader "component_code"]
#    set ccode [lsearch $sheader "planet_names"]matres_input_name
    set mater [lsearch $sheader "matres_input_name"]
    set fdat [lrange $fdat 1 end]
    set bp_lst {}
    set last_bp ""
    set comp_lst {}
    set start 0
    foreach d $fdat {
        if {$d == ""} {
            set tlst  $last_bp
            set tlst [lappend tlst $bp_name]
            set tlst [lappend tlst [lsort -integer $comp_lst]]
            set bp_lst [lappend bp_lst $tlst]
            break
        }
        set sd [split $d ";"]
        
        ##  here get more details about the current.
        #set planets [lindex $sd end]
        #set splanets [split $planets ","]
        #set mat [lindex $sd $mater]
        #if {[llength $splanets] == 1} {
        #    puts "$planets  $mat"
        #}
#        set bp_id "[lindex $sd $bid] : [lindex $sd $bn]"
        set bp_id [lindex $sd $bid]
        #set bp_name [lindex $sd $bn]
        if {$bp_id == $last_bp} {
            #set bp_id [lindex $sd $bid]
            set bp_name [lindex $sd $bn]
            set comp_id [lindex $sd $bcid]
            if {[lsearch $comp_lst $comp_id] < 0} {
                set comp_lst [lappend comp_lst $comp_id]
            }
        } else {
            if {$start == 0} {
                set start 1
                set last_bp $bp_id
                continue
            }
            #puts $last_bp
            #puts [lsort -integer $comp_lst]
            set tlst  $last_bp
            set tlst [lappend tlst $bp_name]
            set tlst [lappend tlst [lsort -integer $comp_lst]]
            set bp_lst [lappend bp_lst $tlst]
            set last_bp $bp_id
            set comp_id [lindex $sd $bcid]
            set comp_lst {}
            set comp_lst [lappend comp_lst $comp_id]
            #set tlst {}
        }
    }
    set blue_list [lappend blue_list [list bp_id bp_name comps_list]]
    foreach b $bp_lst {
        set blue_list [lappend blue_list $b]
    }
    return $blue_list
}



# ############################################
#   get data from list   key:val
proc csv_data {tlst} {
    set rtn {}
    foreach p $tlst {
        set tstr ""
        set txt [string trim $p "\{\}"]
        set stxt [split $txt ","]
        set len [llength $stxt]
        set idx 1
        foreach k $stxt {
            set sk [split $k ":"]
            set tstr [append tstr [lindex $sk 1]]
            if {$idx < $len} {
                set tstr [append tstr ","]
            }
            incr idx
        }
        set rtn [lappend rtn $tstr]
    }
    return $rtn
}

# ############################################
#   get header from list   key:val
proc csv_header {txt} {
    set txt [string trim $txt "\{\}"]
    set stxt [split $txt ","]
    set h_lst {}
    #puts $txt
    foreach h $stxt {
        set sh [split $h ":"]
        set fld [lindex $sh 0]
        #puts $fld
        set h_lst [lappend h_lst $fld]
    }
    set len [llength $h_lst]
    set idx 1
    set rtn ""
    foreach k $h_lst {
        set rtn [append rtn [string trim $k "\""]]
        if {$idx < $len} {
            set rtn [append rtn ","]
        }
        incr idx
    }
    return $rtn
}

# ##################################################
#   extract planet list 
proc extract_list {fh lst} {
    set txt [gets $fh]
    #puts $txt
    set c1 [string first "stars" $txt]
    set ic1 [string range $txt $c1 end-1]
    #puts [string range $ic1 0 200]
    set slen [string length $ic1]
    set st_lst {}
    set tlst ""
    set start 0
    for {set i 1} {$i <= $slen} {incr i} {
        set c [string index $ic1 $i]
        if {$c == "\{"} {
            set tlst $c
            set start 1
        } elseif {$c == "\}"} {
            set tlst [append tlst $c]
            set st_lst [lappend st_lst $tlst]
            set tlst ""
        } else {
            if {$start == 1} {
                set tlst [append tlst $c]
            }
        }
    }
    return $st_lst
    #puts $sinfo
}
# #################################################
#   extrect the univers from the loaded univ_html
proc extract_uni {} {
    set fh [open "univ_html" "r"]
    set tlst {}
    set tlst [extract_list $fh $tlst]
    close $fh
    
    set header [csv_header [lindex $tlst 0]]
    set data [csv_data $tlst]
    set uarray $header
    #puts $header
    foreach l $data {
        set uarray [lappend uarray $l]
        #puts $l
    }
    set uni::star_lst $uarray
    return $data
}

proc get_url_data {url {chunk 4096} } {
    http::register https 443 [list ::tls::socket -autoservername true]
    set hndl [::http::geturl $url]
    set body [::http::data $hndl]
    set b1 [json::json2dict $body]
    #puts $body
    #set header [::http::meta $hndl]
    #puts $header
    foreach {n v} $b1 {
        puts "$n: $v"
    }
    
}
# set result [exec cmd /c ipconfig]   <<<  cmd shell start up.
#set my_cmd "|cmd.exe /c DIR C:\\\"Program Files\"\\G* /B"
#puts "Now executing the command '$my_cmd':\n"
#set f [open $my_cmd "r"]
#process command output
#while {[gets $f line] != -1} {
#  # print line
#  puts $line
#}
#close $f
# ###############################################################
#   dump the url to a file.
proc httpcopy { url file {chunk 4096} } {
    http::register https 443 [list ::tls::socket -autoservername true]
    set out [open $file w]
    set token [::http::geturl $url -channel $out \
            -progress httpCopyProgress -blocksize $chunk]
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
            return [httpcopy [string trim $value] $file $chunk]
        }
    }
    incr max
    foreach {name value} $state(meta) {
        puts [format "%-*s %s" $max $name: $value]
    }

    return $token
}

proc httpCopyProgress {args} {
    puts -nonewline stderr .
    flush stderr
}

#source "array.txt"

proc get_universe {} {
    set url "https://farsite.online/api/1.0/universe"
    set filo  "unv_dump/univ_html"
    httpcopy $url $filo
}

# ###################################################
#  get all the info about planets and gates.
#    input  :  csv list of stars  
proc get_planets_gates {data} {
    foreach p $data {
        set id [lindex [split $p ","] 0]
        puts $id
        set filo  "unv_dump/planet_html$id"
        set purl "https://farsite.online/api/1.0/universe/star/$id/planets"
        httpcopy $purl $filo
        
        after 250
        
        set gurl "https://farsite.online/api/1.0/universe/star/$id/gates"
    
        set filo  "unv_dump/gate_html$id"
        puts $filo
        httpcopy $gurl $filo
    
        after 250
        
        set surl "https://farsite.online/api/1.0/universe/star/$id/stations"
    
        set filo  "unv_dump/station_html$id"
        puts $filo
        httpcopy $surl $filo
    
        after 250
    }
}

# ######################################
#   change list into csv string
proc two_csv {lst} {
    set rtn ""
    set idx 0
    set llen [llength $lst]
    foreach i $lst {
        append rtn $i
        if {$idx < $llen-1} {
            append rtn ", "
        }
        incr idx
    }
    puts $rtn
    return $rtn
}

namespace eval spg {
    set sfields {id x y z size color textureId name}
    set sdb {}
    set pfields {starId id x y z name type size status resources}
    set pdb {}
    set gfields {starId id x y z name toStarId available type fuel defaultTime}
    set gdb {}
    set stdb {}
    set stfields {starId id x y z name}
}
# #####################################
#   get the planets and gates ...
#    NOT complete
proc extract_fields {lst flds} {
    set rtn {}
    set fields $flds
    set idx 1
    set len [string length $lst]
    set tstr ""
    set plst {}
    set tstr [string trim $lst "\]\["]
    set idx [string first "\},\{" $tstr]
    #puts $idx
    while {$idx >= 0} {
        set plst [lappend plst [string range $tstr 0 $idx]]
        set tstr [string range $tstr $idx+2 end]
        #puts $tstr
        set idx [string first "\},\{" $tstr]
    }
    # get the last planet.
    if {$tstr != ""} {
        set plst [lappend plst [string range $tstr 0 end]]
    }
    # if nothing return nul
    if {[llength $plst] == 0} {
        return {}
    }
    
    #set planet_list [lappend planet_list $fields]
    set planet_list {}
    foreach p $plst {
        set sp [split $p ","]
        set tline $flds
        set is_reso 0
        set star_plst {}
        set is_open 0
        foreach s $sp {
            set ss [split $s ":"]
            #puts [lindex $ss 0]
            set field [string trim [lindex $ss 0] "\{\""]
            set val [lindex $ss 1]
            #puts "Field:  $field  Value: $val"
            set idx [lsearch $fields $field]
            #puts $idx
            if {$idx < 0} {
                break
            }
            set preslst {}
            if {$val == "\"opened\""} {
                puts "found open"
                set is_open 1
            }
            if {$field == "\"resource\""} {
                set is_open 0
                puts "Found Resource on planet."
            }
            
            set tline [lreplace $tline $idx $idx [lindex $ss 1]]
            set star_plst [lappend star_plst $tline]
        }
        
        set planet_list [lappend planet_list $tline]
    }
    
    return $planet_list
    #foreach p $planet_list {
    #    puts [lindex $p 0]
    #}
}
# #####################################
#   get the stars
#    NOT complete
proc extract_stars {lst flds} {
    set rtn {}
    set fields $flds
    set idx 1
    set len [string length $lst]
    set tstr ""
    set plst {}
    set tstr [string trim $lst "\]\["]
    set idx [string first "\},\{" $tstr]
    #puts $idx
    while {$idx >= 0} {
        set plst [lappend plst [string range $tstr 0 $idx]]
        set tstr [string range $tstr $idx+2 end]
        #puts $tstr
        set idx [string first "\},\{" $tstr]
    }
    # get the last planet.
    if {$tstr != ""} {
        set plst [lappend plst [string range $tstr 0 end]]
    }
    # if nothing return nul
    if {[llength $plst] == 0} {
        return {}
    }
    
    #set planet_list [lappend planet_list $fields]
    set planet_list {}
    set plst [lrange $plst 1 end]
    foreach p $plst {
        set sp [split $p ","]
        set tline $flds
        set is_reso 0
        set star_plst {}
        set is_open 0
        foreach s $sp {
            set ss [split $s ":"]
            #puts [lindex $ss 0]
            set field [string trim [lindex $ss 0] "\{\""]
            set val [lindex $ss 1]
            #puts "Field:  $field  Value: $val"
            set idx [lsearch $fields $field]
            #puts $idx
            if {$idx < 0} {
                break
            }
            set preslst {}
            if {$val == "\"opened\""} {
                puts "found open"
                set is_open 1
            }
            if {$field == "\"resource\""} {
                set is_open 0
                puts "Found Resource on planet."
            }
            
            set tline [lreplace $tline $idx $idx [lindex $ss 1]]
            set star_plst [lappend star_plst $tline]
        }
        
        set planet_list [lappend planet_list $tline]
    }
    
    return $planet_list
    #foreach p $planet_list {
    #    puts [lindex $p 0]
    #}
}


proc extract_stations {lst flds} {
    set fields $flds
    set idx 1
    set len [string length $lst]
    set tstr ""
    set plst {}
    set tstr [string trim $lst "\]\["]
    set idx [string first "\},\{" $tstr]
    set rtn [list $flds]
    #puts $idx
    while {$idx >= 0} {
        set plst [lappend plst [string range $tstr 0 $idx]]
        set tstr [string range $tstr $idx+2 end]
        #puts $tstr
        set idx [string first "\},\{" $tstr]
    }
    # get the last planet.
    if {$tstr != ""} {
        set plst [lappend plst [string range $tstr 0 end]]
    }
    # if nothing return nul
    if {[llength $plst] == 0} {
        return {}
    }
    
    foreach st $plst {
        set sta_vals {}
        #foreach i $fields {
        #    set sta_vals [lappend sta_vals {}]
        #}
        set st [string trim $st "\{\}"]
        set ssst [split $st ","]
        foreach s $ssst {
            set ss [split $s ":"]
            set field [string trim [lindex $ss 0] "\"\{"]
            #puts $field
            set idx [lsearch $fields $field]
            #puts $idx
            set val [string trim [lindex $ss 1] "\"\}"]
            set sta_vals [lreplace $sta_vals $idx $idx $val]
        }
        if {$sta_vals != {}} {
            set rtn [lappend rtn $sta_vals]
        }
    }
    #puts $rtn
    return $rtn
}

# ####################################################
#  from downloaded planet info, create tcl list for sourcing
proc gen_planet_db {} {
    set pflst [glob -type file unv_dump/planet_html* ]
    set spg::pdb [lappend spg::pdb $spg::pfields]
    foreach f $pflst {
        set fh [open $f "r"]
        set hdat [gets $fh]
        close $fh
        set tmp [extract_fields $hdat $spg::pfields]
        if {$tmp != ""} {
            foreach p $tmp {
                set spg::pdb [lappend spg::pdb $p]
            }
        }
        
        #puts $f
    }
}

proc gen_gate_db {} {
    set gflst [glob -type file unv_dump/gate_html* ]
    set spg::gdb [lappend spg::gdb $spg::gfields]
    foreach f $gflst {
        set fh [open $f "r"]
        set hdat [gets $fh]
        close $fh
        set tmp [extract_fields $hdat $spg::gfields]
        #puts $tmp
        if {$tmp != ""} {
            foreach g $tmp {
                set spg::gdb [lappend spg::gdb $g]
            }
        }
        
        #puts $f
    }
}

proc gen_star_db {} {
    set sflst [glob -type file unv_dump/univ_html ]
    foreach f $sflst {
        set fh [open $f "r"]
        set hdat [gets $fh]
        close $fh
        
        set spg::sdb [extract_stars $hdat $spg::sfields]
        
        #puts $f
    }
}

proc gen_station_db {} {
    set sflst [glob -type file unv_dump/station_html* ]
    foreach f $sflst {
        set fh [open $f "r"]
        set hdat [gets $fh]
        close $fh
        #puts $hdat
        set hdat "\},[string range $hdat 1 end]"
        set spg::stdb [extract_stations $hdat $spg::stfields]
        
        #puts $f
    }
}



proc gen_sql {} {
    gen_planet_db
    gen_gate_db
    gen_star_db
    
    #puts "[two_csv $spg::sfields]"
    
    sqlite3 db univ.db
    db eval {CREATE TABLE stars([two_csv $spg::sfields])}
    set dval [lrange $spg::sdb 1 end]
    foreach s $dval {
        set cs [two_csv $s]
        db eval {INSERT INTO stars VALUES($cs)}
    }
    
    puts [db eval {SELECT * FROM stars}]
    
    set sd [db onecolumn {SELECT * FROM stars}]
    puts $sd
    
    db eval {SELECT * FROM stars ORDER BY "id"} values {
        parray values
        puts ""
    }
    
    db close
}
#gen_planet_db


# set t [frame .f1 -width 50]
# set nf [frame $t.nf1 -borderwidth 4 -relief sunken]
# set nl [label $nf.lbn -text "Name: "]
# set n [entry $nf.en1 -width 30 -textvariable $uzr::name]
# set pf [frame $t.pf1 -borderwidth 4 -relief sunken]
# set pl [label $pf.lbp -text "Password: "]
# set p [entry $pf.en2 -width 30 -show "#" -textvariable $uzr::pass]
# set b [button $t.bt1 -text "Log In" -command {fetch $sign_url $n $p}]

# pack $nl -side left -padx 4
# pack $n  -side right
# pack $nf -expand 1 -fill x
# pack $pl  -side left -padx 4
# pack $p  -side right
# pack $pf -expand 1 -fill x
# pack $b
# pack $t


# ######################################################################
#   market stuff
namespace eval mark {
    set bfields { id username }
    set ofields { id username }
    set dfields {type buyer $mark::bfields owner $mark::ofields buyPrice quantity isPartial originalId }
    #set mfields {id type objectType objectId data $mark::dfields createdAt}
    set mfields {id type objectType objectId data "$dfields" createdAt}
}

proc get_mark_data { str flds } {
    
    set idx 1
    set len [string length $str]
    set tstr ""
    set mlst {}
    set tstr [string trim $str "\]\["]
    set idx [string first "\},\{" $tstr]
    #puts $idx
    while {$idx >= 0} {
        set mlst [lappend mlst [string range $tstr 0 $idx]]
        set tstr [string range $tstr $idx+2 end]
        #puts $tstr
        set idx [string first "\},\{" $tstr]
    }
    
    # get the last planet.
    if {$tstr != ""} {
        set mlst [lappend mlst [string range $tstr 0 end]]
    }
    # if nothing return nul
    if {[llength $mlst] == 0} {
        return {}
    }
    
    foreach m $mlst {
        set len [string length $m]
        set idx 0
        set hidx 0
        while {$idx < $len} {
            set ch [lindex $mark::mfields $hidx]
            puts $ch
            set kl [string first $ch $m $idx]
            puts $kl
            if {$kl >= 0} {
                set send [expr {[string length $ch] + $kl}]
                set key [string range $m $kl $send-1]
                puts $key
                incr idx [string length $ch]
                incr hidx
            } else {
                puts "Key not found?  $idx  $mark::mfields"
                return
            }
        }
    }
}



# #####################################
#   get the planets and gates ...
#    NOT complete
proc get_mark_data_o { lst flds } {
    set rtn {}
    set fields $flds
    set idx 1
    set len [string length $lst]
    set tstr ""
    set mlst {}
    set tstr [string trim $lst "\]\["]
    set idx [string first "\},\{" $tstr]
    #puts $idx
    while {$idx >= 0} {
        set mlst [lappend mlst [string range $tstr 0 $idx]]
        set tstr [string range $tstr $idx+2 end]
        #puts $tstr
        set idx [string first "\},\{" $tstr]
    }
    
    # get the last planet.
    if {$tstr != ""} {
        set mlst [lappend mlst [string range $tstr 0 end]]
    }
    # if nothing return nul
    if {[llength $mlst] == 0} {
        return {}
    }
    
    set return_list {}
    foreach p $mlst {
        set slen [string length $p]
        set kov 0
        set inout 0
        set key ""
        set val ""
        set hlst {}
        set dlst {}
        set lst_lvl 0
        set lvl_lst {}
        for {set i 0} {$i < $slen} {incr i} {
            set c [string index $p $i]
            set code [scan $c %c]
            #puts $code
    #return
            incr lst_lvl
            if {$lst_lvl >= 100} {
                break
            }
            switch $code {
                ##  postrify
                ##  comoa
                "44" {
                    puts "got:  , "
                    set kov 0
                    set hlst [lappend hlst $key]
                    set dlst [lappend dlst $val]
                    set val ""
                    set key ""
                }
                ##  colon
                "58" {
                    puts "got:  : "
                    set kov 1
                }
                ##  left facing curly
                "125" {
                    if {$kov == 1} {
                        incr lst_lvl -1
                    } else {
                        puts "Error  unexpected open curly bracket at index $i"
                    }
                }
                ##  right facing curly
                "123" {
                    if {$kov == 1} {
                        set lvl_lst [lappend lvl_lst $key]
                        set key ""
                        set kov 0
                        incr lst_lvl
                    } else {
                        puts "Error  unexpected open curly bracket at index $i"
                    }
                }
                ##  space
                "32" {}
                default {
                    if {$kov == 1} {
                        append val $c
                    } else {
                        append key $c
                    }
                }
            }
            puts "inout : $inout"
            puts "kov  :  $kov"
            puts "Key  :  $key"
            puts "Val  :  $val"
        }
    
    }
    puts $dlst
    puts $hlst
    
    return $return_list
    #foreach p $return_list {
    #    puts [lindex $p 0]
    #}
}

# #####################################
#   read in the files with market data.
proc load_market_data {} {
    set flst [glob "../hist_*"]
    foreach f $flst {
        puts $f
        set fh [open $f "r"]
        set fdat [read $fh]
        close $fh
        set jvalid [json::validate $fdat]
        puts $fdat
        
        
        #set b1 [json::json2dict $fdat]
        #foreach {k v} $b1 {
        #    puts "$k: $v"
        #}
        #set mdat [get_mark_data $fdat $mark::mfields]
    }
    puts $flst
}

#exit
