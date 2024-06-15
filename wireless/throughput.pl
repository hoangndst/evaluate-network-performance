# type: perl throughput.pl <trace file> <from node> <to node>
$infile  = $ARGV[0];
$srcnode = $ARGV[1];
$tonode  = $ARGV[2];


# we compute how many bytes were transmitted during time interval specified
$sum        = 0;
$start_time = -1;
$end_time   = 0;
open( DATA, "<$infile" ) || die "Can't open $infile $!";
while (<DATA>) {
    @x = split(' ');


    # get src_part, something like: '[0:0'
    # then split with ':'
    @parts_srcnode = split /:/, $x[13];


    # get the first part of splitter, will be '[0'
    $src = "$parts_srcnode[0]";


    # remove bracket
    $src =~ tr/[]//d;


    # get to_part, something like: '2:0'
    @parts_tonode = split /:/, $x[14];


    # get the first part of splitter
    $to = "$parts_tonode[0]";
    # checking if the event corresponds to a reception
    if (   $x[0] == "r"
        && $x[3] == "AGT"
        && $x[6] == "tcp"
        && $src == $srcnode
        && $to == $tonode )
    {
        if ( $start_time == -1 ) {
            $start_time = $x[1];
        }
        else {
            $sum += $x[7];
            if ( $x[1] != $start_time ) {
                $throughput = $sum / ( $x[1] - $start_time );
                $throughput = $throughput * 8 / 1024;
                print STDOUT "$x[1] $throughput \n";
            }
        }
    }
}
close DATA;
exit(0);