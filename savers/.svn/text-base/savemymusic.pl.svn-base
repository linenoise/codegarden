#!/usr/bin/perl -w
use strict;

# hexdump -C XDCardImage1024.dmg | grep -e "ff d8 ff e1" > headers.txt
open("HEADERS",'<','headers.txt')
  ||die "can't open EXIF headers file!\n$?\n$!\n";

# diskutil unmount /dev/disk1s1
# dd if=/dev/disk1s1 of=/Users/dann/Desktop/recordings.iso
open("CARDIMG",'<', 'recordings.iso')
  ||die "can't open card image!\n$?\n$!\n";

### Find the offsets.
my @headers = <HEADERS>;
chomp @headers;
my @offsets = ('00025600', '000bb600', '000e3600', '01a1f600');
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
  print "Found recording $index at offset $offsets[$index]... \n";

  ### Find the next offset distance (file size):
  my $nextoffset = $offsets[$index+1];
  my $distance = hex($nextoffset) - hex($offsets[$index]);

  ### If we're at the last record, guess one hundred megabytes
  $distance = 200000000 if $index == scalar(@offsets)-1;
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
    my $dumpfile = $index."_".uc($offsets[$index]).".mp3";
    open("IMAGEFILE",'>', $dumpfile);
    my $sizecheck = length($imagedata);
    syswrite(IMAGEFILE, $imagedata);
    close("IMAGEFILE");
    print "  Dump image data into $dumpfile.\n";

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
