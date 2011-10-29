#!/usr/bin/perl -w
use strict;

open("HEADERS","<headers.txt")
  ||die "can't open EXIF headers file!\n$?\n$!\n";

open("CARDIMG","<XDCardImage256.dmg")
  ||die "can't open card image!\n$?\n$!\n";

### Find the offsets.
my @headers = <HEADERS>;
chomp @headers;
my @offsets;
foreach my $hexdump (@headers){
  if($hexdump =~ /^([0123456789abcdef]{8})/){
    push @offsets, $1;
  }
}
close("HEADERS");

### Put the file cursor at the first EXIF data find
my $trash = '';
sysread(CARDIMG,$trash,hex($offsets[0]));

### Pull the offsets into files
foreach my $index (0..scalar(@offsets)-1){
  print "Found image $index at offset $offsets[$index]... \n";

  ### Find the next offset distance (file size):
  my $nextoffset = $offsets[$index+1];
  my $distance = hex($nextoffset) - hex($offsets[$index]);

  ### If we're at the last record, guess one megabyte
  $distance = 1000000 if $index == scalar(@offsets)-1;
  print "  Next offset is at $nextoffset, ".
    "which is $distance bytes away.\n";

  ### Read that chunk of binary into a local scalar
  my $imagedata = "\0"x$distance;
  my $decimalOffset = hex($offsets[$index]);
  my $bytesread = sysread(CARDIMG,$imagedata,$distance);
  print "  Read binary data from card image: $distance expected,".
    " $bytesread received.\n";

  ### SANITY CHECK - are "what we wanted", "what we got", 
  ### and "what sysread told us" the same?
  if(($distance == $bytesread) && 
     (length($imagedata) == $distance)){
    
    ### Dump what we found into a file
    my $dumpfile = $index."_".uc($offsets[$index]).".jpg";
    open("IMAGEFILE",">dumps/$dumpfile");
    my $sizecheck = length($imagedata);
    syswrite(IMAGEFILE, $imagedata);
    close("IMAGEFILE");
    print "  Dump image data into dumps/$dumpfile.\n";

    ### exhale.
    print "done.\n\n";

  }else{

    ### Sanity check failed.  Dump and die.
    print "\n\n Sanity check failed:\n   Distance = $distance\n".
          "   Bytes Read = $bytesread\n".
          "   Image Buffer = ".length($imagedata)."\n\n";
    die;
  }
}
