#!/usr/bin/perl -w

###
# buildTable.pm
#  used to build tables of many sorts
# Copyright (C) 2004-2005 Dann Stayskal <dann@doulopolis.net>
#
# This program is free software; you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option) 
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA 02111-1307 USA
###

###
# Sample usage:
#   #!/usr/bin/perl -w
#   use strict;
#   use buildTable;
#
#   my $labels = ['Name','Stands for','Used for'];
#
#   my $data = [
#     {'Name'=>'pretty',
#      'Stands for'=>'Prettied print',
#      'Used for'=>'Text tables with a hint of ASCII art'},
#     {'Name'=>'csv',
#      'Stands for'=>'Comma Separated Values',
#      'Used for'=>'I/O to and from databases and spreadsheets'},
#     {'Name'=>'tsv',
#      'Stands for'=>'tab Separated Values',
#      'Used for'=>'I/O to and from databases and spreadsheets'},
#     {'Name'=>'fixed',
#      'Stands for'=>'Fixed-width columns',
#      'Used for'=>'Preformatted printing, like often used in shells'},
#     {'Name'=>'html',
#      'Stands for'=>'Hypertext Markup Language',
#      'Used for'=>'Web pages'},
#     {'Name'=>'xml',
#      'Stands for'=>'eXtensible Markup Language',
#      'Used for'=>'SGML-compatible data representation and storage'},
#     {'Name'=>'yaml',
#      'Stands for'=>'Yaml a\'int a markup language!',
#      'Used for'=>'Serializing data, human readability'},
#   ];
#
#   print buildTable($labels,$data,
#     {'title'=>'Formats understood by buildTable()','format'=>'pretty'});
###

package buildTable;
use strict;
require Exporter;

my @ISA = qw(Exporter);

my @EXPORT_OK = qw( buildTable );

sub buildTable{
  my ($labels,$data,$options) = @_;

  ### make sure we're dealing with well-formed input
  $options = {} unless ref $options eq 'HASH';
  $$options{format} = 'pretty' unless $$options{format};
  foreach my $datum (@$data){
    foreach my $label (@$labels){
      $$datum{$label} ||='';
    }
  }
  return '' unless $labels && ref $labels eq 'ARRAY' && $data && ref $data eq 'ARRAY'
    && scalar(@$labels) && scalar(@$data) && ref $$data[0] eq 'HASH';

  ### Pretty, ASCII-art style printing (default!  yay!)
  if($$options{format} eq 'pretty'){

    ### Calculate the column widths
    my %width;
    foreach my $label (@$labels){
      $width{$label} = $_ foreach sort({$a<=>$b}
        map({length(scalar($$_{$label}))}@$data));
      $width{$label} = length(scalar($label))
        if $width{$label} < length(scalar($label));
    }

    ### Calculate table dimensions
    my $totalwidth = 4 + 3*(scalar(@$labels)-1);
    $totalwidth += $width{$_} foreach keys %width;
    if($$options{title}){
      if(length($$options{title})+4 > $totalwidth){
        ### If the title's wider than the table, widen the table.
        my $difference = length($$options{title}) + 4 - $totalwidth;
        $totalwidth += $difference;
        $width{$$labels[-1]} += $difference;
      }
    } 
    my $format = '| '.join(' | ',map({'%-'.$width{$_}.'s'}@$labels))." |\n";

    ### Piece it together.  Start with the first ruled line
    my $str = '.'.'-'x($totalwidth-2).".\n";

    ### If they asked for a title, give them one.
    if($$options{title}){
      $str .= sprintf('| %-'.($totalwidth-4).'s |',$$options{title})."\n".
        '|'.'-'x($totalwidth-2)."|\n";
    }

    ### Unless they asked for no labels, give them some and another line
    unless($$options{nolabels}){
      $str .= sprintf($format,@$labels).'|'.'-'x($totalwidth-2)."|\n";
    }

    ### Add the completed data table
    foreach my $element (@$data){
      $str .= sprintf($format,map({$$element{$_}?$$element{$_}:' '}@$labels));
    }
    $str .= '\''.'-'x($totalwidth-2)."'\n";

    ### Return it.
    return $str;

  ### Comma separated values
  }elsif($$options{format} eq 'csv'){

    my $str = '';
    
    ### Print the labels, if requested
    unless($$options{nolabels}){
      $str .= join(',',map("\"$_\"",@$labels))."\n";
    }

    ### Escape and append the data
    foreach my $datum (@$data){
      foreach my $label (@$labels){
        $$datum{$label} =~ s/\"/\\"/g;
      }
      $str .= join(',',map("\"$$datum{$_}\"",@$labels))."\n";
    }

    ### Return it.
    return $str;

  ### Tab separated values
  }elsif($$options{format} eq 'tsv'){

    my $str = '';
    
    ### Print the labels, if requested
    unless($$options{nolabels}){
      $str .= join("\t",@$labels)."\n";
    }

    ### Escape and append the data
    foreach my $datum (@$data){
      foreach my $label (@$labels){
        $$datum{$label} =~ s/\t/\\\t/g;
      }
      $str .= join("\t",map($$datum{$_},@$labels))."\n";
    }

    ### Return it.
    return $str;

  ### Fixed-width (shell style)
  }elsif($$options{format} eq 'fixed'){

    my $str;

    ### Calculate the column widths
    my %width;
    foreach my $label (@$labels){
      $width{$label} = $_ foreach sort({$a<=>$b}
        map({length(scalar($$_{$label}))}@$data));
      $width{$label} = length(scalar($label))
        if $width{$label} < length(scalar($label));
    }

    my $format = join('  ',map({'%-'.$width{$_}.'s'}@$labels))."\n";

    ### If they asked for a title, give them one.
    if($$options{title}){
      $str .= "$$options{title}\n";
    }

    ### Unless they asked for no labels, give them some
    unless($$options{nolabels}){
      $str .= sprintf($format,@$labels);
    }

    ### Add the completed data table
    foreach my $element (@$data){
      $str .= sprintf($format,map({$$element{$_}?$$element{$_}:' '}@$labels));
    }

    ### Return it.
    return $str;

  ### An HTML table
  }elsif($$options{format} eq 'html'){

    foreach my $key (qw/tableAttributes thAttributes tdAttributes trAttributes/){
      if($$options{$key}){
        $$options{$key} = " $$options{$key}";
      }else{
        $$options{$key} = '';
      }
    }
    my $str = "<table$$options{tableAttributes}>\n";
   
    if($$options{title}){
      $$options{title} =~ s/&/&amp;/g;
      $$options{title} =~ s/</&lt;/g;
      $$options{title} =~ s/>/&gt;/g;
      $str .= "  <tr$$options{trAttributes}><th$$options{thAttributes}".
        " rowspan=\"".scalar(@$labels)."\">$$options{title}</th></tr>\n";
    }
 
    ### Escape and append the labels, if requested
    unless($$options{nolabels}){
      my @printLabels = @$labels;
      foreach my $index (0..scalar(@printLabels)-1){
        $printLabels[$index] =~ s/&/&amp;/g;
        $printLabels[$index] =~ s/</&lt;/g;
        $printLabels[$index] =~ s/>/&gt;/g;
      }
      $str .= "  <tr$$options{trAttributes}>".join('',map(
        "<th$$options{thAttributes}>$_</th>",@printLabels))."</tr>\n";
    }

    ### Escape and append the data
    foreach my $datum (@$data){
      foreach my $label (@$labels){
        $$datum{$label} =~ s/&/&amp;/g;
        $$datum{$label} =~ s/</&lt;/g;
        $$datum{$label} =~ s/>/&gt;/g;
      }
      $str .= "  <tr$$options{trAttributes}>".join('',map(
        "<td$$options{tdAttributes}>$$datum{$_}</td>",@$labels))."</tr>\n";
    }

    ### Return it.
    return "$str</table>\n";

  ### An XML Document
  }elsif($$options{format} eq 'xml'){

    my $printLabels;
    foreach my $index (0..scalar(@$labels)-1){
      $$printLabels{$$labels[$index]} = $$labels[$index];
      $$printLabels{$$labels[$index]} =~ s/\s/_/g;
      $$printLabels{$$labels[$index]} =~ s/[^\w_]//g;
    }

    if($$options{title}){
      $$options{title} =~ s/\s/_/g;
      $$options{title} =~ s/[^\w_]//g;
    }else{
      $$options{title} = 'xml';
    }

    my $str = "<$$options{title}>\n";

    foreach my $datum (@$data){
      foreach my $label (@$labels){
        $$datum{$label} =~ s/&/&amp;/g;
        $$datum{$label} =~ s/</&lt;/g;
        $$datum{$label} =~ s/>/&gt;/g;
      }
      $str .= "  <opt>".join('',map(
        "<$$printLabels{$_}>$$datum{$_}</$$printLabels{$_}>",
        @$labels))."</opt>\n";
    }

    $str .= "</$$options{title}>\n";
    return $str;

  ### Yaml a'int a markup language... ( it's a data serialization language )
  }elsif($$options{format} eq 'yaml'){

    my $str = "--- \n";

    ### Print the title if they gave us one
    if($$options{title}){
      $str .= "# $$options{title}\n";
    }
   
    ### We have to excape all labels with colons in them
    my $printLabels;
    foreach my $label (@$labels){
      my $new = $label;
      if($new =~ /[^\w ]/){
        if($new =~ /'/){
          $new =~ s/'/\\'/g;
        }
        $new = "'$new'";
      }
      $$printLabels{$label} = $new;
    }

    ### Append data
    foreach my $datum (@$data){
      my $firstElement = 1;
      foreach my $label (@$labels){
        if($firstElement){
          $str .= "- $$printLabels{$label}: $$datum{$label}\n";
          $firstElement = 0;
        }else{
          $str .= "  $$printLabels{$label}: $$datum{$label}\n";
        }
      }
    }

    return $str;
    
  }
}



1;
