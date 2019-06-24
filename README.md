perl API for eboks.dk
=====================

This is perl interface for http://eboks.dk/, Danish national email system. 

Included a simple POP server for proxying e-boks for read-only mail access
and a simple downloader.

You shall need your CPR# and password.
You can get the password from the e-Boks website. 
Here is a
[video-guide](http://www.e-boks.dk/help.aspx?pageid=db5a89a1-8530-418a-90e9-ff7f0713784a)
on how to get it (in Danish).

For the POP3 login, the username is be your CPR code, such as f.ex: 0123456-7890.
The password is your mobile pincode.

Installation
============

One-time NemID registration
---------------------------

For each user, you will need to go through one-time registration through you
personal NemID signature. `eboks-authenticate` (see below) will ask your
CPR, your password, and will try to show a standard NemID window, that you will
need to log in, and then confirm that indeed you to allow the login to eBoks.
If that works, the script will send that to the eBoks server so it recognizes
your future logins.

This step should be done one time only, for each user, not for each
installation. So it is optional unless you're running it first time or intend
to add more users. If you don't need it, then you don't need Gtk3 modules
either.

Security note: The module's NemID login runs on gtk's own web browser widget,
which is not really different from a real browser. It uses https and all other
means for the secure communications exactly as all other web-based NemID
clients. There are no concerns others than the usual suspects when one uses
NemID logins by other means. To be extra paranoid though, use only two-factor
authentication through NemID app, not through one-time pads, as the app shows
who is the issuer of the login request when asking for its confirmation.
Make sure the requestor is eBoks, not your bank :)

Installation for Unix/Linux
---------------------------

* Install this module by opening command line and typing `sudo cpan Net::Eboks`.
It will ask you if you want gtk3 modules. Short answer: yes for desktop, no for
server (see above why).

If the automatic installation doesn't work properly, install GTK3 manually.
First try the easiset path: `cpan Gtk3::WebKit`. If that works, that's just it.
Otherwise, try pre-packaged solutions first, f.ex: `apt-get install
libgtk3-perl gir1.2-webkit-3.0` on Ubuntu/Debian

Note that having Gtk3::WebKit is not enough, it needs its gireporistory (as
f.ex. gir1.2-webkit-3.0) installed too.

* Run `eboks-authenticate`, it will start NemID auth process (see above)

Installation for Windows
------------------------

* Install cygwin environment:
	- Go to `https://cygwin.org/install.html` and download `https://cygwin.com/setup-x86_64.exe`.
	- Run it, select a mirror and an install folder
	- In the package view, select 'Not installed' dropdown.
	- Install packages (see below) by searching for its name, then clicking on 'Skip' dropdown, and selecting a latest version
* Select the packages below, then click `Next` and let it run:
	- dbus
	- girepository-WebKit3.0
	- make
	- perl-Crypt-OpenSSL-RSA
	- perl-DateTime
	- perl-Digest-SHA
	- perl-Gtk3
	- perl-IO-Socket-SSL
	- perl-MIME-Tools
	- perl-Net-DNS
	- perl-Sub-Name
	- perl-XML-Simple
	- perl-libwww-perl
	- xorg-server
* Close the installer. Install other modules not provided by cygwin:
	- Enter cygwin command line by running `cygwin.bat` from the `C:/Cygwin64` or where you have it installed.
	- Type `cpan`. Let it configure itself, press Enter if it asks questions.
	- Type `force install Gtk3::WebKit`
	- Type `install Net::Eboks`. Press Enter on all questions
	- Type `exit`
* Run X environment:
	- From cygwin command line start X server: `X -multiwindow &`
	- Type `export DISPLAY=:0`
	- Run `eboks-authenticate`, it will start NemID auth process (see above)
	- After finishing, quit the X server by typing `kill %1`. Then close the cygwin command line window.

Operations
==========

Download your mails as a mailbox
--------------------------------

Note: You probably don't need it, this script is mostly for testing that the access works.

On command line, type `eboks-dump`, enter your passwords, and wait until it downloads
all into eboks.mbox. Use your favourite mail agent to read it.

Use eboks.dk as a POP3 server
-----------------------------

You may want this setup if you don't have a dedicated server, or don't want
to spam your mail by eBoks. You can run everything on a single desktop.

1) On command line, type `eboks2pop`

2) Connect your mail client to POP3 server at localhost, where username is
your CPR code such as f.ex: 0123456-7890 and password is your mobile pincode.

Use on mail server
------------------

This is the setup I use on my own remote server, where I connect to using
email clients to read my mail.

1) Create a startup script, f.ex. for FreeBSD see `example/eboks2pop.freebsd`,
and for Debian/Ubuntu see `examples/eboks2pop.debian`

2) Install *procmail* and *fetchmail*. Look into `example/procmailrc.local` and
and `examples/fetchmail` (the latter needs to have permissions 0600). 

3) Add a cron job f.ex.

`  2       2       *       *       *       /usr/local/bin/fetchmail > /dev/null 2>&1`

to fetch mails once a day. Only new mails will be fetched. This will also work for 
more than one user.

Automated forwarding
--------------------

You might want just to forward your eBoks messages to your mail address.  The
setup is basically same as in previous section, but see
`examples/procmailrc.forward.simple` instead.

The problem you might encounter is that the module generates mails as
originated from `noreply@e-boks.dk` and f.ex. Gmail won't accept that due to
DMARC. See if rewriting the sender as in `examples/procmail.forward.srs` helps.

Enjoy!
