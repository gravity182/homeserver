{{/*
Expand the name of the service.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).

Usage:
{{ include "homeserver.common.names.name" ( dict "service" $service "kind" "app") }}
Kind must be one of 'app', 'database', 'database-backup'.
*/}}
{{- define "homeserver.common.names.name" -}}
{{- if eq .kind "app" -}}
{{- .service.name | trunc 63 | trimSuffix "-" -}}
{{- else if eq .kind "database" -}}
{{- printf "%s-database" .service.name | trunc 63 | trimSuffix "-" -}}
{{- else if eq .kind "database-backup" -}}
{{- printf "%s-database-backup" .service.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "Unknown kind of %s" .kind | fail -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "homeserver.common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create namespace.
*/}}
{{- define "homeserver.common.names.namespace" -}}
{{- .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create cert-manager namespace.
*/}}
{{- define "homeserver.names.cert-manager-namespace" -}}
{{- (index .Values "cert-manager").namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create authentik namespace.
*/}}
{{- define "homeserver.names.authentik-namespace" -}}
{{- .Values.authentik.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
