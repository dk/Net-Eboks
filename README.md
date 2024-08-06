perl API for eboks.dk
=====================

This is perl interface for http://eboks.dk/, Danish national email system. 

Included a simple POP server for proxying e-boks for read-only mail access
and a simple downloader.

You shall need your CPR# and password.  You can get the password from the
e-Boks website.  For the POP3 login, the username is be your CPR code, such as
f.ex: 0123456-7890.  The password is your mobile pincode.

How it works
============

The module need to be authenticated using MitID as all other clients to the
danish services.  The only difference is that this module is not an official
client, (I'd love to make it official but I guess that costs an arm and a leg,
plus bureaucratic hassles, so this is not planned so far). You would need to
run the authentication (see below) where you would provide your Eboks password
and confirm the Eboks login using your MitID app. After this is done, the
module stores the RSA public key on the eboks server, and this is the same
hardcoded public key used for all accesses. You may supply your own RSA keypair
by generating it yourself and inserting it in the code.

After the public key is uploaded, the module can login and fetch mails using
the public key authentication. It would still need to ask for your CPR and
Eboks password though. You most probably want to either read these mails on the
same machine that fetches them, or forward them to your email. See below how to
do that.

Installation
============

Unix/Linux
----------

* Install this module by opening command line and typing `cpan Net::Eboks` (with `sudo` if needed)

Windows
-------

* You'll need `perl`. Go to [strawberry perl](http://strawberryperl.com/) and fetch one.

* Install this module by opening command line and typing `cpan Net::Eboks`

* Open command line and run

  `eboks-install-win32`

that will fire up a browser-based install wizard. Click "Install", then login witn eBoks
password and MitID.

* Set up your favourite desktop mail reader so it connects to a POP3 server
running on server localhost, port 8110. Username and password are your CPR# and
eBoks mobile password.

* Optionally, if you want to forward the mails, you can choose from numerous
programs that can forward mails from a POP3 server to another mail account
[(list of
examples)](https://blogs.technet.microsoft.com/brucecowper/2005/03/18/pop-connectors-pullers-for-exchange/).
If you use Outlook it [can do that
too](https://www.laptopmag.com/articles/how-to-set-up-auto-forwarding-in-outlook-2013).

Upgrading
---------

* Windows: run `eboks-install-win32` and stop the server in the browser-based setup.
Quit the setup.

* Install the dev version from github. Download/clone the repo, then run

```
  perl Makefile.PL
  make
  make install
```
(or `sudo make install`, depending); `gmake` instead of `make` for Windows.

* Windows: run `eboks-install-win32` and start the server in the browser-based setup.
Quit the setup.

* Linux: restart `eboks2pop` using your system tools.

Upgrading from NemID to MitID
-----------------------------

Versions v0.08 and before used NemID authentication, which is deprecated now
and doesn't work anymore. You don't need to do another round of MitID
authentication, as the hardcoded RSA keypair can still be reused.

One-time MitID authentication
-----------------------------

For each user, you will need to go through the initial authentication, once.
`eboks-auth-mitid` will start a small webserver on `http://localhost:9999/`,
where you will need to connect to with a browser.  There, it will ask for your
password (from e-boks Menu/Mobiladgang) and will try to show a standard MitID
window. You will need to confirm the login with your MitID app.  If that works,
the script will register the pseudo device Net-Eboks for future logins (you
would see the device entry in Menu/Mobiladgang/Aktiverede enheder; you can also
disable it from there).

**Important**: The authentication step proxies some requests and that doesn't
go well with the [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
policy.  That's why if you try to start the authentication in a normal browser
window, you will not be able to see the MitID login window, but get an error
instead.

To sidestep that, the authentication must be done with some browser security
settings lowered. You may want to use a standalone instance of a browser so it
doesn't mess with your main security settings.

* Chrome on Windows: create a folder f.ex `C:\chrome.nosec` and run
`"C:\Program Files\Google\Chrome\Application\chrome.exe" --disable-web-security --user-data-dir="C:\chrome.nosec"`
(also see `examples/chrome.bat`)

* Chrome on Linux: basically same, `mkdir /tmp/chrome` and `chrome --disable-web-security --user-data-dir=/tmp/chrome`

* Firefox: apparently it cannot do this, but some extentions claim that they
can (simple-modify-headers etc). I didn't succeed to setup a single one so if
you know how to hack Firefox to add `Access-Control-Allow-Origin: *` to all
responses, kindly ping me back.

* Other browsers: I didn't care but again patches to this text are welcome.

**Security note**: *No data is stored on the computer in the process, the only record is stored
on the eBoks server itself*.

The authentication step should be done only once per user, not per
installation.  after the registration you can access eBoks from any server that
has this module installed.

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

1) On command line, type `eboks2pop`. On windows, this is done autmatically and
is not needed if you performed installation using the `eboks-install-win32`
script.

2) Connect your mail client to POP3 server at localhost, where username is
your CPR code such as f.ex: 0123456-7890 and password is your mobile password.

Use on mail server
------------------

This is the setup I use on my own remote server, where I connect to using
email clients to read my mail.

1) Create a startup script, f.ex. for FreeBSD see `example/eboks2pop.freebsd`,
and for systemd-based unices see `examples/eboks2pop.service`

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
[SPF](https://en.wikipedia.org/wiki/Sender_Policy_Framework). You can change
that *From:* address to another by setting the environment variable `MAILFROM`.
Alternatively, see if rewriting the sender as in
`examples/procmail.forward.srs` helps.

Read the associated eBoks shares
--------------------------------

If you have associated mailboxes, that companies open for you, you can access them in two ways.

1) Download them all, by using CPR in a form of 123456-7890:\* . The module
will interpret all shared folders as one huge inbox. For the ease of filtering
there is a mail header `X-Net-Eboks-Shareid` that contains numeric identifier
of the shared folder.

2) Download each of them separately, by using CPR in a form of
123456-7890:SHAREID where `SHAREID` is a numeric identifier of the shared
folder. Get it by running `eboks-dump -l`.

In both cases the password, authentication etc is the same as if you use only your private eBoks.

Enjoy!
