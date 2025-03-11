{{/*
Security context for pods.
Usage:
{{ include "homeserver.common.pod.securityContext" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "homeserver.common.pod.securityContext" -}}
fsGroup: {{ required "A valid GID required!" .context.Values.host.gid }}
fsGroupChangePolicy: Always
supplementalGroups: []
{{- if and (.service.vpn.enabled) (eq .kind "app") }}
sysctls:
{{ include "homeserver.common.vpn.securityContext.sysctls" .context }}
{{- else }}
sysctls: []
{{- end }}
{{- end -}}

{{/*
Priority class for pods.
Usage:
{{ include "homeserver.common.pod.priorityClass" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "homeserver.common.pod.priorityClass" -}}
{{- if .service.critical }}
{{- printf "%s-high-priority" (include "homeserver.common.names.namespace" .context) }}
{{- else }}
{{- printf "%s-normal-priority" (include "homeserver.common.names.namespace" .context) }}
{{- end }}
{{- end -}}

{{/*
Init containers for pods.
Usage:
{{ include "homeserver.common.pod.initContainers" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "homeserver.common.pod.initContainers" -}}
{{- if .context.Values.volumePermissions.enabled -}}
{{- $persistence := include "homeserver.common.utils.getPersistence" (dict "service" .service "kind" .kind) | fromYaml -}}
{{- if $persistence -}}
{{ include "homeserver.common.initContainer.volumePermissions" (dict "volumes" (keys $persistence | uniq | sortAlpha) "context" .context) }}
{{- end }}
{{- end }}
{{- if and (.service.vpn.enabled) (eq .kind "app") -}}
{{ include "homeserver.common.vpn.sidecar" .context }}
{{- end -}}
{{- end -}}

{{/*
Volumes for pods.
Usage:
{{ include "homeserver.common.pod.volumes" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "homeserver.common.pod.volumes" -}}
- name: empty-dir
  emptyDir: {}
{{- if and (.service.vpn.enabled) (eq .kind "app") }}
{{ include "homeserver.common.vpn.volumes" .context }}
{{- end }}
{{- $extraVolumes := include "homeserver.common.utils.getExtraVolumes" (dict "service" .service "kind" .kind) -}}
{{- if $extraVolumes }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $extraVolumes "context" .context) }}
{{- end }}
{{- end -}}

{{/* Get a automountServiceAccountToken value for pods.
Usage:
{{ include "homeserver.common.pod.automountServiceAccountToken" (dict "service" $service "kind" "app" "context" $) }}
{{ include "homeserver.common.pod.automountServiceAccountToken" (dict "context" $) }}
*/}}
{{- define "homeserver.common.pod.automountServiceAccountToken" -}}
{{- $value := required ".Values.automountServiceAccountToken is missing" .context.Values.automountServiceAccountToken -}}
{{- $valueOverride := "" -}}
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $valueOverride = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "automountServiceAccountToken") -}}
{{- end -}}
{{- default $value $valueOverride -}}
{{- end -}}

{{/* Get a enableServiceLinks value for pods.
Usage:
{{ include "homeserver.common.pod.enableServiceLinks" (dict "service" $service "kind" "app" "context" $) }}
{{ include "homeserver.common.pod.enableServiceLinks" (dict "context" $) }}
*/}}
{{- define "homeserver.common.pod.enableServiceLinks" -}}
{{- $value := required ".Values.enableServiceLinks is missing" .context.Values.enableServiceLinks -}}
{{- $valueOverride := "" -}}
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $valueOverride = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "enableServiceLinks") -}}
{{- end -}}
{{- default $value $valueOverride -}}
{{- end -}}
