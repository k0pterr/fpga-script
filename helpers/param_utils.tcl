
proc clog2 {n} {
    set num [expr $n - 1]
    for {set res 0} {$num > 0} {set res [expr $res + 1]} {
        set num [expr $num >> 1]
    }
    return $res
}

proc bits {x} {
    set n [clog2 ${x}]
    return [expr $x == (1 << ${n}) ? ${n} + 1 : ${n}]
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

proc param_exists {name {p config_params} } {

    upvar $p par

    set res [lsearch -index 0 $par $name]
    if {$res < 0} {
        return false 
    } else {
        return true
    }
}

