
proc clog2 {n} {
    set num [expr $n - 1]
    for {set res 0} {$num > 0} {set res [expr $res + 1]} {
        set num [expr $num >> 1]
    }
    return $res
}

proc defparam {name value {p config_params} } {
    
    upvar $p par

    set item [list $name $value]
    lappend par ${item}
}

proc getparam {name {p config_params} } {
    
    upvar $p par
    
    return  [lindex [lsearch -index 0 -inline $par $name] 1]
}

