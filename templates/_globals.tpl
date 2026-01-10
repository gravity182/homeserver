{{/*
Global values to pass to homeserver-app chart via HelmRelease.
These are values that all apps need access to.

Usage:
global: {{ include "homeserver.common.globals" $ | nindent 2 }}
*/}}
{{- define "homeserver.common.globals" -}}
{{- $global := .Values.global -}}
host: {{ .Values.host | toYaml | nindent 2 }}
ingress:
  domain: {{ .Values.ingress.domain }}
  rootService: {{ .Values.ingress.rootService | default "" }}
automountServiceAccountToken: {{ $global.automountServiceAccountToken }}
enableServiceLinks: {{ $global.enableServiceLinks }}
livenessProbe: {{ $global.livenessProbe | toYaml | nindent 2 }}
readinessProbe: {{ $global.readinessProbe | toYaml | nindent 2 }}
startupProbe: {{ $global.startupProbe | toYaml | nindent 2 }}
affinity: {{ $global.affinity | default dict | toYaml | nindent 2 }}
tolerations: {{ $global.tolerations | default list | toYaml | nindent 2 }}
labels: {{ $global.labels | default dict | toYaml | nindent 2 }}
annotations: {{ $global.annotations | default dict | toYaml | nindent 2 }}
volumePermissions: {{ .Values.volumePermissions | toYaml | nindent 2 }}
resources: {{ .Values.resources | toYaml | nindent 2 }}
vpn: {{ $global.vpn | toYaml | nindent 2 }}
{{- end -}}
