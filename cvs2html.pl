#!/usr/bin/perl
#
# Perl program to transform the 'cvs log' output to HTML
#
# Perl program to transform the 'cvs log' output to HTML.
# The HTML output will show the revision log history,
# differences between versions and enable a flexible
# configuration of the amount of information the user
# like to see from the CVS repository.
# cvs2html can be used for any type of cvs archive.

#
# ** Note that the first line might be wrong depending **
# ** on the location of your perl program.             **
# ** The program requires:                             **
# **             perl version 5.003 or newer           **
#
# cvs2html should run on any Unix compatible machine
# with the above programs.
# Test machine: Linux RedHat 7.2 with Perl 5.6.0
#
# Usage :
#
#  type cvs2html with no arguments to display basic help
#  or type cvs2html -h to get more help

# Changelog
# Ver  Date        Who did it            What happened
# -------------------------------------------------------------------------
# 1.96 2002-11-09  Lloyd Parkes          Patch for when -l and -R are used 
#                                        at the same time. 
#
# 1.95 2002-07-24  Holger L. Bille       Patch against problem with empty
#                                        log-entries.
#
# 1.94 2002-06-25  Magnus Ahlman	 Added a option argument -R CVS Reposity
#					 specified in the cvsweb.conf
#					 so you can integrate with cvsweb
#
# 1.93 2002-05-25  John Hardin           Patch against freezing problem
#                                        with cvs log would report "nothing
#                                        known about"
#
# 1.92 2002-03-25  Anna Jonna            Typos removed
#                  Armannsdottir       
#
# 1.91 2002-01-13  Jacob Sparre Andersen Major overhaul of the code
#                  and Peter Toft        in order to generate HTML 4.0
#                                        compliant code. Many bugs corrected.
#
# 1.90 2001-09-07  Stefan Kost           A few "cosmetical" corrections.
#
# 1.89 2001-09-06  Stefan Kost           * "back to main" links in chronofile
#                                          only if frames==1
#                                        * subs html_header/html_footer
#                                        * $cvs2html_diff is now called $diffdirname
#                                          (in preparation for more subdirs)
#                                          and defaults to just "diff"
#                                        * sub cvsrootinfo (with extended infos)
#                                        * the ususal cosmetical fixes here and there
#                                        * both halfs of diff output are now
#                                          delimited by a small gap
#                                        * entries in __rf-files are now sorted
#
# 1.88 2001-09-04  Peter Toft            Kim Schulz means that that 
#                                        text in line 748 (previously 744) 
#                                        was adequite. Updated.
#
# 1.87 2001-08-30  Laurent Besson        Bagged two bugs!!
#                  Stefan Kost           * fixed empty output
#                                        * copyright footer looks the same
#                                          for all pages
#                                        * chrono-file back-links go to
#                                          "top" frame
#
# 1.86 2001-08-26  Stefan Kost           Handling of verbosity level update
#
# 1.85 2001-08-24  Stefan Kost           * handles "cvs connection refused"
#                                        * find_alldirs, find_subdirs do not
#                                          follow symlinks
#                                        * new option -V <verbosity level>
#                                        * cleaned up code indentation
#                                        * more comments
#
# 1.84 2001-07-14  Peter Toft            Added links in the cronological file
#                                        to the main page and removed a
#                                        debug-printout statement.
#
# 1.83 2001-06-28  Grzegorz Pawelczak    Patch to handle branches (fix)
#
# 1.82 2001-06-22  Grzegorz Pawelczak    Patch to handle branches
#
# 1.81 2001-06-18  David Carson          Minor update - added support
#                                        for underscore in author-field
#
# 1.80 2001-05-31  Peter V. Pretsch      Fixed the problem with missing
#                                        right frames
#
# 1.79 2000-12-27  Peter Toft            Peter made error in the Changelog :-)
#
# 1.78 2000-12-27  Peter Toft            Error in making diff-directories
#                                        corrected. Example included in help-
#                                        description.
#                                        Changed mkdir to perl-command.
#
# 1.77 2000-12-15  Peter Toft            Hack to avoid generating the
#                                        same diff-files over and over again.
#                                        Renaming of the diff-files.
#                                        Dumping the diff-files in a
#                                        separate subdir.
#
# 1.76 2000-11-30  Jody Lewis            Typo; The parent links in the
#                                        lower left frame were incorrect
#
# 1.75 2000-11-04  Kirby Vandivort       URL of cvs2html changed
#
# 1.73 2000-11-02  Peter Toft            Clean up - deleted an old status line
#
# 1.72 2000-10-28  Peter Toft            If basename() or dirname() adds
#                                        a \n code, then cvs2html malfunctions
#                                        This should solve the problem.
#
# 1.71 2000-10-26  Peter Toft            Minor clean-up
#
# 1.70 2000-10-26  Jon Berndt            Documentation problem -L option
#                  Peter Toft            -L/-E option was not working
#                                        Redefined -L and dumped the -E option
#
# 1.69 2000-09-29  Robert Merkle         Support for users with 0-9
#                                        in name
#
# 1.68 2000-09-20  Wolfgang Bangerth     Patch to avoid HTML syntax
#                                        problems and link error.
#
# 1.67 2000-08-21  Kirby Vandivort       Update to cvs2html to fix html
#                                        markup display in cvs comments
#
# 1.66 2000-08-11  Kirby Vandivort       Added support for an
#                                        parameter -P controlled location
#                                        of cvs
#
# 1.65 2000-06-24  Peter Toft            Added support for filenames
#                                        containing whitespaces -
#                                        requested by John Stone
#
# 1.64 2000-06-11  Peter Toft            Better documentation in the start
#                                        of the program
#
# ---- ----------  --------------------  -------------------------------
#
# This program is protected by the GPL, and all modifications of
# general interest can be emailed to Peter Toft <pto@sslug.dk>
#
# The GPL can be found at http://www.gnu.org/copyleft/gpl.html
#
# Other people that have contributed directly or indirectly to cvs2html
#  Holger L. Bille <hlb@vitesse.com>
#  Henner Zeller <zeller@think.de>
#  Henning Niss <hniss@diku.dk>
#  Henrik Carlquist <Henrik.Carlqvist@dynamics.saab.se>
#  Tim Bradshaw <tfb@cley.com>
#  David Miller
#  Parkes, Lloyd <lloyd.parkes@eds.com>
#  David Carson <DCarson@extremenetworks.com>
#  Finn Aarup Nielsen <fn@imm.dtu.dk>
#  Michael Krause <mkrause@teuto.net>
#  Jim Phillips <jim@ks.uiuc.edu>
#  Jon S. Berndt <jsb@hal-pc.org>
#  Edward S. Marshall <emarshal@logic.net>
#  Curtis L. Olson <curt@me.umn.edu>
#  Aubrey Jaffer <jaffer@colorage.com>
#  Mark Cooke <mpc@star.sr.bham.ac.uk>
#  Carlo Wood <carlo@runaway.xs4all.nl>
#  Kirby Vandivort <kvandivo@ks.uiuc.edu>
#  Dag Br�ck <dag@Dynasim.se>
#  Wolfgang Bangerth <wolfgang.bangerth@iwr.uni-heidelberg.de>
#  Robert Merkle <r.merkle@siep.shell.com>
#  Jody Lewis <jody.lewis@philips.com>
#  Peter V. Pretsch <pvp@pe.dk>
#  Grzegorz Pawelczak <gpawel@adlex.com>
#  Stefan Kost <st_kost@gmx.de>
#  Anna Jonna Armannsdottir <a@sleepy.dk>
#  John Hardin <johnh@aproposretail.com>
#  Magnus Ahlman <magnus.ahlman@eds.com>

#
# Copyright under GPL 1997 - 2002 by
# Peter Toft (pto@sslug.dk) + the persons above
#
# Join the cvs2html mailing list <sslug-cvs2html@sslug.dk>
# by sending an email to <sslug-cvs2html-subscribe@sslug.dk>,
# the contents of this mails is of no matter.
# You will receive an email than you need to reply to.
#
# If you want to unsubscribe from the list - write a mail to
# <sslug-cvs2html-unsubscribe@sslug.dk>, and reply to the mail you get.
# In case of problems contact <pto@sslug.dk>
#
# The URL of cvs2html is:

$URL = "http://cvs.sslug.dk/cvs2html";

$cvs2html_version='$Id: cvs2html.pl,v 1.1 2005/09/15 11:46:03 gasche Exp $';

require 'getopts.pl';
require 'ctime.pl';

use File::Basename;
use File::Find;

if($cvs2html_version =~ /^\$Id\: (\w+?),v (\d+?\.\d+?) /i) {
  $version=$2;
}
else {
  $version="?.?";
}

# get options from cfgfile

# now get the options. The ones with a colon means the an extra argument follows.
# all options given will override the ones specified in cfgfile
&Getopts('R:r:abc:C:d:efhkl:n:N:s:vo:D:E:L:O:w:i:pP:V:');

###############################################################
# graphic related default variables that you can change
###############################################################

# Default width of the left frame in pixels. Also changed by -w option
$leftframewidth = 150;

# Default splitratio of the left frame in percent. Also changed by -s option
$leftsplitratio = "70%";

# Default cell color
$cellcolor = "#c7c7c7";

# Default filename cell color
$filenamecellcolor = "#7777FF";

# Default background color gray
$backcolor = "#AAAAAA";

# Default background for the difference cells
$differencebackground = "#BBBBBB";

# Colors and font to show the diff type of code changes when using -a
$diffcolorHeading    ='#999999';     # color of 'Line'-heading of each diffed file
$diffcolorEmpty      ='#999999';     # color of 'empty' lines
$diffcolorNormal     ='#BBBBBB';     # color of 'unchanged' ('equal') lines
$diffcolorRemove     ='#FF9999';     # Removed line(s) (left)  (empty)
$diffcolorChange     ='#99FF99';     # Added line(s)   (empty) (right)
$diffcolorDarkChange ='#77AA77';     # lines, which are empty on the left/right
$diffcolorAdd        ='#AAAAFF';     # Changed line(s) (     both    )
# just uncomment if you don't want any font-changes
#$difffontface        ="Arial,Helvetica";
$difffontface        ="Courier,Courier New";
$difffontsize        ="-1";

###############################################################
# other default variables that you can change
###############################################################

# Set $kkon ="-kk" if you permanently want to hide keyword substitutions
# when making diff-files.
$kkon = "";

# Set $whitespace = "-w" if you want to ignore white space changes
# in diff
$whitespace="-w";

# The timedifference in seconds which we consider as the same
# commit time
$commit_smalltimedifference = 10;

# default CVS location (default assumes in path)
$cvsLocation="cvs";

# warnings if omitting generating of diff-files
$diffwarning = 0;

# sub dir name for diff-files
$diffdirname = "diff";

###############################################################
# Subfunctions
###############################################################

#html helper
sub html_footer {
  my ($stradd)=@_;

  if(!defined($stradd)){ $stradd=""; }
  (undef,$min,$hour,$mday,$mon,$year,undef,undef,undef) = localtime(time);
  $struser=getlogin;
  $strdate=sprintf "%4d-%02d-%02d %2d:%02d",$year+1900, $mon+1, $mday,$hour,$min;

  $ret="<hr>\n";
  $ret.="<center><font size=\"-1\">\n";
  $ret.="File made using version $version of ";
  $ret.="<a href=\"$URL\" target=\"_new\">cvs2html</a> by ";
  $ret.="$struser at $strdate  $revisionlimitertext $stradd";
  $ret.="</font></center>\n";
  return($ret);
}

sub html_header {
  my ($title)=@_;

  $ret="<\!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n
<html>\n<head>\n<title>";
  if(defined($title) && length($title)>0) {
	$ret.="$title";
  }
  else {
	$ret.="cvs2html";
  }
  $ret.="</title>\n</head>\n";
  if ($opt_i) {
	$ret.="<body background=\"$opt_i\">\n";
  } else {
	$ret.="<body bgcolor=\"$backcolor\">\n";
  }
  if(defined($title) && length($title)>0) {
	$ret.="<h2 align=\"center\">$title</h2>\n<hr>\n";
  }
  return($ret);
}

sub cvsrootinfo {
  # the two tables are needed for proper layout
  $ret="<table border=\"0\" cellpadding=\"1\" cellspacing=\"1\" align=\"center\" bgcolor=\"$cellcolor\" width=\"100%\">\n";
  $ret.="<tr>\n";
  $ret.="<td width=\"15%\" align=\"right\"><b>Protocol:</b></td><td width=\"35%\">$protocol</td>\n";
  $ret.="<td width=\"15%\" align=\"right\"><b>    User:</b></td><td width=\"35%\">$cvsuser</td>\n";
  $ret.="</tr>\n<tr>\n";
  $ret.="<td width=\"15%\" align=\"right\"><b> Machine:</b></td><td width=\"35%\">$machine</td>\n";
  $ret.="<td width=\"15%\" align=\"right\"><b> CVSROOT:</b></td><td width=\"35%\">$cvsroot</td>\n";
  $ret.="</tr>\n";
  $ret.="</table><hr>\n";
  return($ret);
}

#function to help sort
sub sorter{
  $chronotimesince0[$a] <=> $chronotimesince0[$b];
}

#Function to close the main file
sub closemainfile {
  # Print date & copyright info in the last part of the HTML document
  $stradd="";
  if ($cutdate>"00000000") {
    $stradd.=" leaving out any log message prior to $cutyearformat2";
  }
  if (($opt_n>0) && ($opt_a)) {
    $stradd.=" and only showing the $opt_n latest version differences";
  }
  print OUTFILE html_footer($stradd);

  # Lets wrap up OUTFILE
  print OUTFILE "</body>\n";
  print OUTFILE "</html>\n";

  close(OUTFILE);
}

# Function to show how the function is used. Called if no options are given.
sub shorthelp {
  print "*** CVS2HTML ***\nA Perl program to transform the 'cvs log' output to HTML.\n";

  print "Usage of cvs2html\n\n";
  print "cvs2html [-a [-b][-k]] [-n NUMDIF] [-l/-L FTPHOME]\n";
  print "         [-e] [-f] [-d \"MMM DD [YYYY]\"] [-D DD] [-i IMAGE] [-h]\n";
  print "         [-v] [-w FRAMEWIDTH] [-s PERCENTAGE] [-N MAXCHRONO]\n";
  print "         [-rREV1:REV2] [-c/-C CFILENAME] -O/o HTMLNAME\n";
  print "         [-P CVSPATH] [-V VERBOSITY]\n [-R CVSWEB ROOT ";

  print "\n\nTry: cvs2html -help\n";
}

sub showhelp {
  print "\n";

  print " cvs2html -O foo\n";
  print " outputs html files foo.html and alike for each subdirectory\n";
  print " Note that if foo is a directory the files are stored there\n";
  print " using the name of the repository as the base filename.\n";
  print "\n";

  print " cvs2html -O foo -v\n";
  print " which outputs a html file to the file foo.html including\n";
  print " information about the CVSROOT setting.\n";
  print "\n";

  print " Using -o instead of -O, frames will be made for easy control.\n";
  print "\n";

  print " If -e is specified the log messages are printed\n";
  print " in courier (non-proportional) font.\n";
  print "\n";

  print " If -c CFILENAME is specified a chronological sorted list of all log\n";
  print " entries will be saved in CFILENAME (CFILENAME is a full html filename)\n";
  print " Use -C CFILENAME instead of -c to do reverse sort of the log file.\n";
  print " Add -p to include cvs log information into the CFILENAME.\n\n";

  print " If -a is specified additional fields and files are generated\n";
  print " containing differences betweeen versions\n";
  print " in a xdiff-like side by side manner.\n";
  print " The -n NUMDIF will only output the lastest NUMDIF diff files.\n";
  print " The -N MAXCHRONO will only show the last MAXCHRONO file changes\n";
  print " in the chronological list of changes.\n";
  print "\n";

  print " if -b is specified in addition to diff-mode\n";
  print " spcaces are used as breakpoint to wrap the text\n";
  print " so the two columns don't exceed the total width\n";
  print " If -k is specified in addition to diff-mode\n";
  print " changes in lines caused by CVS-keyword substition\n";
  print " are ignored.\n";

  print " If an option -l ftphome is given links to the files relative\n";
  print " to the URL ftphome is made. Use -L ftphtmlhome to do the same as\n";
  print " -l, but substitutes file extension with .html\n";
  print "\n";

  print " If an option -d \"month day year\" is given (year optional) any\n";
  print " log message prior to that date is omitted. The three first \n";
  print " letters of the name of the month is used, e.g., Jun 5.\n";
  print " A -D DD option will drop any log DD days ago or earlier\n";
  print "\n";

  print " If an option -rREVISIONTAG1:REVISIONTAG2 is given, then\n";
  print " the log messages are only shown between those revision\n";
  print " REVISIONTAG1 and REVISIONTAG2. If a file was not tagged\n";
  print " then the whole revision story of the file will be shown.\n";
  print "\n";

  print " If -o and -w FRAMEWIDTH is used the left frame will have\n";
  print " FRAMEWIDTH pixels. Add -f when using the -o option to \n";
  print " generate individual log files for each file.\n";
  print " Use -s PERCENTAGE to set width of the fraction of the left\n";
  print " bar in percentage.\n";
  print "\n";

  print " Use -i IMAGE to replace the background with file specified as IMAGE\n";
  print "\n";

  print " Use -P CVSPATH to specify an explicit location cvs.  The\n";
  print " default value is simply 'cvs', which means that cvs is in your\n";
  print " path.\n";
  print "\n";

  print " Use -V VERBOSITY to make cvs2html report what it is doing. A\n";
  print " value of 0 means be quiet and bigger numbers means more output.\n";
  print " This is especially useful, when something went wrong.\n";
  print "\n";

  print " Use -R CVSWEBROOT to make reports intergrated with cvsweb.\n";
  print " The argument should be the symbolic_name in cvsweb.conf.\n";

  print " The html file also contains anchors, if a file foo.html\n";
  print " containing a file e.g., foofoo.m is generated then it is\n";
  print " possible to search http://CORRECT_URL/foo.html#foofoo.m\n";
  print "\n";

  print " Example :\n";
  print " cvs2html  -l http://cvs.sslug.dk/linuxbog -f -p \\\\ \n";
  print "   -o cvs2html/index.html -v -a -b -n 6 -C crono.html\n";
  print " makes cvs2html/ with individual log data for each file \n";
  print " with links relative to \"http://cvs.sslug.dk/linuxbog\"\n";
  print " and creates a chronological log file \"crono.html\".\n";
  print "\n";

  print " cvs2html with no arguments displays this help\n";
  print " Peter Toft et al, Technical University of Denmark, 1997\n";
  exit(0);
}

# This function will set the date after which the log info is shown.
# Any log info before the date is NOT shown.
sub date_control {
  %months= (
            'Jan','01',
            'Feb','02',
            'Mar','03',
            'Apr','04',
            'May','05',
            'Jun','06',
            'Jul','07',
            'Aug','08',
            'Sep','09',
            'Oct','10',
            'Nov','11',
            'Dec','12',
            );


  &ctime(time) =~/^(\w+) (\w+) (\d+) (\d+):(\d+):(\d+) (\d+)$/;

  $currentyear=$7;

  if (($opt_d)||($opt_D)) {
    if ($opt_d) {
      ($cutmonthtxt,$cutdatetxt,$cutyeartxt)= $opt_d =~ /^(\w+) (\d+) (\d+)$/;
    }
    if ($opt_D) {
      $cd = localtime(time-3600*24*$opt_D);
      $cd =~ /^(\w+) (\w+)[ ]*(\d+)[ ]*(\d+):(\d+):(\d+) (\d+)$/;
      $cutyeartxt = $7;
      $cutmonthtxt = $2;
      $cutdatetxt = $3;
    }

    if (length($cutyeartxt)==0) {
      ($cutmonthtxt,$cutdatetxt)= $opt_d =~ /^(\w+) (\d+)$/;
      $cutyeartxt=$currentyear;
    }
    $cutyearformat2="$cutmonthtxt $cutdatetxt $cutyeartxt";
	
    if (length($cutdatetxt)==1) {
      $cutdatetxt="0".$cutdatetxt;
    }
    $m=$months{$cutmonthtxt};
    if (length($m)==0) {
      print "The option -d \"month day [year]\" was used with a wrong month ($cutmonthtxt).\n";
      print "First three letters is used\n";
      exit(0);
    }
    $cutdate = $cutyeartxt.$m.$cutdatetxt;
  }
  else {
    $cutdate = "00000000";
  }
  # Anything before year 0000 - I dont think so...........
}

# Function to read the next line from cvslogarray
sub getnextline {
  $lineno++;
  if($lineno<=scalar(@cvslogarray)) {
	# DEBUG
	#print STDOUT "    cvslogarray[$lineno]=$cvslogarray[$lineno]";
	# DEBUG
	return($cvslogarray[$lineno]);
  }
  else {
	return(undef);
  }
}

sub flush_diff_rows ($$$$) {
    local $j;
    my ($leftColRef,$rightColRef,$leftRow,$rightRow) = @_;
    if ($state eq "PreChangeRemove") {          # we just got remove-lines before
      for ($j = 0 ; $j < $leftRow; $j++) {
          print DIFFFILE "<tr><td bgcolor=\"$diffcolorRemove\">@$leftColRef[$j]</td>";
		  print DIFFFILE "<td bgcolor=\"$backcolor\">&nbsp;</td>";
          print DIFFFILE "<td bgcolor=\"$diffcolorEmpty\">&nbsp;</td></tr>\n";
      }
    }
    elsif ($state eq "PreChange") {             # state eq "PreChange"
      # we got removes with subsequent adds
      for ($j = 0; $j < $leftRow || $j < $rightRow ; $j++) {  # dump out both cols
          print DIFFFILE "<tr>";
          if ($j < $leftRow) { print DIFFFILE "<td bgcolor=\"$diffcolorChange\">@$leftColRef[$j]</td>"; }
          else { print DIFFFILE "<td bgcolor=\"$diffcolorDarkChange\">&nbsp;</td>"; }
		  print DIFFFILE "<td bgcolor=\"$backcolor\">&nbsp;</td>";
          if ($j < $rightRow) { print DIFFFILE "<td bgcolor=\"$diffcolorChange\">@$rightColRef[$j]</td>"; }
          else { print DIFFFILE "<td bgcolor=\"$diffcolorDarkChange\">&nbsp;</td>"; }
          print DIFFFILE "</tr>\n";
      }
    }
}
# Function to generate diff-files
sub generate_diff_file {
  local ( $ii,$difftxt,@diffar );
  $diffname = $outdirname.'/'.$diffdirname.'/'."diff$convdir\_$filename\_$oldrevnumber\_$revnumber.html";

  stat($diffname);
  if (-e _) {
    if ($diffwarning == 1) {
      print "WARNING; cvs2html does not generate $diffname\n";
    }
  }
  else {
    @listhtmlnames = (@listhtmlnames,$diffname);
    open(DIFFFILE,">$diffname") or die "Error: Could not open ; $diffname";
    print DIFFFILE html_header("Difference for $currentdir/$filename from version $revnumber to $oldrevnumber");
    if ($opt_k) {
      $kkon = "-kk";
    }
    @diffar = `$cvsLocation diff $kkon $whitespace -u -r $revnumber -r $oldrevnumber $currentdir/$filename\n`;

    print DIFFFILE "<table border=0 cellspacing=0 cellpadding=0 width=\"100%\">\n";
    print DIFFFILE "<tr bgcolor=\"#ffffff\"><th width=\"50%\">version $revnumber</th><th bgcolor=\"$backcolor\">&nbsp;</th><th width=\"50%\">version $oldrevnumber</th></tr>";

	$fs="<font";
	if(defined($difffontface) && length($difffontface)>0) {
	  $fs.=" face=\"$difffontface\"";
	}
	if(defined($difffontsize) && length($difffontsize)>0) {
	  $fs.=" size=\"$difffontsize\"";
	}
	$fs.=">";
    $fe="</font>";

    $leftRow = 0;
    $rightRow = 0;

    # the first 8 lines are garbage for us
    for ($ii=8;$ii<=$#diffar;$ii++) {
      chop($difftxt = $diffar[$ii]);
      if ($difftxt =~ /^@@/) {
        ($oldline,$newline) = $difftxt =~ /@@ \-([0-9]+).*\+([0-9]+).*@@/;
        print DIFFFILE "<tr bgcolor=\"$diffcolorHeading\"><td width=\"50%\">";
        print DIFFFILE "<table width=\"100%\" border=0 cellpadding=5><tr><td><b>Line $oldline</b></td></tr></table>";
        print DIFFFILE "</td><td bgcolor=\"$backcolor\">&nbsp;</td><td width=\"50%\">";
        print DIFFFILE "<table width=\"100%\" border=0 cellpadding=5><tr><td><b>Line $newline</b></td></tr></table>";
        print DIFFFILE "</td></tr>\n";
        $state = "dump";
        $leftRow = 0;
        $rightRow = 0;
      }
      else {
        ($diffcode,$rest) = $difftxt =~ /^([-+ ])(.*)/;
        $_= $rest;
########
# quote special characters
# according to RFC 1866,Hypertext Markup Language 2.0,
# 9.7.1. Numeric and Special Graphic Entity Set
# (Hen)
#######
		s/&/&amp;/g;
		s/\"/&quot;/g;
		s/</&lt;/g;
		s/>/&gt;/g;

		# replace <tab> and <space>
		if ($opt_b) {
		  # make every other space 'breakable'
		  s/        /&nbsp; &nbsp; &nbsp; &nbsp; /g;    # <tab>
		  s/   /&nbsp; &nbsp;/g;                        # 3 * <space>
		  s/  /&nbsp; /g;                               # 2 * <space>
		  # leave single space as it is
		}
		else {
		  s/        /&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/g;
		  s/ /&nbsp;/g;
		}

		# Add fontface, size
		$_ = "$fs&nbsp;$_$fe";

		#########
		# little state machine to parse unified-diff output (Hen, zeller@think.de)
		# in order to get some nice 'ediff'-mode output
		# states:
		#  "dump"             - just dump the value
		#  "PreChangeRemove"  - we began with '-' .. so this could be the start of a 'change' area or just remove
		#  "PreChange"        - okey, we got several '-' lines and moved to '+' lines -> this is a change block
		##########

		if ($diffcode eq '+') {
		  if ($state eq "dump") {  # 'change' never begins with '+': just dump out value
			print DIFFFILE "<tr><td bgcolor=\"$diffcolorEmpty\">&nbsp;</td><td bgcolor=\"$backcolor\">&nbsp;</td><td bgcolor=\"$diffcolorAdd\">$_</td></tr>\n";
		  }
		  else {                   # we got minus before
			$state = "PreChange";
			$rightCol[$rightRow++] = $_;
		  }
		}
		elsif ($diffcode eq '-') {
		  $state = "PreChangeRemove";
		  $leftCol[$leftRow++] = $_;
		}
        else {  # empty diffcode
		  flush_diff_rows \@leftCol, \@rightCol, $leftRow, $rightRow;
		  print DIFFFILE "<tr><td bgcolor=\"$diffcolorNormal\">$_</td><td bgcolor=\"$backcolor\">&nbsp;</td><td bgcolor=\"$diffcolorNormal\">$_</td></tr>\n";
		  $state = "dump";
		  $leftRow = 0;
		  $rightRow = 0;
		}
      }
    }
    flush_diff_rows \@leftCol, \@rightCol, $leftRow, $rightRow;
    print DIFFFILE "</table>";

    # print legend
    print DIFFFILE "<br><hr><table border=0><tr><td>";
    print DIFFFILE "Legend:<br><table border=0 cellspacing=0 cellpadding=1>\n";
    print DIFFFILE "<tr><td align=center bgcolor=\"$diffcolorRemove\">$fs"."line(s) removed in v.$revnumber"."$fe</td><td bgcolor=\"$diffcolorEmpty\">$fs"."&nbsp;"."$fe</td></tr>";
    print DIFFFILE "<tr bgcolor=\"$diffcolorChange\"><td align=center colspan=2>$fs"."line(s) changed"."$fe</td></tr>";
    print DIFFFILE "<tr><td bgcolor=\"$diffcolorEmpty\">$fs"."&nbsp;"."$fe</td><td align=center bgcolor=\"$diffcolorAdd\">$fs"."line(s) added in v.$oldrevnumber"."$fe</td></tr>";
    print DIFFFILE "</table></td></tr></table>\n";

    print DIFFFILE html_footer("");
    print DIFFFILE "</body>\n</html>\n";
    close(DIFFFILE);
  }
}

sub find_alldirs {
  my @dirs = ();
  find(
       sub {
         if (-d && ! -l && ! /CVS$/) {
           if ($File::Find::dir eq "." && $_ eq ".") {
             push @dirs, "./";
           }
           else {
             push @dirs, "$File::Find::dir/$_";
           }
         }
       }, '.'
	  );

  @dirs = map { $_ . "\n" } @dirs;

  return @dirs;
}

sub find_subdirs {
  my $currentdir = shift;

  my @dirs = ();
  finddepth(
            sub {
              if (-d && ! -l && ! /CVS$/ && $File::Find::dir eq $currentdir) {
                if ( ! ($File::Find::dir eq $currentdir && $_ eq ".") ) {
                  push @dirs, "$File::Find::dir/$_";
                }
              }
            }, $currentdir
		   );

  @dirs = map { $_ . "\n" } @dirs;

  return @dirs;
}

sub kill_log_header {
  @llcvslog = ();
  $headerstill = -1;
  foreach $ii (0 .. ($#lcvslog-1)) {
    if ($headerstill == 0) {
      @llcvslog = (@llcvslog,$lcvslog[$ii]);
    }
    else {
      $headerstill = $headerstill - 1;
      if ($lcvslog[$ii] =~ '----------------------------') {
		$headerstill = 2;
      }
    }
  }
}

#############################################################
# Lets set up the basics
#############################################################

# Always enforce restrictions on dates. If no date is given
# a very early one is used.
date_control;

# Set the width of the left frame.
# Default value has been set above.
if ($opt_w) {
  $leftframewidth = $opt_w;
}

# Set the splitratio of the left frame.
# Default value has been set above.
if ($opt_s) {
  $leftsplitratio = $opt_s;
}

# I want help!
if ($opt_h) {
  shorthelp;
  showhelp;
  exit(0);
}

# The user must give a filename for the HTML-file(s)
if ((!(($opt_O) || ($opt_o))) || (($opt_O) && ($opt_o))) {
  shorthelp;
  print "\nMade by Peter Toft (pto\@sslug.dk).\ncvs2html is protected by the GPL.\n";
  exit(0);
}

$dochrono="";
if($opt_c) {
  $dochrono=$opt_c;
}
if($opt_C) {
  $dochrono=$opt_C;
}


# Is -c followed by a "valid" filename ?
if (length($dochrono)>5) {
  $chronooutname = $dochrono;
}
else {
  $chronooutname = "cvs2html_chrono_log.html";
}

# Want to write to a file with frames?
if ($opt_o) {
  $frames = 1;
  $outname = $opt_o;
}

# Do you want to limit to certain revisions
$revisionlimiter="";
$revisionlimitertext="";
$starttag="";
if ($opt_r) {
  $revisionlimiter = "-r".$opt_r;
  $revisionlimitertext=" and only showing data between revisions $opt_r";
  if ($opt_r =~ /^(\S*):(\S*)/) {
    $starttag=$1;
    $endtag=$2;
  }
  $revisionlimiter_end = "-r:".$endtag;
  $revisionlimiter_startonly = "-r".$starttag;
}

# Want to write to a file without frames?
if ($opt_O) {
  $frames = 0;
  $outname = $opt_O;
}

$linkrel = "";
# Want to link to external file
if ($opt_l) {
  $linkrel = $opt_l;
}

# Explicit path to cvs
if ($opt_P) {
  $cvsLocation = $opt_P;
}

# Get the environment variable CVSROOT for this CVS repository
open(INFILE,"<./CVS/Root") or die "Error: The file ./CVS/Root is missing  - this directory does not seem to be under CVS-control.";
($fullcvsroot) = <INFILE> =~/^(.*)$/;
close INFILE;

# Split CVSROOT in machine and dir if possible.
@spl = split(':',$fullcvsroot);
if ($#spl == 3) {
# @spl[0] is empty because client/server root starts with ':' -> ":pserver" or ":ext"
    $protocol =$spl[1]; # client/server
    ($cvsuser,$machine) = split('@',$spl[2]);
    $cvsroot = $spl[3];
}
elsif ($#spl == 1) {
    $protocol = "rsh/ssh";
    ($cvsuser,$machine) = split('@',$spl[0]);
    $cvsroot = $spl[1];
}
else {
    $protocol = "local";
    $cvsuser = "";
    $machine =  "localhost";
    $cvsroot = $spl[0];
}

# Get the name of the repository
open(INFILE,"<./CVS/Repository")  or die "Error: The file ./CVS/Repository is missing.";

#($rootdir) = <INFILE> =~/^\Q$fullcvsroot\E(.*)$/;
($rootdir) = <INFILE>;
$rootdir = basename($rootdir);
($rootdir) = $rootdir =~ /^(.*)$/;

close INFILE;

# Strip a .html from the outname if any (pasted on later)
($outnamem) = $outname =~ /^(.*)\.html$/;
if (length($outnamem)>0) {
  $outname = $outnamem;
}

# If an outputname is a directory a file named after the repository
# is generated (and others if using frames).
if (-d $outname) {
  $outname = $outname."/".$rootdir;
}

# Split the outname from a possible directory full path
$outfilename = basename($outname);
$outdirname = dirname($outname);

($outfilename) = $outfilename =~ /^(.*)$/;
($outdirname) = $outdirname =~ /^(.*)$/;
$fulldiffdirname = $outdirname."/".$diffdirname;

mkdir($outdirname,0775);
mkdir($fulldiffdirname,0775);

if(defined($opt_V) && $opt_V>0) { print STDOUT "Processing \#1 $currentdir\n"; }

# Get all dirs to search
@entirealldirs = find_alldirs();

# Only pass along subdirectories that are under version control
@alldirs = ();
foreach $dir (@entirealldirs) {
    chop($dir);
    if ( -d "$dir/CVS" ) {
        if(defined($opt_V) && $opt_V>1) { print STDOUT "  $dir\n"; }
        push(@alldirs, "$dir\n");
    }
}

if ($frames == 1) {
  # Write the start of the left lower frame if more than one dir
  if (($#alldirs > 0) || ($dochrono)) {
    $llname = $outdirname.'/'.$outfilename."__lfl.html";
    open(OUTFILE3,">$llname") or die "Error: The file $llname could not be opened.";
    @listhtmlnames = (@listhtmlnames,$llname);
	print OUTFILE3 html_header("");

    if ($dochrono) {
      print OUTFILE3 "<table border=0 cellspacing=1 cellpadding=3 bgcolor=\"$cellcolor\" width=\"100%\">\n";
      $coutref = $outdirname."/".$chronooutname;
      print OUTFILE3 '<tr><td><a href="'.$chronooutname.'" target="rf"><FONT SIZE="-1">Chronological Log'."</font></a></td></tr>\n";
      print OUTFILE3 "</table><br>\n";
    }

    print OUTFILE3 "<h3 align=center>Dirs</h3>\n";
    print OUTFILE3 "<table border=0 cellspacing=1 cellpadding=3 bgcolor=\"$cellcolor\" width=\"100%\">";

    for ($ii=0;$ii<=$#alldirs;$ii++) {
      $alldirs[$ii] =~ /^\.(.*)$/;
      $dir = $1;
      $showdir = "[$rootdir]$dir";
      $refname = $dir;

      $refname =~ tr/\//_/;

      if (length($refname) == 1) {
        $refname = $outfilename;
      }
      else {
        $refname = $outfilename.$refname;
      }
      print OUTFILE3 '<tr><td><a href="'.$refname.'.html" target="_top"><FONT SIZE="-1">'.$showdir."</font></a></td></tr>\n";
    }
    print OUTFILE3 "</table>\n";
    print OUTFILE3 "</body>\n";
    print OUTFILE3 "</html>\n";

    close(OUTFILE3);
  }
}

if ($dochrono) {
  $chronocounter = -1;
  @chronoindex=();
  @chronoauthor=();
  @chrononame=();
  @chronotimesince0=();
  @chronoversion=();
  @chronoshowtime=();
  @chronolinknames=();
}

#############################################################
# Lets go for each of the directories
#############################################################
for ($dd=0;$dd<=$#alldirs;$dd++) {
  # Initialization
  @otherdnames = ();
  $lineno = -1;
  $foundbadone = 0;
  $fnumber = 1;

  # Where are we ?
  # $convdir is the current dir where all / are converted to _
  ($currentdir) = $alldirs[$dd] =~ /^\.\/(.*)$/;
  $convdir = $currentdir;
  $convdir =~ tr/\//_/;
  if (length($currentdir)==0) {
    $currentdirformat2 ="";
    $currentdir='.';
    $convdir = "";
  }
  else {
    $currentdirformat2 = $currentdir."/";
    $convdir = '_'.$convdir;
  }
  if(defined($opt_V) && $opt_V>0) { print STDOUT "Processing \#2 $currentdir\n"; }

  @entiresubdirs = find_subdirs($currentdir);
  @subdirs = ();
  foreach $dir (@entiresubdirs) {
    chop($dir);
    if ( -d "$dir/CVS" ) {
	  if(defined($opt_V) && $opt_V>1) { print STDOUT "  $dir\n"; }
	  push(@subdirs, "$dir\n");
	}
  }

  if ($frames == 1) {
	$llname = $outdirname.'/'.$outfilename.$convdir."__lfl.html";
	open(OUTFILE3,">$llname") or die "Error: The file $llname could not be opened.";
	@listhtmlnames = (@listhtmlnames,$llname);
	print OUTFILE3 html_header("");
	
	if ($dochrono) {
	  print OUTFILE3 "<table border=0 cellspacing=1 cellpadding=3 bgcolor=\"$cellcolor\" width=\"100%\">";
	  $coutref = $outdirname."/".$chronooutname;
	  print OUTFILE3 '<tr><td><a href="'.$chronooutname.'" target="rf"><font size="-1">Chronological Log'."</font></a></td></tr>\n";
	  print OUTFILE3 "</table><br>\n";
	}
	
	if ($#subdirs>=0 || $currentdir ne '.') {
	  print OUTFILE3 "<h3 align=center>Sub Dirs</h3>\n";
	  print OUTFILE3 "<table border=0 cellspacing=1 cellpadding=3 bgcolor=\"$cellcolor\" width=\"100%\">";

	  if($currentdir eq '.') {
		# No parent directory to top
	  }
	  else {
		$showdir = ".. Parent Dir";
		$up = dirname ($currentdir);
		($up) = $up =~ /^(.*)$/;

		if ($up eq ".") {
		  $refname = "/";
		}
		else {
		  $refname = "/$up";
		}
		$refname =~ tr/\//_/;
		if (length($refname) == 1) {
		  $refname = $outfilename;
		}
		else {
		  $refname = $outfilename.$refname;
		}
		print OUTFILE3 '<tr><td><a href="'.$refname.'.html" target="_top"><FONT SIZE="-1">'.$showdir."</font></a></td></tr>\n";
	  }
	  for ($ii=0;$ii<=$#subdirs;$ii++) {
		$subdirs[$ii] =~ /^\.(.*)$/;
		$dir = $1;
		$up = dirname ($subdirs[$ii]);
		($up) = $up =~ /^(.*)$/;
		$up = basename ($up);
		($up) = $up =~ /^(.*)$/;
		$down = basename ($subdirs[$ii]);
		($down) = $down =~ /^(.*)$/;
		$dir = "/$down";
		if ($up eq ".\n") {
		  $showdir = "[$rootdir]$dir";
		}
		else {
		  $showdir = "[$up]$dir";
		}

		if($currentdir eq '.') {
		  $refname = $dir;
		}
		else {
		  $refname = "/$currentdir$dir";
		}
		$refname =~ tr/\//_/;
		if (length($refname) == 1) {
		  $refname = $outfilename;
		}
		else {
		  $refname = $outfilename.$refname;
		}

		print OUTFILE3 '<tr><td><a href="'.$refname.'.html"  target="_top"><FONT SIZE="-1">'.$showdir."</font></a></td></tr>\n";
	  }
	  print OUTFILE3 "</TABLE><br>\n";
	}
	print OUTFILE3 "</body>\n";
	print OUTFILE3 "</html>\n";

	close(OUTFILE3);
  }

  # Should the output have frames then make left lower frame.
  if ($frames == 1) {
    # Write the start of the left upper frame
    $luname = $outdirname.'/'.$outfilename.$convdir."__lfu.html";
    open(OUTFILE2,">$luname") or die "Error: The file $luname could not be opened.";
    @listhtmlnames = (@listhtmlnames,$luname);
	print OUTFILE2 html_header("");
 	print OUTFILE2 "<h3 align=\"center\">Log History</h3>\n";
    print OUTFILE2 "<table border=0 cellspacing=1 cellpadding=3 bgcolor=\"$cellcolor\" width=\"100%\">";
	%outfile2lines=();
  }

  # Should the output have frames ?
  if ($frames == 1) {
    $mainname = $outdirname.'/'.$outfilename.$convdir.".html";

    # Write the start of the main html file
    open(OUTFILE4,">$mainname") or die "Error: The file $mainname could not be opened.";
    @listhtmlnames = (@listhtmlnames,$mainname);
    print OUTFILE4 "<\!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\">\n<html>\n";
    print OUTFILE4 "<head><title>CVS2HTML</title></head>\n";
    print OUTFILE4 "<frameset cols=\"$leftframewidth,*\">\n";
    # only do the left lower frame if subdirs found

    if (($#alldirs > 0)  || ($dochrono)) {
      print OUTFILE4 "<frameset rows=\"".$leftsplitratio.",*\">\n";
      print OUTFILE4 "<frame scrolling=auto src=\"".$outfilename.$convdir."__lfu.html\" name=\"lfu\">\n";
      print OUTFILE4 "<frame scrolling=auto src=\"".$outfilename.$convdir."__lfl.html\" name=\"lfl\">\n";
#      print OUTFILE4 "<frame scrolling=auto src=\"$outfilename"."__lfl.html\" name=\"lfl\">\n";
      print OUTFILE4 "</frameset>\n";
    }
    else {
      print OUTFILE4 "<frame scrolling=auto src=\"$outfilename".$convdir."__lfu.html\" name=\"lfu\">\n";
    }
    # Do right frame link
    print OUTFILE4 "<frame scrolling=auto src=\"$outfilename".$convdir."__rf.html\" name=\"rf\">\n";
    print OUTFILE4 "<noframes>\n";
    print OUTFILE4 "<h2 align=center>CVS Directories</h2>\n<hr>\n<br>\n";
  }

  if(defined($opt_V) && $opt_V>0) { print STDOUT "Getting cvs-entries\n"; }

  $cvsnames = "";
  @cvsnameslist = ();
  $Entryfilename = $currentdir."/CVS/Entries";

  open(NAMEFILE,"<$Entryfilename");
  $contin = 1;
  $nooffiles = 0;
  while ($contin ==1) {
    $namlin = <NAMEFILE>;
    ($readnameline) = $namlin =~ /^\/([ a-zA-Z0-9-+_\.(...)]*)\/.*$/;
    $_ = $readnameline;
    s/ /~/g;
    $readnameline = $_;
    if (length($namlin)>0) {
      if (length($readnameline)>0) {
        $nooffiles++;
        $cvsnames = $cvsnames." ".$currentdir.'/'.$readnameline;
        push @cvsnameslist, $currentdir.'/'.$readnameline;
      }
    }
    else {
      $contin=0;
    }
  }
  close(NAMEFILE);

  # Check for an empty Log (if, e.g., the directory does not contain files
  # registered with CVS).
  if (length ($cvsnames) <= 0) {
	print STDERR "Error 4 : Doing $currentdir: Log is empty.\n";
	# We really should make a file here I think
	if ($frames == 1) {
	  $rfoutname = $outdirname.'/'.$outfilename.$convdir."__rf.html";
	  open(OUTFILE,">$rfoutname") or die "Error: Could not open $rfoutname\n.";
	  @listhtmlnames = (@listhtmlnames,$rfoutname);
	}
	$fnumber=2;
	if (length($currentdir)==1) {
	  print OUTFILE html_header("--- $rootdir ---");
	}
	else {
	  print OUTFILE html_header("--- $rootdir/$currentdir ---");
	}
	
	if ($opt_v) { print OUTFILE cvsrootinfo(); }
	print OUTFILE html_footer("");
	print OUTFILE "</body></html>\n";
	
	# Lets open the main file and process
	if ($frames == 1) {
	  $rfoutname = $outdirname.'/'.$outfilename.$convdir.$fname."__rf.html";
	  open(OUTFILE,">$rfoutname") or die "Error: Could not open $rfoutname\n.";
	  @listhtmlnames = (@listhtmlnames,$rfoutname);
	}
	else {
	  $mainoutname = $outdirname.'/'.$outfilename.$convdir.$fname.".html";
	  open(OUTFILE,">$mainoutname") or die "Error: Could not open $mainoutname\n.";
	  @listhtmlnames = (@listhtmlnames,$mainoutname);
	}
	$fnumber=2;
	if (length($currentdir)==1) {
	  print OUTFILE html_header("--- $rootdir ---");
	}
	else {
	  print OUTFILE html_header("--- $rootdir/$currentdir ---");
	}
	print OUTFILE "<center>This directory is empty</center>\n";
	closemainfile;
  }
  next if (length ($cvsnames) <= 0); # Log is empty so proceed to next directory

  if(defined($opt_V) && $opt_V>0) { print STDOUT "Retrieving logdata\n"; }

  $_ = join ('" "', sort (split ' ', $cvsnames));
  s/~/ /g;
  $cvsnames = '"'.$_.'"';
  @cvslogarray = ();

# it would be nice to have just one cvs log <file_1> <file_2> ... <file_n>
# the filter out invalid branch blocs and re-request them
# for this I would need to know how this message looks like

  foreach $cvsnamesentry (@cvsnameslist) {
	if(defined($opt_V) && $opt_V>1) { print STDOUT "  $cvsnamesentry\n"; }
    @cvslogarray_sub = `$cvsLocation log $revisionlimiter $cvsnamesentry 2>&1 `;
    if ($cvslogarray_sub[0] =~ /connection refused/i) {
	  print STDERR "Error 3 : connection to cvs refused for \"$cvsnamesentry\"\n";
	  @cvslogarray_sub = ();
	  last;
	}
    if ($cvslogarray_sub[0] =~ /invalid branch or revision pair/i) {
      # the end tag was probably the first rev in a branch and "cvs log"
      # does not tolerate such combination, it needs special handling
      # retry with '-r:endtag'
      print "retrying with $revisionlimiter_end\n";
      @cvslogarray_sub_branch = `$cvsLocation log $revisionlimiter_end $cvsnamesentry`;
      @cvslogarray_sub_trunk = `$cvsLocation log $revisionlimiter_startonly $cvsnamesentry`;
      # find index of log entry separator line in @cvslogarray_sub_trunk
      $trunk_log_line = 0;
      while ( $trunk_log_line <=  $#cvslogarray_sub_trunk and
			  ! ($cvslogarray_sub_trunk[$trunk_log_line] =~ /^--------*$/) ){
		$trunk_log_line++;
      }
      # combine both logs
      @cvslogarray_sub = (@cvslogarray_sub_branch[0 .. $#cvslogarray_sub_branch-1],
						  @cvslogarray_sub_trunk[$trunk_log_line .. $#cvslogarray_sub_trunk]);
    }
    push @cvslogarray, @cvslogarray_sub;
  }

  if(defined($opt_V) && $opt_V>0) { print STDOUT "Processing logdata\n"; }

  $line = getnextline;

  # skip lines starting with "?"
  while ($line =~ /^\? (.*)$/) {
    $foundbadone = 1 ;
    $line = getnextline;
  }

  while ($line) {
    if ($opt_n>0) {
      $nodiff = $opt_n;
    }
    else {
      $nodiff = -1;
    }
    $oldrevnumber=0;
    if ($line =~ /^\? (.*)/) {
      print STDERR "The file \"$1\" is not part of cvs\n";
      $line = getnextline;
    }
    $line = getnextline;

	# skip lines starting with "?"
    while ($line =~ /^\? (.*)$/) {
      $foundbadone = 1 ;
      $line = getnextline;
    }

	# skip empty lines
    while ($line =~ /^( *)$/) {
      $line = getnextline;
    }

	# found a filename (ends on ",v")
    if ($line =~ /^.*: (.*),v$/) {
      $line = getnextline;
      ($lfilename) = $line =~ /^.*: (.*)$/;

      ($filename) = $lfilename =~ (/^.*\/([ a-zA-Z0-9-+_\.(...)]*)$/);
      if (length($filename) == 0) {
        $filename = $lfilename;
      }

      if (length($filename) == 0) {
        print STDERR "Error 2 in processing the output of cvs log in $currentdir\n";
        print STDERR $line;
      }
	  else {
		if(defined($opt_V) && $opt_V>1) { print STDOUT "  $filename\n"; }
	  }
      $printfilename = 0;
      $onlist = 0;
    }
    else  {
      print STDERR "Error 1 in processing the output of cvs log in $currentdir\n";
      print STDERR $line;
      print STDERR "\n";
      if ($line =~ /nothing known about/) {
        print STDERR "No log info for file.\n";
        last;
      }
    }

    # Find the next separator...
    while ($line and !($line =~ /^symbolic names:/) and !($line =~ /^--------*$/) and !($line =~ /^========*$/)) {
      $line = getnextline;
    }

    # Find the revision of the startrevision if any:
    $startrevision="";
    if ($line =~ /^symbolic names:/) {
      $line = getnextline;
      while (!($line =~ /^[a-z]/)) {
		if ($line =~ /[ 	]*(\S*): (\S*)$/) {
		  if ($1 eq $starttag) {
			$startrevision=$2;
		  }
		}
        $line = getnextline;
      }
      # Find the next separator...
      while (!($line =~ /^--------*$/) and !($line =~ /^========*$/)) {
		$line = getnextline;
      }
    }

    $newfile=0;

    # If the separator is a new file separator, flag it.
    if ($line =~ /^========*$/) {
      $newfile = 1;
      # FIXME: We still need to create a index~<filename>__rf.html
	  if ($frames == 1) {
		$rfoutname = $outdirname.'/'.$outfilename.$convdir."__rf.html";
		open(OUTFILE,">$rfoutname") or die "Error: Could not open $rfoutname\n.";
		@listhtmlnames = (@listhtmlnames,$rfoutname);
	  }
	  $fnumber=2;
	  if (length($currentdir)==1) {
		print OUTFILE html_header("--- $rootdir ---");
	  }
	  else {
		print OUTFILE html_header("--- $rootdir/$currentdir ---");
	  }
	  if ($opt_v) { print OUTFILE cvsrootinfo(); }
	  print OUTFILE html_footer("");
	  print OUTFILE "</body></html>\n";

      # This just skips over this file.
    }

	if(defined($opt_V) && $opt_V>2) { print STDOUT "    Getting metadata\n"; }

    $leftfill = 0;
    $line = getnextline;

    while ($newfile==0) {
      if ($line =~ /revision (\S*)/) {
        $revnumber=$1;
      }
      else {
        $revnumber = "[Error_in_revnumber]";
      }

      $line = getnextline;

      if ($line =~ /date: (...................)/) {
        $revdate = $1;
      }
      else {
        $revdate = "[Error_in_revdate]";
      }

      if ($line =~ /author: ([a-zA-Z0-9_]*);/) {
        $author = $1;
      }
      else {
        $author = "[Error_in_author]";
      }

      if ($line =~ /lines: ([+\-0-9 ]*)$/) {
        $changelines = $1;
      }
      else {
        $changelines = "None";
      }

      $line = getnextline;

      if ($line =~ /branches: (.*)/) {
        $line = getnextline;
      }

      ($rd1,$rd2,$rd3,$rdrest) = $revdate =~ /^(\d+)\/(\d+)\/(\d+) (.*)$/;
      $revdateformat2 = $rd1.$rd2.$rd3;
      ($rt1,$rt2,$rt3) = $rdrest =~/(\d+)\:(\d+)\:(\d+)/;

      $revdateformat3 = 3600*$rt1+60*$rt2+$rt3+86400*$revdateformat2;
      $printfilename = $printfilename + 1;

      $fname="";
      if ($opt_f) {
        $fname = '~'.$filename;
      }
      if ((($fnumber == 1) || ($opt_f)) && ($printfilename==1)) {
        if (($opt_f) && ($fnumber==1)){
          $rfoutname = $outdirname.'/'.$outfilename.$convdir."__rf.html";
          open(OUTFILE,">$rfoutname") or die "Error: Could not open $rfoutname\n.";
          @listhtmlnames = (@listhtmlnames,$rfoutname);
		  if (length($currentdir)==1) {
			print OUTFILE html_header("--- $rootdir ---");
		  }
		  else {
			print OUTFILE html_header("--- $rootdir/$currentdir ---");
		  }
          print OUTFILE "<h3>Select entries from the left panel to get to the cvs log information for the files</h3>\n";
		  print OUTFILE html_footer("");
          print OUTFILE "</body>\n</html>\n";
          close(OUTFILE);
        }

        # Lets open the main file and process
        if ($frames == 1) {
          $rfoutname = $outdirname.'/'.$outfilename.$convdir.$fname."__rf.html";
          open(OUTFILE,">$rfoutname") or die "Error: Could not open $rfoutname\n.";
          @listhtmlnames = (@listhtmlnames,$rfoutname);
        }
        else {
          $mainoutname = $outdirname.'/'.$outfilename.$convdir.$fname.".html";
          open(OUTFILE,">$mainoutname") or die "Error: Could not open $mainoutname\n.";
          @listhtmlnames = (@listhtmlnames,$mainoutname);
        }
        $fnumber=2;
		if (length($currentdir)==1) {
		  print OUTFILE html_header("--- $rootdir ---");
		}
		else {
		  print OUTFILE html_header("--- $rootdir/$currentdir ---");
		}
		if ($opt_v) { print OUTFILE cvsrootinfo(); }
      }

      $needthisrevision = 0;
      if (($revdateformat2 >= $cutdate) and ($revnumber ne $startrevision)) {
        $needthisrevision = 1;
      }

      if ( $needthisrevision or $needthisdiffonly ) {
		if (($onlist == 0) && ($printfilename == 1)) {
		  print OUTFILE "<a name=\"$filename\">\n</a>\n";
		  print OUTFILE "<table border=0 cellspacing=1 cellpadding=3 bgcolor=\"$cellcolor\" width=\"100%\">\n";
		  print OUTFILE "<tr>\n";
		  print OUTFILE "<td colspan=4 bgcolor=\"$filenamecellcolor\"><b><font size=\"+1\">\n";

		  $cdir = "";
		  if (length($currentdir)>1) {
			$cdir = '/'.$currentdir;
		  }

		  $Ls = "";
		  $Le = "";
		  if ($opt_L) {
			($flname,$ext) = $filename =~ /^([a-zA-Z0-9+-_]*)\.([a-zA-Z0-9]*)$/;
			if (length($ext)==0) {
			  $flname = $filename;
			}
			$Ls = "<a href=\"$opt_L$cdir/$flname".".html\" target=\"_top\">";
			$Le = "</a>\n";
		  }
		  print OUTFILE $Ls."Filename".$Le.": ";

		  $Ls = "";
		  $Le = "";
		  if (($opt_l) && ($opt_R)) {
			$Ls = "<a href=\"$opt_l$cdir/$filename\?cvsroot\=$opt_R\">";
		   	$Le = "</a>\n";
		  } elsif (($opt_l) && (! opt_R)) {
			$Ls = "<a href=\"$opt_l$cdir/$filename\">";
			$Le = "</a>\n";
		  }
			
		  print OUTFILE $Ls.$filename.$Le;
		  print OUTFILE "</font></B><br></td></tr>\n";
		}
        $onlist = 1;
        if (($opt_o) && ($leftfill == 0)) {
          if ($opt_f) {
            $chronolinker = $outfilename.$convdir.'~'.$filename.'__rf.html';
          }
          else {
            $chronolinker = $outfilename.$convdir.'__rf.html#'.$filename;
          }
		  # justcollect, we'll output them sorted on filename
		  $outfile2lines{$filename}="<tr><td><a href=\"$chronolinker\" target=\"rf\"><font size=\"-1\">$filename</font></a></td></tr>\n";
          $leftfill=2;
        }
        if (($opt_a) && ($oldrevnumber!=0) && ($nodiff!=0)) {
          print OUTFILE "<tr><td colspan=4 bgcolor=\"$differencebackground\"><i>Show difference between <a href=\"$diffdirname/diff$convdir\_$filename\_$oldrevnumber\_$revnumber.html\">Revision $revnumber and $oldrevnumber </a></i>\n";
          generate_diff_file;
          $nodiff--;
        }
        $oldrevnumber=$revnumber;
		if ( $needthisrevision==0 ) {
		  $needthisdiffonly = 0;
		}
		if ( $needthisrevision!=0 ) {
		  if (($opt_a) && ($nodiff!=0)) {
			$needthisdiffonly = 1;
		  }
		  print OUTFILE "<tr><td><b>Revision $revnumber</b><td>$author\n";
		  print OUTFILE "<td>$revdate";
		  if (length($changelines)<2) {
			print OUTFILE "<td>None\n";
		  }
		  else {
			print OUTFILE "<td>$changelines\n";
		  }
		  print OUTFILE "<tr><td colspan=4>\n";
		  if ($dochrono) {
			$chronocounter++;
			$nams = $currentdirformat2.$filename;
			@chronoindex = (@chronoindex,$chronocounter);
			@chrononame = (@chrononame,$nams);
			@chronoauthor = (@chronoauthor,$author);
			@chronoversion = (@chronoversion,$revnumber);
			@chronoshowtime = (@chronoshowtime,$revdate);
			@chronotimesince0 = (@chronotimesince0,$revdateformat3);
			@chronolinknames = (@chronolinknames,$chronolinker);
		  }
		}
      }

      # While more log read and process
      $morelog=1;
      while ($morelog==1) {
        if ($line =~ /^----------*$/) {
          $morelog=0;
        }
        else {
          if ($line =~ /^========*$/) {
            $newfile=1;
            $morelog=0;
          }
          else {
            $_=$line;
            s/&/&amp;/g;
            s/\"/&quot;/g;
            s/</&lt;/g;
            s/>/&gt;/g;
            $line=$_;
            if ($line =~ /^(.*)$/) {
              if (($revdateformat2 >= $cutdate) and ($revnumber ne $startrevision)) {
                if ($opt_e) {
                  print OUTFILE "<code>$1</code><br>\n";
                }
                else {
                  print OUTFILE "$1<br>\n";
                }
              }
            }
          }
        }
        $line = getnextline;
      }
      print OUTFILE "\n";
    }

    if ($onlist==1) {
      print OUTFILE "</table><br>\n";
    }
    if ($onlist==0) {
      @otherdnames = (@otherdnames,$filename);
    }
    if ($opt_f) {
      closemainfile;
    }
  }

  if (!$opt_f) {
    closemainfile;
  }

  if ($opt_o) {
	# output all filenames sorted
	foreach $key (sort { lc($a) cmp lc($b) } keys %outfile2lines) {
	  print OUTFILE2 $outfile2lines{$key}
	}
    print OUTFILE2 "</table><br>\n";
  }
  if (($opt_o) && ($nooffiles == $#otherdnames+1)) {
    print OUTFILE2 "No file revisions.<br>\n";
  }
  if (($#otherdnames>=0) && ($opt_o)) {
    print OUTFILE2 "<br><hr><h3 align=center>Unchanged</h3>\n";
    if ($#otherdnames>=0) {
      print OUTFILE2 "<table border=0 cellspacing=1 cellpadding=3 bgcolor=\"$cellcolor\" width=\"100%\">\n";
      for ($ii=0;$ii<=$#otherdnames;$ii++) {
		print OUTFILE2 "<tr><td><font size=\"-1\">$otherdnames[$ii]</font></td></tr>\n";
      }
      print OUTFILE2 "</table><br>\n";
	}
    else {
      print OUTFILE2 "All files have revisions.<br>\n";
    }
  }

  # Lets wrap up OUTFILE2
  if ($opt_o) {
    print OUTFILE2 "</body>\n";
    print OUTFILE2 "</html>\n";
    close(OUTFILE2);
  }

  # Found a bad one....... This should NOT happen
  if ($foundbadone == 1) {
    print STDERR "\ncvs2html found some files that was no part of CVS\n\n";
  }

  if ($frames == 1) {
    print OUTFILE4 "<table border=0 cellspacing=1 cellpadding=3 bgcolor=\"$cellcolor\" width=\"100%\">\n";

    for ($ddd=0;$ddd<=$#alldirs;$ddd++) {
      ($currentdir) = $alldirs[$ddd] =~ /^\.\/(.*)$/;
      $convdir = $currentdir;
      $convdir =~ tr/\//_/;
      if (length($currentdir)==0) {
        $currentdir='.';
        $convdir = "";
      }
      else {
        $convdir = '_'.$convdir;
      }

      chop($ldir = $alldirs[$ddd]);
      if (length($ldir) == 2) {
        $ldir ="";
      }
      print OUTFILE4 "<tr><td><a href=\"".$outfilename.$convdir."__lfu.html\">[$rootdir]$ldir</a></td></tr>\n";
    }
    print OUTFILE4 "</table><br>\n";
  }

  print OUTFILE4 html_footer("");
  print OUTFILE4 "</noframes>\n";
  print OUTFILE4 "</frameset>\n";
  print OUTFILE4 "</html>\n";
  close(OUTFILE4);
}

if ($dochrono) {
  $coutref = $outdirname."/".$chronooutname;
  open(CHRONOFILE,">$coutref");

  if(defined($opt_V) && $opt_V>0) { print STDOUT "Generate chrono file\n"; }

  print CHRONOFILE html_header("CVS time sorted logs");
  if ($frames == 0) {
	print CHRONOFILE '<a href="'.$outfilename.'.html" target="_top">Back to main page</a><p>';
  }


  #print "Sorting the logfiles\r";
  @cindex = sort sorter @chronoindex;
  #print "Done sorting the logfiles\n";

  if ($frames == 1) {
    print CHRONOFILE "<table border=\"0\" width=\"100%\" bgcolor=\"$cellcolor\" cellspacing=\"1\" cellpadding=\"3\">";
    printf(CHRONOFILE "<tr><td><b>%s</b></td> <td><b>%s</b></td> <td><b>%s</b></td>  <td><b>%s</b></td></tr>\n","Time       ","Revision","Author","Filename");
  }
  else {
    printf(CHRONOFILE "<br><tr><br>\n%20s %8s %10s %s<br><hr>\n","Time       ","Revision","Author","Filename");
  }

  $cclim = $chronocounter;
  $cindexlow=0;
  if ($opt_N>0) {
    if ($opt_N-1<$chronocounter) {
      $cclim = $opt_N-1;
      $cindexlow = $chronocounter+1-$opt_N;
      $cctxt = " and only the last $opt_N changes are shown.";
    }
  }

  if ($cindexlow<0) {
    $cindexlow=0;
  }

  if ($opt_p) {
    for ($ii=$cindexlow;$ii<=$chronocounter;$ii++) {
      if ($opt_c) {
		$cind = $ii;
      }
      else {
		$cind = $chronocounter-$ii+$cindexlow;
      }
      $index = $cindex[$cind];

	  if(defined($opt_V) && $opt_V>1) { print STDOUT "  $chrononame[$index]\n"; }

      @lcvslog = `$cvsLocation log -N -r$chronoversion[$index] "$chrononame[$index]"`;
      @llcvslog = ();
      $headerstill = -1;
      foreach $jj (0 .. ($#lcvslog-1)) {
		if ($headerstill == 0) {
		  $_=$lcvslog[$jj];
		  s/&/&amp;/g;
		  s/\"/&quot;/g;
		  s/</&lt;/g;
		  s/>/&gt;/g;
		  @llcvslog = (@llcvslog,$_);
		}
		else {
		  $headerstill = $headerstill - 1;
		  if ($lcvslog[$jj] =~ '----------------------------') {
			$headerstill = 2;
		  }
		}
      }
      $lcvslogar[$index] = join('<br>',@llcvslog);
      if (length($lcvslogar[$index])<2) {
		$lcvslogar[$index] = "<i>(Empty log)</i>";
      }
    }
  }
  for ($ii=$cindexlow;$ii<=$chronocounter;$ii++) {
    if ($opt_c) {
      $cind = $ii;
      $cind2 = $ii+1;
    }
    else {
      $cind = $chronocounter-$ii+$cindexlow;
      $cind2 = $cind-1;
    }
    $index = $cindex[$cind];
    $index2 = $cindex[$cind2];
    $ccc = '<A HREF="'.$chronolinknames[$index].'">'.$chrononame[$index]."</a>";
    if ($frames==0) {
      printf(CHRONOFILE "%20s %8s %10s %s<br>\n",$chronoshowtime[$index],$chronoversion[$index],$chronoauthor[$index],$ccc);
    }
    else {
      printf(CHRONOFILE "<tr><td><b>%s</b></td> <td>%s</td> <td>%s</td> <td>%s</td></tr>\n",$chronoshowtime[$index],$chronoversion[$index],$chronoauthor[$index],$ccc);
      if ($opt_p) {
	if ($ii == $chronocounter){
	  printf(CHRONOFILE "<tr><td COLSPAN=4>\n");
	  print CHRONOFILE  $lcvslogar[$index];
	  printf(CHRONOFILE "</td></tr>\n");
	}
	elsif (($lcvslogar[$index] ne $lcvslogar[$index2]) || (abs($chronotimesince0[$index]-$chronotimesince0[$index2]))>$commit_smalltimedifference) {
	  printf(CHRONOFILE "<tr><td COLSPAN=4>\n");
	  print CHRONOFILE  $lcvslogar[$index];
	  printf(CHRONOFILE "</td></tr>\n");
	}
      }
    }
  }

  if ($frames == 1) {
    print CHRONOFILE "</table>\n";
  }
  else {
    print CHRONOFILE "<hr>\n";
  }

  if ($frames == 0) {
	print CHRONOFILE '<p><a href="'.$outfilename.'.html" target="_top">Back to main page</a><p>';
  }


  $stradd="";
  if ($cutdate>"00000000") {
    $stradd.=" leaving out any log message prior to $cutyearformat2 $revisionlimitertext";
  }
  print CHRONOFILE html_footer($stradd.$cctxt);
  #Wrap up the file
  print CHRONOFILE "\n</body>\n</html>\n";

  close(CHRONOFILE);
# We must report that a new file has been made
  @listhtmlnames = (@listhtmlnames,$coutref);
}

# Print status about which files have been generated
#  all diffs are under *_diff/ directory
#  files ending on "__rf" are those displayed in the right frame (the ones showing the revision history)
#  files ending on "__lfu" are those displayed in the upper part of the left frame
#  files ending on "__lfl" are those displayed in the lower part of the left frame
#
if(defined($opt_V) && $opt_V>0) {
  print STDOUT "cvs2html has generated the following files :\n";
  @ll=sort(@listhtmlnames);
  for ($ff=0;$ff<=$#listhtmlnames;$ff++) {
	print "  $ll[$ff]\n";
  }
  print "\n";
}
