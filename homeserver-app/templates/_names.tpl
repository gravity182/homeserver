{{/*
Expand the name of the service.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).

Usage:
{{ include "homeserver.common.names.name" $ }}
*/}}
{{- define "homeserver.common.names.name" -}}
{{- .Values.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the service's database.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).

Usage:
{{ include "homeserver.common.names.database" (dict "name" .Values.name "database" "postgres") }}
*/}}
{{- define "homeserver.common.names.database" -}}
{{- printf "%s-%s" .name .database | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "homeserver.common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart namespace.
*/}}
{{- define "homeserver.common.names.namespace" -}}
{{- .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}
