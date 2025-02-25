{{/*
Kubernetes standard labels

Usage:
{{ include "common.labels.standard" ( dict "service" $service "kind" "app" "context" $ ) -}}
{{ include "common.labels.standard" ( dict "context" $ ) -}}
Kind must be one of 'app', 'database', 'database-backup'.
*/}}
{{- define "common.labels.standard" -}}
{{- $extraLabels := dict -}}
{{- $default := dict "helm.sh/chart" (include "common.names.chart" .context) "app.kubernetes.io/part-of" "homeserver" "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $_ := set $default "app.kubernetes.io/name" (include "common.names.name" (dict "service" .service "kind" .kind)) -}}
{{- if eq .kind "app" -}}
{{- $_ := set $default "homeserver/vpn" ( .service.vpn.enabled | default false | ternary "true" "false" ) -}}
{{- end -}}
{{- $extraLabels = include "common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraLabels") | fromYaml -}}
{{- end -}}
{{ template "common.tplvalues.merge" (dict "values" (list $extraLabels .context.Values.commonLabels $default) "context" .context) }}
{{- end -}}

{{/*
Labels used on immutable fields such as deploy.spec.selector.matchLabels or svc.spec.selector

Usage:
{{ include "common.labels.matchLabels" ( dict "service" $service "kind" "app" "context" $ ) -}}
Kind must be one of 'app', 'database', 'database-backup'.
*/}}
{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" ( dict "service" .service "kind" .kind) }}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- end -}}
