{{/*
Resolve a volume spec from a mount definition.
Returns the volume configuration object that the mount points to.

Input: dict with keys:
  - service: service object
  - mountName: name of the mount (key in persistence.mounts)

Output: volume config object or empty dict if not found

Usage:
  {{- $volume := include "homeserver.validation.resolveVolumeFromMount" (dict "service" $service "mountName" "soulseek-downloads") | fromYaml }}
*/}}
{{- define "homeserver.validation.resolveVolumeFromMount" -}}
{{- $service := .service -}}
{{- $mountName := .mountName -}}

{{- if not (and $service.persistence (hasKey $service.persistence "mounts")) -}}
  {{- dict | toYaml -}}
{{- else -}}
  {{- $mount := index $service.persistence.mounts $mountName -}}
  {{- if not $mount -}}
    {{- dict | toYaml -}}
  {{- else -}}
    {{- $volumeName := $mount.volume -}}
    {{- if not (and $service.persistence (hasKey $service.persistence "volumes")) -}}
      {{- dict | toYaml -}}
    {{- else -}}
      {{- $found := dict -}}
      {{- range $service.persistence.volumes -}}
        {{- if eq .name $volumeName -}}
          {{- $found = . -}}
        {{- end -}}
      {{- end -}}
      {{- $found | toYaml -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Extract the canonical storage identifier from a volume config.
This normalizes different volume types to a comparable string.

For hostPath: returns "hostPath:{path}"
For pvc: returns "pvc:{claimName}" (existingClaim or generated name)
For nfs: returns "nfs:{server}:{path}"
For emptyDir: returns "emptyDir:{volumeName}"

Input: dict with keys:
  - volume: volume configuration object
  - service: service object (for PVC name generation)

Output: string representing the canonical storage location

Usage:
  {{- $storageId := include "homeserver.validation.getVolumeStorageId" (dict "volume" $vol "service" $service) }}
*/}}
{{- define "homeserver.validation.getVolumeStorageId" -}}
{{- $config := .volume -}}
{{- $service := .service -}}

{{- if hasKey $config "hostPath" -}}
  {{- printf "hostPath:%s" $config.hostPath.path -}}
{{- else if hasKey $config "pvc" -}}
  {{- if $config.pvc.existingClaim -}}
    {{- printf "pvc:%s" $config.pvc.existingClaim -}}
  {{- else -}}
    {{- $pvcName := include "homeserver.persistence.pvcName" (dict "service" $service "name" $config.name) -}}
    {{- printf "pvc:%s" $pvcName -}}
  {{- end -}}
{{- else if hasKey $config "nfs" -}}
  {{- printf "nfs:%s:%s" $config.nfs.server $config.nfs.path -}}
{{- else if hasKey $config "emptyDir" -}}
  {{- printf "emptyDir:%s" $config.name -}}
{{- else -}}
  {{- printf "unknown:%s" $config.name -}}
{{- end -}}
{{- end -}}

{{/*
Validate persistence configuration for a single service.

Checks:
1. Mount references must be valid (mount.volume must exist in volumes[].name)
2. Volume names must be unique within persistence.volumes[]
3. Each volume must specify exactly ONE of: hostPath, pvc, nfs, emptyDir

Input: dict with keys:
  - serviceName: name of the service
  - service: service object

Usage:
  {{- include "homeserver.validation.persistence.validateService" (dict "serviceName" "radarr" "service" $service) }}
*/}}
{{- define "homeserver.validation.persistence.validateService" -}}
{{- $serviceName := .serviceName -}}
{{- $service := .service -}}

{{- if and $service.enabled $service.persistence -}}

    {{- /* Validate mount references */ -}}
    {{- if $service.persistence.mounts -}}
      {{- range $mountName, $mount := $service.persistence.mounts -}}
        {{- if not $mount.volume -}}
          {{- fail (printf "Service '%s': Mount '%s' must specify a 'volume' field" $serviceName $mountName) -}}
        {{- end -}}

        {{- /* Check if referenced volume exists */ -}}
        {{- $volumeName := $mount.volume -}}
        {{- $found := false -}}
        {{- if $service.persistence.volumes -}}
          {{- range $service.persistence.volumes -}}
            {{- if eq .name $volumeName -}}
              {{- $found = true -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}

        {{- if not $found -}}
          {{- $availableVolumes := list -}}
          {{- if $service.persistence.volumes -}}
            {{- range $service.persistence.volumes -}}
              {{- $availableVolumes = append $availableVolumes .name -}}
            {{- end -}}
          {{- end -}}
          {{- $errorMsg := printf "Service '%s': Mount '%s' references volume '%s' which doesn't exist in persistence.volumes\n\nAvailable volumes: %s\n\nFix: Add the volume to persistence.volumes or update the mount to reference an existing volume" $serviceName $mountName $volumeName (join ", " $availableVolumes) -}}
          {{- fail $errorMsg -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    {{- /* Validate volume name uniqueness */ -}}
    {{- if $service.persistence.volumes -}}
      {{- $volumeNames := dict -}}
      {{- range $service.persistence.volumes -}}
        {{- $volName := .name -}}
        {{- if hasKey $volumeNames $volName -}}
          {{- $errorMsg := printf "Service '%s': Duplicate volume name '%s' found in persistence.volumes (volume names must be unique)\n\nFix: Rename duplicate volumes to have unique names" $serviceName $volName -}}
          {{- fail $errorMsg -}}
        {{- end -}}
        {{- $_ := set $volumeNames $volName true -}}
      {{- end -}}

      {{- /* Validate volume type exclusivity */ -}}
      {{- range $service.persistence.volumes -}}
        {{- $volName := .name -}}
        {{- $typeCount := 0 -}}
        {{- if hasKey . "hostPath" -}}
          {{- $typeCount = add $typeCount 1 -}}
        {{- end -}}
        {{- if hasKey . "pvc" -}}
          {{- $typeCount = add $typeCount 1 -}}
        {{- end -}}
        {{- if hasKey . "nfs" -}}
          {{- $typeCount = add $typeCount 1 -}}
        {{- end -}}
        {{- if hasKey . "emptyDir" -}}
          {{- $typeCount = add $typeCount 1 -}}
        {{- end -}}

        {{- if ne $typeCount 1 -}}
          {{- $errorMsg := printf "Service '%s': Volume '%s' must specify exactly ONE of: hostPath, pvc, nfs, emptyDir (found %d)\n\nFix: Specify exactly one volume type" $serviceName $volName $typeCount -}}
          {{- fail $errorMsg -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    {{- /* Validate unused volumes (volumes defined but never mounted) */ -}}
    {{- if $service.persistence.volumes -}}
      {{- $usedVolumes := dict -}}
      {{- if $service.persistence.mounts -}}
        {{- range $mountName, $mount := $service.persistence.mounts -}}
          {{- $_ := set $usedVolumes $mount.volume true -}}
        {{- end -}}
      {{- end -}}

      {{- range $service.persistence.volumes -}}
        {{- $volName := .name -}}
        {{- if not (hasKey $usedVolumes $volName) -}}
          {{- $errorMsg := printf "Service '%s': Volume '%s' is defined but never mounted\n\nFix: Either add a mount that uses this volume, or remove the unused volume from persistence.volumes" $serviceName $volName -}}
          {{- fail $errorMsg -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

{{- end -}}
{{- end -}}

{{/*
Validate service name uniqueness across all services.
*/}}
{{- define "homeserver.validation.services.uniqueNames" -}}
{{- $serviceNames := dict -}}
{{- range $serviceName, $serviceValue := .Values.services -}}
  {{- $servicesToCheck := list -}}
  {{- if kindIs "slice" $serviceValue -}}
    {{- $servicesToCheck = $serviceValue -}}
  {{- else if kindIs "map" $serviceValue -}}
    {{- $servicesToCheck = list $serviceValue -}}
  {{- end -}}

  {{- range $service := $servicesToCheck -}}
    {{- $name := $service.name -}}
    {{- if hasKey $serviceNames $name -}}
      {{- fail (printf "Duplicate service name '%s' found (used by '%s' and '%s')" $name (index $serviceNames $name) $serviceName) -}}
    {{- end -}}
    {{- $_ := set $serviceNames $name $serviceName -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate general persistence configuration for ALL enabled services.
*/}}
{{- define "homeserver.validation.persistence.general" -}}
{{- range $serviceName, $serviceValue := .Values.services -}}
  {{- /* Handle both single service objects and arrays of services (e.g., jellyfin) */ -}}
  {{- if kindIs "slice" $serviceValue -}}
    {{- /* Service is an array - iterate over each element */ -}}
    {{- range $service := $serviceValue -}}
      {{- include "homeserver.validation.persistence.validateService" (dict "serviceName" $serviceName "service" $service) -}}
    {{- end -}}
  {{- else if kindIs "map" $serviceValue -}}
    {{- /* Service is a single object */ -}}
    {{- include "homeserver.validation.persistence.validateService" (dict "serviceName" $serviceName "service" $serviceValue) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate that soularr, lidarr, and slskd share the same storage for soulseek downloads.

This ensures all services can access the same downloaded files directory.

Input: root context ($)

Fails if:
- soularr is enabled but slskd is not
- slskd doesn't have downloads mount
- soularr doesn't have soulseek-downloads mount
- lidarr doesn't have soulseek-downloads mount
- The mounts point to different volumes

Usage:
  {{- include "homeserver.validation.soularr.sharedStorage" $ }}
*/}}
{{- define "homeserver.validation.soularr.sharedStorage" -}}
{{- $soularr := .Values.services.soularr -}}
{{- $lidarr := .Values.services.lidarr -}}
{{- $slskd := .Values.services.slskd -}}

{{- if $soularr.enabled -}}

  {{- /* Validate slskd is enabled (dependency) */ -}}
  {{- if not $slskd.enabled -}}
    {{- fail "soularr requires slskd to be enabled (soularr integrates with slskd for Soulseek downloads)" -}}
  {{- end -}}

  {{- /* Validate slskd has the downloads mount */ -}}
  {{- if not (and $slskd.persistence (hasKey $slskd.persistence "mounts")) -}}
    {{- fail "slskd.persistence.mounts is required when soularr is enabled" -}}
  {{- end -}}

  {{- if not (hasKey $slskd.persistence.mounts "downloads") -}}
    {{- fail "slskd requires a 'downloads' mount in slskd.persistence.mounts when soularr is enabled" -}}
  {{- end -}}

  {{- /* Resolve slskd's volume */ -}}
  {{- $slskdVolume := include "homeserver.validation.resolveVolumeFromMount" (dict "service" $slskd "mountName" "downloads") | fromYaml -}}
  {{- if not $slskdVolume -}}
    {{- fail "slskd's 'downloads' mount references a volume that doesn't exist in slskd.persistence.volumes" -}}
  {{- end -}}
  {{- $slskdStorage := include "homeserver.validation.getVolumeStorageId" (dict "volume" $slskdVolume "service" $slskd) -}}

  {{- /* Validate soularr has the mount */ -}}
  {{- if not (and $soularr.persistence (hasKey $soularr.persistence "mounts")) -}}
    {{- fail "soularr.persistence.mounts is required when soularr is enabled" -}}
  {{- end -}}

  {{- if not (hasKey $soularr.persistence.mounts "soulseek-downloads") -}}
    {{- fail "soularr requires a 'soulseek-downloads' mount in soularr.persistence.mounts when enabled" -}}
  {{- end -}}

  {{- /* Resolve soularr's volume */ -}}
  {{- $soularrVolume := include "homeserver.validation.resolveVolumeFromMount" (dict "service" $soularr "mountName" "soulseek-downloads") | fromYaml -}}
  {{- if not $soularrVolume -}}
    {{- fail "soularr's 'soulseek-downloads' mount references a volume that doesn't exist in soularr.persistence.volumes" -}}
  {{- end -}}

  {{- /* Compare soularr storage with slskd */ -}}
  {{- $soularrStorage := include "homeserver.validation.getVolumeStorageId" (dict "volume" $soularrVolume "service" $soularr) -}}

  {{- if ne $soularrStorage $slskdStorage -}}
    {{- $errorMsg := printf "Storage mismatch: soularr and slskd must share the same download directory.\nslskd storage: %s\nsoularr storage: %s\n\nBoth services must point to the same underlying storage (same hostPath.path, pvc.existingClaim, or nfs server:path)" $slskdStorage $soularrStorage -}}
    {{- fail $errorMsg -}}
  {{- end -}}

  {{- /* Validate lidarr if enabled */ -}}
  {{- if $lidarr.enabled -}}
    {{- if not (and $lidarr.persistence (hasKey $lidarr.persistence "mounts")) -}}
      {{- fail "lidarr.persistence.mounts is required when both lidarr and soularr are enabled" -}}
    {{- end -}}

    {{- if not (hasKey $lidarr.persistence.mounts "soulseek-downloads") -}}
      {{- fail "lidarr requires a 'soulseek-downloads' mount in lidarr.persistence.mounts when soularr is enabled" -}}
    {{- end -}}

    {{- /* Resolve lidarr's volume */ -}}
    {{- $lidarrVolume := include "homeserver.validation.resolveVolumeFromMount" (dict "service" $lidarr "mountName" "soulseek-downloads") | fromYaml -}}
    {{- if not $lidarrVolume -}}
      {{- fail "lidarr's 'soulseek-downloads' mount references a volume that doesn't exist in lidarr.persistence.volumes" -}}
    {{- end -}}

    {{- /* Compare lidarr storage with slskd */ -}}
    {{- $lidarrStorage := include "homeserver.validation.getVolumeStorageId" (dict "volume" $lidarrVolume "service" $lidarr) -}}

    {{- if ne $lidarrStorage $slskdStorage -}}
      {{- $errorMsg := printf "Storage mismatch: lidarr and slskd must share the same download directory.\nslskd storage: %s\nlidarr storage: %s\n\nBoth services must point to the same underlying storage (same hostPath.path, pvc.existingClaim, or nfs server:path)" $slskdStorage $lidarrStorage -}}
      {{- fail $errorMsg -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
{{- end -}}

{{/*
Validate that openbooks and calibre share the same storage for book ingestion.

This ensures openbooks can write books to the same directory that calibre ingests from.

Input: root context ($)

Fails if:
- openbooks is enabled but calibre is not
- calibre doesn't have ingest mount
- openbooks doesn't have calibre-ingest mount
- The mounts point to different underlying storage

Usage:
  {{- include "homeserver.validation.openbooks.sharedStorage" $ }}
*/}}
{{- define "homeserver.validation.openbooks.sharedStorage" -}}
{{- $openbooks := .Values.services.openbooks -}}
{{- $calibre := .Values.services.calibre -}}

{{- if $openbooks.enabled -}}

  {{- /* Validate calibre is enabled (dependency) */ -}}
  {{- if not $calibre.enabled -}}
    {{- fail "openbooks requires calibre to be enabled (openbooks writes books to calibre's ingest directory)" -}}
  {{- end -}}

  {{- /* Validate calibre has the ingest mount */ -}}
  {{- if not (and $calibre.persistence (hasKey $calibre.persistence "mounts")) -}}
    {{- fail "calibre.persistence.mounts is required when openbooks is enabled" -}}
  {{- end -}}

  {{- if not (hasKey $calibre.persistence.mounts "ingest") -}}
    {{- fail "calibre requires an 'ingest' mount in calibre.persistence.mounts when openbooks is enabled" -}}
  {{- end -}}

  {{- /* Resolve calibre's volume */ -}}
  {{- $calibreVolume := include "homeserver.validation.resolveVolumeFromMount" (dict "service" $calibre "mountName" "ingest") | fromYaml -}}
  {{- if not $calibreVolume -}}
    {{- fail "calibre's 'ingest' mount references a volume that doesn't exist in calibre.persistence.volumes" -}}
  {{- end -}}
  {{- $calibreStorage := include "homeserver.validation.getVolumeStorageId" (dict "volume" $calibreVolume "service" $calibre) -}}

  {{- /* Validate openbooks has the mount */ -}}
  {{- if not (and $openbooks.persistence (hasKey $openbooks.persistence "mounts")) -}}
    {{- fail "openbooks.persistence.mounts is required when openbooks is enabled" -}}
  {{- end -}}

  {{- if not (hasKey $openbooks.persistence.mounts "calibre-ingest") -}}
    {{- fail "openbooks requires a 'calibre-ingest' mount in openbooks.persistence.mounts when enabled" -}}
  {{- end -}}

  {{- /* Resolve openbooks's volume */ -}}
  {{- $openbooksVolume := include "homeserver.validation.resolveVolumeFromMount" (dict "service" $openbooks "mountName" "calibre-ingest") | fromYaml -}}
  {{- if not $openbooksVolume -}}
    {{- fail "openbooks's 'calibre-ingest' mount references a volume that doesn't exist in openbooks.persistence.volumes" -}}
  {{- end -}}

  {{- /* Compare openbooks storage with calibre */ -}}
  {{- $openbooksStorage := include "homeserver.validation.getVolumeStorageId" (dict "volume" $openbooksVolume "service" $openbooks) -}}

  {{- if ne $openbooksStorage $calibreStorage -}}
    {{- $errorMsg := printf "Storage mismatch: openbooks and calibre must share the same ingest directory.\ncalibre storage: %s\nopenbooks storage: %s\n\nBoth services must point to the same underlying storage (same hostPath.path, pvc.existingClaim, or nfs server:path)" $calibreStorage $openbooksStorage -}}
    {{- fail $errorMsg -}}
  {{- end -}}

{{- end -}}
{{- end -}}

{{/*
Validate that qbit_manage and qbittorrent share the same storage for torrent data.

This ensures qbit_manage can access qbittorrent's torrent files for management operations.

Input: root context ($)

Fails if:
- qbit_manage is enabled but qbittorrent is not
- qbittorrent doesn't have data mount
- qbit_manage doesn't have qbittorrent-data mount
- The mounts point to different underlying storage

Usage:
  {{- include "homeserver.validation.qbitManage.sharedStorage" $ }}
*/}}
{{- define "homeserver.validation.qbitManage.sharedStorage" -}}
{{- $qbitManage := .Values.services.qbit_manage -}}
{{- $qbittorrent := .Values.services.qbittorrent -}}

{{- if $qbitManage.enabled -}}

  {{- /* Validate qbittorrent is enabled (dependency) */ -}}
  {{- if not $qbittorrent.enabled -}}
    {{- fail "qbit_manage requires qbittorrent to be enabled (qbit_manage manages qbittorrent's torrents)" -}}
  {{- end -}}

  {{- /* Validate qbittorrent has the data mount */ -}}
  {{- if not (and $qbittorrent.persistence (hasKey $qbittorrent.persistence "mounts")) -}}
    {{- fail "qbittorrent.persistence.mounts is required when qbit_manage is enabled" -}}
  {{- end -}}

  {{- if not (hasKey $qbittorrent.persistence.mounts "data") -}}
    {{- fail "qbittorrent requires a 'data' mount in qbittorrent.persistence.mounts when qbit_manage is enabled" -}}
  {{- end -}}

  {{- /* Resolve qbittorrent's volume */ -}}
  {{- $qbittorrentVolume := include "homeserver.validation.resolveVolumeFromMount" (dict "service" $qbittorrent "mountName" "data") | fromYaml -}}
  {{- if not $qbittorrentVolume -}}
    {{- fail "qbittorrent's 'data' mount references a volume that doesn't exist in qbittorrent.persistence.volumes" -}}
  {{- end -}}
  {{- $qbittorrentStorage := include "homeserver.validation.getVolumeStorageId" (dict "volume" $qbittorrentVolume "service" $qbittorrent) -}}

  {{- /* Validate qbit_manage has the mount */ -}}
  {{- if not (and $qbitManage.persistence (hasKey $qbitManage.persistence "mounts")) -}}
    {{- fail "qbit_manage.persistence.mounts is required when qbit_manage is enabled" -}}
  {{- end -}}

  {{- if not (hasKey $qbitManage.persistence.mounts "qbittorrent-data") -}}
    {{- fail "qbit_manage requires a 'qbittorrent-data' mount in qbit_manage.persistence.mounts when enabled" -}}
  {{- end -}}

  {{- /* Resolve qbit_manage's volume */ -}}
  {{- $qbitManageVolume := include "homeserver.validation.resolveVolumeFromMount" (dict "service" $qbitManage "mountName" "qbittorrent-data") | fromYaml -}}
  {{- if not $qbitManageVolume -}}
    {{- fail "qbit_manage's 'qbittorrent-data' mount references a volume that doesn't exist in qbit_manage.persistence.volumes" -}}
  {{- end -}}

  {{- /* Compare qbit_manage storage with qbittorrent */ -}}
  {{- $qbitManageStorage := include "homeserver.validation.getVolumeStorageId" (dict "volume" $qbitManageVolume "service" $qbitManage) -}}

  {{- if ne $qbitManageStorage $qbittorrentStorage -}}
    {{- $errorMsg := printf "Storage mismatch: qbit_manage and qbittorrent must share the same torrent data directory.\nqbittorrent storage: %s\nqbit_manage storage: %s\n\nBoth services must point to the same underlying storage (same hostPath.path, pvc.existingClaim, or nfs server:path)" $qbittorrentStorage $qbitManageStorage -}}
    {{- fail $errorMsg -}}
  {{- end -}}

{{- end -}}
{{- end -}}

{{/*
Master validation runner.
Calls all validation helpers in sequence.

Input: root context ($)

Usage:
  {{- include "homeserver.validation.runAll" $ }}
*/}}
{{- define "homeserver.validation.runAll" -}}
{{- include "homeserver.validation.services.uniqueNames" $ -}}
{{- include "homeserver.validation.persistence.general" $ -}}
{{- include "homeserver.validation.soularr.sharedStorage" $ -}}
{{- include "homeserver.validation.openbooks.sharedStorage" $ -}}
{{- include "homeserver.validation.qbitManage.sharedStorage" $ -}}
{{- end -}}
