#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use PDF::API2;

# The point of this script is to accept a string and print it, centered, on
# a portrait, US-letter page.

my $filename = $ARGV[0];
my $title = $ARGV[1];

$title =~ s/^\s+|\s+$//g;

my $pdf =  PDF::API2->new();
my $page = $pdf->page();
$page->mediabox('Letter');

my $text = $page->text();
my $font = $pdf->corefont("Times-Bold");
$text->font($font, 24);
my ($llx, $lly, $urx, $ury) = $page->get_mediabox;
my $centerX = (($urx - $llx)/2)+$llx;
my $centerY = (($ury - $lly)/2) + $lly;
$text->translate($centerX, $centerY); # move to the center of the page
$text->text_center($title);

$pdf->saveas($filename);

exit 0;
