{{/*
Kubernetes standard annotations

Usage:
{{ include "homeserver.common.annotations.standard" ( dict "service" $service "context" $ ) -}}
{{ include "homeserver.common.annotations.standard" ( dict "context" $ ) -}}
*/}}
{{- define "homeserver.common.annotations.standard" -}}
{{- $default := dict -}}
{{- $extraAnnotations := dict -}}
{{- if (hasKey . "service") -}}
{{- $extraAnnotations = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "extraAnnotations") | fromYaml -}}
{{- end -}}
{{- $values := (list $extraAnnotations .context.Values.commonAnnotations $default) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Kubernetes database annotations

Usage:
{{ include "homeserver.common.annotations.database" ( dict "service" $service "database" "postgres" "context" $ ) -}}
*/}}
{{- define "homeserver.common.annotations.database" -}}
{{- $default := dict -}}
{{- $extraAnnotations := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "extraAnnotations") | fromYaml -}}
{{- $values := (list $extraAnnotations .context.Values.commonAnnotations $default) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .context) }}
{{- end -}}
{{- end -}}
