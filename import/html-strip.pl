#!/usr/bin/perl

use strict;

my $text;

while (<>) {
  $text .= $_;
}

$text =~ s/<p>&nbsp;<\/p>//g;
$text =~ s/<p>//g;
$text =~ s/<\/p>/\n/g;

$text =~ s/&nbsp;//g;
$text =~ s/&amp;/&/g;
$text =~ s/&#8216;/'/g;
$text =~ s/&#8217;/'/g;
$text =~ s/&#8220;/"/g;
$text =~ s/&#8221;/"/g;


$text =~ s/(<img)/\n$1/g;

$text =~ s|</a><a|</a>\n<a|g;
$text =~ s|</a>|\n|g;

$text =~ s|<a href="(.*?jpg).*?>|$1|g;
$text =~ s|<.*?src="(.*?jpg).*?>|$1|g;

$text =~ s|<br>|\n|g;
$text =~ s|<br.*?>|\n|g;

$text =~ s|<div>||g;
$text =~ s|<div.*?>||g;
$text =~ s|</div>||g;

$text =~ s|<table.*?>||g;
$text =~ s|<tbody.*?>||g;
$text =~ s|<tr.*?>||g;
$text =~ s|<td.*?>||g;
$text =~ s|</table>||g;
$text =~ s|</tbody>||g;
$text =~ s|</td>|\n\n|g;
$text =~ s|</tr>|\n\n|g;



print $text;

