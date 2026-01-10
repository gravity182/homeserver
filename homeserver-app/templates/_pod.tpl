{{/*
Pod security context

Usage:
{{ include "homeserver.app.pod.securityContext" $ }}
*/}}
{{- define "homeserver.app.pod.securityContext" -}}
fsGroup: {{ required "A valid GID required!" .Values.host.gid }}
fsGroupChangePolicy: Always
supplementalGroups: []
{{- if .Values.vpn.enabled }}
sysctls:
{{ include "homeserver.app.vpn.securityContext.sysctls" . }}
{{- else }}
sysctls: []
{{- end }}
{{- end -}}

{{/*
Pod priority class

Usage:
{{ include "homeserver.app.pod.priorityClass" $ }}
*/}}
{{- define "homeserver.app.pod.priorityClass" -}}
{{- $value := printf "%s-normal-priority" (include "homeserver.common.names.namespace" .) }}
{{- if .Values.critical }}
{{- $value = printf "%s-high-priority" (include "homeserver.common.names.namespace" .) }}
{{- end }}
{{- $value }}
{{- end -}}

{{/*
Pod init containers

Usage:
{{ include "homeserver.app.pod.initContainers" $ }}
*/}}
{{- define "homeserver.app.pod.initContainers" -}}
{{- if .Values.volumePermissions.enabled -}}
{{- $volumeNames := list -}}
{{- range .Values.volumes -}}
{{- $volumeNames = append $volumeNames .name -}}
{{- end -}}
{{- if $volumeNames -}}
{{ include "homeserver.app.initContainer.volumePermissions" (dict "volumes" ($volumeNames | uniq | sortAlpha) "context" .) }}
{{- end }}
{{- end }}
{{- if .Values.vpn.enabled -}}
{{ include "homeserver.app.vpn.sidecar" . }}
{{- end -}}
{{- end -}}

{{/*
Pod volumes

Usage:
{{ include "homeserver.app.pod.volumes" $ }}
*/}}
{{- define "homeserver.app.pod.volumes" -}}
- name: empty-dir
  emptyDir: {}
{{- if .Values.vpn.enabled }}
{{ include "homeserver.app.vpn.volumes" . }}
{{- end }}
{{- with .Values.volumes }}
{{ . | toYaml }}
{{- end }}
{{- with .Values.extraVolumes }}
{{ include "homeserver.common.tplvalues.render" (dict "value" . "context" $) }}
{{- end }}
{{- end -}}

{{/*
Pod automountServiceAccountToken

Usage:
{{ include "homeserver.app.pod.automountServiceAccountToken" $ }}
*/}}
{{- define "homeserver.app.pod.automountServiceAccountToken" -}}
{{- if hasKey .Values "automountServiceAccountToken" -}}
{{- .Values.automountServiceAccountToken -}}
{{- else -}}
{{- required ".Values.global.automountServiceAccountToken is missing" .Values.global.automountServiceAccountToken -}}
{{- end -}}
{{- end -}}

{{/*
Pod enableServiceLinks

Usage:
{{ include "homeserver.app.pod.enableServiceLinks" $ }}
*/}}
{{- define "homeserver.app.pod.enableServiceLinks" -}}
{{- if hasKey .Values "enableServiceLinks" -}}
{{- .Values.enableServiceLinks -}}
{{- else -}}
{{- required ".Values.global.enableServiceLinks is missing" .Values.global.enableServiceLinks -}}
{{- end -}}
{{- end -}}

{{/*
Pod affinity

Usage:
{{ include "homeserver.app.pod.affinity" $ }}
*/}}
{{- define "homeserver.app.pod.affinity" -}}
{{- $value := .Values.affinity | default .Values.global.affinity -}}
{{- if $value }}
{{- include "homeserver.common.tplvalues.render" (dict "value" $value "context" .) }}
{{- end }}
{{- end -}}

{{/*
Pod tolerations

Usage:
{{ include "homeserver.app.pod.tolerations" $ }}
*/}}
{{- define "homeserver.app.pod.tolerations" -}}
{{- $value := .Values.tolerations | default .Values.global.tolerations -}}
{{- if $value }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $value "context" .) }}
{{- end }}
{{- end -}}
