# Home Media Server

> [!WARNING]
> **This project is no longer maintained.**
>
> I've moved to a new GitOps-based setup. Check it out at [home-ops](https://github.com/gravity182/home-ops).

## Description

This repo will get you your own home server with a lot of useful self-hosted software. This stack is well-built and will serve you reliably.

All services are optional and can be enabled/disabled anytime. Detailed list:
- Media:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/radarr.svg"> [Radarr](https://github.com/Radarr/Radarr) - Movies management
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sonarr.svg"> [Sonarr](https://github.com/Sonarr/Sonarr) - TV Series management
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/lidarr.svg"> [Lidarr](https://github.com/Lidarr/Lidarr) - Music management
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/whisparr.svg"> [Whisparr](https://github.com/Whisparr/Whisparr) - Adult videos management
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg"> [Prowlarr](https://github.com/Prowlarr/Prowlarr) - Indexers management. Allows you to sync your torrent/usenet indexers across all of the *arr stack
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/bazarr.svg"> [Bazarr](https://github.com/morpheus65535/bazarr) - Companion application to Radarr and Sonarr. It manages and downloads subtitles based on your requirements
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/plex.svg"> [Plex](https://www.plex.tv/) - Media server for watching downloaded movies and series from any of your devices (PC, Android, iOS, iPad, TV)
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/jellyfin.svg"> [Jellyfin](https://github.com/jellyfin/jellyfin) - Open-source alternative to Plex
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/jellyseerr.svg"> [Jellyseerr](https://github.com/Fallenbagel/jellyseerr) - Media request platform, which you can share with your friends for automatic movie/series downloading. Companion application to Radarr/Sonarr and Plex/Jellyfin
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/autobrr.svg"> [Autobrr](https://github.com/autobrr/autobrr) - Download automation for torrents and Usenet. Monitors indexers' IRC channels and grabs a release as soon as it's announced
- Downloaders:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/qbittorrent.svg"> [qBittorrent](https://github.com/qbittorrent/qBittorrent) - Torrent downloader
    - <img width="15" height="15" src="https://github.com/StuffAnThings/qbit_manage/blob/master/icons/qbm_logo.png?raw=true"> [qBit_manage](https://github.com/StuffAnThings/qbit_manage) - Manage qBittorrent automatically: tag, categorize, remove orphaned data, remove unregistered torrents, and much much more
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg"> [SABnzbd](https://github.com/sabnzbd/sabnzbd) - Usenet downloader
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/pinchflat.png"> [Pinchflat](https://github.com/kieraneglin/pinchflat) - YouTube downloader based on yt-dlp
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/slskd.svg"> [slskd](https://github.com/slskd/slskd) - Soulseek client for music sharing and discovery
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/soularr.png"> [Soularr](https://github.com/mrusse08/soularr) - Soulseek integration with Lidarr for automated music downloads
- Books:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/calibre-web.svg"> [Calibre-Web Automated](https://github.com/crocodilestick/Calibre-Web-Automated) - Calibre-Web but automated
    - 📚 [Calibre-Web-Automated-Book-Downloader](https://github.com/calibrain/calibre-web-automated-book-downloader) - A web interface for searching and downloading books from Anna's Archive
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/openbooks.svg"> [Openbooks](https://github.com/evan-buss/openbooks) - A web interface for searching and downloading books from IRCHighWay
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/kavita.svg"> [Kavita](https://github.com/Kareadita/Kavita) - Books reader
- Utilities:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/miniflux-light.svg"> [Miniflux](https://github.com/dysosmus/miniflux) - RSS feed reader
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/stirling-pdf.svg"> [Stirling PDF](https://github.com/Stirling-Tools/Stirling-PDF) - PDF Manipulation Tool
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/the-lounge.svg"> [The Lounge](https://github.com/thelounge/thelounge) - IRC Client
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/convertx.png"> [Convertx](https://github.com/C4illin/ConvertX) - File conversion
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/mealie.svg"> [Mealie](https://github.com/mealie-recipes/mealie) - Cooking recipe manager
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/librechat.svg"> [Librechat](https://github.com/danny-avila/LibreChat) - Self-hosted ChatGPT clone, supporting multiple local & remote AI providers (Ollama, OpenRouter, OpenAI, Groq, and others)
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/meilisearch.svg"> [MeiliSearch](https://github.com/meilisearch/meilisearch) - A lightning-fast search engine API
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/couchdb.svg"> [CouchDB](https://github.com/apache/couchdb) - CouchDB instance tailored for usage by the Obsidian [Livesync plugin](https://github.com/vrtmrz/obsidian-livesync)
    - <img width="15" height="15" src="https://github.com/ajayyy/SponsorBlock/blob/master/public/icons/LogoSponsorBlocker64px.png?raw=true"> [iSponsorBlockTV](https://github.com/dmunozv04/iSponsorBlockTV) - Skip sponsored segments, intros, outros, and other annoying parts on YouTube TV
- Notification:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/apprise.svg"> [Apprise](https://github.com/caronc/apprise-api) - Send notifications to many popular services like Telegram, Discord, Slack, Gotify, and others
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/gotify.svg"> [Gotify](https://github.com/gotify/server) - Self-hosted push notification service
- Monitoring:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/grafana.svg"> [Grafana](https://github.com/grafana/grafana) - Observability platform for monitoring and visualization
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/loki.svg"> [Loki](https://github.com/grafana/loki) - Log aggregation system for collecting and querying logs
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/myspeed.png"> [MySpeed](https://github.com/gnmyt/myspeed) - Speed test tracker. Monitors your download & upload speed over time
- Security:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/authentik.svg"> [Authentik](https://github.com/goauthentik/authentik) - SSO (Single-Sign On) Authentication. Protects your homeserver from unathenticated access. Allows you to sign in only once and use any of the services without the hassle of remembering a credentials for each service
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/authelia.svg"> [Authelia](https://github.com/authelia/authelia) - Open-source authentication and authorization server providing 2FA and single sign-on (SSO) for your applications
    - <img width="15" height="15" src="https://github.com/cert-manager/cert-manager/blob/master/logo/logo-small.png?raw=true"> [cert-manager](https://github.com/cert-manager/cert-manager) - Automatically provision, manage, and renew TLS certificates
- Backups:
    - <img width="15" height="15" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/backrest-light.svg"> [Backrest](https://github.com/garethgeorge/backrest) - a web-accessible backup solution built on top of restic

---

## Features

Chart features:
- Chart customization - important service settings are controlled through Helm values
- SSO authentication powered by [Authentik](https://github.com/goauthentik/authentik) or [Authelia](https://github.com/authelia/authelia)
- Automatic TLS certificates provisioning powered by [cert-manager](https://github.com/cert-manager/cert-manager)
- Scheduled server backups powered by [Backrest](https://github.com/garethgeorge/backrest)
- VPN support - every service can route its traffic through a WireGuard VPN. This is especially important for such services as qBitTorrent for smooth Linux ISO downloading
- Any kind of volume (hostPath/PVC/NFS) is supported
- Proper file permissions handling - you will never encounter permission issues
- Follows best security practices - containers are running as a non-root user and with a read-only filesystem

---

## Quickstart / Documentation

Please see [Installation](Installation.md).

---

## Credits

I want to thank these amazing resources which I heavily used during the development:
- <https://trash-guides.info>
- <https://wiki.servarr.com>
- a bunch of random questions on r/SelfHosted

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Disclaimer

This code is provided for informational purposes only and should not be used for illegal activities. I am not responsible for any actions performed by the users of this code.
