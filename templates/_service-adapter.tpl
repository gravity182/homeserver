{{/*
Service to Values Adapter

Transforms boilerplate service fields + cluster config + global config to homeserver-app chart values.
*/}}
{{- define "homeserver.main.service.toValues" -}}
{{- $service := .service -}}
{{- $context := .context -}}

name: {{ $service.name }}
enabled: {{ $service.enabled }}
exposed: {{ $service.exposed | default false }}
critical: {{ $service.critical | default false }}
replicaCount: {{ $service.replicaCount | default 1 }}

image:
  repository: {{ $service.image.repository }}
  tag: {{ $service.image.tag | quote }}
  pullPolicy: {{ $service.image.pullPolicy | default "IfNotPresent" }}

{{- if $service.ingress }}
hosts: {{ $service.ingress | toYaml | nindent 2 }}
{{- end }}

{{- if $service.vpn }}
vpn:
  enabled: {{ $service.vpn.enabled | default false }}
{{- end }}

{{- if $service.securityContext }}
securityContext:
  strict: {{ $service.securityContext.strict | default false }}
{{- end }}

{{- if $service.resourcesPreset }}
resourcesPreset: {{ $service.resourcesPreset }}
{{- end }}

{{- if hasKey $service "automountServiceAccountToken" }}
automountServiceAccountToken: {{ $service.automountServiceAccountToken }}
{{- end }}
{{- if hasKey $service "enableServiceLinks" }}
enableServiceLinks: {{ $service.enableServiceLinks }}
{{- end }}

{{- if $service.affinity }}
affinity: {{ $service.affinity | toYaml | nindent 2 }}
{{- end }}
{{- if $service.tolerations }}
tolerations: {{ $service.tolerations | toYaml | nindent 2 }}
{{- end }}

{{- if $service.extraEnv }}
extraEnv: {{ $service.extraEnv | toYaml | nindent 2 }}
{{- end }}
{{- if $service.extraEnvSecrets }}
extraEnvSecrets: {{ $service.extraEnvSecrets | toYaml | nindent 2 }}
{{- end }}
{{- if $service.extraEnvFromCM }}
extraEnvFromCM: {{ $service.extraEnvFromCM }}
{{- end }}
{{- if $service.extraEnvFromSecret }}
extraEnvFromSecret: {{ $service.extraEnvFromSecret }}
{{- end }}

{{- if $service.extraLabels }}
extraLabels: {{ $service.extraLabels | toYaml | nindent 2 }}
{{- end }}
{{- if $service.extraAnnotations }}
extraAnnotations: {{ $service.extraAnnotations | toYaml | nindent 2 }}
{{- end }}

{{- if $service.extraVolumes }}
extraVolumes: {{ $service.extraVolumes | toYaml | nindent 2 }}
{{- end }}
{{- if $service.extraVolumeMounts }}
extraVolumeMounts: {{ $service.extraVolumeMounts | toYaml | nindent 2 }}
{{- end }}

global:
  {{- include "homeserver.common.globals" $context | nindent 2 }}

host:
  {{- $context.Values.host | toYaml | nindent 2 }}

ingress:
  {{- $context.Values.ingress | toYaml | nindent 2 }}

resources:
  {{- $context.Values.resources | toYaml | nindent 2 }}

volumePermissions:
  {{- $context.Values.volumePermissions | toYaml | nindent 2 }}
{{- end -}}

{{/*
Service Dependencies Helper

Automatically determines HelmRelease dependencies based on service configuration.
Returns a list of dependencies that should be added to spec.dependsOn.

Logic:
- If service is exposed (has ingress) → depends on cert-manager
- If authentik is enabled and service is exposed → depends on authentik

Usage in HelmRelease:
{{- $deps := include "homeserver.main.service.dependencies" (dict "service" $service "context" $) | fromYamlArray }}
{{- if $deps }}
spec:
  dependsOn: {{ $deps | toYaml | nindent 4 }}
{{- end }}
*/}}
{{- define "homeserver.main.service.dependencies" -}}
{{- $service := .service -}}
{{- $context := .context -}}
{{- $deps := list -}}
{{- /* If service is exposed, it needs cert-manager for TLS certificates */ -}}
{{- if and $service.exposed $service.ingress -}}
{{- $deps = append $deps (dict "name" "cert-manager" "namespace" (required "cert-manager.namespace is required" (index $context.Values "cert-manager").namespace)) -}}
{{- /* If authentik is enabled, exposed services should wait for it (for SSO) */ -}}
{{- if eq $context.Values.authProvider "authentik" -}}
{{- if $context.Values.authentik.authentik.enabled -}}
{{- $deps = append $deps (dict "name" "authentik" "namespace" (required "authentik.namespace is required" $context.Values.authentik.namespace)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if $deps -}}
{{ $deps | toYaml }}
{{- end -}}
{{- end -}}
