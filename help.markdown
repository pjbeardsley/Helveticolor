---
layout: default
title: Help
class: interior
id: help
---

## What versions of OS X does Helveticolor support?

Helveticolor supports OS X 10.7 (Lion), OS X 10.8 (Mountain Lion) and OS X 10.9 (Mavericks).

## How do I install Helveticolor?

On OS X 10.7 (Lion), simply unzip Helveticolor and double-click on `Helveticolor.saver`.

On OS X 10.8 (Mountain Lion) and later, the proccess is a bit more involved due to the fact that Helveticolor
is an unsigned app.[^1]

Unzip Helveticolor and right-click on `Helveticolor.saver`.  Choose `Open`:

![Open](/Helveticolor/img/helveticolor_open.png)
    

A dialog will appear to confirm the opening of an unsigned application—click `Open`:

![Are You Sure](/Helveticolor/img/helveticolor_are_you_sure.png)
    




In System Preferences, a sheet will determine which users Helveticolor will be installed for—typically 'Install for this user only' is sufficient:

![Install for user](/Helveticolor/img/helveticolor_install_for_user.png)
    
## What are Helveticolor's licensing terms?

Helveticolor is licensed under the [MIT License](http://opensource.org/licenses/mit-license.php).  The project source is available on [Github](https://github.com/pjbeardsley/Helveticolor).

## I have a bug report or enhancement suggestion for Helveticolor.  How should I contact you?

Please feel free to contact me via [Twitter](http://twitter.com/helveticolor), or submit a pull request via [Github](https://github.com/pjbeardsley/Helveticolor).

[^1]: In OS X 10.8, Apple added a security feature named
[Gatekeeper](http://www.apple.com/osx/what-is/security.html). In short, the default
settings discourage the installation of applications that are not cryptographically
signed with an Apple Developer ID. Since Helveticolor is an Open Source project
developed in my spare time, I've opted against the $100/year program fee that
would be required to sign the app.
