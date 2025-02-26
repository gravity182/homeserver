# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## \[3.0.1] - 2025-02-26

- Allow overriding global `automountServiceAccountToken` setting per service
- Allow overriding global `enableServiceLinks` setting per service

## \[3.0.0] - 2025-02-23

Another big update:
- Now most of the containers truly run as a non-root user and as a read-only filesystem
    - That was kinda a case even before, however images like Linuxserver used a custom mechanism, running as a root user at startup and then dropping to a less privileged one. It poses some risks since there's still a small window at startup for causing harm. Now most images truly run rootless from the beginning
    - Enabled by default
    - Controlled via `services.<service>.securityContext.strict`. When set to `true`, containers run as non-root/read-only from the startup
- Replaced some images with less bloated ones, prefering those that allow to run as non-root and read-only
    - S6-overlay/Linuxserver images are notorious for being bloated and making it very hard to run as non-root or read-only
    - Big thanks to [onedr0p](https://github.com/onedr0p/containers) for these amazing images
- Add [resources constraints](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
    - Disabled by default
    - Controlled via `resources.enabled`
- Allow even more customization:
    - Custom labels
    - Custom annotatitions
    - Custom env vars populating from a secret
    - Custom env vars populating from a config map
    - Custom env vars using specific secrets and keys
    - Custom volumes
    - Custom volumeMounts
- Extract repeated stuff into helm templates

## \[2.0.3] - 2025-02-19

- Kometa: clear watchlist in Radarr/Sonarr before fetching it from IMDb/Letterboxd. Now watchlist always stays in sync with IMDb/Letterboxd

## \[2.0.2] - 2025-02-16

- CWA-Book-Downloader: add customization of the AA Donator Key

## \[2.0.1] - 2025-02-16

- Miniflux: add customization of the [cleanup params](https://miniflux.app/docs/configuration.html#cleanup-archive-read-days)

## \[2.0.0] - 2025-02-16

Big update! The chart is becoming even better!

1. New services:
    - [Pinchflat](https://github.com/kieraneglin/pinchflat) - a Youtube downloader
    - [Myspeed](https://github.com/gnmyt/myspeed) - speed test with multiple providers
    - [Calibre-Web-Automated](https://github.com/crocodilestick/Calibre-Web-Automated) (CWA) - books management
    - [CWA-Book-Downloader](https://github.com/calibrain/calibre-web-automated-book-downloader) - download books from Anna's Archive
    - [Openbooks](https://github.com/evan-buss/openbooks) - download books from IRCHighWay
    - [Mealie](https://github.com/mealie-recipes/mealie) - recipe manager
    - [Convertx](https://github.com/C4illin/ConvertX) - file convertor
2. Removed services:
    - Readarr - unfortunately, it's inherently broken. Replaced by Calibre-Web-Automated, Calibre-Web-Automated-Book-Downloader and Openbooks
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
