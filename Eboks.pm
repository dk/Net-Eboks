package Net::Eboks;

use 5.010;
use strict;
use warnings;
use Encode qw(encode decode);
use DateTime;
use HTTP::Request;
use Digest::SHA qw(sha256_hex);
use XML::Simple;
use LWP::UserAgent;
use LWP::ConnCache;
use MIME::Entity;
use IO::Lambda qw(:all);
use IO::Lambda::HTTP qw(http_request);


our $VERSION = '0.05';

sub new
{
	my ( $class, %opts ) = @_;
	my $self = bless {
		cpr        => '0000000000',
		password   => '',
		activation => '',
		country    => 'DK',
		type       => 'P',
		deviceid   => 'DEADBEEF-1337-1337-1337-000000000000',
		datetime   => DateTime->now->strftime('%Y-%m-%d %H:%M:%SZ'),
		root       => 'rest.e-boks.dk',

		nonce      => '',
		sessionid  => '',
		response   => "3a1a51f235a8bd6bbc29b2caef986a1aeb77018d60ffdad9c5e31117e7b6ead3", # XXX
		uid        => undef,
		uname      => undef,
		conn_cache => LWP::ConnCache->new,

		%opts,
	}, $class;

	$self->{challenge} = sha256_hex(sha256_hex(join(':', @{$self}{qw(activation deviceid type cpr country password datetime)})));

	return $self;
}

sub response
{
	my ($self, $decode, $response) = @_;

	unless ($response->is_success) {
		my $sl = $response->message // $response-> status_line;
		chomp $sl;
		$sl =~ s/\+/ /g;
		return undef, $sl;
	}
	
	for ( split /,\s*/, $response->header('x-eboks-authenticate')) {
		warn "bad x-eboks-authenticate: $_\n" unless m/^(sessionid|nonce)="(.*?)"$/;
		$self->{$1} = $2;
	}
		
	return $response->decoded_content unless $decode;
	
	my %options = ref($decode) ? %$decode : ();
	my $content = $response->decoded_content;
	if ( $content !~ /[^\x00-\xff]/ && $content =~ /[\x80-\xff]/ ) {
		# try to upgrade
		eval { 
			my $c = decode('latin1', $content);
			$content = $c;
		};
	}
	my $xml = XMLin($content, ForceArray => 1, %options);
	if ( $xml && ref($xml) eq 'HASH' ) {
		return $xml;
	} else {
		return undef, "xml returned is not a hash";
	}
}

sub login
{
	my $self = shift;

	return undef if defined $self->{uid};

	my $authstr = 'logon ' . join(',', map { "$_=\"$self->{$_}\"" } qw(deviceid datetime challenge));
	my $content = <<XML;
<Logon xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="urn:eboks:mobile:1.0.0">
<User identity="$self->{cpr}" identityType="$self->{type}" nationality="$self->{country}" pincode="$self->{password}"/>
</Logon>
XML

	my $login = HTTP::Request->new(
		'PUT',
		'https://' . $self->{root} . '/mobile/1/xml.svc/en-gb/session',
		[
			'Content-Type'         => 'application/xml',
			'Content-Length'       => length($content),
			'X-EBOKS-AUTHENTICATE' => $authstr,
			'Accept'               => '*/*',
			'Accept-Language'      => 'en-US',
			'Accept-Encoding'      => 'gzip,deflate',
			'Host'                 => $self->{root},
		],
		$content
	);
	$login->protocol('HTTP/1.1');

	return $login, sub { 
		my ($xml, $error) = $self-> response({ForceArray => 0}, @_);
		return $xml, $error unless $xml;
		return undef, "'User' is not present in response" unless exists $xml->{User};

		$self->{uid}   = $xml->{User}->{userId};
		$self->{uname} = $xml->{User}->{name};
		return $self->{uname};
	};
}

sub ua { LWP::UserAgent->new(conn_cache => shift->{conn_cache}) }

sub get
{
	my ($self, $path) = @_;
	my $authstr = join(',', map { "$_=\"$self->{$_}\"" } qw(deviceid nonce sessionid response));
	my $get = HTTP::Request->new(
		'GET',
		'https://' . $self->{root} . '/' . $path,
		[
			'X-EBOKS-AUTHENTICATE' => $authstr,
			'Accept'               => '*/*',
			'Accept-Language'      => 'en-US',
			'Host'                 =>  $self->{root},
		],
	);
	$get->protocol('HTTP/1.1');
	return $get;
}

sub xmlget
{
	my ( $self, $uri, $path, %xmlopt ) = @_;
	return
		$self->get($uri), sub {
			my ($xml, $error) = $self-> response(\%xmlopt, @_);
			return $xml, $error unless $xml;
			for my $step ( @{ $path // [] } ) {
				return undef, "key '$step' not found" unless ref $xml;
				if ( ref($xml) eq 'ARRAY') {
					$xml = $xml->[$step];
				} else {
					$xml = $xml->{$step};
				}
			}

			my $key = $xmlopt{KeyAttr} // 'name';
			while ( my ( $k, $v ) = each %$xml ) {
				$v->{$key} = $k if defined($v) && ref($v) eq 'HASH';
			}

			return $xml;
		};
}

sub folders
{
	my $self = shift;
	return undef unless $self->{uid};
	$self-> xmlget("/mobile/1/xml.svc/en-gb/$self->{uid}/0/mail/folders", ['FolderInfo']);
}

sub messages
{
	my ($self, $folder_id, $offset, $limit) = @_;
	return undef unless $self->{uid};
	$limit  //= 1;
	$offset //= 0;
	$self-> xmlget(
		"/mobile/1/xml.svc/en-gb/$self->{uid}/0/mail/folder/$folder_id?skip=$offset&take=$limit", 
		[ qw(Messages 0 MessageInfo) ],
		KeyAttr => 'id'
	);
}

sub message
{
	my ($self, $folder_id, $message_id) = @_;
	return undef unless $self->{uid};
	$self-> xmlget(
		"/mobile/1/xml.svc/en-gb/$self->{uid}/0/mail/folder/$folder_id/message/$message_id",
		[],
		KeyAttr => 'id'
	);
}

sub content
{
	my ( $self, $folder_id, $content_id ) = @_;
	return 
		$self-> get( "/mobile/1/xml.svc/en-gb/$self->{uid}/0/mail/folder/$folder_id/message/$content_id/content" ), sub {
			$self-> response( 0, @_ )
		};
}

sub attachments { $_[1]->{Attachements}->[0]->{AttachmentInfo} }

sub filename    { 
	my $fn = $_[1]-> {name};
	$fn =~ s[:\\\/][_];
	my $fmt = lc($_[1]->{format});
	$fmt = 'txt' if $fmt eq 'plain';
	return $fn . '.' .lc($_[1]->{format})
}

sub mime_type
{
	my $fmt = lc $_[1]->{format};
	if ( $fmt =~ /^(pdf)$/ ) {
		return "application/$fmt";
	} elsif ( $fmt =~ /^(gif|jpg|jpeg|tiff|png|webp)$/) {
		return "image/$fmt";
	} elsif ( $fmt =~ /^(txt|text|html|plain)$/) {
		$fmt = 'plain' if $fmt =~ /^(txt|text)$/;
		return "text/$fmt";
	} else {
		return "application/$fmt";
	}
}

sub first_value
{
	my ($self, $entry) = @_;
	if ( ref($entry) eq 'HASH') {
		my $k = (sort keys %$entry)[0];
		return $entry->{$k};
	} elsif ( ref($entry) eq 'ARRAY') {
		return $entry->[0];
	} else {
		return "bad entry";
	}
}

sub safe_encode
{
	my ($enc, $text) = @_;
	utf8::downgrade($text, 'fail silently please');
	return (utf8::is_utf8($text) || $text =~ /[\x80-\xff]/) ? encode($enc, $text) : $text;
}

sub assemble_mail
{
	my ( $self, %opt ) = @_;

	my $msg = $opt{message};
	my $sender = $self->first_value($msg->{Sender});
	$sender = $sender->{content} if ref($sender) eq 'HASH';
	$sender //= 'unknown';

	my $received = $msg->{receivedDateTime} // '';
	my $date;
	if ( $received =~ /^(\d{4})-(\d{2})-(\d{2})T(\d\d):(\d\d):(\d\d)/) {
		$date = DateTime->new(
			year   => $1,
			month  => $2,
			day    => $3,
			hour   => $4,
			minute => $5,
			second => $6,
		);
	} else {
		$date = DateTime->now;
	}
	$received = $date->strftime('%a, %d %b %Y %H:%M:%S %z');

	my $mail = MIME::Entity->build(
		From          => $opt{from}    // ( safe_encode('MIME-Q', $sender) . ' <noreply@e-boks.dk>' ) ,
		To            => $opt{to}      // ( safe_encode('MIME-Q', $self->{uname}) . ' <' . ( $ENV{USER} // 'you' ) . '@localhost>' ),
		Subject       => $opt{subject} // safe_encode('MIME-Header', $msg->{name}),
		Data          => $opt{data}    // encode('utf-8', "Mail from $sender"),
		Date          => $opt{date}    // $received,
		Charset       => 'utf-8',
		Encoding      => 'quoted-printable',
		'X-Net-Eboks' => "v/$VERSION",
	);

	my @attachments;
	push @attachments, [ $msg, $opt{body} ] if exists $opt{body};

        my $attachments = $self->attachments($msg);
	for my $att_id ( sort keys %$attachments ) {
		push @attachments, [ $attachments->{$att_id}, $opt{attachments}->{$att_id} ];
	}

	for ( @attachments ) {
		my ( $msg, $body ) = @$_;
		my $fn = $self->filename($msg);
		my $entity = $mail->attach(
			Type     => $self->mime_type($msg),
			Encoding => 'base64',
			Data     => $body,
			Filename => $fn,
		);

		# XXX hack filename for utf8
		next unless $fn =~ m/[^\x00-\x80]/;
		$fn = Encode::encode('utf-8', $fn);
		$fn =~ s/([^A-Za-z])/'%'.sprintf("%02x",ord($1))/ge;
		for ( 'Content-disposition', 'Content-type') {
			my $v = $entity->head->get($_);
			$v =~ s/name="(.*)"/name*=.utf-8''$fn/;
			$entity->head->replace($_, $v);
		}
	}

	return 
		'From noreply@localhost ' . 
		$date->strftime('%a %b %d %H:%M:%S %Y') . "\n" .
		$mail->stringify
		;
}

sub fetch_request
{
	my ($self, $request, $callback) = @_;
	return lambda { undef, "bad request" } unless $request;
	return lambda {
		context $request,
			conn_cache => $self->{conn_cache}, #XXX
			keep_alive => 1;                   #XXX
	http_request {
		my $response = shift;
		return undef, $response unless ref $response;
		return $callback->($response);
	}};
}

sub fetch_message_and_attachments
{
	my ($self, $message ) = @_;

	return lambda {
		context $self-> fetch_request( $self->message( $message->{folderId}, $message->{id} ) );
	tail {
		my ($xml, $error) = @_;
		return ($xml, $error) unless defined $xml;

		my $attachments = $self-> attachments( $xml );
		my @attachments = keys %$attachments;
		my %opt = ( 
			message     => $xml,
			attachments => {},
		);

		context $self-> fetch_request( $self-> content( $message->{folderId}, $message->{id} ));
	tail {
		my ($body, $error) = @_;
		return ($body, $error) unless defined $body;
		$opt{body} = $body;
	
		my $att_id = shift @attachments or return \%opt;
		context $self-> fetch_request( $self-> content( $message->{folderId}, $att_id ));
	tail {
		my ($att_body, $error) = @_;
		return ($att_body, $error) unless defined $att_body;

		$opt{attachments}->{$att_id} = $att_body;
		$att_id = shift @attachments or return \%opt;
		context $self-> fetch_request( $self-> content( $message->{folderId}, $att_id ));
		again;
	}}}};
}

sub list_all_messages
{
	my ( $self, $folder_id ) = @_;

	my $offset = 0;
	my $limit  = 1000;

	my %ret;

	return lambda {
		context $self-> fetch_request( $self-> messages( $folder_id, $offset, $limit ));
	tail {
		my ($xml, $error) = @_;
		return ($xml, $error) unless $xml;

		%ret = ( %ret, %$xml );
		return \%ret if keys(%$xml) < $limit;

		$offset += $limit;
		context $self-> fetch_request( $self-> messages( $folder_id, $offset, $limit ));
		again;
	}};
}

1;

__DATA__

=pod

=head1 NAME

Net::Eboks - perl API for http://eboks.dk/

=head1 DESCRIPTION

Read-only interface for eboks. See README for more info.

=head1 AUTHOR

Dmitry Karasik <dmitry@karasik.eu.org>

=cut
