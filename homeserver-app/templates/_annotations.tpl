{{/*
App-specific annotations

Usage:
{{ include "homeserver.app.annotations.standard" $ }}
*/}}
{{- define "homeserver.app.annotations.standard" -}}
{{- $default := dict -}}
{{- $extraAnnotations := .Values.extraAnnotations | default dict -}}
{{- $commonAnnotations := include "homeserver.common.annotations.standard" . | fromYaml -}}
{{- $values := (list $extraAnnotations $default $commonAnnotations) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .) }}
{{- end -}}
{{- end -}}

