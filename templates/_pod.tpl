{{/*
Security context for pods.
Usage:
{{ include "homeserver.common.pod.securityContext" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.common.pod.securityContext" -}}
fsGroup: {{ required "A valid GID required!" .context.Values.host.gid }}
fsGroupChangePolicy: Always
supplementalGroups: []
{{- if (default dict .service.vpn).enabled }}
sysctls:
{{ include "homeserver.common.vpn.securityContext.sysctls" .context }}
{{- else }}
sysctls: []
{{- end }}
{{- end -}}

{{/*
Priority class for pods.
Usage:
{{ include "homeserver.common.pod.priorityClass" (dict "service" $service "context" $) }}
{{ include "homeserver.common.pod.priorityClass" (dict "context" $) }}
*/}}
{{- define "homeserver.common.pod.priorityClass" -}}
{{- $value := printf "%s-normal-priority" (include "homeserver.common.names.namespace" .context) }}
{{- if and (hasKey . "service") (eq .service.critical true) }}
{{- $value = printf "%s-high-priority" (include "homeserver.common.names.namespace" .context) }}
{{- end }}
{{- $value }}
{{- end -}}

{{/*
Init containers for pods.
Usage:
{{ include "homeserver.common.pod.initContainers" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.common.pod.initContainers" -}}
{{- if .context.Values.volumePermissions.enabled -}}
{{- $persistence := include "homeserver.common.utils.getPersistence" (dict "service" .service) | fromYaml -}}
{{- if $persistence -}}
{{ include "homeserver.common.initContainer.volumePermissions" (dict "volumes" (keys $persistence | uniq | sortAlpha) "context" .context) }}
{{- end }}
{{- end }}
{{- if (default dict .service.vpn).enabled -}}
{{ include "homeserver.common.vpn.sidecar" (dict "service" .service "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Volumes for pods.
Usage:
{{ include "homeserver.common.pod.volumes" (dict "service" $service "context" $) }}
{{ include "homeserver.common.pod.volumes" (dict "context" $) }}
*/}}
{{- define "homeserver.common.pod.volumes" -}}
- name: empty-dir
  emptyDir: {}
{{- if (hasKey . "service") -}}
{{- $service := .service -}}
{{- /* VPN volumes */ -}}
{{- if (default dict .service.vpn).enabled }}
{{ include "homeserver.common.vpn.volumes" (dict "service" .service "context" .context) }}
{{- end }}
{{- /* Persistence volumes */ -}}
{{- if and $service.persistence (hasKey $service.persistence "volumes") }}
{{- range $service.persistence.volumes }}
- name: {{ .name | quote }}
  {{- include "homeserver.common.persistence.volume" (dict "service" $service "volume" .) | nindent 2 }}
{{- end }}
{{- end }}
{{- /* Extra volumes */ -}}
{{- $extraVolumes := include "homeserver.common.utils.getExtraVolumes" (dict "service" .service) -}}
{{- if $extraVolumes }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $extraVolumes "context" .context) }}
{{- end }}
{{- end }}
{{- end -}}

{{/* Get a automountServiceAccountToken value for pods.
Usage:
{{ include "homeserver.common.pod.automountServiceAccountToken" (dict "service" $service "context" $) }}
{{ include "homeserver.common.pod.automountServiceAccountToken" (dict "context" $) }}
*/}}
{{- define "homeserver.common.pod.automountServiceAccountToken" -}}
{{- $value := required ".Values.automountServiceAccountToken is missing" .context.Values.automountServiceAccountToken -}}
{{- $valueOverride := "" -}}
{{- if (hasKey . "service") -}}
{{- $valueOverride = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "automountServiceAccountToken") -}}
{{- end -}}
{{- default $value $valueOverride -}}
{{- end -}}

{{/* Get a enableServiceLinks value for pods.
Usage:
{{ include "homeserver.common.pod.enableServiceLinks" (dict "service" $service "context" $) }}
{{ include "homeserver.common.pod.enableServiceLinks" (dict "context" $) }}
*/}}
{{- define "homeserver.common.pod.enableServiceLinks" -}}
{{- $value := required ".Values.enableServiceLinks is missing" .context.Values.enableServiceLinks -}}
{{- $valueOverride := "" -}}
{{- if (hasKey . "service") -}}
{{- $valueOverride = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "enableServiceLinks") -}}
{{- end -}}
{{- default $value $valueOverride -}}
{{- end -}}

{{/* Get affinity configuration for pods.

Usage:
{{ include "homeserver.common.pod.affinity" (dict "service" $service "context" $) }}
{{ include "homeserver.common.pod.affinity" (dict "context" $) }}
*/}}
{{- define "homeserver.common.pod.affinity" -}}
{{- $value := default dict .context.Values.affinity -}}
{{- $valueOverride := dict -}}
{{- if (hasKey . "service") -}}
{{- $valueOverride = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "affinity") | fromYaml -}}
{{- end -}}
{{- if (hasKey . "customAffinity") -}}
{{- $valueOverride = .customAffinity -}}
{{- end -}}
{{- if (default $value $valueOverride) }}
{{- include "homeserver.common.tplvalues.render" (dict "value" (default $value $valueOverride) "context" .context) }}
{{- end }}
{{- end -}}

{{/* Get tolerations configuration for pods.

Usage:
{{ include "homeserver.common.pod.tolerations" (dict "service" $service "context" $) }}
{{ include "homeserver.common.pod.tolerations" (dict "context" $) }}
*/}}
{{- define "homeserver.common.pod.tolerations" -}}
{{- $value := default (list) .context.Values.tolerations -}}
{{- $valueOverride := (list) -}}
{{- if (hasKey . "service") -}}
{{- $valueOverride = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "tolerations") | fromYamlArray -}}
{{- end -}}
{{- if (default $value $valueOverride) }}
{{ include "homeserver.common.tplvalues.render" (dict "value" (default $value $valueOverride) "context" .context) }}
{{- end }}
{{- end -}}

{{/*
Pod security context for bjw-s format.
Usage:
{{ include "homeserver.pod.securityContext.bjws" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.pod.securityContext.bjws" -}}
runAsNonRoot: true
runAsUser: 1001
runAsGroup: 1001
fsGroup: 1001
fsGroupChangePolicy: Always
supplementalGroups: []
{{- if (default dict .service.vpn).enabled }}
sysctls: {{- include "homeserver.vpn.sysctls.bjws" (dict "service" .service "context" .context) | nindent 2 }}
{{- else }}
sysctls: []
{{- end }}
{{- end -}}

{{/*
Init containers for bjw-s format (volumePermissions only, VPN is a sidecar container).
Usage:
{{ include "homeserver.pod.initContainers.bjws" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.pod.initContainers.bjws" -}}
{{- if .context.Values.volumePermissions.enabled -}}
volume-permissions:
  image:
    repository: busybox
    tag: latest
    pullPolicy: IfNotPresent
  command:
    - /bin/sh
    - -c
    - chown -R 1001:1001 /config
  securityContext:
    runAsUser: 0
    runAsNonRoot: false
  resources: {{- include "homeserver.common.resources.preset" (dict "type" "2xnano") | nindent 4 }}
{{- end -}}
{{- end -}}

{{/*
All persistence entries for bjw-s format (empty-dir, app mounts, VPN, extraVolumes).

Input: dict with keys:
  - service: service object
  - mounts: list of mount definitions (name + path)
  - context: root context ($)

Usage:
{{ include "homeserver.persistence.bjws" (dict "service" $service "mounts" $mounts "context" $) }}
*/}}
{{- define "homeserver.persistence.bjws" -}}
empty-dir:
  type: emptyDir
  globalMounts:
    - path: /tmp
      subPath: tmp-dir
    - path: /log
      subPath: log-dir
{{ include "homeserver.persistence.toBjwsFormat" (dict "service" .service "mounts" .mounts) }}
{{- if .service.vpn.enabled }}
{{ include "homeserver.vpn.persistence.bjws" (dict "service" .service "context" .context) }}
{{- end }}
{{- $extraVolumes := include "homeserver.common.utils.getExtraVolumes" (dict "service" .service) -}}
{{- if $extraVolumes }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $extraVolumes "context" .context) }}
{{- end -}}
{{- end -}}
