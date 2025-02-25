{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).

Usage:
{{ include "common.names.name" ( dict "service" $service "kind" "app") }}
Kind must be one of 'app', 'database', 'database-backup'.
*/}}
{{- define "common.names.name" -}}
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
{{- define "common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create namespace.
*/}}
{{- define "common.names.namespace" -}}
{{- .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}
