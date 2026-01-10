{{/*
Render Kubernetes volume spec from volume config.

Input: dict with key:
  - service: service object
  - volume: volume configuration object

Notes:
- For hostPath, default type is DirectoryOrCreate unless overridden

Usage:
  {{- include "homeserver.common.persistence.volume" (dict "service" $service "volume" $volume) }}
*/}}
{{- define "homeserver.common.persistence.volume" }}
{{- $service := .service }}
{{- $config := .volume }}
{{- $name := required "volume.name is required" $config.name }}

{{- if hasKey $config "hostPath" }}
{{- $hostPath := required (printf "Volume %s: hostPath.path is required" $name) $config.hostPath.path }}
{{- if not (hasPrefix "/" $hostPath) }}
  {{- fail (printf "Volume %s: hostPath.path must be an absolute path (must start with /), got: %s" $name $hostPath) }}
{{- end }}
{{- $validTypes := list "DirectoryOrCreate" "Directory" "FileOrCreate" "File" "Socket" "CharDevice" "BlockDevice" }}
{{- $hostPathType := $config.hostPath.type | default "DirectoryOrCreate" }}
{{- if not (has $hostPathType $validTypes) }}
  {{- fail (printf "Volume %s: hostPath.type must be one of: %s, got: %s" $name (join ", " $validTypes) $hostPathType) }}
{{- end }}
hostPath:
  path: {{ $hostPath | quote }}
  type: {{ $hostPathType | quote }}

{{- else if hasKey $config "pvc" }}
{{- if and (not $config.pvc.existingClaim) (not $config.pvc.size) }}
  {{- fail (printf "Volume %s: pvc.size is required for managed PVCs (or specify pvc.existingClaim to use an existing PVC)" $name) }}
{{- end }}
persistentVolumeClaim:
  {{- if $config.pvc.existingClaim }}
  claimName: {{ required (printf "Volume %s: pvc.existingClaim is required" $name) $config.pvc.existingClaim | quote }}
  {{- else }}
  claimName: {{ include "homeserver.persistence.pvcName" (dict "service" $service "name" $name) | quote }}
  {{- end }}

{{- else if hasKey $config "nfs" }}
{{- $nfsPath := required (printf "Volume %s: nfs.path is required" $name) $config.nfs.path }}
{{- if not (hasPrefix "/" $nfsPath) }}
  {{- fail (printf "Volume %s: nfs.path must be an absolute path (must start with /), got: %s" $name $nfsPath) }}
{{- end }}
nfs:
  server: {{ required (printf "Volume %s: nfs.server is required" $name) $config.nfs.server | quote }}
  path: {{ $nfsPath | quote }}
  {{- if hasKey $config.nfs "readOnly" }}
  readOnly: {{ $config.nfs.readOnly }}
  {{- end }}

{{- else if hasKey $config "emptyDir" }}
{{- $medium := $config.emptyDir.medium | default "" }}
{{- $sizeLimit := $config.emptyDir.sizeLimit | default "" }}
{{- if and (ne $medium "") (ne $medium "Memory") (not (hasPrefix "HugePages-" $medium)) }}
  {{- fail (printf "Volume %s: emptyDir.medium must be one of: \"\" (default/disk), \"Memory\", or \"HugePages-<size>\", got: %s" $name $medium) }}
{{- end }}
emptyDir:
{{- if ne $medium "" }}
  medium: {{ $medium | quote }}
{{- end }}
{{- if ne $sizeLimit "" }}
  sizeLimit: {{ $sizeLimit | quote }}
{{- end }}

{{- else }}
  {{- fail (printf "Volume %s must specify one of: hostPath, pvc, nfs, emptyDir" $name) }}
{{- end }}
{{- end }}

{{/*
Convert persistence mount config to Kubernetes volume mount spec.

Input: dict with keys:
  - service: service object
  - name: mount name (key in persistence.mounts)
  - mountPath: container mount path

Usage:
  {{- include "homeserver.common.persistence.volumeMount" (dict "service" $service "name" "config" "mountPath" "/app") }}
*/}}
{{- define "homeserver.common.persistence.volumeMount" }}
{{- $service := .service }}
{{- $mountName := .name }}
{{- $mountPath := .mountPath }}

{{- if not (and $service.persistence (hasKey $service.persistence "mounts")) }}
  {{- fail (printf "%s.persistence.mounts is required" $service.name) }}
{{- end }}

{{- $mount := index $service.persistence.mounts $mountName }}
{{- if not $mount }}
  {{- fail (printf "Mount '%s' not found in %s.persistence.mounts" $mountName $service.name) }}
{{- end }}

- name: {{ required (printf "Volume name %s.volume is required" $mountName) $mount.volume | quote }}
  mountPath: {{ $mountPath | quote }}
  {{- $subPath := $mount.subPath | default "" }}
  {{- if ne $subPath "" }}
  {{- if hasPrefix "/" $subPath }}
    {{- fail (printf "Mount '%s': subPath must be a relative path (must NOT start with /), got: %s" $mountName $subPath) }}
  {{- end }}
  {{- if contains ".." $subPath }}
    {{- fail (printf "Mount '%s': subPath must not contain '..' (path traversal not allowed), got: %s" $mountName $subPath) }}
  {{- end }}
  subPath: {{ $subPath | quote }}
  {{- end }}
  {{- if hasKey $mount "readOnly" }}
  readOnly: {{ $mount.readOnly }}
  {{- end }}
{{- end }}

{{/*
Render a PVC manifest.

Renders nothing if pvc.existingClaim is set.

Input: dict with keys:
  - service: service object (for PVC naming)
  - volume: volume config with "name" and "pvc" keys
  - context: root context ($)

Usage: {{ include "homeserver.persistence.pvcManifest" (dict "service" $service "volume" $volume "context" $) }}
*/}}
{{- define "homeserver.persistence.pvcManifest" }}
{{- $service := .service }}
{{- $volume := .volume }}
{{- $name := required "volume.name is required" $volume.name }}
{{- $pvc := required "volume.pvc is required" $volume.pvc }}

{{- if $pvc.existingClaim -}}
{{- else -}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "homeserver.persistence.pvcName" (dict "service" $service "name" $name) | quote }}
  namespace: {{ include "homeserver.common.names.namespace" .context | quote }}
  labels: {{- include "homeserver.common.labels.standard" (dict "context" .context) | nindent 4 }}
  annotations: {{- include "homeserver.common.annotations.standard" (dict "context" .context) | nindent 4 }}
    # CRITICAL: Prevent Helm from deleting PVC when service is disabled or chart is uninstalled
    # This protects against accidental data loss
    helm.sh/resource-policy: keep
spec:
  accessModes:
  {{- if $pvc.accessModes }}
{{ toYaml $pvc.accessModes | nindent 4 }}
  {{- else }}
  - ReadWriteOnce
  {{- end }}
  resources:
    requests:
      storage: {{ required (printf "PVC size is required: service=%s, volume=%s" $service.name $name) $pvc.size | quote }}
  {{- $storageClassName := $pvc.storageClassName | default "" }}
  {{- if ne $storageClassName "" }}
  storageClassName: {{ $storageClassName | quote }}
  {{- end }}
  {{- $volumeMode := $pvc.volumeMode | default "" }}
  {{- if ne $volumeMode "" }}
  volumeMode: {{ $volumeMode | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Generate PVC name from service and volume name.

Input: dict with keys:
  - service: service object
  - name: volume name

Output: {{ service.name }}-{{ volumeName }}-pvc

Examples:
  - qbittorrent-config-pvc
  - qbittorrent-data-pvc
  - radarr-config-pvc

Usage:
  {{ include "homeserver.persistence.pvcName" (dict "service" $service "name" "config") }}
*/}}
{{- define "homeserver.persistence.pvcName" }}
{{- printf "%s-%s-pvc" .service.name .name -}}
{{- end -}}
