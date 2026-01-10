{{/*
App-specific Kubernetes labels

Calls common labels helper and adds service-specific labels:
- app.kubernetes.io/name
- homeserver/vpn
- extraLabels

Usage:
{{ include "homeserver.app.labels.standard" $ }}
*/}}
{{- define "homeserver.app.labels.standard" -}}
{{- $default := dict
  "app.kubernetes.io/name" (include "homeserver.common.names.name" .)
  "homeserver/vpn" ((.Values.vpn).enabled | default false | ternary "true" "false")
-}}
{{- $extraLabels := .Values.extraLabels | default dict -}}
{{- $commonLabels := include "homeserver.common.labels.standard" . | fromYaml -}}
{{- $values := (list $extraLabels $default $commonLabels) -}}
{{- if (compact $values) -}}
{{ template "homeserver.common.tplvalues.merge" (dict "values" $values "context" .) }}
{{- end -}}
{{- end -}}

{{/*
Labels used on immutable fields such as deploy.spec.selector.matchLabels or svc.spec.selector

Usage:
{{ include "homeserver.app.labels.matchLabels" $ }}
*/}}
{{- define "homeserver.app.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "homeserver.common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

