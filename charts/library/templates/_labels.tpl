{{/*
Kubernetes standard labels

Generic labels helper for non-service resources (gateway, certificates, etc).
Does NOT include app.kubernetes.io/name or service-specific labels.

Usage:
{{ include "homeserver.common.labels.standard" $ }}
*/}}
{{- define "homeserver.common.labels.standard" -}}
{{- $default := dict "helm.sh/chart" (include "homeserver.common.names.chart" .) "app.kubernetes.io/part-of" "homeserver" "app.kubernetes.io/instance" .Release.Name "app.kubernetes.io/managed-by" .Release.Service -}}
{{- with .Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{- $globalLabels := .Values.global.labels | default dict -}}
{{- $values := (list $globalLabels $default) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .) }}
{{- end -}}
{{- end -}}


{{/*
Kubernetes database labels

Usage:
{{ include "homeserver.common.labels.standard" ( dict "service" $service "database" "postgres" "context" $ ) -}}
*/}}
{{- define "homeserver.common.labels.database" -}}
{{- $default := dict "app.kubernetes.io/part-of" "homeserver" "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- $extraLabels := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "extraLabels") | fromYaml -}}
{{- $_ := set $default "app.kubernetes.io/name" (include "homeserver.common.names.database" (dict "service" .service "database" .database)) -}}
{{- $values := (list $extraLabels .context.Values.commonLabels $default) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .context) }}
{{- end -}}
{{- end -}}
