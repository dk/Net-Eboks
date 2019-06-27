use strict;
use warnings;
use Getopt::Long  qw(GetOptions);
use ExtUtils::MakeMaker;

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
		'IO::Socket::SSL' => 0,
		'Crypt::OpenSSL::RSA' => 0,
	},
	MIN_PERL_VERSION  => 5.010,
	META_MERGE     => {
		resources => {
			repository => 'http://github.com/dk/Net-Eboks'
		},
	},
);
