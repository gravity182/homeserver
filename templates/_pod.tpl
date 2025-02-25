{{/*
Security context for pods.
Usage:
{{ include "common.pod.securityContext" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "common.pod.securityContext" -}}
fsGroup: {{ required "A valid GID required!" .context.Values.host.gid }}
fsGroupChangePolicy: Always
supplementalGroups: []
{{- if and (.service.vpn.enabled) (eq .kind "app") }}
sysctls:
{{ include "common.vpn.securityContext.sysctls" .context }}
{{- else }}
sysctls: []
{{- end }}
{{- end -}}

{{/*
Priority class for pods.
Usage:
{{ include "common.pod.priorityClass" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "common.pod.priorityClass" -}}
{{- if .service.critical }}
{{- printf "%s-high-priority" (include "common.names.namespace" .context) }}
{{- else }}
{{- printf "%s-normal-priority" (include "common.names.namespace" .context) }}
{{- end }}
{{- end -}}

{{/*
Init containers for pods.
Usage:
{{ include "common.pod.initContainers" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "common.pod.initContainers" -}}
{{- if and (.service.vpn.enabled) (eq .kind "app") }}
{{ include "common.vpn.sidecar" .context }}
{{- end }}
{{- end -}}

{{/*
Volumes for pods.
Usage:
{{ include "common.pod.volumes" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "common.pod.volumes" -}}
- name: empty-dir
  emptyDir: {}
{{- if and (.service.vpn.enabled) (eq .kind "app") }}
{{ include "common.vpn.volumes" .context }}
{{- end }}
{{- $extraVolumes := include "common.utils.getExtraVolumes" (dict "service" .service "kind" .kind) -}}
{{- if $extraVolumes }}
{{ include "common.tplvalues.render" (dict "value" $extraVolumes "context" .context) }}
{{- end }}
{{- end -}}
