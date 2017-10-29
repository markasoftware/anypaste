# Anypaste

Anypaste is a file sharing site aggregator for *nix-like systems (Mac, Linux, BSD, etc). It uses the mime type of a file to automatically detect compatible hosting sites. For example, if you run `anypaste something.jpg`, it will get uploaded to tinyimg.io, an image hosting site. If you run `anypaste something.m4v`, it will get uploaded to SendVid, a video hosting site. More information about Anypaste can be found on the official website: [anypaste.xyz](https://anypaste.xyz).

## Demo

<a href="https://asciinema.org/a/144137" target="_blank"><img src="https://asciinema.org/a/144137.png" height='300px' /></a>

## Install

Anypaste is just a shell script. It's hosted at `https://anypaste.xyz/sh`. A quick command to install it is: `sudo curl -o /usr/bin/anypaste https://anypaste.xyz/sh && sudo chmod +x /usr/bin/anypaste`.

## Basic Usage Examples

* `anypaste file.jpg`: Upload `file.jpg`, automatically selecting the plugin (standard usage).
* `anypaste file.jpg file.m4v`: Upload multiple files, with automatic plugin selection for both.
* `anypaste -p gfycat file.m4v`: Upload `file.m4v`; use a plugin containing `gfycat` in its name (manual plugin selection).
* `anypaste -p gfycat something.tar.gz`: Upload `something.tar.gz` with `gfycat`, even though `gfycat` is not compatible (override compatibility checks).
* `anypaste some-directory`: Upload `some-directory`, a compressed tarball will automatically be created (`.tar.gz`)

## Website

[Documentation](https://anypaste.xyz/docs.html), and the [list of plugins](https://anypaste.xyz/plugins.html) can be found on the [Anypaste website](https://anypaste.xyz). The website is open source and can be contributed to in its [GitHub repo](https://github.com/markasoftware/anypaste-website).

## Contributing

Please, make some plugins so we can support more sites! If the plugins seem good enough, I may even make them built-in plugins! Additionally, PRs to improve "Anypaste Core" are also welcome.