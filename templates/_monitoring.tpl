{{/*
Returns monitoring namespace.
*/}}
{{- define "homeserver.monitoring.names.namespace" -}}
{{- default "monitoring" .Values.monitoring.namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}
