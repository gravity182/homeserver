{{/*
Kubernetes standard labels

Usage:
{{ include "homeserver.common.labels.standard" ( dict "service" $service "context" $ ) -}}
{{ include "homeserver.common.labels.standard" ( dict "context" $ ) -}}
*/}}
{{- define "homeserver.common.labels.standard" -}}
{{- $default := dict "helm.sh/chart" (include "homeserver.common.names.chart" .context) "app.kubernetes.io/part-of" "homeserver" "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- $extraLabels := dict -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{- if (hasKey . "service") -}}
{{- $_ := set $default "app.kubernetes.io/name" (include "homeserver.common.names.name" (dict "service" .service)) -}}
{{- $_ := set $default "homeserver/vpn" ((default dict .service.vpn).enabled | default false | ternary "true" "false") -}}
{{- $extraLabels = include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "extraLabels") | fromYaml -}}
{{- end -}}
{{- $values := (list $extraLabels .context.Values.commonLabels $default) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Labels used on immutable fields such as deploy.spec.selector.matchLabels or svc.spec.selector

Usage:
{{ include "homeserver.common.labels.matchLabels" ( dict "service" $service "context" $ ) -}}
*/}}
{{- define "homeserver.common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "homeserver.common.names.name" ( dict "service" .service) }}
app.kubernetes.io/instance: {{ .context.Release.Name }}
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
