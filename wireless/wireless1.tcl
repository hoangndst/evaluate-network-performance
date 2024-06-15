# A simple example for wireless simulation

# ======================================================================
# Define options
# ======================================================================
set val(chan)	Channel/WirelessChannel	;# channel type
set val(prop)	Propagation/TwoRayGround ;# radio-propagation model
set val(netif)	Phy/WirelessPhy		;# network interface type
set val(mac)	Mac/802_11		;# MAC type
set val(ifq)	Queue/DropTail/PriQueue	;# Interface queue type
set val(ll)	LL			;# Link layer type
set val(ant)	Antenna/OmniAntenna	;# Antenna type
set val(x)	670	;# X dimension of the topography
set val(y)	670	;# Y dimension of the topography
set val(ifqlen)	50	;# max packet in ifq
set val(seed)	0.0		;# random seed 
set val(adhocRouting)	AODV	;# AODV/DSDV/TORA...
set val(nn)             74	;# how many nodes are simulated
# set val(cp)	"../mobility/scene/cbr-3-test" 
set val(cp)	"./cbr-3-test"		;#cp= connection pattern 
# set val(sc)	"../mobility/scene/scen-3-test" 
set val(sc)	"./20021361.txt"		;#sc= scenario= movement pattern 
set val(stop)	400.0			;# simulation time

# =====================================================================
# Main Program
# ======================================================================
#
# Initialize Global Variables
#
# create simulator instance
set ns_		[new Simulator]

# setup topography object
set topo	[new Topography]

# create trace object for ns and nam
set tracefd	[open wireless1-out.tr w]
set namtrace    [open wireless1-out.nam w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# define topology
$topo load_flatgrid $val(x) $val(y)

# Create ogject God (General Operations Director)
# that stores the total number of mobilenodes and a table of shortest
# number of hops required to reach from one node to another. ++
set god_ [create-god $val(nn)]

# define how node should be created
#

#global node setting (configuring)
$ns_ node-config -adhocRouting $val(adhocRouting) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -channelType $val(chan) \
		 -topoInstance $topo \
		 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON 


#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 
for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0	;# disable random motion
}

# Define node movement model
puts "Loading connection pattern..."
source $val(cp)			;# Load and run codes specified by $val(cp)

# Define traffic model
puts "Loading scenario file..."
source $val(sc)			;# Load and run codes specified by $val(sc)

# Define node initial size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
# 20 defines the node size but node position in nam, 
# must adjust it according to your scenario. 
# The function must be called after mobility model is defined
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y) rp $val(adhocRouting)"
puts $tracefd "M 0.0 sc $val(sc) cp $val(cp) seed $val(seed)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"

puts "Starting Simulation..."
$ns_ run

