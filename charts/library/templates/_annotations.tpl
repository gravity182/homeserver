{{/*
Common Kubernetes annotations

Generic annotations helper for non-service resources (gateway, certificates, etc).

Usage:
{{ include "homeserver.common.annotations.standard" $ }}
*/}}
{{- define "homeserver.common.annotations.standard" -}}
{{- $default := dict -}}
{{- $globalAnnotations := .Values.global.annotations | default dict -}}
{{- $values := (list $globalAnnotations $default) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .) }}
{{- end -}}
{{- end -}}

