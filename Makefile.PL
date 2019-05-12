use strict;
use warnings;
use Getopt::Long  qw(GetOptions);
use ExtUtils::MakeMaker;

my $with_gtk;

GetOptions(
	'with-gtk!' => \$with_gtk,
);

unless ( defined $with_gtk ) {
	print <<EOT;
	
For this module to be useful, you need to go through one-time registration
with NemID for each user. This requires gtk3 modules to be installed.
If you already registered or you don't intend to to so, for example for
server use only, then you don't need those.
	
EOT
	$with_gtk = prompt(
		"Do you want to install Gtk3 modules for NemID authentication?", "n"
	) =~ /^y/i ? 1 : 0;
}

WriteMakefile(
	NAME           => 'Net::Eboks',
	AUTHOR         => 'Dmitry Karasik <dmitry@karasik.eu.org>',
	ABSTRACT_FROM  => 'Eboks.pm',
	VERSION_FROM   => 'Eboks.pm',
        EXE_FILES      => [map { "bin/eboks$_" } qw(2pop -dump -authenticate)],
        LICENSE        => 'freebsd',
	PREREQ_PM      => { 
		'LWP'          => 0,
		'DateTime'     => 0,
		'IO::Lambda'   => 1.28,
		'MIME::Entity' => 0,
		'MIME::Base64' => 0,
		'XML::Simple'  => 0,
		'Getopt::Long' => 0,
		'Digest::SHA'  => 0,
		'Crypt::OpenSSL::RSA' => 0,
		($with_gtk ? ('Gtk3::WebKit' => 0) : ()),
	},
	MIN_PERL_VERSION  => 5.010,
	META_MERGE     => {
		resources => {
			repository => 'http://github.com/dk/Net-Eboks'
		},
	},
);
