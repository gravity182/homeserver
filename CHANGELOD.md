# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## \[5.5.1] - 2025-10-14

Changes:
- Use bitnamilegacy repo for Bitnami PostgreSQL/MongoDB charts

## \[5.5.0] - 2025-10-05

New services:
- [CouchDB](https://github.com/apache/couchdb) - CouchDB instance tailored for usage by the Obsidian [Livesync plugin](https://github.com/vrtmrz/obsidian-livesync)

## \[5.4.0] - 2025-09-26

New services:
- [Authelia](https://www.authelia.com/): an open-source authentication and authorization server providing 2FA and single sign-on (SSO) for your applications
    - Allows selection between Authentik and Authelia via the `authProvider` global setting
    - Authentik is still the default, Authelia is optional

## \[5.3.0] - 2025-09-25

New services:
- [iSponsorBlockTV](https://github.com/dmunozv04/iSponsorBlockTV): Skip sponsored segments, intros, outros, and other annoying parts on YouTube TV

## \[5.2.0] - 2025-09-15

Updates:
- Lidarr: migrated to the home-operations rootless image. Should not break anything

## \[5.1.1] - 2025-09-15

Updates:
- MeiliSearch: added upgrade automation via export/import jobs to handle version compatibility issues

## \[5.1.0] - 2025-09-14

New services:
- [slskd](https://github.com/slskd/slskd): Soulseek client for music sharing and discovery
- [Soularr](https://github.com/mrusse08/soularr): Soulseek integration with Lidarr for automated music downloads

## \[5.0.0] - 2025-05-18

Changes:
- Added monitoring stack: Grafana, Loki, Alloy
- Added more security-tailored HTTP middlewares
- Added a new housekeeping cronjob to clean leftover dirs
- Subcharts are now deployed via k3s' Helm Controller
- Added Gateway API, which fully replaces the old Ingress
- Added customization of pod affinity and tolerations
- Added Traefik configuration:
    - Trust Cloudflare's IP when accepting `X-Forwarded-*` headers
    - Forward `http` traffic to `https`

Breaking changes:
- Refactored configuration schema of the cert-manager's ClusterIssue:
    - Customize solvers
    - Customize ACME server URL
- Since this update uses Gateway API, it might be not available in the old versions of Traefik. Please upgrade your k3s cluster to the latest version (`v1.32.4`)
    - Moreover, please disable your Authentik ingress as it'll no longer work

## \[4.11.0] - 2025-04-29

Changes:
- Added a housekeeping cronjob for cleaning up media directories that contain only leftover files such as metadata

## \[4.10.0] - 2025-04-28

Changes:
- Added user-scripts files config for Pinchflat
- File configs for other services now copy all the files in the directory without extension requirement

## \[4.9.1] - 2025-04-20

Fixes:
- Fixed periodic backup jobs for databases

## \[4.9.0] - 2025-04-16

New services:
- [qbit_manage](https://github.com/StuffAnThings/qbit_manage): Manage qBittorrent automatically: tag, categorize, remove orphaned data, remove unregistered torrents, and much much more

## \[4.8.0] - 2025-04-09

Updates:
- Librechat: now supports search via MeiliSearch. Configured via `.Values.services.librechat.search`. Disabled by default

New services:
- MeiliSearch: advanced search engine

## \[4.7.0] - 2025-03-30

- Pinchflat: allow customization of the yt-dlp config

## \[4.6.1] - 2025-03-30

- Remove redundant annotations for some services

## \[4.6.0] - 2025-03-30

- Add missing annotations

## \[4.5.0] - 2025-03-25

- Migrate to the [home-operations](https://github.com/home-operations/containers) images instead of the onedr0p ones, which have been deprecated

## \[4.4.1] - 2025-03-22

- Wireguard VPN: set `0600` (non world-accessible) file permissions for the secret volume containing the Wireguard config
- Wireguard VPN: the `SYS_MODULE` capability is active by default

## \[4.4.0] - 2025-03-22

- Jellyfin: use the official image. Now strict security context is supported
- Templates don't fail anymore if `vpn` definition is missing

## \[4.3.2] - 2025-03-19

- Pinchflat: fix running as a non-root user

## \[4.3.1] - 2025-03-18

- Homepage: add a new required env var `HOMEPAGE_ALLOWED_HOSTS`. Fixes the broken homepage for the latest image (v1.0.4)

## \[4.3.0] - 2025-03-17

- Extract CloudflareBypassForScraping to the separate service (`.Values.services.cloudflarebypassforscraping`)

## \[4.2.1] - 2025-03-12

- Fix host_whitelist for SABnzbd - include pod's IP

## \[4.2.0] - 2025-03-12

- Added missing liveness/readiness/startup probes to all deployments

## \[4.1.0] - 2025-03-11

- Added `volumePermissions.enabled` property to enable/disable the automatic fix of volume permissions

## \[4.0.0] - 2025-03-10

Big refactoring:
- Now Authentik and cert-manager are installed as subcharts
- Added JSON schema for values.yaml validation

## \[3.0.5] - 2025-03-04

- Librechat: Added customization of a refresh token expiry duration via `refreshTokenExpiryMilliseconds`
- Librechat: Added customization of `ALLOW_SOCIAL_LOGIN`/`ALLOW_EMAIL_LOGIN` env vars
- Librechat: Added more clarifications in comments of `values.template.yaml`

## \[3.0.4] - 2025-03-02

- Librechat: Fixed crash when using read-only fs. Added a new empty dir `/app/data`

## \[3.0.3] - 2025-02-28

- Librechat: Fix image uploading for read-only fs. Had to create a few temporary empty dirs
- Librechat: Persist user-uploaded images. Now the value `services.librechat.persistence.clientImages` is required

## \[3.0.2] - 2025-02-26

- ConvertX: Add an empty dir `/home/bun/.config` - fixes the read-only fs warning

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
