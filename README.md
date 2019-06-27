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

* For windows, you'll need `perl`. Go to [strawberry perl](http://strawberryperl.com/) and fetch one.

* Install this module by opening command line and typing `cpan Net::Eboks`.

One-time NemID registration
---------------------------

For each user, you will need to go through one-time registration through you
personal NemID signature. `eboks-authenticate` will start a small webserver on
`http://localhost:9999/`, where you will need to connect to with a browser.
There, it will ask for your CPR, your password (from e-boks Menu/Mobiladgang),
and will try to show a standard NemID window, that you will need to log in, and
then confirm that indeed you to allow the login to eBoks.  If that works, the
script will send that to the eBoks server so it recognizes your future logins
from a pseudo device (you would see it as Net-Eboks in
Menu/Mobiladgang/Aktiverede enheder).

This step should be done one time only, for each user, not for each
installation. 

Security note: There are no security concerns others than the usual suspects
when one uses NemID logins by other means. To be extra paranoid though, use
only two-factor authentication through NemID app, not through one-time pads, as
the app shows who is the issuer of the login request when asking for its
confirmation.  Make sure the requestor is eBoks, not your bank :)

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
