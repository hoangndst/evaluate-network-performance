# type: perl granularity.pl <trace file> <from node> <to node> <granularity_sec>
$infile      = $ARGV[0];
$srcnode     = $ARGV[1];
$tonode      = $ARGV[2];
$granularity = $ARGV[3];
$start_time  = 0;
$end_time    = 0;


# we compute how many bytes were transmitted during time interval# specified by granularity parameter in seconds
$sum   = 0;
$clock = 0;
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
    if ( $x[0] == 'r' && $src == $srcnode && $to == $tonode ) {
        if ( $start_time <= 0 ) {
            $start_time = $x[1];
            $clock      = $start_time;


            # print STDOUT "Start_time = $start_time\n";
        }
        if ( $x[1] - $clock < $granularity ) { $sum = $sum + $x[5] * 8 / 1024; }
        else {
            $end_time   = $x[1];    # $throughput=$sum/$granularity;
            $throughput = $sum / ( $end_time - $clock );
            print STDOUT "$x[1] $throughput\n";
            $clock = $clock + $granularity;
            $sum   = 0;
        }
    }
}
if ( $x[1] - $clock < $granularity ) {
    $throughput = $sum / ( $x[1] - $clock );
    print STDOUT "$end_time $throughput\n";
}
close DATA;
exit(0);
