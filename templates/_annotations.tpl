{{/*
Kubernetes standard annotations

Usage:
{{ include "homeserver.common.annotations.standard" ( dict "service" $service "kind" "app" "context" $ ) -}}
{{ include "homeserver.common.annotations.standard" ( dict "context" $ ) -}}
Kind must be one of 'app', 'database', 'database-backup'.
*/}}
{{- define "homeserver.common.annotations.standard" -}}
{{- $default := dict -}}
{{- $extraAnnotations := dict -}}
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $extraAnnotations = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraAnnotations") | fromYaml -}}
{{- end -}}
{{- $values := (list $extraAnnotations .context.Values.commonAnnotations $default) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .context) }}
{{- end -}}
{{- end -}}
