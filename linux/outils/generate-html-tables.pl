#!/usr/bin/perl
# 2023-07-19T1747+0200
# 2023-11-02T0819+0100
# 2024-05-16T1520+0200
# 2024-10-28T1417+0100
# 2025-09-25T0143+0200
# 2025-11-30T2108+0100
# 2025-12-26T0915+0100
# 2026-01-30T0714+0100
# 2026-04-09T1108+0200
# 2026-11-26T1615+0100
# = last modified.
#
# Generates an HTML table of math symbols, based on multikey sequences in
# Compose.yml.
#
# The input requires the "START_MATH" start tag, and the "END_MATH" end tag.
#
# Alias sequences with no-break space, with numpad digits, with curly
# apostrophe or with the Greek or circled dead key are skipped.
#
# The keyboard output is displayed on a white background span (class "bg") with
# a light-blue baseline for the purpose of delimiting whitespace characters and
# clarifying advance width and vertical alignment.
#
# Localized tooltips require the Unicode NamesList.txt and equivalents in the
# target locale as configured under ## Character names localization.
# ListeNoms.txt is used for characters missing from Udescripteurs.txt.
# Characters missing from both are counted and listed with their line number
# in Compose.yml, and documented in English.
#
# In print, Unicode character names may be replaced with descriptors in the
# last column.
#
# The output is designed for use in WordPress, where "{{{anrghg-classes}}}" can
# be replaced with additional CSS classes, as well as "{{{anrghg-value}}}" with
# anything, classes too in this file, using the A.N.R.GHG Publishing Toolkit.
#
# Emoji style display should be deactivated on the page that this math table
# is a partial of.
#
#
# Using old-style file handles.
use warnings;
use strict;
use utf8;
use feature 'unicode_strings';

# By courtesy of https://stackoverflow.com/a/12291409
use open ":std", ":encoding(UTF-8)";

# By courtesy of https://johnbokma.com/blog/2016/09/14/padding-numbers-with-zero-in-perl.html
use Time::Piece;

## Character names
my $names_file_path       = '../../ressource/NamesList.txt';
## Localized names
my $fr_names_file_path    = '../../ressource/ListeNoms.txt';
## Descriptors
my $descriptors_file_path = '../../ressource/Udescripteurs.txt';

my $names_count           = 0;
my $descriptors_count     = 0;
my $missing_count         = 0;
my $missing_log           = '';

my $input_path = '../compose/Compose.yml';
open( INPUT, '<', $input_path ) or die $!;
print( "Opened file $input_path for reading.\n" );

my $output_directory = 'multikey-tables';
unless ( -d $output_directory ) {
	mkdir $output_directory;
	print( "New directory $output_directory/.\n" );
}
my $output_file_name = 'math-table-partial.html';
my $output_path      = "$output_directory/$output_file_name";
open( OUTPUT, '>', $output_path ) or die $!;
print( "Opened file $output_path.\n" );
print( "Processing math symbols from $input_path to $output_path.\n" );

my $parsing_on              = !1;
my $date_legend           = 'Tableau mis à jour le ';

# By courtesy of https://johnbokma.com/blog/2016/09/14/padding-numbers-with-zero-in-perl.html
my $now_date             = Time::Piece->new;
my $date                 = $now_date->strftime( '%d/%m/%Y' );

my $table_id             = 'tableau-math';
my $table_header_1       = 'Caractère';
my $table_header_2       = 'Séquence de composition';
my $table_header_3       = 'Identifiant Unicode';
my $table_header_4       = 'Descripteur';
my $table_header_title   = 'Cliquer pour basculer entre français et anglais';
my $checkbox_label       = 'Imprimer les descripteurs, non les identifiants';
my $checkbox_checked     = '☑&nbsp;';
my $checkbox_not_checked = '☐&nbsp;';

print OUTPUT "<input type=\"checkbox\" checked=\"checked\" id=\"print\" />\n";
print OUTPUT "<figure class=\"wp-block-table alignwide multikey math {{{anrghg-classes}}} {{{anrghg-value}}}\">\n";
print OUTPUT "<table id=\"$table_id\"><caption><a href=\"#$table_id\">$date_legend$date</a></caption>";
print OUTPUT "<thead><tr><th colspan=\"2\" class=\"has-text-align-left\" data-align=\"left\">$table_header_1</th>";
print OUTPUT "<th class=\"has-text-align-left\" data-align=\"left\">$table_header_2</th><th class=\"has-text-align-left\" data-align=\"left\">\n";
print OUTPUT "<span class=\"en\">$table_header_3</span><span class=\"fr\">$table_header_4</span>\n";
print OUTPUT "<label for=\"print\"><div class=\"status\" title=\"$table_header_title\">";
print OUTPUT "<span class=\"fr\">$checkbox_checked</span><span class=\"en\">$checkbox_not_checked</span>$checkbox_label</div></label>\n";
print OUTPUT "</th></tr></thead><tbody>\n";
print OUTPUT "<!-- Symboles mathématiques -->\n";

my ( $anchor, $check, $class, $comment, $cp, $descrip, $file_id, $index, $line_nb,
     $math, $regex, $str, $test, $text, $textstyle, $tooltip, $ucodes, $winspe, @anchors );
# my ( @anchors, $anchor, $cp, $descrip, $index, $line_nb, $regex, $str, $test, $tooltip );

while ( my $line = <INPUT> ) {
	$line_nb = $.;
	if ( $line =~ /START_MATH/ ) {
		$parsing_on = !0;
	}
	if ( $line =~ /END_MATH/ ) {
		$parsing_on = !1;
	}

	if ( $parsing_on ) {
		unless ( $line =~ /^#/                 # Skip annotations.
			|| $line =~ /<KP_/                   # Keypad equivalents, a Linux feature.
			|| $line =~ /<nobreakspace>/         # No-break space alias sequences.
			|| $line =~ /<rightsinglequotemark>/ # Curly apostrophe alias sequences.
			|| $line =~ /<dead_greek/            # Alias of <at> in multikey sequences.
		) {

			# Collapse spaces.
			$line =~ s/ {2,}/ /g;
			$line =~ s/> </></g;

			# Add tooltips.
			$line =~ s/<Multi_key>/<span class="tooltip" title="Touche de composition AltGr\/Option + ⟦+=}⟧&#10;et en mode ASCII, AltGr\/Option + ⟦£\$¤⟧">¦<\/span>/g;
			$line =~ s/<space>/<span class="tooltip" title="Espace">␣<\/span>/g;
			$line =~ s/<apostrophe>/<span class="tooltip" title="Apostrophe ASCII ou guillemet simple générique Touche ⟦+=}⟧ en mode français,&#10;ou touche ⟦%ù⟧ en mode ASCII,&#10;ou AltGr\/Option + ⟦U⟧&#10;ou encore le guillemet apostrophe Touche ⟦4&#x27;{⟧ en mode français">&#x27;<\/span>/g;
			$line =~ s/<rightsinglequotemark>/<span class="tooltip" title="Guillemet apostrophe Touche ⟦4&#x27;{⟧">’<\/span>/g;
			$line =~ s/<periodcentered>/<span class="tooltip" title="Point médian Touche ⟦§!⟧ en mode français">·<\/span>/g;

			# Convert remaining ASCII and iconic.
			$line =~ s/<asciicircum>/^/g;
			$line =~ s/<percent>/%/g;
			$line =~ s/<EuroSign>/€/g;
			$line =~ s/<quotedbl>/"/g;
			$line =~ s/<backslash>/\\/g;
			$line =~ s/<asciitilde>/~/g;
			$line =~ s/<at>/@/g;
			$line =~ s/<braceleft>/{/g;
			$line =~ s/<braceright>/}/g;
			$line =~ s/<ampersand>/&amp;/g;
			$line =~ s/<numbersign>/#/g;
			$line =~ s/<dollar>/\$/g;
			$line =~ s/<parenleft>/(/g;
			$line =~ s/<parenright>/)/g;
			$line =~ s/<minus>/-/g;
			$line =~ s/<plus>/+/g;
			$line =~ s/<underscore>/_/g;
			$line =~ s/<bracketleft>/[/g;
			$line =~ s/<bracketright>/]/g;
			$line =~ s/<bar>/|/g;
			$line =~ s/<slash>/\//g;
			$line =~ s/<asterisk>/*/g;
			$line =~ s/<less>/&lt;/g;
			$line =~ s/<greater>/&gt;/g;
			$line =~ s/<equal>/=/g;
			$line =~ s/<grave>/`/g;
			$line =~ s/<comma>/,/g;
			$line =~ s/<question>/?/g;
			$line =~ s/<period>/./g;
			$line =~ s/<exclam>/!/g;
			$line =~ s/<colon>/:/g;
			$line =~ s/<semicolon>/;/g;
			$line =~ s/<section>/§/g;
			$line =~ s/<egrave>/è/g;

			# Remove remaining delimiters.
			$line =~ s/<(.)>/$1/g;

			# Add anchors and localized tooltips.
			$line    =~ m/^.+ : +"(.+?)"/u;
			$str     = $1;
			$cp      = ord( $str ); # Code point.
			$cp      = sprintf( "%X", $cp ); # To hex.
			$cp      =~ s/^(.)$/000$1/;
			$cp      =~ s/^(..)$/00$1/;
			$cp      =~ s/^(...)$/0$1/;
			$descrip = '';
			if ( $descriptors_file_path ) {
				open( LIST, '<', $descriptors_file_path ) or die $!;
				while ( my $des_line = <LIST> ) {
					if ( $des_line =~ /U$cp;/ ) {
						chomp( $des_line );
						$des_line =~ s/^.+; (.+)$/$1/;
						$descrip = $des_line;
						++$descriptors_count;
						last;
					}
				}
				close( LIST );
			}
			unless ( $descrip ) {
				open( LIST, '<', $fr_names_file_path ) or die $!;
				while ( my $name_line = <LIST> ) {
					if ( $name_line =~ /^$cp\t/ ) {
						chomp( $name_line );
						$name_line =~ s/^.+\t(.+)$/$1/;
						$descrip = $name_line;
						++$names_count;
						last;
					}
				}
				close( LIST );
			}
			unless ( $descrip ) {
				++$missing_count;
				$missing_log .= $cp . ' (:' . $line_nb . ")\n";
				open( LIST, '<', $names_file_path ) or die $!;
				while ( my $name_line = <LIST> ) {
					if ( $name_line =~ /^$cp\t/ ) {
						chomp( $name_line );
						$name_line =~ s/^.+\t(.+)$/$1/;
						$descrip = $name_line;
						last;
					}
				}
				close( LIST );
			}
			$tooltip = $descrip . " U+$cp";
			$anchor  = 'U+' . $cp;
			$regex   = quotemeta( $anchor );
			$index   = 0;
			if ( grep( /^$regex$/, @anchors ) ) {
				$test = $regex;
				while ( grep( /^$test$/, @anchors ) ) {
					++$index;
					$test = $regex . '_' . $index;
				}
				$anchor = $anchor . '_' . $index;
			}
			push( @anchors, $anchor );

			# Anchor end tags are spaced out so as to not match the regex adding a tooltip to anchor elements.
			# (For this to be effective, KSES needs to be turned off when this is loaded into the web page.)
			
			# Diacritics.
			$line =~ s/^(.+?) : "(.+?)" U(20[DE][0-9A-F]) # (.+)/<tr id="$anchor"><td title="$tooltip"><a href="#$anchor"><span class="bg">◌$2<\/span><\/a ><\/td><td title="$4">U+$3<\/td><td>$1<\/td><td><span class="en">$4<\/span><span class="fr">$descrip<\/span><\/td><\/tr>/;
			
			# Spacing symbols.
			$line =~ s/^(.+?) : "(.+?)" U([0-9A-F]{4,5}) # (.+)/<tr id="$anchor"><td title="$tooltip"><a href="#$anchor"><span class="bg">$2<\/span><\/a ><\/td><td title="$4">U+$3<\/td><td>$1<\/td><td><span class="en">$4<\/span><span class="fr">$descrip<\/span><\/td><\/tr>/;
			
			print OUTPUT "$line";
		}
	}
}
print OUTPUT "</tbody></table></figure>\n";
close( INPUT );
print( "Closed file $input_path.\n" );
close( OUTPUT );
print( "Closed file $output_path.\n" );
print( "Math table generated in $output_directory/.\n" );
print( "Used $names_count times $fr_names_file_path.\n" );
print( "Used $descriptors_count times $descriptors_file_path.\n" );
if ( $missing_count == 1 ) {
	print( "Not localized: $missing_count name.\n" );
	print( "Affected code point (at line number): $missing_log" );
} elsif ( $missing_count > 1 ) {
	print( "Not localized: $missing_count names.\n" );
	print( "Affected code points (at line numbers):\n$missing_log" );
} else {
	print( "All names localized.\n" );
}

# 2023-07-23T0239+0200
# 2023-08-06T1934+0200
# 2024-10-28T1416+0100
# 2025-05-26T2331+0200
# 2025-11-30T2107+0100
# 2026-01-12T1834+0100
# 2026-10-19T2048+0200
# = last modified.
#
# Generates HTML tables of dead keys from dead key sequences in Compose.yml.
# Multi_key equivalents are skipped.
#
# The input requires "START_GREEK" as a start tag.
#
# Section headings with a leading "#*#" and the following headings switch files
# of partial tables:
#
#     ### Space and symbol groups
#     ### Letter groups
#     ### Greek with diacritics
#     #.# DEAD_LEGACYTILDE
#     #.# DEAD_LEGACYGRAVE
#     #   EMOJI_READY
#
# As the keyboard input may end with a dead key, this needs to be marked up
# with a bold label and a bold border, so as to not raise questions about
# whether the base character display is broken, as it happens when a keysym
# is not converted. That is achieved by :last-child style rules, so that the
# unwrapped input characters need to be wrapped each one in a span.
#
# The keyboard output is marked up for display with a white background and with
# a light-blue baseline for the purpose of delimiting whitespace characters and
# clarifying advance width and vertical alignment.
#
# In these tables, a second instance of each emoji is displayed in text style,
# provided that the text style variation selector is supported. This feature
# is intended to make emoji searchable (the alt attribute is not).
#
# Math symbols get an appended link to their first instance on the math symbols
# page https://dispoclavier.com/nouvel-azerty/composition/symboles-mathematiques/
# on the condition that the "math" string occurs right before the EOL.
#
# Localized tooltips require the Unicode NamesList.txt or equivalents in the
# target locale as configured under ## Character names localization.
# ListeNoms.txt is used for characters missing from Udescripteurs.txt.
# Characters missing from both are counted and listed with their line number
# in Compose.yml.
#
# In order to compensate Windows users for a defective dead key implementation
# that disregards the official Unicode recommendation as of supporting composed
# letters by dead keys, alternative input may be provided in Compose.yml so as
# to have all sequences in a single place with special markup in the dead key
# tables. These lines starting with "#@" are parsed in Compose.yml alongside.
# https://www.unicode.org/versions/Unicode17.0.0/core-spec/chapter-5/#G1076
# See Compose.yml # # Notes about documentation
# See Compose.yml # # Notes for maintenance
#
# The output is designed for use in WordPress, where "{{{anrghg-classes}}}" can
# be replaced with additional CSS classes, as well as "{{{anrghg-value}}}" with
# anything, classes too in this file, using the A.N.R.GHG Publishing Toolkit.
#
# The partials are included in pages in WordPress using the “Include partial”
# block provided by this plugin. Posts with too much code in HTML blocks cannot
# be saved.
#
#
# Using old-style file handles.
# use strict;
# use warnings;
# use utf8;
# use feature 'unicode_strings';

# By courtesy of https://stackoverflow.com/a/12291409
# use open ":std", ":encoding(UTF-8)";

# By courtesy of https://johnbokma.com/blog/2016/09/14/padding-numbers-with-zero-in-perl.html
# use Time::Piece;

# my $names_count           = 0;
# my $descriptors_count     = 0;
# my $missing_count         = 0;
# my $missing_log           = '';

# my $input_path = '../compose/Compose.yml';
open( INPUT, '<', $input_path ) or die $!;
print( "Opened file $input_path for reading.\n" );

$output_directory = 'deadkey-tables';
unless ( -d $output_directory ) {
	mkdir $output_directory;
	print( "New directory $output_directory/.\n" );
}
my $output_file_name_template = 'deadkey-table-partial';
my $output_path_trunk         = "$output_directory/$output_file_name_template";
my $output_file_index         = -2;
my $output_file_extension     = '.html';
$output_path               = "$output_directory/ALL_$output_file_name_template$output_file_extension";
open( WHOLEOUTPUT, '>', $output_path ) or die $!;
print( "Opened file $output_path.\n" );
my $wholeoutput_path = $output_path;
$output_path         = $output_path_trunk . $output_file_extension;
open( OUTPUT, '>', $output_path ) or die $!;
print( "Opened file $output_path.\n" );
print( "Processing dead keys from $input_path to $output_path.\n" );

$parsing_on       = !1;
my $comprehensive  = !0;
# my $date_legend    = 'Tableau mis à jour le ';

# By courtesy of https://johnbokma.com/blog/2016/09/14/padding-numbers-with-zero-in-perl.html
# my $now_date             = Time::Piece->new;
# my $date                 = $now_date->strftime( '%d/%m/%Y' );

$table_id             = 'tableau-tm';
$table_header_1       = 'Caractère(s)';
$table_header_2       = 'Touches';
$table_header_3       = 'Identifiant Unicode';
$table_header_4       = 'Descripteur';
$table_header_title   = 'Cliquer pour basculer entre français et anglais';
$checkbox_label       = 'Imprimer les descripteurs, non les identifiants';
$checkbox_checked     = '☑&nbsp;';
$checkbox_not_checked = '☐&nbsp;';
#my $start_tags_1         = "<input type=\"checkbox\" checked=\"checked\" id=\"print\" />\n";
my $start_tags_1        = "<figure class=\"wp-block-table alignwide deadkeys {{{anrghg-classes}}} {{{anrghg-value}}}\"><table id=\"";
my $start_tags_2         = "\">$date_legend$date</a></caption><thead><tr><th colspan=\"2\" class=\"has-text-align-left\" data-align=\"left\">$table_header_1</th><th class=\"has-text-align-left\" data-align=\"left\">$table_header_2</th><th class=\"has-text-align-left\" data-align=\"left\">$table_header_3</th></tr></thead><tbody>\n";
my $start_tags           = "$start_tags_1$table_id\"><caption><a href=\"#$table_id$start_tags_2";
my $end_tags             = "</tbody></table></figure>\n";
print WHOLEOUTPUT $start_tags;
print OUTPUT $start_tags;
# my ( @anchors, $anchor, $check, $cp, $class, $descrip, $index, $line_nb, $math, $regex, $str,
#		 $test, $textstyle, $tooltip, $ucodes, $winspe );
my $highsu = 'Uniquement pour Windows';
my $nowin  = 'Ne fonctionne pas sous Windows';

while ( my $line = <INPUT> ) {
	$line_nb = $.;
	if ( $line =~ /START_GREEK/ ) {
		$parsing_on = !0;
	}
	if ( $parsing_on ) {
		if ( $line =~ /^#\*# /
			|| $line =~ /^### Space and symbol groups/
			|| $line =~ /^### Letter groups/
			|| $line =~ /^### Greek with diacritics/
			|| $line =~ /^#\.# DEAD_LEGACYTILDE/
			|| $line =~ /^#\.# DEAD_LEGACYGRAVE/
		#	|| $line =~ /^#   EMOJI_READY/
		) {
			print OUTPUT $end_tags;
			close( OUTPUT );
			print( "Closed file $output_path.\n" );
			$line =~ s/^....//;
			$line =~ s/,//g;
			$line =~ s/ /-/g;
			$line =~ m/(.+)/;
			$output_path = $output_path_trunk . '_' . $output_file_index . '_' . $1 . $output_file_extension;
			$table_id    = "tableau-tm-$output_file_index";
			$start_tags  = "$start_tags_1$table_id\"><caption><a href=\"#$table_id$start_tags_2";
			++$output_file_index;
			open( OUTPUT, '>', $output_path ) or die $!;
			print( "Opened file $output_path.\n" );
			print( "Processing dead keys from $input_path to $output_path.\n" );
			print OUTPUT $start_tags;
			print OUTPUT "<!-- $1 -->\n";
		}

		unless ( $line =~ /<Multi_key>/                  # Multikey equivalents are skipped.
			|| $line =~ /^#[^@]/                 # Annotations are not (yet) processed.
			|| $line =~ /<KP_/                   # Keypad equivalents, a Linux feature.
			|| $line =~ /<rightsinglequotemark>/ # Curly apostrophe alias of ASCII apostrophe.
			|| $line =~ /high surrogate/         # High surrogates, a Windows feature.
			|| $line =~ /# [Aa]vailable\.?$/     # Empty slots in letter groups.
			|| $line =~ /<UEFD0><UEFD0><UEFD0>/  # Triple or quadruple group dead key press alternatives.
		) {
			if ( $line =~ /<dead_abovedot>/
				|| $line =~ /<dead_abovering>/
				|| $line =~ /<dead_acute>/
				|| $line =~ /<dead_belowcomma>/
				|| $line =~ /<dead_belowdot>/
				|| $line =~ /<dead_breve>/
				|| $line =~ /<dead_caron>/
				|| $line =~ /<dead_cedilla>/
				|| $line =~ /<dead_circumflex>/
				|| $line =~ /<dead_currency>/
				|| $line =~ /<dead_diaeresis>/
				|| $line =~ /<dead_doubleacute>/
				|| $line =~ /<dead_grave>/
				|| $line =~ /<dead_greek>/
				|| $line =~ /<dead_hook>/
				|| $line =~ /<dead_horn>/
				|| $line =~ /<dead_invertedbreve>/
				|| $line =~ /<dead_macron>/
				|| $line =~ /<dead_ogonek>/
				|| $line =~ /<dead_stroke>/
				|| $line =~ /<dead_tilde>/
				|| $line =~ /<UEFD0>/
				|| $line =~ /<UEFD1>/
				|| $line =~ /<UEFD2>/
				|| $line =~ /<UEFD3>/
				|| $line =~ /<UEFD4>/
				|| $line =~ /<UEFD5>/
				|| $line =~ /<UEFD6>/
				|| $line =~ /<UEFD7>/
				|| $line =~ /<UEFD8>/
				|| $line =~ /<UEFD9>/
				|| $line =~ /<UEFDA>/
			) {

				# The Windows-specific prefix triggers special formatting.
				if ( $line =~ /^#@/ ) {
					$line    =~ s/^#@//;
					$class   = 'winspe';
					$winspe  = ' title="Uniquement sous Windows"';
					$check   = '<div class="check">Windows</div>';
				} else {
					$class = 'common';
					$winspe = '';
					$check  = '';
				}

				# Starting from here, this should be in sync with generate-multikey-tables.pl,
				# except for the attributeless spans needed for dead key base markup.

				# Convert dead keys.
				$line =~ s/<dead_abovedot>/<kbd class="deadkey long" title="Touche morte point en chef Maj + AltGr\/Option + ⟦P⟧">point en chef<\/kbd>/g;
				$line =~ s/<dead_abovering>/<kbd class="deadkey long" title="Touche morte rond en chef Maj + AltGr\/Option + ⟦X⟧">rond en chef<\/kbd>/g;
				$line =~ s/<dead_acute>/<kbd class="deadkey" title="Touche morte accent aigu Touche ⟦£\$¤⟧&#10;ou Maj + AltGr\/Option + ⟦U⟧">aigu<\/kbd>/g;
				$line =~ s/<dead_belowcomma>/<kbd class="deadkey long" title="Touche morte virgule souscrite Maj + AltGr\/Option + ⟦.;⟧">virgule souscrite<\/kbd>/g;
				$line =~ s/<dead_belowdot>/<kbd class="deadkey long" title="Touche morte point souscrit Maj + AltGr\/Option + ⟦§!⟧">point souscrit<\/kbd>/g;
				$line =~ s/<dead_breve>/<kbd class="deadkey" title="Touche morte brève Maj + AltGr\/Option + ⟦F⟧">brève<\/kbd>/g;
				$line =~ s/<dead_caron>/<kbd class="deadkey" title="Touche morte hatchek Maj + AltGr\/Option + ⟦V⟧">hatchek<\/kbd>/g;
				$line =~ s/<dead_cedilla>/<kbd class="deadkey" title="Touche morte cédille Maj + AltGr\/Option + ⟦?,⟧">cédille<\/kbd>/g;
				$line =~ s/<dead_circumflex>/<kbd class="deadkey" title="Touche morte accent circonflexe Touche ⟦¨^⟧&#10;ou Maj + AltGr\/Option + ⟦C⟧">circonflexe<\/kbd>/g;
				$line =~ s/<dead_currency>/<kbd class="deadkey long" title="Touche morte monétaire Maj + AltGr\/Option + ⟦S⟧">monétaire<\/kbd>/g;
				$line =~ s/<dead_diaeresis>/<kbd class="deadkey" title="Touche morte tréma Touche ⟦5([⟧&#10;ou Maj + AltGr\/Option + ⟦\/:⟧">tréma<\/kbd>/g;
				$line =~ s/<dead_doubleacute>/<kbd class="deadkey" title="Touche morte double accent aigu Maj + AltGr\/Option + ⟦E⟧">double aigu<\/kbd>/g;
				$line =~ s/<dead_grave>/<kbd class="deadkey" title="Touche morte accent grave AltGr\/Option + ⟦£\$¤⟧&#10;ou Maj + AltGr\/Option + ⟦N⟧">grave<\/kbd>/g;
				$line =~ s/<dead_greek>/<kbd class="deadkey" title="Touche morte grec ou cerclé AltGr\/Option + ⟦Y⟧&#10;ou Maj + AltGr\/Option + ⟦Y⟧">grec<\/kbd>/g;
				$line =~ s/<dead_hook>/<kbd class="deadkey" title="Touche morte crosse ou crochet Maj + AltGr\/Option + ⟦I⟧">crosse<\/kbd>/g;
				$line =~ s/<dead_horn>/<kbd class="deadkey" title="Touche morte cornu Maj + AltGr\/Option + ⟦H⟧">cornu<\/kbd>/g;
				$line =~ s/<dead_invertedbreve>/<kbd class="deadkey long" title="Touche morte brève inversée Maj + AltGr\/Option + ⟦D⟧">brève inversée<\/kbd>/g;
				$line =~ s/<dead_macron>/<kbd class="deadkey" title="Touche morte macron Maj + AltGr\/Option + ⟦M⟧">macron<\/kbd>/g;
				$line =~ s/<dead_ogonek>/<kbd class="deadkey" title="Touche morte ogonek Maj + AltGr\/Option + ⟦K⟧">ogonek<\/kbd>/g;
				$line =~ s/<dead_stroke>/<kbd class="deadkey" title="Touche morte barré Maj + AltGr\/Option + ⟦W⟧">barré<\/kbd>/g;
				$line =~ s/<dead_tilde>/<kbd class="deadkey" title="Touche morte tilde AltGr\/Option + ⟦¨^⟧&#10;ou Maj + AltGr\/Option + ⟦T⟧">tilde<\/kbd>/g;
				$line =~ s/<UEFD0>/<kbd class="deadkey" title="Touche morte groupe Touche ⟦µ*⟧&#10;ou Maj + AltGr\/Option + ⟦Q⟧">groupe<\/kbd>/g;
				$line =~ s/<UEFD1>/<kbd class="deadkey" title="Touche morte exposant Maj + AltGr\/Option + ⟦A⟧">exposant<\/kbd>/g;
				$line =~ s/<UEFD2>/<kbd class="deadkey" title="Touche morte indice Maj + AltGr\/Option + ⟦J⟧">indice<\/kbd>/g;
				$line =~ s/<UEFD3>/<kbd class="deadkey long" title="Touche morte crochet en chef Maj + AltGr\/Option + ⟦L⟧">crochet en chef<\/kbd>/g;
				$line =~ s/<UEFD4>/<kbd class="deadkey long" title="Touche morte crochet rétroflexe Maj + AltGr\/Option + ⟦O⟧">crochet rétroflexe<\/kbd>/g;
				$line =~ s/<UEFD5>/<kbd class="deadkey" title="Touche morte tourné Maj + AltGr\/Option + ⟦Z⟧">tourné<\/kbd>/g;
				$line =~ s/<UEFD6>/<kbd class="deadkey" title="Touche morte réfléchi Maj + AltGr\/Option + ⟦R⟧">réfléchi<\/kbd>/g;
				$line =~ s/<UEFD7>/<kbd class="deadkey" title="Touche morte drapeau Maj + AltGr\/Option + ⟦B⟧">drapeau<\/kbd>/g;
				$line =~ s/<UEFD8>/<kbd class="deadkey" title="Touche morte rayé Maj + AltGr\/Option + ⟦G⟧">rayé<\/kbd>/g;
				$line =~ s/<UEFD9>/<kbd class="deadkey long" title="Touche morte tilde rétrocompatible Maj + AltGr\/Option + ⟦2é~⟧">tilde rétrocompatible<\/kbd>/g;
				$line =~ s/<UEFDA>/<kbd class="deadkey long" title="Touche morte accent grave rétrocompatible Maj + AltGr\/Option + ⟦7è`⟧">grave rétrocompatible<\/kbd>/g;

				# Remove spaces.
				$line =~ s/ {2,}/ /g;
				$line =~ s/> </></g;

				# Mark up invisibles or confusables.
				$line =~ s/<U202F>/<kbd class="livekey" title="Espace fine insécable AltFr + ⟦Espace⟧ (en mode français uniquement)">fine insécable<\/kbd>/g;
				$line =~ s/<U200B>/<kbd class="livekey" title="Césure conditionnelle Maj + AltGr\/Option + ⟦Espace⟧ (en mode français uniquement)">espace nulle<\/kbd>/g;
				$line =~ s/<hyphen>/<kbd class="livekey" title="Trait d’union conditionnel Maj + ⟦5([⟧ (en mode français uniquement)">- conditionnel<\/kbd>/g;
				$line =~ s/<emdash>/<kbd class="livekey" title="Tiret cadratin Maj + ⟦4&#x27;{⟧">— tiret cadratin<\/kbd>/g;
				$line =~ s/<endash>/<kbd class="livekey" title="Tiret demi-cadratin Maj + ⟦3&#x22;#⟧">– tiret demi-cadratin<\/kbd>/g;
				$line =~ s/<U2212>/<kbd class="livekey" title="Signe moins AltFr + ⟦T⟧">− signe moins<\/kbd>/g;
				$line =~ s/<U02BB>/<kbd class="livekey" title="Lettre apostrophe tournée Maj + ⟦8_\\⟧ sur les variantes pour la Polynésie">ʻ lettre apostrophe tournée<\/kbd>/g;
				$line =~ s/<UEF60>/<kbd class="livekey" title="Point d’exclamation espacé AltFr + ⟦§!⟧">[fine insécable]!<\/kbd>/g;
				$line =~ s/<UEF63>/<kbd class="livekey" title="Point d’interrogation espacé AltFr + ⟦?,⟧">[fine insécable]?<\/kbd>/g;
				$line =~ s/<UEF65>/<kbd class="livekey" title="Guillemet fermant espacé AltFr + ⟦?,⟧">[fine insécable]»<\/kbd>/g;
				$line =~ s/<UEF67>/<kbd class="livekey" title="Guillemet simple fermant espacé AltFr + ⟦£\$¤⟧">[fine insécable]›<\/kbd>/g;
				$line =~ s/<UEF64>/<kbd class="livekey" title="Guillemet ouvrant espacé AltFr + ⟦%ù⟧">«[fine insécable]<\/kbd>/g;
				$line =~ s/<UEF66>/<kbd class="livekey" title="Guillemet simple ouvrant espacé AltFr + ⟦¨^⟧">‹[fine insécable]<\/kbd>/g;

				# Add tooltips.
				$line =~ s/<Multi_key>/<span class="tooltip" title="Touche de composition AltGr\/Option + ⟦+=}⟧&#10;et en mode ASCII, AltGr\/Option + ⟦£\$¤⟧">¦<\/span>/g;
				$line =~ s/<space>/<span class="tooltip" title="Espace">␣<\/span>/g;
				$line =~ s/<nobreakspace>/<span class="tooltip" title="Espace insécable AltGr\/Option + ⟦Espace⟧ (en mode français uniquement)">⍽<\/span>/g;
				$line =~ s/<apostrophe>/<span class="tooltip" title="Apostrophe ASCII ou guillemet simple générique Touche ⟦+=}⟧ en mode français,&#10;ou touche ⟦%ù⟧ en mode ASCII,&#10;ou AltGr\/Option + ⟦U⟧&#10;ou encore le guillemet apostrophe Touche ⟦4&#x27;{⟧ en mode français">&#x27;<\/span>/g;
				$line =~ s/<rightsinglequotemark>/<span class="tooltip" title="Guillemet apostrophe Touche ⟦4&#x27;{⟧">’<\/span>/g;
				$line =~ s/<degree>/<span class="tooltip" title="Symbole degré Maj + ⟦°)]⟧">°<\/span>/g;
				$line =~ s/<multiply>/<span class="tooltip" title="Symbole multiplication AltFr + ⟦C⟧">×<\/span>/g;
				$line =~ s/<paragraph>/<span class="tooltip" title="Symbole paragraphe américain Maj + AltFr + ⟦P⟧">¶<\/span>/g;
				$line =~ s/<U2039>/<span class="tooltip" title="Guillemet chevron simple AltFr + ⟦¨^⟧">‹<\/span>/g;
				$line =~ s/<U203A>/<span class="tooltip" title="Guillemet chevron simple AltFr + ⟦£\$¤⟧">›<\/span>/g;
				$line =~ s/<U0190>/<span class="tooltip" title="Capitale latine E ouvert Maj + ⟦1&⟧ sur les variantes pour l’Afrique francophone">Ɛ<\/span>/g;
				$line =~ s/<U025B>/<span class="tooltip" title="Minuscule latine e ouvert Touche ⟦1&⟧ sur les variantes pour l’Afrique francophone">ɛ<\/span>/g;
				$line =~ s/<U0186>/<span class="tooltip" title="Capitale latine O ouvert Maj + ⟦8_\\⟧ sur les variantes pour l’Afrique francophone">Ɔ<\/span>/g;
				$line =~ s/<U0254>/<span class="tooltip" title="Minuscule latine o ouvert Touche ⟦8_\\⟧ sur les variantes pour l’Afrique francophone">ɔ<\/span>/g;
				$line =~ s/<twosuperior>/<span class="tooltip" title="Exposant 2 Touche ⟦1&⟧ en mode français">²<\/span>/g;
				$line =~ s/<periodcentered>/<span class="tooltip" title="Point médian Touche ⟦§!⟧ en mode français">·<\/span>/g;
				$line =~ s/<ellipsis>/<span class="tooltip" title="Points de suspension Touche ⟦%ù⟧ en mode français">…<\/span>/g;

				# Convert remaining ASCII and iconic.
				$line =~ s/<asciicircum>/<span>^<\/span>/g;
				$line =~ s/<percent>/<span>%<\/span>/g;
				$line =~ s/<EuroSign>/<span>€<\/span>/g;
				$line =~ s/<quotedbl>/<span>&quot;<\/span>/g;
				$line =~ s/<backslash>/<span>\\<\/span>/g;
				$line =~ s/<asciitilde>/<span>~<\/span>/g;
				$line =~ s/<at>/<span>@<\/span>/g;
				$line =~ s/<braceleft>/<span>{<\/span>/g;
				$line =~ s/<braceright>/<span>}<\/span>/g;
				$line =~ s/<ampersand>/<span>&amp;<\/span>/g;
				$line =~ s/<numbersign>/<span>#<\/span>/g;
				$line =~ s/<dollar>/<span>\$<\/span>/g;
				$line =~ s/<parenleft>/<span>(<\/span>/g;
				$line =~ s/<parenright>/<span>)<\/span>/g;
				$line =~ s/<minus>/<span>-<\/span>/g;
				$line =~ s/<plus>/<span>+<\/span>/g;
				$line =~ s/<underscore>/<span>_<\/span>/g;
				$line =~ s/<bracketleft>/<span>[<\/span>/g;
				$line =~ s/<bracketright>/<span>]<\/span>/g;
				$line =~ s/<bar>/<span>|<\/span>/g;
				$line =~ s/<slash>/<span>\/<\/span>/g;
				$line =~ s/<asterisk>/<span>*<\/span>/g;
				$line =~ s/<less>/<span>&lt;<\/span>/g;
				$line =~ s/<greater>/<span>&gt;<\/span>/g;
				$line =~ s/<equal>/<span>=<\/span>/g;
				$line =~ s/<grave>/<span>`<\/span>/g;
				$line =~ s/<comma>/<span>,<\/span>/g;
				$line =~ s/<question>/<span>?<\/span>/g;
				$line =~ s/<period>/<span>.<\/span>/g;
				$line =~ s/<exclam>/<span>!<\/span>/g;
				$line =~ s/<colon>/<span>:<\/span>/g;
				$line =~ s/<semicolon>/<span>;<\/span>/g;
				$line =~ s/<section>/<span>§<\/span>/g;
				$line =~ s/<mu>/<span>µ<\/span>/g;
				$line =~ s/<guillemotleft>/<span>«<\/span>/g;
				$line =~ s/<guillemotright>/<span>»<\/span>/g;
				$line =~ s/<agrave>/<span>à<\/span>/g;
				$line =~ s/<Agrave>/<span>À<\/span>/g;
				$line =~ s/<egrave>/<span>è<\/span>/g;
				$line =~ s/<Egrave>/<span>È<\/span>/g;
				$line =~ s/<ugrave>/<span>ù<\/span>/g;
				$line =~ s/<Ugrave>/<span>Ù<\/span>/g;
				$line =~ s/<eacute>/<span>é<\/span>/g;
				$line =~ s/<Eacute>/<span>É<\/span>/g;
				$line =~ s/<ccedilla>/<span>ç<\/span>/g;
				$line =~ s/<Ccedilla>/<span>Ç<\/span>/g;
				$line =~ s/<adiaeresis>/<span>ä<\/span>/g;
				$line =~ s/<Adiaeresis>/<span>Ä<\/span>/g;
				$line =~ s/<odiaeresis>/<span>ö<\/span>/g;
				$line =~ s/<Odiaeresis>/<span>Ö<\/span>/g;
				$line =~ s/<udiaeresis>/<span>ü<\/span>/g;
				$line =~ s/<Udiaeresis>/<span>Ü<\/span>/g;
				$line =~ s/<ntilde>/<span>ñ<\/span>/g;
				$line =~ s/<Ntilde>/<span>Ñ<\/span>/g;

				# Convert remaining Unicode keysyms to NCRs.
				$line =~ s/<U([0-9A-F]{4})>/<span>&#x$1;<\/span>/g;

				# Format Unicode scalars in comments.
				$line =~ s/U([0-9A-F]{4,5})/U+$1/g;

				# Remove remaining keysym delimiters.
				$line =~ s/<([a-zA-Z0-9])>/<span>$1<\/span>/g;

				# Down to here, this should be in sync with generate-multikey-tables.pl,
				# except for the attributeless spans needed for dead key base markup.

				# Translate English comments to French.
				$line =~ s/ # Wide-headed arrow high surrogate/ # Surrogat haut de flèche à pointe large/g;
				$line =~ s/( # .*) "(.)" key emulation/$1 émulation de touche &quot;$2&quot;/g;
				$line =~ s/( # .*) (\d\d?)th-ranking/$1 classé au rang $2/g;
				$line =~ s/( # .*) \(lenient\)/$1 pour une expérience utilisateur plus lisse/g;
				$line =~ s/( # .*) \(Pe̍h-ōe-jī orthography\)/$1 (orthographe Pe̍h-ōe-jī)/g;
				$line =~ s/( # .*) affected by glyph like (U\+[0-9A-F]{4,5}) disturbance/$1 victime d’une confusion de glyphes, s’affiche comme $2/g;
				$line =~ s/( # .*) ALA-LC for/$1 ALA-LC pour/g;
				$line =~ s/( # .*) ALA-LC romanization/$1 romanisation ALA-LC/g;
				$line =~ s/( # .*) Arabic transliteration/$1 translittération arabe/g;
				$line =~ s/( # .*) Canadian French:/$1 Français du Canada :/g;
				$line =~ s/( # .*) check mark button/$1 bouton de coche/g;
				$line =~ s/( # .*) Chimane orthography of Wayne Gill/$1 Chimane orthographe de Wayne Gill/g;
				$line =~ s/( # .*) Croatian/$1 croate/g;
				$line =~ s/( # .*) cross mark button/$1 bouton de croix/g;
				$line =~ s/( # .*) Cuneiform transliteration/$1 translittération cunéiforme/g;
				$line =~ s/( # .*) cursive joiner/$1 liant cursif/g;
				$line =~ s/( # .*) cursive non-joiner/$1 antiliant cursif/g;
				$line =~ s/( # .*) Demotic transcription/$1 transcription démotique/g;
				$line =~ s/( # .*) double comma quotation mark/$1 guillemet apostrophe double/g;
				$line =~ s/( # .*) double reversed comma quotation mark/$1 guillemet apostrophe double réfléchi/g;
				$line =~ s/( # .*) double turned comma quotation mark/$1 guillemet apostrophe double tourné/g;
				$line =~ s/( # .*) drive slow sign/$1 panneau aller doucement/g;
				$line =~ s/( # .*) Dutch/$1 néerlandais/g;
				$line =~ s/( # .*) emoji style/$1 style émoji/g;
				$line =~ s/( # .*) emoji with skin tone support/$1 émoji avec prise en charge de la couleur de peau/g;
				$line =~ s/( # .*) engaged, betrothed, wedding ring/$1 fiancé, fiancée, alliance/g;
				$line =~ s/( # .*) ergonomic mapping/$1 disposition ergonomique/g;
				$line =~ s/( # .*) fast down button/$1 bouton de diminution rapide/g;
				$line =~ s/( # .*) fast reverse button/$1 bouton de retour rapide/g;
				$line =~ s/( # .*) fast up button/$1 bouton d’augmentation rapide/g;
				$line =~ s/( # .*) fast-forward button/$1 bouton d’avance rapide/g;
				$line =~ s/( # .*) for African and Breton variants/$1 pour variantes africaine et bretonne/g;
				$line =~ s/( # .*) for African variant/$1 pour variante africaine/g;
				$line =~ s/( # .*) for Breton variant/$1 pour variante bretonne/g;
				$line =~ s/( # .*) for Swiss layout/$1 pour disposition suisse/g;
				$line =~ s/( # .*) for use in Rromani/$1 pour son usage en rromani/g;
				$line =~ s/( # .*) fountain pen/$1 stylo plume/g;
				$line =~ s/( # .*) French:/$1 Français :/g;
				$line =~ s/( # .*) Fula in Senegalese orthography/$1 fula selon l’orthographe sénégalaise/g;
				$line =~ s/( # .*) generic base character for combining diacritics/$1 caractère de base générique pour diacritiques combinants/g;
				$line =~ s/( # .*) Georgian/$1 géorgien/g;
				$line =~ s/( # .*) German dialectology/$1 dialectologie allemande/g;
				$line =~ s/( # .*) Hausa in Boko/$1 hausa en boko/g;
				$line =~ s/( # .*) heart suit/$1 couleur de cœur/g;
				$line =~ s/( # .*) Herero old orthography/$1 héréro ancienne orthographe/g;
				$line =~ s/( # .*) highlighter mark/$1 mise en évidence/g;
				$line =~ s/( # .*) hollow red circle/$1 anneau rouge/g;
				$line =~ s/( # .*) hourglass done/$1 sablier terminé/g;
				$line =~ s/( # .*) hourglass not done/$1 sablier non terminé/g;
				$line =~ s/( # .*) in legacy usage/$1 précédemment/g;
				$line =~ s/( # .*) infinity/$1 infinité/g;
				$line =~ s/( # .*) Japanese kome/$1 kome japonais/g;
				$line =~ s/( # .*) Languages in Gabon/$1 langues au Gabon/g;
				$line =~ s/( # .*) Languages in Togo/$1 langues au Togo/g;
				$line =~ s/( # .*) last track button/$1 bouton de la dernière piste/g;
				$line =~ s/( # .*) Lezgian/$1 lezghien/g;
				$line =~ s/( # .*) lightning/$1 éclair/g;
				$line =~ s/( # .*) Lithuanian/$1 lithuanien/g;
				$line =~ s/( # .*) low double comma quotation mark/$1 guillemet virgule double/g;
				$line =~ s/( # .*) low single comma quotation mark/$1 guillemet virgule simple/g;
				$line =~ s/( # .*) Malagasy/$1 malgache/g;
				$line =~ s/( # .*) mapped like on Greek keyboards/$1 disposé comme sur les claviers grecs/g;
				$line =~ s/( # .*) Marshallese/$1 marshallais/g;
				$line =~ s/( # .*) Medical notations/$1 notations médicales/g;
				$line =~ s/( # .*) medical symbol/$1 symbole médical/g;
				$line =~ s/( # .*) mnemonic mapping/$1 disposition mnémonique/g;
				$line =~ s/( # .*) Moldovan and Romanian until 1904/$1 moldavien et roumain jusqu’en 1904/g;
				$line =~ s/( # .*) most-used in France/$1 le plus utilisé en France/g;
				$line =~ s/( # .*) next track button/$1 bouton de la piste suivante/g;
				$line =~ s/( # .*) no-break space/$1 espace insécable/g;
				$line =~ s/( # .*) outline scissors/$1 ciseaux ajourés/g;
				$line =~ s/( # .*) overrides/$1 remplace/g;
				$line =~ s/( # .*) Overrides/$1 Remplace/g;
				$line =~ s/( # .*) page break in plain text/$1 saut de page en texte brut/g;
				$line =~ s/( # .*) part of alphabetic mathematical symbol input sequences/$1 utilisé pour l’accès à 10 alphabets mathématiques latins préformatés supplémentaires et aux 5 alphabets ou symboles mathématiques grecs/g;
				$line =~ s/( # .*) Parthian transcription/$1 transcription parthe/g;
				$line =~ s/( # .*) Pashto romanization/$1 romanisation pachto/g;
				$line =~ s/( # .*) pause button/$1 bouton pause/g;
				$line =~ s/( # .*) plain scissors/$1 ciseaux pleins/g;
				$line =~ s/( # .*) play button/$1 bouton lecture/g;
				$line =~ s/( # .*) play or pause button/$1 bouton lecture ou pause/g;
				$line =~ s/( # .*) Portuguese/$1 portugais/g;
				$line =~ s/( # .*) preferred glyph for Latin theta/$1 glyphe préféré pour le thêta latin/g;
				$line =~ s/( # .*) preferred in Rromani/$1 préféré en rromani/g;
				$line =~ s/( # .*) record button/$1 bouton d’enregistrement/g;
				$line =~ s/( # .*) red emoji/$1 émoji rouge/g;
				$line =~ s/( # .*) red heart/$1 cœur rouge/g;
				$line =~ s/( # .*) repurposed as multikey symbol/$1 utilisé comme symbole de composition/g;
				$line =~ s/( # .*) rescue worker’s helmet/$1 casque de secouriste/g;
				$line =~ s/( # .*) reverse button/$1 bouton marche arrière/g;
				$line =~ s/( # .*) Romanized Avestan/$1 avestique romanisé/g;
				$line =~ s/( # .*) Romanized Kharoṣṭhī/$1 kharoṣṭhī romanisé/g;
				$line =~ s/( # .*) Romanized Pashto following/$1 pachto romanisé selon/g;
				$line =~ s/( # .*) Serbian/$1 serbe/g;
				$line =~ s/( # .*) shortcut/$1 raccourci/g;
				$line =~ s/( # .*) single comma quotation mark/$1 guillemet apostrophe simple/g;
				$line =~ s/( # .*) single reversed comma quotation mark/$1 guillemet apostrophe simple réfléchi/g;
				$line =~ s/( # .*) single turned comma quotation mark/$1 guillemet apostrophe simple tourné/g;
				$line =~ s/( # .*) Slovene/$1 slovène/g;
				$line =~ s/( # .*) snowman with snow/$1 bonhomme de neige sous la neige/g;
				$line =~ s/( # .*) space character/$1 espace/g;
				$line =~ s/( # .*) Spanish/$1 espagnol/g;
				$line =~ s/( # .*) stop button/$1 bouton d’arrêt/g;
				$line =~ s/( # .*) Swedish grave accent/$1 accent grave suédois/g;
				$line =~ s/( # .*) text style/$1 style texte/g;
				$line =~ s/( # .*) twice/$1 deux fois/g;
				$line =~ s/( # .*) voiceless alveolar trill/$1 consonne roulée alvéolaire sourde/g;
				$line =~ s/( # .*) Yoruba in current Nigerian alphabet/$1 yoruba avec l’alphabet nigérian actuel/g;
				$line =~ s/( # .*) emoji/$1 émoji/g;
				$line =~ s/( # .*\w): /$1 : /g;
				$line =~ s/( # .*\w); /$1 ; /g;

				# Add text style emoji for searchability.
				if ( $line   =~ m/ émoji/u ) {
					$line      =~ m/^.+ : +"(.+?)"/u;
					$textstyle = "$1&#xFE0E; ";
				} else {
					$textstyle = '';
				}

				# Add localized tooltips.
				$line    =~ m/^.+ : +"(.+?)"/u;
				$str     = $1;
				$tooltip = '';
				$ucodes  = '';
				$anchor  = '';
				until ( $str eq '' ) {
					$cp      = ord( $str );
					$cp      = sprintf( "%X", $cp ); # To hex.
					$cp      =~ s/^(.)$/000$1/;
					$cp      =~ s/^(..)$/00$1/;
					$cp      =~ s/^(...)$/0$1/;
					$descrip = '';
					if ( $descriptors_file_path ) {
						open( DESCRIP, '<', $descriptors_file_path ) or die $!;
						while ( my $des_line = <DESCRIP> ) {
							if ( $des_line =~ /U$cp;/ ) {
								chomp( $des_line );
								$des_line =~ s/^.+; (.+)$/$1/;
								$descrip = $des_line;
								++$descriptors_count;
								last;
							}
						}
						close( DESCRIP );
					}
					unless ( $descrip ) {
						open( NAMES, '<', $names_file_path ) or die $!;
						while ( my $name_line = <NAMES> ) {
							if ( $name_line =~ /^$cp\t/ ) {
								chomp( $name_line );
								$name_line =~ s/^.+\t(.+)$/$1/;
								$descrip = $name_line;
								++$names_count;
								last;
							}
						}
						close( NAMES );
					}
					unless ( $descrip ) {
						++$missing_count;
						$missing_log .= $cp . ' (:' . $line_nb . ")\n";
					}
					$tooltip .= $descrip . " U+$cp\n";
					$ucodes  .= "U+$cp<br />";
					$anchor  .= 'U+' . $cp . '-';
					$str     =~ s/.//u;
				}
				$tooltip =~ s/\n$//;
				$ucodes  =~ s/<br \/>$//;
				$anchor  =~ s/-$//;

				# Make sure anchors are unique.
				$regex   = quotemeta( $anchor );
				$index   = 0;
				if ( grep( /^$regex$/, @anchors ) ) {
					$test = $regex;
					while ( grep( /^$test$/, @anchors ) ) {
						++$index;
						$test = $regex . '_' . $index;
					}
					$anchor = $anchor . '_' . $index;
				}
				push( @anchors, $anchor );

				# Link to first instance in math list if applicable.
				if ( $line =~ m/ math$/u ) {
					$line    =~ s/ math//u;
					$math = " <a href=\"https://dispoclavier.com/nouvel-azerty/composition/symboles-mathematiques/#U+$cp\">math</a>";
				} else {
					$math = '';
				}

				# High surrogates.
				$line =~ s/^(.+?) : "surrogat_haut_(U\+D[8-9A-B][0-9A-F]{2})" # (.+)/<tr><td title="Surrogat haut $2 (pour Windows)"><\/td><td title="$3">$2<\/td><td title="$highsu">$1<\/td><td>$3<\/td><\/tr>/;

				# Composed characters.
				# Anchor end tags are spaced out to prevent adding another tooltip in this table.
				$line =~ s/^(.+?) : "(.+?)" # (.+)/<tr id="$anchor" class="$class"><td title="$tooltip"><a href="#$anchor"><span class="bg">$2<\/span><\/a ><\/td><td title="$3">$ucodes<\/td><td title="$nowin">$1<\/td><td>$3<\/td><\/tr>/;

				# Combining characters.
				$line =~ s/^(.+?) : "(.+?)" (U\+(?:03[0-6]|1A[BC]|1D[C-F]|20[D-F])[0-9A-F]) # (.+)/<tr id="$anchor" class="$class"><td title="$tooltip"><a href="#$anchor"><span class="bg">◌$2<\/span><\/a ><\/td><td title="$4">$3<\/td><td$winspe>$check$1<\/td><td>$4<\/td><\/tr>/;

				# All other characters.
				$line =~ s/^(.+?) :(?: "(.+?)")? (U\+[0-9A-F]{4,5}) # (.+)/<tr id="$anchor" class="$class"><td title="$tooltip"><a href="#$anchor"><span class="bg">$2<\/span><\/a ><\/td><td title="$4">$textstyle$3<\/td><td$winspe>$check$1<\/td><td>$4$math<\/td><\/tr>/;

				print OUTPUT $line;
				if ( $comprehensive ) {
					print WHOLEOUTPUT $line;
				}
			}
		}
	}
}
print OUTPUT $end_tags;
print WHOLEOUTPUT $end_tags;

close( INPUT );
print( "Closed file $input_path.\n" );
close( OUTPUT );
print( "Closed file $output_path.\n" );
close( WHOLEOUTPUT );
print( "Closed file $wholeoutput_path.\n" );
print( "Dead key tables generated in $output_directory/.\n" );
print( "Used $names_count times $names_file_path.\n" );
print( "Used $descriptors_count times $descriptors_file_path.\n" );
if ( $missing_count == 1 ) {
	print( "Not localized: $missing_count name.\n" );
	print( "Affected code point (at line number): $missing_log" );
} elsif ( $missing_count > 1 ) {
	print( "Not localized: $missing_count names.\n" );
	print( "Affected code points (at line numbers): $missing_log" );
} else {
	print( "All names localized.\n" );
}

# 2023-08-06T1935+0200
# 2023-08-20T0243+0200
# 2023-11-02T0819+0100
# 2024-05-16T1520+0200
# 2024-10-28T1415+0100
# 2025-11-30T2108+0100
# 2026-01-30T0713+0100
# 2026-04-09T1107+0200
# = last modified.
#
# Generates HTML tables of dedicated non-math multikey sequences configured in
# Compose.yml.
#
# In the input file, parsing starts at "START_MULTIKEY", and parsing stops at
# "START_MATH".
#
# Section headings with a caret between the two leading hashes switch files.
#
# The keyboard output is displayed on a white background span (class "bg") with
# a light-blue baseline for the purpose of delimiting whitespace characters and
# clarifying advance width and vertical alignment.
#
# Localized tooltips require the Unicode NamesList.txt or equivalents in the
# target locale as configured under ## Character names localization.
# ListeNoms.txt is used for characters missing from Udescripteurs.txt.
# Characters missing from both are counted and listed with their line number
# in Compose.yml.
#
# The output is designed for use in WordPress, where "{{{anrghg-classes}}}" can
# be replaced with additional CSS classes, as well as "{{{anrghg-value}}}" with
# anything, classes too in this file, using the A.N.R.GHG Publishing Toolkit.
#
# The all-in-one table generated alongside can only be included in web pages in
# WordPress when using the “Include partial” block provided by this plugin, as
# posts with too much code in HTML blocks are not saved.
#
#
# Using old-style file handles.
# use strict;
# use warnings;
# use utf8;
# use feature 'unicode_strings';

# By courtesy of https://stackoverflow.com/a/12291409
# use open ":std", ":encoding(UTF-8)";

# By courtesy of https://johnbokma.com/blog/2016/09/14/padding-numbers-with-zero-in-perl.html
# use Time::Piece;

# my $names_count           = 0;
# my $descriptors_count     = 0;
# my $missing_count         = 0;
# my $missing_log           = '';

# my $input_path = '../compose/Compose.yml';
open( INPUT, '<', $input_path ) or die $!;
print( "Opened file $input_path for reading.\n" );

$output_directory = 'multikey-tables';
unless ( -d $output_directory ) {
	mkdir $output_directory;
	print( "New directory $output_directory/.\n" );
}
$output_file_name_template = 'multikey-table-partial';
$output_path_trunk         = "$output_directory/$output_file_name_template";
# my $output_file_extension     = '.html';
$output_path               = "$output_directory/ALL_$output_file_name_template$output_file_extension";
open( WHOLEOUTPUT, '>', $output_path ) or die $!;
print( "Opened file $output_path for writing.\n" );
$wholeoutput_path     = $output_path;
$parsing_on           = !1;
# my $date_legend          = 'Tableau mis à jour le ';

# By courtesy of https://johnbokma.com/blog/2016/09/14/padding-numbers-with-zero-in-perl.html
# my $now_date             = Time::Piece->new;
# my $date                 = $now_date->strftime( '%d/%m/%Y' );

$table_id             = 'tableau-compose';
$table_header_1       = 'Caractère';
$table_header_2       = 'Séquence de composition';
$table_header_3       = 'Identifiant Unicode';
$table_header_4       = 'Descripteur';
$table_header_title   = 'Cliquer pour basculer entre français et anglais';
$checkbox_label       = 'Imprimer les descripteurs, non les identifiants';
$checkbox_checked     = '☑&nbsp;';
$checkbox_not_checked = '☐&nbsp;';
#my $start_tags_1         = "<input type=\"checkbox\" checked=\"checked\" id=\"print\" />\n";
$start_tags_1        = "<figure class=\"wp-block-table alignwide multikey {{{anrghg-classes}}} {{{anrghg-value}}}\"><table id=\"";
$start_tags_2         = "\">$date_legend$date</a></caption><thead><tr><th colspan=\"2\" class=\"has-text-align-left\" data-align=\"left\">$table_header_1</th><th class=\"has-text-align-left\" data-align=\"left\">$table_header_2</th><th class=\"has-text-align-left\" data-align=\"left\">$table_header_3</th></tr></thead><tbody>\n";
$start_tags           = "$start_tags_1$table_id\"><caption><a href=\"#$table_id$start_tags_2";
$end_tags             = "</tbody></table></figure>\n";
my $section_partial_open = !1;
# my ( @anchors, $anchor, $comment, $cp, $descrip, $file_id, $index, $line_nb, $regex, $str, $test, $text, $tooltip, $ucodes );

print WHOLEOUTPUT $start_tags;

while ( my $line = <INPUT> ) {
	$line_nb = $.;
	if ( $line =~ /START_MULTIKEY/ ) {
		$parsing_on = !0;
	}
	if ( $line =~ /START_MATH/ ) {
		$parsing_on = !1;
	}
	if ( $parsing_on ) {
  	if ( $line =~ /^#\^# / ) {
			if ( $section_partial_open ) {
				print OUTPUT $end_tags;
		    close( OUTPUT );
		    print( "Closed file $output_path.\n" );
			}
			$line        =~ s/^....//;
			$line        =~ m/(.+)/;
			$comment     = $1;
			$line        =~ s/,//g;
			$line        =~ s/ /-/g;
			$line        =~ m/(.+)/;
			$file_id     = lc( $1 );
			$output_path = $output_path_trunk . '_' . $file_id . $output_file_extension;
			$table_id    = "tableau-compose-$file_id";
			$start_tags  = "$start_tags_1$table_id\"><caption><a href=\"#$table_id$start_tags_2";
	    open( OUTPUT, '>', $output_path ) or die $!;
			$section_partial_open = !0;
	    print( "Opened file $output_path for writing.\n" );
			print( "Processing multikey sequences from $input_path to $output_path.\n" );
			print OUTPUT $start_tags;
			print OUTPUT "<!-- $comment -->\n";
		}

		unless ( $line =~ /^#/                 # Skip annotations.
			|| $line =~ /<KP_/                   # Keypad equivalents, a Linux feature.
			|| $line =~ /<nobreakspace>/         # No-break space alias sequences.
			|| $line =~ /<rightsinglequotemark>/ # Curly apostrophe alias sequences.
			|| $line =~ /<dead_greek/            # Alias of <at> in multikey sequences.
			|| $line =~ /\/Compose"/             # Output like "en_US.UTF-8/Compose".
		) {
			if ( $line =~ /<Multi_key>/ ) {

				# Starting from here, this should be in sync with generate-deadkey-tables.pl,
				# except for the attributeless spans needed for dead key base markup.

				# Convert dead keys.
				$line =~ s/<dead_abovedot>/<kbd class="deadkey long" title="Touche morte point en chef Maj + AltGr\/Option + ⟦P⟧">point en chef<\/kbd>/g;
				$line =~ s/<dead_abovering>/<kbd class="deadkey long" title="Touche morte rond en chef Maj + AltGr\/Option + ⟦X⟧">rond en chef<\/kbd>/g;
				$line =~ s/<dead_acute>/<kbd class="deadkey" title="Touche morte accent aigu Touche ⟦£\$¤⟧&#10;ou Maj + AltGr\/Option + ⟦U⟧">aigu<\/kbd>/g;
				$line =~ s/<dead_belowcomma>/<kbd class="deadkey long" title="Touche morte virgule souscrite Maj + AltGr\/Option + ⟦.;⟧">virgule souscrite<\/kbd>/g;
				$line =~ s/<dead_belowdot>/<kbd class="deadkey long" title="Touche morte point souscrit Maj + AltGr\/Option + ⟦§!⟧">point souscrit<\/kbd>/g;
				$line =~ s/<dead_breve>/<kbd class="deadkey" title="Touche morte brève Maj + AltGr\/Option + ⟦F⟧">brève<\/kbd>/g;
				$line =~ s/<dead_caron>/<kbd class="deadkey" title="Touche morte hatchek Maj + AltGr\/Option + ⟦V⟧">hatchek<\/kbd>/g;
				$line =~ s/<dead_cedilla>/<kbd class="deadkey" title="Touche morte cédille Maj + AltGr\/Option + ⟦?,⟧">cédille<\/kbd>/g;
				$line =~ s/<dead_circumflex>/<kbd class="deadkey" title="Touche morte accent circonflexe Touche ⟦¨^⟧&#10;ou Maj + AltGr\/Option + ⟦C⟧">circonflexe<\/kbd>/g;
				$line =~ s/<dead_currency>/<kbd class="deadkey long" title="Touche morte monétaire Maj + AltGr\/Option + ⟦S⟧">monétaire<\/kbd>/g;
				$line =~ s/<dead_diaeresis>/<kbd class="deadkey" title="Touche morte tréma Touche ⟦5([⟧&#10;ou Maj + AltGr\/Option + ⟦\/:⟧">tréma<\/kbd>/g;
				$line =~ s/<dead_doubleacute>/<kbd class="deadkey" title="Touche morte double accent aigu Maj + AltGr\/Option + ⟦E⟧">double aigu<\/kbd>/g;
				$line =~ s/<dead_grave>/<kbd class="deadkey" title="Touche morte accent grave AltGr\/Option + ⟦£\$¤⟧&#10;ou Maj + AltGr\/Option + ⟦N⟧">grave<\/kbd>/g;
				$line =~ s/<dead_greek>/<kbd class="deadkey" title="Touche morte grec ou cerclé AltGr\/Option + ⟦Y⟧&#10;ou Maj + AltGr\/Option + ⟦Y⟧">grec<\/kbd>/g;
				$line =~ s/<dead_hook>/<kbd class="deadkey" title="Touche morte crosse ou crochet Maj + AltGr\/Option + ⟦I⟧">crosse<\/kbd>/g;
				$line =~ s/<dead_horn>/<kbd class="deadkey" title="Touche morte cornu Maj + AltGr\/Option + ⟦H⟧">cornu<\/kbd>/g;
				$line =~ s/<dead_invertedbreve>/<kbd class="deadkey long" title="Touche morte brève inversée Maj + AltGr\/Option + ⟦D⟧">brève inversée<\/kbd>/g;
				$line =~ s/<dead_macron>/<kbd class="deadkey" title="Touche morte macron Maj + AltGr\/Option + ⟦M⟧">macron<\/kbd>/g;
				$line =~ s/<dead_ogonek>/<kbd class="deadkey" title="Touche morte ogonek Maj + AltGr\/Option + ⟦K⟧">ogonek<\/kbd>/g;
				$line =~ s/<dead_stroke>/<kbd class="deadkey" title="Touche morte barré Maj + AltGr\/Option + ⟦W⟧">barré<\/kbd>/g;
				$line =~ s/<dead_tilde>/<kbd class="deadkey" title="Touche morte tilde AltGr\/Option + ⟦¨^⟧&#10;ou Maj + AltGr\/Option + ⟦T⟧">tilde<\/kbd>/g;
				$line =~ s/<UEFD0>/<kbd class="deadkey" title="Touche morte groupe Touche ⟦µ*⟧&#10;ou Maj + AltGr\/Option + ⟦Q⟧">groupe<\/kbd>/g;
				$line =~ s/<UEFD1>/<kbd class="deadkey" title="Touche morte exposant Maj + AltGr\/Option + ⟦A⟧">exposant<\/kbd>/g;
				$line =~ s/<UEFD2>/<kbd class="deadkey" title="Touche morte indice Maj + AltGr\/Option + ⟦J⟧">indice<\/kbd>/g;
				$line =~ s/<UEFD3>/<kbd class="deadkey long" title="Touche morte crochet en chef Maj + AltGr\/Option + ⟦L⟧">crochet en chef<\/kbd>/g;
				$line =~ s/<UEFD4>/<kbd class="deadkey long" title="Touche morte crochet rétroflexe Maj + AltGr\/Option + ⟦O⟧">crochet rétroflexe<\/kbd>/g;
				$line =~ s/<UEFD5>/<kbd class="deadkey" title="Touche morte tourné Maj + AltGr\/Option + ⟦Z⟧">tourné<\/kbd>/g;
				$line =~ s/<UEFD6>/<kbd class="deadkey" title="Touche morte réfléchi Maj + AltGr\/Option + ⟦R⟧">réfléchi<\/kbd>/g;
				$line =~ s/<UEFD7>/<kbd class="deadkey" title="Touche morte drapeau Maj + AltGr\/Option + ⟦B⟧">drapeau<\/kbd>/g;
				$line =~ s/<UEFD8>/<kbd class="deadkey" title="Touche morte rayé Maj + AltGr\/Option + ⟦G⟧">rayé<\/kbd>/g;
				$line =~ s/<UEFD9>/<kbd class="deadkey long" title="Touche morte tilde rétrocompatible Maj + AltGr\/Option + ⟦2é~⟧">tilde rétrocompatible<\/kbd>/g;
				$line =~ s/<UEFDA>/<kbd class="deadkey long" title="Touche morte accent grave rétrocompatible Maj + AltGr\/Option + ⟦7è`⟧">grave rétrocompatible<\/kbd>/g;

				# Remove spaces.
				$line =~ s/ {2,}/ /g;
				$line =~ s/> </></g;

				# Mark up invisibles or confusables.
				$line =~ s/<U202F>/<kbd class="livekey" title="Espace fine insécable AltFr + ⟦Espace⟧ (en mode français uniquement)">fine insécable<\/kbd>/g;
				$line =~ s/<U200B>/<kbd class="livekey" title="Césure conditionnelle Maj + AltGr\/Option + ⟦Espace⟧ (en mode français uniquement)">espace nulle<\/kbd>/g;
				$line =~ s/<hyphen>/<kbd class="livekey" title="Trait d’union conditionnel Maj + ⟦5([⟧ (en mode français uniquement)">- conditionnel<\/kbd>/g;
				$line =~ s/<emdash>/<kbd class="livekey" title="Tiret cadratin Maj + ⟦4&#x27;{⟧">— tiret cadratin<\/kbd>/g;
				$line =~ s/<endash>/<kbd class="livekey" title="Tiret demi-cadratin Maj + ⟦3&#x22;#⟧">– tiret demi-cadratin<\/kbd>/g;
				$line =~ s/<U2212>/<kbd class="livekey" title="Signe moins AltFr + ⟦T⟧">− signe moins<\/kbd>/g;
				$line =~ s/<U02BB>/<kbd class="livekey" title="Lettre apostrophe tournée Maj + ⟦8_\\⟧ sur les variantes pour la Polynésie">ʻ lettre apostrophe tournée<\/kbd>/g;
				$line =~ s/<UEF60>/<kbd class="livekey" title="Point d’exclamation espacé AltFr + ⟦§!⟧">[fine insécable]!<\/kbd>/g;
				$line =~ s/<UEF63>/<kbd class="livekey" title="Point d’interrogation espacé AltFr + ⟦?,⟧">[fine insécable]?<\/kbd>/g;
				$line =~ s/<UEF65>/<kbd class="livekey" title="Guillemet fermant espacé AltFr + ⟦?,⟧">[fine insécable]»<\/kbd>/g;
				$line =~ s/<UEF67>/<kbd class="livekey" title="Guillemet simple fermant espacé AltFr + ⟦£\$¤⟧">[fine insécable]›<\/kbd>/g;
				$line =~ s/<UEF64>/<kbd class="livekey" title="Guillemet ouvrant espacé AltFr + ⟦%ù⟧">«[fine insécable]<\/kbd>/g;
				$line =~ s/<UEF66>/<kbd class="livekey" title="Guillemet simple ouvrant espacé AltFr + ⟦¨^⟧">‹[fine insécable]<\/kbd>/g;

				# Add tooltips.
				$line =~ s/<Multi_key>/<span class="tooltip" title="Touche de composition AltGr\/Option + ⟦+=}⟧&#10;et en mode ASCII, AltGr\/Option + ⟦£\$¤⟧">¦<\/span>/g;
				$line =~ s/<space>/<span class="tooltip" title="Espace">␣<\/span>/g;
				$line =~ s/<nobreakspace>/<span class="tooltip" title="Espace insécable AltGr\/Option + ⟦Espace⟧ (en mode français uniquement)">⍽<\/span>/g;
				$line =~ s/<apostrophe>/<span class="tooltip" title="Apostrophe ASCII ou guillemet simple générique Touche ⟦+=}⟧ en mode français,&#10;ou touche ⟦%ù⟧ en mode ASCII,&#10;ou AltGr\/Option + ⟦U⟧&#10;ou encore le guillemet apostrophe Touche ⟦4&#x27;{⟧ en mode français">&#x27;<\/span>/g;
				$line =~ s/<rightsinglequotemark>/<span class="tooltip" title="Guillemet apostrophe Touche ⟦4&#x27;{⟧">’<\/span>/g;
				$line =~ s/<degree>/<span class="tooltip" title="Symbole degré Maj + ⟦°)]⟧">°<\/span>/g;
				$line =~ s/<multiply>/<span class="tooltip" title="Symbole multiplication AltFr + ⟦C⟧">×<\/span>/g;
				$line =~ s/<paragraph>/<span class="tooltip" title="Symbole paragraphe américain Maj + AltFr + ⟦P⟧">¶<\/span>/g;
				$line =~ s/<U2039>/<span class="tooltip" title="Guillemet chevron simple AltFr + ⟦¨^⟧">‹<\/span>/g;
				$line =~ s/<U203A>/<span class="tooltip" title="Guillemet chevron simple AltFr + ⟦£\$¤⟧">›<\/span>/g;
				$line =~ s/<U0190>/<span class="tooltip" title="Capitale latine E ouvert Maj + ⟦1&⟧ sur les variantes pour l’Afrique francophone">Ɛ<\/span>/g;
				$line =~ s/<U025B>/<span class="tooltip" title="Minuscule latine e ouvert Touche ⟦1&⟧ sur les variantes pour l’Afrique francophone">ɛ<\/span>/g;
				$line =~ s/<U0186>/<span class="tooltip" title="Capitale latine O ouvert Maj + ⟦8_\\⟧ sur les variantes pour l’Afrique francophone">Ɔ<\/span>/g;
				$line =~ s/<U0254>/<span class="tooltip" title="Minuscule latine o ouvert Touche ⟦8_\\⟧ sur les variantes pour l’Afrique francophone">ɔ<\/span>/g;
				$line =~ s/<twosuperior>/<span class="tooltip" title="Exposant 2 Touche ⟦1&⟧ en mode français">²<\/span>/g;
				$line =~ s/<periodcentered>/<span class="tooltip" title="Point médian Touche ⟦§!⟧ en mode français">·<\/span>/g;
				$line =~ s/<ellipsis>/<span class="tooltip" title="Points de suspension Touche ⟦%ù⟧ en mode français">…<\/span>/g;

				# Convert remaining ASCII and iconic.
				$line =~ s/<asciicircum>/^/g;
				$line =~ s/<percent>/%/g;
				$line =~ s/<EuroSign>/€/g;
				$line =~ s/<quotedbl>/&quot;/g;
				$line =~ s/<backslash>/\\/g;
				$line =~ s/<asciitilde>/~/g;
				$line =~ s/<at>/@/g;
				$line =~ s/<braceleft>/{/g;
				$line =~ s/<braceright>/}/g;
				$line =~ s/<ampersand>/&amp;/g;
				$line =~ s/<numbersign>/#/g;
				$line =~ s/<dollar>/\$/g;
				$line =~ s/<parenleft>/(/g;
				$line =~ s/<parenright>/)/g;
				$line =~ s/<minus>/-/g;
				$line =~ s/<plus>/+/g;
				$line =~ s/<underscore>/_/g;
				$line =~ s/<bracketleft>/[/g;
				$line =~ s/<bracketright>/]/g;
				$line =~ s/<bar>/|/g;
				$line =~ s/<slash>/\//g;
				$line =~ s/<asterisk>/*/g;
				$line =~ s/<less>/&lt;/g;
				$line =~ s/<greater>/&gt;/g;
				$line =~ s/<equal>/=/g;
				$line =~ s/<grave>/`/g;
				$line =~ s/<comma>/,/g;
				$line =~ s/<question>/?/g;
				$line =~ s/<period>/./g;
				$line =~ s/<exclam>/!/g;
				$line =~ s/<colon>/:/g;
				$line =~ s/<semicolon>/;/g;
				$line =~ s/<section>/§/g;
				$line =~ s/<mu>/µ/g;
				$line =~ s/<guillemotleft>/«/g;
				$line =~ s/<guillemotright>/»/g;
				$line =~ s/<agrave>/à/g;
				$line =~ s/<Agrave>/À/g;
				$line =~ s/<egrave>/è/g;
				$line =~ s/<Egrave>/È/g;
				$line =~ s/<ugrave>/ù/g;
				$line =~ s/<Ugrave>/Ù/g;
				$line =~ s/<eacute>/é/g;
				$line =~ s/<Eacute>/É/g;
				$line =~ s/<ccedilla>/ç/g;
				$line =~ s/<Ccedilla>/Ç/g;
				$line =~ s/<adiaeresis>/ä/g;
				$line =~ s/<Adiaeresis>/Ä/g;
				$line =~ s/<odiaeresis>/ö/g;
				$line =~ s/<Odiaeresis>/Ö/g;
				$line =~ s/<udiaeresis>/ü/g;
				$line =~ s/<Udiaeresis>/Ü/g;
				$line =~ s/<ntilde>/ñ/g;
				$line =~ s/<Ntilde>/Ñ/g;

				# Convert remaining Unicode keysyms to NCRs.
				$line =~ s/<U([0-9A-F]{4})>/&#x$1;/g;

				# Format Unicode scalars in comments.
				$line =~ s/U([0-9A-F]{4,5})/U+$1/g;

				# Remove remaining keysym delimiters.
				$line =~ s/<([a-zA-Z0-9])>/$1/g;

				# Down to here, this should be in sync with generate-deadkey-tables.pl,
				# except for the attributeless spans needed for dead key base markup.

				# Add ZWNJ between a colon and a parenthesis to prevent WordPress from
				# parsing the sequence as an emoji.
				$line =~ s/:([()])/:&#x200C;$1/g;

				# Translate English comments to French.
				$line =~ s/( # .*) (\d\d?)th-ranking/$1 classé au rang $2/g;
				$line =~ s/( # .*) capitals lock/$1 verrouillage capitales/g;
				$line =~ s/( # .*) Control key ISO symbol/$1 symbole ISO de la touche Contrôle/g;
				$line =~ s/( # .*) emoji with skin tone support/$1 émoji avec prise en charge de la couleur de peau/g;
				$line =~ s/( # .*) Japanese kome/$1 kome japonais/g;
				$line =~ s/( # .*) Japanese tainome/$1 tainome japonais/g;
				$line =~ s/( # .*) level 3 select/$1 AltGr\/Option/g;
				$line =~ s/( # .*) numeric lock/$1 verrouillage numérique/g;
				$line =~ s/( # .*) outline scissors/$1 ciseaux ajourés/g;
				$line =~ s/( # .*) red emoji/$1 émoji rouge/g;
				$line =~ s/( # .*) repurposed as multikey symbol/$1 utilisé comme symbole de composition/g;
				$line =~ s/( # .*) tab with shift tab/$1 Tab avec Majuscule Tab/g;
				$line =~ s/( # .*) bullet/$1 puce/g;
				$line =~ s/( # .*) emoji/$1 émoji/g;
				$line =~ s/( # .*) not/$1 non/g;
				$line =~ s/( # .*) shift/$1 Majuscule/g;

				# Add text style emoji for searchability.
				if ( $line =~ m/ emoji/u ) {
					$line    =~ m/^.+ : +"(.+?)"/u;
					$text    = "$1&#xFE0E; ";
				} else {
					$text    = '';
				}

				# Add localized tooltips.
				$line    =~ m/^.+ : +"(.+?)"/u;
				$str     = $1;
				$tooltip = '';
				$ucodes  = '';
				$anchor  = '';
				until ( $str eq '' ) {
					$cp      = ord( $str );
					$cp      = sprintf( "%X", $cp ); # To hex.
					$cp      =~ s/^(.)$/000$1/;
					$cp      =~ s/^(..)$/00$1/;
					$cp      =~ s/^(...)$/0$1/;
					$descrip = '';
					if ( $descriptors_file_path ) {
						open( DESCRIP, '<', $descriptors_file_path ) or die $!;
						while ( my $des_line = <DESCRIP> ) {
							if ( $des_line =~ /U$cp;/ ) {
								chomp( $des_line );
								$des_line =~ s/^.+; (.+)$/$1/;
								$descrip = $des_line;
								++$descriptors_count;
								last;
							}
						}
						close( DESCRIP );
					}
					unless ( $descrip ) {
						open( NAMES, '<', $names_file_path ) or die $!;
						while ( my $name_line = <NAMES> ) {
							if ( $name_line =~ /^$cp\t/ ) {
								chomp( $name_line );
								$name_line =~ s/^.+\t(.+)$/$1/;
								$descrip = $name_line;
								++$names_count;
								last;
							}
						}
						close( NAMES );
					}
					unless ( $descrip ) {
						++$missing_count;
						$missing_log .= $cp . ' (:' . $line_nb . ")\n";
					}
					$tooltip .= $descrip . " U+$cp\n";
					$ucodes  .= "U+$cp<br />";
					$anchor  .= 'U+' . $cp . '-';
					$str     =~ s/.//u;
				}
				$tooltip =~ s/\n$//;
				$ucodes  =~ s/<br \/>$//;
				$anchor  =~ s/-$//;

				# Make sure anchors are unique.
				$regex   = quotemeta( $anchor );
				$index   = 0;
				if ( grep( /^$regex$/, @anchors ) ) {
					$test = $regex;
					while ( grep( /^$test$/, @anchors ) ) {
						++$index;
						$test = $regex . '_' . $index;
					}
					$anchor = $anchor . '_' . $index;
				}
				push( @anchors, $anchor );

				# Anchor end tags are spaced out to prevent adding another tooltip in this table.
				# The white background (span of class bg) clarifies whitespace and vertical alignment.
				# Characters with an XKB keysym instead of their scalar.
				$line =~ s/^(.+?) : +"(.+?)" +(?:[a-z]+ +)?# (.+)/<tr id="$anchor"><td title="$tooltip"><a href="#$anchor"><span class="bg">$2<\/span><\/a ><\/td><td title="$3">$ucodes<\/td><td>$1<\/td><td>$3<\/td><\/tr>/;
				# Combining characters.
				$line =~ s/^(.+?) : +"(.+?)" +(U\+(?:03[0-6]|1A[BC]|1D[C-F]|20[D-F])[0-9A-F]) # (.+)/<tr id="$anchor"><td title="$tooltip"><a href="#$anchor"><span class="bg">◌$2<\/span><\/a ><\/td><td title="$4">$3<\/td><td>$1<\/td><td>$4<\/td><\/tr>/;
				# Other characters.
				$line =~ s/^(.+?) : +"(.+?)" +(U\+[0-9A-F]{4,5}) # (.+)/<tr id="$anchor"><td title="$tooltip"><a href="#$anchor"><span class="bg">$2<\/span><\/a ><\/td><td title="$4">$text$3<\/td><td>$1<\/td><td>$4<\/td><\/tr>/;
				print OUTPUT $line;
				print WHOLEOUTPUT $line;
			}
		}
	}
}
print OUTPUT $end_tags;
print WHOLEOUTPUT $end_tags;

close( INPUT );
print( "Closed file $input_path.\n" );
close( OUTPUT );
print( "Closed file $output_path.\n" );
close( WHOLEOUTPUT );
print( "Closed file $wholeoutput_path.\n" );
print( "Multi_key tables generated in $output_directory/.\n" );
print( "Used $names_count times $names_file_path.\n" );
print( "Used $descriptors_count times $descriptors_file_path.\n" );
if ( $missing_count == 1 ) {
	print( "Not localized: $missing_count name.\n" );
	print( "Affected code point (at line number): $missing_log" );
} elsif ( $missing_count > 1 ) {
	print( "Not localized: $missing_count names.\n" );
	print( "Affected code points (at line numbers): $missing_log" );
} else {
	print( "All names localized.\n" );
}
