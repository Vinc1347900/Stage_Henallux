#!/usr/bin/perl
use File::Glob ':glob';
use Data::Dumper;

@files = <*csv>;
my %results;
my $parmcount = 1;
my $lcount = 0;
foreach my $file (@files) {
    undef @lines;
    open (LOG, "<$file");
    my @lines = <LOG>;
    foreach my $line (@lines) {
        $lcount++;
        if ($line =~ /'Access\sspecification\sname.+/) {
            $line = $lines[$lcount];
            $line =~ /(.+),\d/;
            $thistest = $1;
        }
        if ($line =~ /ALL,All.+/) {
            @thisres = (split(",", $line));
            $results{$file}{$thistest}{IOps} = $thisres[6];
            $results{$file}{$thistest}{ReadIOps} = $thisres[7];
            $results{$file}{$thistest}{WriteIOps} = $thisres[8];
            $results{$file}{$thistest}{MBps} = $thisres[9];
            $results{$file}{$thistest}{ReadMBps} = $thisres[10];
            $results{$file}{$thistest}{CPU} = $thisres[45];
        }
    }
    $parmcount = 0;
    $lcount = 0;
}

sub swrite {
  my $fmt = shift(@_);
  $^A = '';
  formline($fmt,@_);
  return $^A;
}

my %output;
foreach my $logfile ( sort keys %results ) {
    $header = 1;
    foreach $test ( sort keys %{$results{$logfile}} ) {
        foreach $tsize ( sort keys %{$results{$logfile}{$test}} ) {
            $output{$test}{$logfile}{$tsize} =  swrite("@<<<<<<<<<<<<<", $results{$logfile}{$test}{$tsize});
        }
    }
}

foreach $testsize ( sort keys %output ) {
    $TXT .= "$testsize\n";
    $header = 1;
    foreach $unit ( sort keys %{$output{$testsize}} ) {
        if ($header) {
            $TXT .= "\t\t";
            foreach $test ( sort keys %{$output{$testsize}{$unit}} ) {
                $TXT .= swrite("@>>>>>>>>>>> @<<<<<<<<<<<<<<", $test);
            }
            $TXT .= "\n";
            undef $header;
        }
        $testunit = $unit;
        $testunit =~ s/\.csv//;
        $TXT .= swrite("@<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<", $testunit);

        foreach $test ( sort keys %{$output{$testsize}{$unit}} ) {
            $TXT .= swrite("@<<<<<<<<<<<<<<<<<", $output{$testsize}{$unit}{$test});
        }
        $TXT .= "\n";
    }
    $TXT .= "\n";
}

print $TXT;
