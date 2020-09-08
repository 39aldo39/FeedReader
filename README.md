FeedReader
==========

This is a fork of the archived [jangernert/FeedReader](https://github.com/jangernert/FeedReader), but with an updated [DecSync](https://github.com/39aldo39/DecSync) plugin.

Build from source
-----------------

In addition to the dependencies below, the library [libdecsync](https://github.com/39aldo39/libdecsync) is also required.

Install dependencies:

### Ubuntu

```
sudo apt install \
	build-essential \
	meson \
	ninja-build \
	valac \
	pkg-config \
	libgirepository1.0-dev \
	libgtk-3-dev \
	libgumbo-dev \
	libsoup2.4-dev \
	libjson-glib-dev \
	libwebkit2gtk-4.0-dev \
	libsqlite3-dev \
	libsecret-1-dev \
	libnotify-dev \
	libxml2-dev \
	libunity-dev \
	librest-dev \
	libgee-0.8-dev \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev \
	libgoa-1.0-dev \
	libcurl4-openssl-dev \
	libpeas-dev \
	libgumbo-dev
```

### Fedora

```
sudo dnf install \
	gcc \
	gettext \
	git \
	gnome-online-accounts-devel \
	gstreamer1-devel \
	gstreamer1-plugins-base-devel \
	gtk3-devel \
	gumbo-parser-devel \
	json-glib-devel \
	libcurl-devel \
	libgee-devel \
	libnotify-devel \
	libpeas-devel \
	libsecret-devel \
	libsoup-devel \
	libxml2-devel \
	meson \
	rest-devel \
	sqlite-devel \
	vala \
	webkitgtk4-devel \
	appstream \
	desktop-file-utils \
	libunity-devel
```

### Build

```bash
git clone --recursive https://github.com/39aldo39/FeedReader
cd ./FeedReader
meson build
sudo ninja -C build install
```

Donations
---------

### PayPal
[![](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4V96AFD3S4TPJ)

### Bitcoin
[`1JWYoV2MZyu8LYYHCur9jUJgGqE98m566z`](bitcoin:1JWYoV2MZyu8LYYHCur9jUJgGqE98m566z)
