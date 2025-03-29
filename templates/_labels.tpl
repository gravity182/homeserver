{{/*
Kubernetes standard labels

Usage:
{{ include "homeserver.common.labels.standard" ( dict "service" $service "kind" "app" "context" $ ) -}}
{{ include "homeserver.common.labels.standard" ( dict "context" $ ) -}}
Kind must be one of 'app', 'database', 'database-backup'.
*/}}
{{- define "homeserver.common.labels.standard" -}}
{{- $default := dict "helm.sh/chart" (include "homeserver.common.names.chart" .context) "app.kubernetes.io/part-of" "homeserver" "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- $extraLabels := dict -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $_ := set $default "app.kubernetes.io/name" (include "homeserver.common.names.name" (dict "service" .service "kind" .kind)) -}}
{{- if eq .kind "app" -}}
{{- $_ := set $default "homeserver/vpn" ((default dict .service.vpn).enabled | default false | ternary "true" "false") -}}
{{- end -}}
{{- $extraLabels = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraLabels") | fromYaml -}}
{{- end -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" (list $extraLabels .context.Values.commonLabels $default) "context" .context) }}
{{- end -}}

{{/*
Labels used on immutable fields such as deploy.spec.selector.matchLabels or svc.spec.selector

Usage:
{{ include "homeserver.common.labels.matchLabels" ( dict "service" $service "kind" "app" "context" $ ) -}}
Kind must be one of 'app', 'database', 'database-backup'.
*/}}
{{- define "homeserver.common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "homeserver.common.names.name" ( dict "service" .service "kind" .kind) }}
app.kubernetes.io/instance: {{ .context.Release.Name }}
{{- end -}}
