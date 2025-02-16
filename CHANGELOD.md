# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## \[2.0.2] - 2025-02-16

- CWA-Book-Downloader: add customization of the AA Donator Key

## \[2.0.1] - 2025-02-16

- Miniflux: add customization of the [cleanup params](https://miniflux.app/docs/configuration.html#cleanup-archive-read-days)

## \[2.0.0] - 2025-02-16

Big update! The chart is becoming even better!

1. New services:
    - [Pinchflat](https://github.com/kieraneglin/pinchflat) - a Youtube downloader
    - [Myspeed](https://github.com/gnmyt/myspeed) - speed test with multiple providers
    - [Calibre-Web-Automated](https://github.com/crocodilestick/Calibre-Web-Automated) - books management
    - [CWA-Book-Downloader](https://github.com/calibrain/calibre-web-automated-book-downloader) - download books from Anna's Archive
    - [Openbooks](https://github.com/evan-buss/openbooks) - download books from IRCHighWay
    - [Mealie](https://github.com/mealie-recipes/mealie) - recipe manager
    - [Convertx](https://github.com/C4illin/ConvertX) - file convertor
2. Removed services:
    - Readarr - unfortunately, it's inherently broken. Replaced by Calibre, Calibre-book-downloader and Openbooks
    - Speedtest - consumed too much RAM, had only a single non-transparent provider. Myspeed allows you to choose a provider: Librespeed, Cloudflare, or Speedtest
3. Now services can connect to a VPN
4. Now each service can be served under multiple subdomains in ingress

## \[1.0.5] - 2024-12-10

Added `backupRetentionDays` setting for those services having periodic backups.
This settings controls how long the backups will live (locally).

## \[1.0.4] - 2024-10-25

Added Jellyfin to homepage.

## \[1.0.3] - 2024-10-24

Add the service name to the `host_whitelist` in SABnzbd to allow connections from the other pods.

## \[1.0.2] - 2024-10-24

Add a missing `services.kometa.enableJmxdOverlays` value to the values template

## \[1.0.1] - 2024-10-24

Update Kometa config:
1. Add the [letterboxd](https://kometa.wiki/en/latest/defaults/chart/letterboxd) chart

## \[1.0.0] - 2024-10-23

Initial release
