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

* Install this module by opening command line and typing `cpan Net::Eboks` (with `sudo` if you need it system-wide)

* *Development*: you can install the dev version from github. Download/clone the repo, then run

```
  perl Makefile.PL
  make
  make install
```
(or `sudo make install`, depending)

One-time NemID registration
---------------------------

For each user, you will need to go through one-time registration through you
personal NemID signature. `eboks-authenticate` will start a small webserver on
`http://localhost:9999/`, where you will need to connect to with a browser.
There, it will ask for your CPR, your password (from e-boks Menu/Mobiladgang),
and will try to show a standard NemID window. You will need to log in there, in
the way you usually do, using either one-time pads or the NemID app, and then
confirm the request from eBoks. If that works, the script will register the
pseudo device Net-Eboks for future logins (you would see the device entry in
Menu/Mobiladgang/Aktiverede enheder; you can also disable it from there).

This step should be done only once per user, not per installation - after the
registration you can access eBoks from any server that has this module installed.

**Security note**: *No data is stored on the computer in the process, the only record is stored
on the eBoks server itself*.

Also, there are no specific security concerns others than the usual suspects
when one logs into NemID. To be extra paranoid though, use only two-factor
authentication through NemID app, not through one-time pads, as the app shows
who is the issuer of the login request when asking for its confirmation.  Make
sure the requestor is eBoks, not your bank :)

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
[SPF](https://en.wikipedia.org/wiki/Sender_Policy_Framework). See if rewriting
the sender as in `examples/procmail.forward.srs` helps.

Use on Windows desktop
----------------------

1) Assuming you have installed strawberry perl and the module, open command line and run

  `eboks-install-win32`

that will fire up a browser-based install wizard. Click "Install", then login witn eBoks
credentials and NemID credentials.

2) Set up your favourite desktop mail reader so it connects to a POP3 server
running on server localhost, port 8110. Username and password are your CPR# and
eBoks mobile password.

3) Optionally, if you want to forward the mails, you can choose from numerous
programs that can forward mails from a POP3 server to another mail account
[(list of
examples)](https://blogs.technet.microsoft.com/brucecowper/2005/03/18/pop-connectors-pullers-for-exchange/).
If you use Outlook it [can do that
too](https://www.laptopmag.com/articles/how-to-set-up-auto-forwarding-in-outlook-2013).

Read associated eBoks shares
----------------------------

If you have associated mailboxes, that companies open for you, you can access them in two ways.

1) Download them all, by using CPR in a form of 123456-7890:\* . The module
will interpret all shared folders as one huge inbox. For ease of filtering
there is a mail header `X-Net-Eboks-Shareid` that contains numeric identifier
of the shared folder.

2) Download each of them separately, by using CPR in a form of
123456-7890:SHAREID where `SHAREID` is a numeric identifier of the shared
folder. Get it by running `eboks-dump -l`.

In both cases the password, authentication etc is the same as if you use only your private eBoks.

Enjoy!
