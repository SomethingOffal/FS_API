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
#           Description: This file contains most of the proces that access the
#               Farsite DB tab.  Also several generic procs to access rescources.
#
# -------------------------------------------------------------------------------

# for reloading / sourcing more than once. ...
set fts [font names]
set is_f [lsearch $fts font_info_txt]
if {$is_f  >= 0} {
    font delete font_info_txt font_info_res font_info_cou
}
font create font_info_txt -family Helvetica -size 8
font create font_info_res -family Helvetica -size 11 -weight bold
font create font_info_cou -family Courier -size 9

# ###################################
proc scrol_canv  {wid diff} {
    if {$diff < 0} {
        $wid yview scroll $diff unit
    } else {
        $wid yview scroll $diff unit
    }
}

# #####################################
#   get the resource chain based on passed ID
proc get_reso_chain {rid lst} {

    if {$rid == ""} {
        return ""
    }
    set rtn $lst
    set rlst {}
    # #{input_resource_id max min output_resource_id}
    set mlst {}
    set dlst {}
    set $res::cur_type {}
    #puts "looking for idx is $rid"
    foreach r $far_db::refo_lst {
        if {[lindex $r 0] == 0} {
            continue
        }
        #puts $r
        if {[lindex $r 0] == $rid} {
            set mlst [lappend mlst $r]
            #puts "Found master $mlst"
        } elseif {[lindex [lindex $r 1] 0] == $rid} {
            set dlst [lappend dlst $r]
            #puts "Found deriv  $dlst"
        }
    }
    
    ## if we got a main list
    if {$mlst != {}} {
        #set rlst [lappend rlst $mlst]
        set rlst $mlst
        set res::cur_type "prim"
    } else {
    ## else got deriviative
        if {$dlst != {}} {
            foreach d $dlst {
                set sres [lindex $d 0]
                set rlst [lappend rlst [get_reso_chain $sres $rlst]]
            }
           set res::cur_type "deriv"
        } else {
            set rtn {}
        }
    }
    return $rlst
}

# #####################################
#   get the res_lst item from id
proc get_reso {id} {
    set rtn {}
    foreach res $far_db::res_lst {
        if {[lindex $res 0] == $id} {
            set rtn $res
            break
        }
    }
    return $rtn
}

proc get_reso_id {wid} {
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set reso [$wid get $sel_idx]
    
    set id ""
    foreach r $far_db::res_lst {
        set info [lindex $r 1]
        set reso_info [string first $reso [lindex $info 0]]
        #puts $reso_info
        if {$reso_info >= 0} {
            set info $r
            set id [lindex $r 0]
            #puts $id
            break
        }
    }
    return [list $id $info]
}
# ######################################
#   get the material names from the ID
proc get_mat_code {id} {
    set header [lindex $far_db::res_lst 0]
    set header [lindex $header 1]
    set code_idx [lsearch $header "code"]
    set color_idx [lsearch $header "color"]
    
    set rtn {}
    set mlst {}
    foreach i $id {
        set mid [lindex $i 0]
        set rlst [lindex $i 1]
        set mlst [lappend mlst [lindex [lindex $i 1] 2]]
    }
    foreach md $far_db::res_lst {
        if {[lindex $md 0] == $mid} {
            set rtn [lappend rtn $md]
        }
    }
    # get  resource chain list.
    foreach dd $mlst {
        foreach md $far_db::res_lst {
            if {[lindex $md end] == $dd} {
                set rtn [lappend rtn $md]
            }
        }
    }
    
   return $rtn
}

# #########################################
#  get star by name
proc get_str_name {n} {
    foreach s $far_db::star_lst {
        set rtn {}
        set rtn [lappend rtn [lindex $s 0]]
        set star [lindex $s 1]
        set sn [lindex $star end]
        #puts "Check: $sn against: $n"
        if {$sn == $n} {
            set rtn [lappend rtn $star]
            break
        }
    }
    return $rtn
}

# ##############################################
#  get planets of star id
proc get_system {id} {
    
}
# ##############################################
#   get full star data of id passed.
proc get_star {id} {
    set rtn {}
    foreach s $far_db::star_lst {
        set sid [lindex [lindex $s 1] 0]
        if {$sid == $id} {
            set rtn $s
            break
        }
    }
    return $rtn
}

# ##########################################
#   make the resource list a single list if items
#   flatten to one index stream.
proc singlify {lst} {
    set rtn {}
    if {$res::cur_type == "prim"} {
        list lst $lst
        foreach c $lst {
            set rtn [lappend rtn $c]
        }
    } elseif {$res::cur_type == "deriv"} {
        foreach c $lst {
            foreach i $c {
                set rtn [lappend rtn $i]
            }
        }
    } else {
        puts  "no list !!!"
    }
    return $rtn
}

# ###################################################
#   get the connected stars to the star passed.
proc get_connected_stars {star} {
    set sid [lindex [lindex $star 1] 0]
    set all_star [get_star $sid]
    if {$all_star == {}} {
        return {}
    }
    set gates [lindex $all_star 3]
    set glst {}
    #set glst [lappend glst "$sid"]
    set header [lindex $gates 0]
    #puts $header
    set gates [lrange $gates 1 end]
    set next_idx [lsearch $header toStarId]
    set fuel_idx [lsearch $header fuel]
    foreach g $gates {
        #puts $g
        if {$g == ""} {
            continue
        }
        set glst [lappend glst [list [lindex $g $next_idx] [lindex $g $fuel_idx]]]
    }
    return $glst
}


# ##########################################
#  draw arrows on the canvase relative location x y
proc draw_arrows_r {canv x yt yb} {
    set xs [expr {$x + 4}]
    set xe [expr {$x + 16}]
    set ys [expr {($yb - $yt) / 2}]
    
    $canv create line $xs [expr {$ys + 6}] $xe $ys -width 2
    $canv create line $xs [expr {$ys - 6}] $xe $ys -width 2
    
}

# ###########################################
#  draw a circle
proc draw_cir {canv center sz fil} {
    set cx [lindex $center 0]
    set cy [lindex $center 1]
    set xt [expr {$cx - ($sz / 2)}]
    set xb [expr {$cx + ($sz / 2)}]
    set yt [expr {$cy - ($sz / 2)}]
    set yb [expr {$cy + ($sz / 2)}]
    $canv create oval $xt $yt $xb $yb -fill $fil
}

# ###########################################
#  draw star at location
proc draw_star {canv star center} {
    #puts $center
    set header [lindex $star 0]
    set dat [lindex $star 1]
    set id_idx [lsearch $header "id"]
    set name_idx [lsearch $header name]
    set sz_idx [lsearch $header size]
    set color_idx [lsearch $header color]
    
    set tx [lindex $center 0]
    set ty [expr {int([lindex $center 1]) - 26}]

    # draw connecting line
    #if {$uzr::canv_src_loc != [list 0 0]} {
        #set lxs [lindex $uzr::canv_src_loc 0]
        #set lys [lindex $uzr::canv_src_loc 1]
        
        #$canv create line $lxs $lys $tx [lindex $center 1] -fill #ffc0c0
        #set lstart $uzr::canv_src_loc
    #}


    draw_cir $uzr::univ_canv $center 20 [lindex $dat $color_idx]
    $canv create text $tx $ty -text [lindex $dat $name_idx] -font font_info_res -fill #80ff80
    #  add some text
    set tx [expr {$tx + 26}]
    set ty [expr {$ty + 20}]
    $canv create text $tx $ty -text [lindex $dat $id_idx] -font font_info_txt -fill #c0ffc0

}

# ##########################################
#  Draw the next start
proc get_next_loc {lvl pos binc} {

    set xinc [expr {$lvl * $binc}]
    set yinc [expr {$lvl * $binc}]
    set cx [lindex $uzr::canv_cent 0]
    set cy [lindex $uzr::canv_cent 1]
    #puts $uzr::canv_cnt2
#    set stx2 [expr {$cx - ($uzr::canv_cnt2 * $binc)}]
    set stx2 [expr {($cx -  $binc) + ($uzr::canv_cnt2 * $binc)}]
    set sty2 [expr {($cy -  $binc) + ($uzr::canv_cnt2 * $binc)}]
    
    #puts "x:$stx2 y:$sty2"
    
    set xloc ""
    set yloc ""
    #puts $lvl
    switch $lvl {
        0 {
            switch $pos {
                0 {set xloc [expr {$cx - int($xinc)}]; set yloc $cy}
                1 {set xloc $cx; set yloc [expr {$cy - int($yinc)}]}
                2 {set xloc [expr {$cx + int($xinc)}]; set yloc $cy}
                3 {set xloc $cx; set yloc [expr {$cy + int($yinc)}]}
                default {puts "Error:  "}
            }
        }
        1 {
            switch $pos {
                0 {set xloc [expr {$cx - int($xinc)}]; set yloc $cy}
                1 {set xloc $cx; set yloc [expr {$cy - int($yinc)}]}
                2 {set xloc [expr {$cx + int($xinc)}]; set yloc $cy}
                3 {set xloc $cx; set yloc [expr {$cy + int($yinc)}]}
                default {puts "Error:  "}
            }
        }
        2 {
            
            switch $pos {
                0 {set xloc [expr {$cx - int($xinc)}]; set yloc $sty2}
                1 {set xloc $stx2; set yloc [expr {$cy - int($yinc)}]}
                2 {set xloc [expr {$cx + int($xinc)}]; set yloc $sty2}
                3 {set xloc $stx2; set yloc [expr {$cy + int($yinc)}]}
                default {puts "Error:  "}
            }
            incr uzr::canv_cnt2
        }
        default {puts "Error:  "}
    }
    
    
    return [list $xloc $yloc]
}

# ############################################
#  display the material info from id passed
#   canv   canvas
#   mid   master id, materials have several sources.
#   id    material ID
#   x y   coorinate start place
proc mater_info {canv mid id x y {side ""}} {
    set rtn {}
    set tmp_lst {}
    set mx  $x
    set my  $y
    set refo {}
    
    #puts "$mid  $id"
    set header [lindex $far_db::refo_lst 0]
    #puts "mater header :  $header  looking for :  $mid $id"
    foreach i $far_db::refo_lst {
        #puts "$i  [lindex $i 0]"
        if {[lindex $i 0] == $mid} {
            set tmp_lst [lindex $i 1]
            if {[lindex $tmp_lst 0] == $id} {
                set refo $i
                break
            }
        }
    }
    if {$refo == {}} {
        return 1
    }
    set mlst [lindex $refo 1]
    
    set midm [lindex $mlst 0]
    set minm [lindex $mlst 1]
    set maxm [lindex $mlst 2]
    #puts $refo
    
    # get the refinery info
    set inqua ""
    set refine_cost ""
    set refine_dur ""
    set ref_header {}
#    set ref_dat {}
    set done [$canv find withtag "tg$mid"]
    #puts "Found tag $done"
    if {$side == "" && $done == {}} {
        #puts "Is not a side ..."
        set ref_header [lindex [lindex $far_db::refreq_lst 0] 1]
        foreach re $far_db::refreq_lst {
            set a [lindex $re 1]
            set ref_dat [lindex $re 1]
            #puts "$ref_dat  id: $id   mid: $mid"
            set isr [lsearch $ref_dat $mid]
            if {$isr >= 0} {
                #puts "Found refine data:  $ref_dat"
                break
            }
        }

        set tx [expr {$mx - 14}]
        set ty [expr {$my + 110}]
        set bx [expr {$mx + 250}]
        set by [expr {$my + 152}]
        $canv create rectangle $tx $ty $bx $by -width 3 -fill white -tag "tg$mid"

        set lx [expr {$mx - 8}]
        set ly [expr {$my + 122}]
        set idx 1
        foreach r $ref_dat {
            #puts "$r   [lindex $ref_header $idx]"
            switch [lindex $ref_header $idx] {
                "credits" {set ttxt "Cred"}
                "duration" {
                    set ttxt "Drua"
                    set r "[string range [expr {$r / 3600}] 0 4] hrs"
                }
                "input_qty" {set ttxt "Input"}
                "input_resource_id" {set ttxt "Ore ID"}
                default {puts "refinery header type or text not found ..."
                         set ttxt "Problem"}
            }
            if {$idx == 3} {
                set lx [expr {$lx + 130}]
                set ly [expr {$my + 122}]
            }
            $canv create text $lx $ly -text "$ttxt: $r" -font font_info_txt -justify left -anchor w
            incr idx
            incr ly 16
        }
    }
    
    
    set name ""
    set col ""
    foreach r $far_db::res_lst {
        if {[lindex $r 0] == $id} {
            set name [lindex [lindex $r 1] 0]
            set col [lindex [lindex $r 1] 4]
        }
    }
    
    # this is not a side product.
    #if {$side == ""} {
    #    set refino_lst {}
    #    foreach m $
    #}
    
    set bcolr "black"
    set brcolr "white"
    #puts $res::cur_name
    #puts "$name  $id   $mid"
    if {$res::cur_name == $name} {
        set bcolr "red"
        set brcolr "yellow1"
    }
    
    set tx [expr {$mx - 4}]
    set ty [expr {$my - 14}]
    set bx [expr {$mx + 100}]
    set by [expr {$my + 30}]
    $canv create rectangle $tx $ty $bx $by -outline $bcolr -width 3 -fill $brcolr

    $canv create text $mx $my -text $name -font font_info_res -justify left -anchor w -fill $col
    $canv create text $mx [expr {$my + 18}] -text $minm -font font_info_txt -justify left -anchor w
    $canv create text [expr {$mx + 40}] [expr {$my + 18}] -text $maxm -font font_info_txt -justify left -anchor w
}

# ###########################################
#  display the mine costs in passed cavnas
#    canv  canvas
#    id  resource id
#    y   y coorinate to start place
proc mine_cost {canv id x y} {
    set tmp_lst {}
    set my $y
    set mx $x
    set header [lindex $far_db::mine_lst  0]
    # collect info
    foreach h [lindex $header 1] {
        set hd_lst [lappend hd_lst $h]
    }
    foreach r $far_db::mine_lst {
        if {[lindex $r 0] == $id} {
            set tmp_lst [lappend tmp_lst [lindex $r 0]]
            foreach i [lindex $r 1] {
                set tmp_lst [lappend tmp_lst $i]
            }
            break
        }
    }
    set name ""
    set col ""
    foreach r $far_db::res_lst {
        if {[lindex $r 0] == $id} {
            set name [lindex [lindex $r 1] 0]
            set col [lindex [lindex $r 1] 4]
        }
    }
    # Draw in the info on the canvas.
    if {$tmp_lst != {}} {
        set idx 0
        # create the rectangle to draw on
        set ryb $y
        foreach h $hd_lst {
            incr ryb 20
        }
        ## add for the bottom cost text 3  60
        incr ryb 72
        set yt [expr {$y - 14}]
        set xb [expr {$x + 132}]
        set xt [expr {$x - 4}]
        $canv create rectangle $xt $yt $xb $ryb -width 3 -fill white
        # Draw in main resource name
        $canv create text $mx $my -text $name -font font_info_res -justify left -anchor w -fill $col
        incr my 22
        set cred 0
        set dura 0
        set exta 0
        foreach h $hd_lst {
            set dat [lindex $tmp_lst $idx]
            $canv create text $mx $my -text "$h:  $dat" -font font_info_txt -justify left -anchor w
            if {$h == "credits"} {
                set cred [lindex $tmp_lst $idx]
                #puts $cred
            }
            if {$h == "duration"} {
                set dura [lindex $tmp_lst $idx]
                #puts $dura
            }
            if {$h == "extraction"} {
                set exta [lindex $tmp_lst $idx]
                #puts $exta
            }
            incr idx
            incr my 20
        }
        set hr_dr [expr {$dura / 3600}]
        set cred_item [expr {$cred / $exta}]
        set itperhr [expr {$exta / $hr_dr}]
        $canv create text $mx $my -text "Hr/Cyc: [string range $hr_dr 0 6]" -font font_info_txt -justify left -anchor w
        incr my 20
        $canv create text $mx $my -text "Item / Hr: [string range $itperhr 0 6]" -font font_info_txt -justify left -anchor w
        incr my 20
        $canv create text $mx $my -text "Cost/Item: [string range $cred_item 0 6]" -font font_info_txt -justify left -anchor w
        
        #puts "Hours per cycle:  $hr_dr"
        #puts "Item at: $itperhr /hr costing  $cred_item  /unit"
    }
}

# ############################################
#  wid is expected to be a canvas
#  ch is the resource chain list.
proc disp_res_chain {cnv1 chain} {

    set rtn 1

    set col1 50
    set col2 220
    set col3 380
    set rw 50
    set hed 20


    set xc 50
    set yc 10
    set xm 192
    set xp 10
    set xs 340
    set yp 60
    set ym 0
    set ys 0
    
    set yincr 190
    set ymincr 60
    
    ##  canvas  column text
    $cnv1 create text $col1 $hed -text "Primary"
    $cnv1 create text $col2 $hed -text "Material"
    $cnv1 create text $col3 $hed -text "Side"
    $cnv1 create line 0 36 4500 36 -width 4
    
    #  create single list
    set res_chain [singlify $chain]
    
    set lastmid ""
    set mupdated 0
    foreach r $res_chain {
        set disp_lst {}
        set id [lindex $r 0]
        ##  update if different
        if {$id != $lastmid} {
            if {$lastmid != ""} {
                $cnv1 create line 0 [expr {$yp - 26}] 450 [expr {$yp - 26}] -width 4
            }
            set mreso [get_reso $id]
            #puts "Got res id :  $mreso"
            set lastmid $id
            set mupdated 1
            set disp_lst [lappend disp_lst $mreso]
            set ym $yp
            set ys $yp
        }
        ## get the derivative
        set der [lindex $r 1]
        #puts $der
        set der_id [lindex $der 0]
        #puts $der_id
        set dreso [get_reso $der_id]
        #puts "Got dres id :  $mreso"
        set disp_lst [lappend disp_lst $dreso]
        set orig_id ""
        
        foreach ir $disp_lst {
            set matid [lindex $ir 0]
            set dat [lindex $ir 1]
            set code [lindex $dat 0]
            set name [lindex $dat 1]
            set type [lindex $dat 2]
            set group [lindex $dat 3]
            set colr [lindex $dat 4]
            set vol [lindex $dat 5]
            if {$type == "Ore"} {
                set yc $yp
                set xc $xp
                mine_cost $cnv1 $id $xc $yc
                set orig_id $id
                incr yp $yincr
                
            } elseif {$type == "Material"} {
                set sidem 0
                if {$group == "Side"} {
                    set xc $xs
                    set  yc $ys
                    incr ys $ymincr
                    set sidem 1
                } else {
                    set xc $xm
                    set  yc $ym
                    incr ym $ymincr
                }
                #puts "ID:  $id   mat id:   $matid"
                if {$sidem == 0} {
                    mater_info $cnv1 $id $matid $xc $yc
                } else {
                    mater_info $cnv1 $id $matid $xc $yc $sidem
                }
            }
        }
    }
    set rtn 0
    return $rtn
}

# ########################################
proc show_res_details {wid} {

    update
    
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set reso [$wid get $sel_idx]
    
    if {$reso == "All"} {
        load_base
        return
    }
    
    set res::cur_name $reso
    #puts $reso
    set res_info [get_reso_id $wid]
    set id [lindex $res_info 0]
    set info [lindex $res_info 1]
    #  make a single list
    set inflst [lindex $info 0]
    foreach i [lindex $info 1] {
        set inflst [lappend inflst $i]
    }
    set header [lindex $far_db::res_lst 0]
    # clean up from previous
    set info_cont [winfo children $info::info_fr]
    foreach w $info_cont {
        destroy $w
    }
    #  set up for gen fields
    set fr $info::info_fr
    $fr configure -height 10
    set hdr [lindex $header 1]
    set idx 0
    set lb [label $fr.tlb -text "Resource Information" -justify center]
    pack $lb -side top -fill x -expand 1
    foreach t $hdr {
        set if_fr$idx [frame $fr.fr$idx -borderwidth 4 -relief sunken -width 60]
        set lbname $t
        #puts $lbname
        if {$lbname == ""} {
            incr idx
            continue
        }
        set lb [label $fr.fr$idx.lb -text $lbname]
        set lb1 [label $fr.fr$idx.lb2 -text [lindex $inflst $idx]]
        pack $lb -side left -padx 20
        pack $lb1 -side right -padx 20
        pack $fr.fr$idx -fill x -expand 1 -anchor nw
        incr idx
    }
    # get the resource chain
    set chain {}
    set chain [get_reso_chain $id $chain]
    #puts $chain
    set lbc [label $fr.clb -text "Resource Chain" -justify center]
    pack $lbc -side top -fill x -expand 1
    set cnv1 [canvas $fr.canv1  -borderwidth 4 -relief sunken -width 650 -height 900 -background wheat]
    $cnv1 configure -yscrollincrement 1
    $cnv1 configure -scrollregion {0 0 450 1200}
    pack $cnv1 -side top -fill both -expand 1
    bind $cnv1 <MouseWheel> {scrol_canv %W %D}
    if {$chain == {}} {
        mine_cost $cnv1 $id 10 20
    } else {
        set ok [disp_res_chain $cnv1 $chain]
    }
    
    
}

# ##############################################
proc inv_color {col} {
    set sc [split $col ""]
    set rtn "#"
    for {set i 1} {$i < [string length $col]} {incr i} {
        set tmp ""
        switch [lindex $sc $i] {
            0 {set tmp "f"}
            1 {set tmp "e"}
            2 {set tmp "d"}
            3 {set tmp "c"}
            4 {set tmp "b"}
            5 {set tmp "a"}
            6 {set tmp "9"}
            7 {set tmp "8"}
            8 {set tmp "7"}
            9 {set tmp "6"}
            a {set tmp "5"}
            b {set tmp "4"}
            c {set tmp "3"}
            d {set tmp "2"}
            e {set tmp "1"}
            f {set tmp "0"}
        }
        append rtn $tmp
    }
    return $rtn
}

# ##############################################
#   update the comps list box
proc load_comp_list {lst} {
    
    $comp::clb delete 0 end
    set clst {}
    foreach cmp $lst {
        if {[lindex $cmp 0] == "0"} {
            set header [lindex $cmp 1]
            continue
        }
        set cnumb [lindex $cmp 0]
        set nam [lindex [lindex $cmp 1] 1]
        set cid [lindex [lindex $cmp 1] 2]
        set csz [lindex [lindex $cmp 1] 4]
        set clst [lappend clst "$cnumb :  $nam $csz"]
        #$comp::clb insert end "$cnumb :  $nam $csz"
    }
    set clst [lsort -decreasing $clst]
    set cnt 0
    foreach c $clst {
        $comp::clb insert end $c
        incr cnt
    }
    set comp::comp_cnt "Showing: $cnt"
}

# ##############################################
#   update the comps list box
proc load_bp_list {lst} {
    
    $cmp_dets::bp_lb delete 0 end
    set plst {}
    foreach bp $lst {
        if {[lindex $bp 0] == "bp_id"} {
            set header $bp
            continue
        }
        set bid [lindex $bp 0]
        set bname [lindex $bp 1]
        set plst [lappend clst "$bid : $bname"]
        #$comp::clb insert end "$cnumb :  $nam $csz"
    }
    #set plst [lsort -integer $plst]
    set cnt 0
    foreach c $plst {
        $cmp_dets::bp_lb insert end $c
        incr cnt
    }
    set cmp_dets::bp_cnt "Showing: $cnt"
}

# #############################################
#  simple load, may need upgrading  hard coded indexes.
proc load_star_lst {lst} {
    $uzr::univ_strlb delete 0 end
    $uzr::univ_pltlb delete 0 end
    
    foreach s $lst {
        set star [lindex $s 1]
        set sname [lindex $star end]
        $uzr::univ_strlb insert end $sname
    }
}

proc show_star_view {wid} {
    set uzr::canv_cnt2 0
    set cx [lindex $uzr::canv_cent 0]
    set cy [lindex $uzr::canv_cent 1]
    set binc 100
    set px $cx
    set py $cy
    set lvl 0
    set pos 0

    set sel_idx [$wid curselection]
    #puts $sel_idx
    set sname [$wid get $sel_idx]
    set star [get_str_name $sname]
    set msidx [lindex [lindex $star 1] 0]
    set fstar [get_star $msidx]
    set uzr::canv_prev_star $msidx
    #puts [lindex $dat $id_idx]
    $uzr::univ_canv delete all
    draw_star $uzr::univ_canv $star [list $cx $cy]
    set uzr::canv_src_loc [list $cx $cy]
    set con_stars {}
    set con_stars [get_connected_stars $star]
    #puts $con_stars
    set lvl 1
    foreach c $con_stars {
        set uzr::canv_cnt2 0
        set s [get_star [lindex $c 0]]
        set fuel [lindex $c 1]
        set npos [get_next_loc $lvl $pos $binc]
        $uzr::univ_canv create line [lindex $npos 0] [lindex $npos 1] $cx $cy -fill #ffc0c0
        if {$fuel >= "700"} {
            set ffill #ff6060
        } else {
            set ffill #ffc000
        }
        $uzr::univ_canv create text [lindex $npos 0] [expr {[lindex $npos 1] + 20}] -text $fuel -fill $ffill
        #puts $npos
        draw_star $uzr::univ_canv $s $npos
        set con [get_connected_stars $s]
        set len [llength $con]
        #puts "$con  length $len"
        if {$len != 0} {
            set uzr::canv_src_loc $npos
            set lvl 2
            foreach l1 $con {
                if {[lindex $l1 0] == $uzr::canv_prev_star} {
                    continue
                }
                #puts "Draw next "
                set sl2 [get_star [lindex $l1 0]]
                set fuel [lindex $l1 1]
                set loc [get_next_loc $lvl $pos $binc]
                set nx [lindex $loc 0]
                set ny [lindex $loc 1]
                draw_star $uzr::univ_canv $sl2 [list $nx $ny]
                $uzr::univ_canv create line [lindex $npos 0] [lindex $npos 1] $nx $ny -fill #ffc000
                if {$fuel >= "700"} {
                    $uzr::univ_canv create text $nx [expr {$ny + 20}] -text $fuel -fill #ff6060
                } else {
                    $uzr::univ_canv create text $nx [expr {$ny + 20}] -text $fuel -fill #ffc000
                }
            }
        }
        incr pos
        #if {$pos >= 4} break
        set lvl 1
    }
    
    load_planet_lst $fstar
}

proc load_planet_lst {star} {
    # enter planets in planet list box
    set pheader [lindex [lindex $star 2] 0]
    set nidx [lsearch $pheader "name"]
    set pdat [lrange [lindex $star 2] 1 end]
    $uzr::univ_pltlb delete 0 end
    foreach p $pdat {
        set pname [lindex $p $nidx]
        $uzr::univ_pltlb insert end $pname
        #puts $pname
    }
    set gheader [lindex [lindex $star 3] 0]
    set nidx [lsearch $pheader "name"]
    set gdat [lrange [lindex $star 3] 1 end]
    foreach g $gdat {
        set gname [lindex $g $nidx]
        $uzr::univ_pltlb insert end $gname
        #puts $pname
    }
    
}

proc show_planet_view {wid} {
    set cx [lindex $uzr::canv_cent 0]
    set cy [lindex $uzr::canv_cent 1]
    set scale_down 26
    $uzr::univ_canv delete all
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set pname [$wid get $sel_idx]
    #puts $uzr::canv_prev_star
    set sdat [get_star $uzr::canv_prev_star]
    set star [lindex $sdat 1]
    set planets [lindex $sdat 2]
    set gates [lindex $sdat 3]
    
    set pdat [lrange $planets 1 end]
    foreach p $pdat {
        set cid [lindex $p 0]
        set x [lindex $p 2]
        set y [lindex $p 3]
        set z [lindex $p 4]
        set pn [lindex $p 5]
        set pt [lindex $p 6]
        set pav [lindex $p 8]
        set rad [expr {sqrt(($x * $x) + ($z * $z))}]
        
        # adjust the size and center.
        set x [expr {int($x / $scale_down) + $cx}]
        set z [expr {int($z / $scale_down) + $cy}]
        set rad [expr {int($rad / $scale_down)}]
        set c $x
        set c [lappend c $z]
        set xt [expr {$cx - $rad}]
        set yt [expr {$cy - $rad}]
        set xb [expr {$cx + $rad}]
        set yb [expr {$cy + $rad}]
        $uzr::univ_canv create oval $xt $yt $xb $yb -dash 20 -outline #203020
        if {$pname == $pn} {
            draw_cir $uzr::univ_canv $c 25 #80ff80
            $uzr::univ_canv create text $x [expr {$z - 20}] -text $pn -font font_info_cou -fill #ffffff
        } else {
            draw_cir $uzr::univ_canv $c 15 #a0a0a0
        }
    }
    draw_star $uzr::univ_canv $sdat [list $cx $cy]
    
    set gheader [lindex $gates 0]
    set gdat [lrange $gates 1 end]
    set gc_lst {}
    foreach g $gdat {
    # starId id x y z name toStarId available type
        set x [lindex $g 2]
        set y [lindex $g 3]
        set z [lindex $g 4]
        set gn [lindex $g 5]
        set gt [lindex $g 6]
        set gav [lindex $g 7]
        set gtp [lindex $g 8]
        
        set x [expr {int($x / $scale_down) + $cx}]
        set z [expr {int($z / $scale_down) + $cy}]
        set xt [expr {$x - 10}]
        set yt [expr {$z - 10}]
        set xb [expr {$x + 10}]
        set yb [expr {$z + 10}]
        if {$pname == $gn} {
            $uzr::univ_canv create rectangle [expr {$xt - 10}] [expr {$yt-10}] $xb $yb -fill #40ff40
        } else {
            $uzr::univ_canv create rectangle $xt $yt $xb $yb -fill #fff080
        }
        $uzr::univ_canv create text $xb [expr {$yb + 20}] -text $gn -fill #ffffff
        set gc_lst [lappend gc_lst [list $x $z]]
    }
    set sid [lindex $star 0]
    set s [expr {srand($sid)}]
    set nstars [expr {int(rand() * 200.0 + 100.0)}]
    for {set i 1} {$i < $nstars} {incr i} {
        set loc [expr {int(rand() * 1300)}]
        set loc [lappend loc [expr {int(rand() * 980)}]]
        set r [expr {int(rand() * 127)}]
        set g [expr {int(rand() * 127)}]
        set b [expr {int(rand() * 127)}]
        #puts $num
        set color [format "#%02X%02X%02X" $r $g $b]
        draw_cir $uzr::univ_canv $loc 4 $color

    }
    
}

# #######################################
#  fill the reso listbox with passed list
proc load_reso_lb {lst} {
    set header ""
    $res::plb delete 0 end
    $res::plb insert end "All"
    foreach ore $lst {
        if {[lindex $ore 0] == "0"} {
            set header [lindex $ore 1]
            continue
        }
        set data [lindex $ore 1]
        # filter off the reso  not discovered.
        if {[lindex $data end] != "True"} {continue}
        $res::plb insert end [lindex $data 0]
        $res::plb itemconfigure end -background [lindex $data 4]
        $res::plb itemconfigure end -foreground white
    }
}

# ###############################################
proc load_base {} {
    puts "loading base ..."
    load_reso_lb $far_db::res_lst
    # load blueprints
    load_bp_list $far_db::bp_lst
    # load comps list with default
    load_comp_list $far_db::comps_lst
    #  reset check button state
    set comp::show_uzr_comps 0
    set comp::show_uzr_txt "Show Buildable"
    load_star_lst $far_db::star_lst
}

load_base
# ##################################################################################
#   component stuff
# ##################################################################################

# #####################################
#   get the component spec from id sent
#    id :  name
proc get_comp_spec {cmp} {
    set rtn {}
    
    set scomp [split $cmp ":"]
    set cid [lindex $scomp 0]
    set header ""
    set rlst {}
    
    foreach c $far_db::compres_lst {
        if {[lindex $c 0] == 0} {
            set header [lindex $c 1]
            set rtn [lappend rtn $header]
        }
        
        if {[lindex $c 0] == $cid} {
            #  flatten  c
            set tlst {}
            set tlst [lappend tlst [lindex $c 0]]
            set tlst [lappend tlst [lindex [lindex $c 1] 0]]
            set tlst [lappend tlst [lindex [lindex $c 1] 1]]
            set rtn [lappend rtn $tlst]
        }
    }
    return $rtn
}

# #################################
#   filter the list box based on entry
#   wid   entry widget
#   lb    list box to filter.
proc filter_lb {wid lb} {
    set txt [string tolower [$wid get]]
    #puts $txt
    ## if no text reload 
    if {$txt == ""} {
        load_base
        return
    }
    $lb delete 0 end
    
    if {$wid == $comp::filter} {
        foreach cmp $far_db::comps_lst {
            if {[lindex $cmp 0] == "0"} {
                continue
            }
            set cnumb [lindex $cmp 0]
            set nam [lindex [lindex $cmp 1] 1]
            set cid [lindex [lindex $cmp 1] 2]
            set compt [string tolower "$cid :  $nam"]
            set is_one [string first $txt $compt]
            if {$is_one >= 0} {
                $comp::clb insert end "$cnumb :  $nam"
            }
        }
    } elseif {$wid == $cmp_dets::bp_filter} {
        set bp_lst [lrange $far_db::bp_lst 1 end]
        foreach bp $bp_lst {
            set bpid [lindex $bp 0]
            set bpna [lindex $bp 1]
            set field "$bpid : $bpna"
            set lfield [string tolower $field]
            set is_in [string first $txt $lfield]
            if {$is_in >= 0} {
                $cmp_dets::bp_lb insert end $field
            }
        }
    } else {
        puts "Error unknown list box ..."
        return
    }
    #$cmp_dets::bp_lb
    #puts $wid
    
    #$lb delete 0 end
}

# ##############################################
#  show the component details.
#   wid is the component list box
proc show_comp_details {wid} {
    
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set comp_txt [$wid get $sel_idx]
    set comp::comp_id $comp_txt
    #set res::cur_name $reso
    #puts $comp_txt
    set comp_spec [get_comp_spec $comp_txt]
    #puts $comp_spec
    
    ##  hard coded index ...
    set dlst [lrange $comp_spec 1 end]
    #$cmp_dets::canv delete all
    #$cmp_dets::canv configure -scrollregion {0 0 450 3600}
    #bind $cmp_dets::canv <MouseWheel> {scrol_canv %W 1}
    set mlst {}
    foreach d $dlst {
        set r [lindex $d 1]
        set mlst [lappend mlst [get_reso $r]]
    }
    
    #$res::plb delete 0 end
    #$res::plb insert end "All"
    set reso_lst {}
    foreach r $mlst {
        #puts $r
        set mat [lindex [lindex $r 1] 0]
        foreach ore $far_db::res_lst {
            if {[lindex $ore 0] == "0"} {
                set header [lindex $ore 1]
                continue
            }
            set data [lindex $ore 1]
            #puts $data
            set name [lindex $data 0]
            #puts "Looking for '$mat'   but is  '$name'"
            if {$name == $mat} {
                #puts $name
                #break
                set reso_lst [lappend reso_lst $ore]
                #set txt [inv_color [lindex $data 4]]
                #$res::plb insert end [lindex $data 0]
                #$res::plb itemconfigure end -background [lindex $data 4]
                #puts $txt
                #$res::plb itemconfigure end -foreground white
                #puts $ore
            }
        }
    }
    load_reso_lb $reso_lst
}

# ##############################################
#  show the blueprint details.
#   wid is the component list box
proc show_bp_details {wid} {
    
    set sel_idx [$wid curselection]
    #puts $sel_idx
    set bp_txt [$wid get $sel_idx]
    set stxt [split $bp_txt ":"]
    
    set pid [string trim [lindex $stxt 0]]
    #puts $pid
    set rtn {}
    set bdat [lrange $far_db::bp_lst 1 end]
    foreach p $bdat {
        #puts $p
        if {[lindex $p 0] == $pid} {
            set rtn $p
            break
        }
    }
    set bp_clst {}
    foreach c $far_db::comps_lst {
        if {[lindex $c 0] == 0} {continue}
        set c_idx [lindex $c 0]
        #puts $c_idx
        foreach pc $rtn {
            set pidx [lsearch $pc $c_idx]
            if {$pidx >= 0} {
                set bp_clst [lappend bp_clst $c]
                #puts $c
                break
            }
        }
    }
    
    set rtn [lsort -index 0 -integer $bp_clst]

    load_comp_list $rtn
    set rlst [get_rlst_from_clst $rtn]
    
    #puts $rtn
}

# #################################################################################
#   access functions
#
#  get the list of components from the material passed
#    if not a mat,  return list of full component details.
proc get_comps_from_id {wid} {
    set sel_idx [$wid curselection]
    set sel_txt [$wid get $sel_idx]
    
    set midx ""
    foreach m $far_db::res_lst {
        if {[lindex $m 0] == 0} {continue}
        set lnm [lindex [lindex $m 1] 0]
        if {$lnm == $sel_txt} {
            set typ [lindex [lindex $m 1] 2]
            if {$typ == "Ore"} {return ""}
            set disc [lindex [lindex $m 1] end]
            if {$disc != "True"} {return ""}
            set midx [lindex $m 0]
            #puts "Found $lnm  index :  $midx"
            break
        }
    }
    if {$midx == ""} {return ""}
    set cmp_lst {}
    foreach cmp $far_db::compres_lst {
        if {[lindex $cmp 0] == 0} {continue}
        set res [lindex [lindex $cmp 1] 0]
        if {$res == $midx} {
            set comp [lindex $cmp 0]
            set cmp_lst [lappend cmp_lst $comp]
        }
    }
    set fcmp_lst {}
    foreach c $far_db::comps_lst {
        set id [lindex $c 0]
        if {[lsearch $cmp_lst [lindex $c 0]] >= 0} {
            set fcmp_lst [lappend fcmp_lst $c]
        }
    }
    #foreach c $cmp_lst {
    #    puts $c
    #}
    return $fcmp_lst
}

# #######################################
#  get the Blue prints that have items on
#    the component list passed.
proc get_bp_from_comp_lst {lst} {
    set rtn_lst {}
    foreach bp $far_db::bp_lst {
        set bps [lindex $bp 2]
        foreach c $lst {
            #puts $c
            set cid [lindex $c 0]
            set ison [lsearch $bps $cid]
            if {$ison >= 0} {
                if {[lsearch $rtn_lst $bp] < 0} {
                    set rtn_lst [lappend rtn_lst $bp]
                }
            }
        }
    }
    return $rtn_lst
}

# ########################################
#   get components from BP  id
proc get_get_comps_from_bp {id} {
    set rtn {}
    set bp {}
    foreach b $far_db::bp_lst {
        set bid [lindex $b 0]
        if {$bid == $id} {
            set bp $b
            set clst [lindex $b 2]
        }
    }
    foreach c $clst {
        foreach r $far_db::comps_lst {
            set rid [lindex $r 0]
            if {$rid == $c} {
                set rtn [lappend rtn $r]
            }
        }
    }
    return $rtn
}

# ###########################################
#   get resourse list from component list.
proc get_rlst_from_clst {clst} {
    set rtn {}
    set rlst {}
    set rqu_lst {}
    foreach c $clst {
        set fc [lindex $c 0]
        foreach i $far_db::compres_lst {
            set id [lindex $i 0]
            if {$id == $fc} {
                set resl [lindex $i 1]
                set rid  [lindex $resl 0]
                set is_on [lsearch $rlst $rid]
                if {$is_on} {
                }
                set rid [lappend rid [lindex $resl 1]]
            }
        }
        #puts $c
    }
}
# ################################################
#  update the whole view of lists based on sorting mode
#  
proc update_view {wid} {
    set sel_idx [$wid curselection]
    set sel_txt [$wid get $sel_idx]
    if {$wid == $res::plb} {
        if {$cmode::srch_mode == "Reso"} {
            set rcmp_lst [get_comps_from_id $wid]
            if {$rcmp_lst != ""} {
                load_comp_list $rcmp_lst
                set bp_lst [get_bp_from_comp_lst $rcmp_lst]
                load_bp_list $bp_lst
            } else {
                load_comp_list $far_db::comps_lst
                load_bp_list $far_db::bp_lst
            }
        }
        show_res_details $wid
    } elseif {$wid == $comp::clb} {
        if {$cmode::srch_mode == "Reso"} {
            set ssel [split $sel_txt ":"]
            set cmpid [string trim [lindex $ssel 0]]
            set bp_lst [get_bp_from_comp_lst $cmpid]
            load_bp_list $bp_lst
        } elseif {$cmode::srch_mode == "Comp"} {
            set ssel [split $sel_txt ":"]
            set cmpid [string trim [lindex $ssel 0]]
            set bp_lst [get_bp_from_comp_lst $cmpid]
            load_bp_list $bp_lst            
            show_comp_details $wid
        } elseif {$cmode::srch_mode == "Blue"} {
            show_comp_details $wid
        }
        
    } elseif {$wid == $cmp_dets::bp_lb} {
        if {$cmode::srch_mode == "Blue"} {
            set ssel [split $sel_txt ":"]
            set bpid [string trim [lindex $ssel 0]]
            set cmplst [get_get_comps_from_bp $bpid]
            load_comp_list $cmplst
            set reso_lst [get_rlst_from_clst $cmplst]
        }
    } else {
        puts "Error update_view unexpected wid def ..."
        return
    }
}