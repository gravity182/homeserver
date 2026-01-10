{{/*
Container security context

Usage:
{{ include "homeserver.app.container.securityContext" $ }}
*/}}
{{- define "homeserver.app.container.securityContext" -}}
{{- if .Values.securityContext.strict }}
{{ include "homeserver.common.securityContext.strict" . }}
{{- else }}
{{ include "homeserver.common.securityContext.lenient" . }}
{{- end }}
{{- end -}}

{{/*
Container resources

Usage:
{{ include "homeserver.app.container.resources" $ }}
*/}}
{{- define "homeserver.app.container.resources" -}}
{{- if .Values.resources.enabled -}}
{{- $preset := .Values.resourcesPreset -}}
{{- if not $preset -}}
{{- printf "Resources preset is missing" | fail -}}
{{- end -}}
{{- if not (eq $preset "none") -}}
{{ include "homeserver.common.resources.preset" (dict "type" $preset) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Container envFrom

Usage:
{{ include "homeserver.app.container.envFrom" $ }}
*/}}
{{- define "homeserver.app.container.envFrom" -}}
{{- $extraEnvFromCM := .Values.extraEnvFromCM | default "" -}}
{{- $extraEnvFromSecret := .Values.extraEnvFromSecret | default "" -}}
{{- if $extraEnvFromCM }}
- configMapRef:
    name: {{ $extraEnvFromCM | quote }}
    optional: false
{{- end }}
{{- if $extraEnvFromSecret }}
- secretRef:
    name: {{ $extraEnvFromSecret | quote }}
    optional: false
{{- end }}
{{- end -}}

{{/*
Container environment variables

Usage:
{{ include "homeserver.app.container.env" $ }}
*/}}
{{- define "homeserver.app.container.env" -}}
- name: TZ
  value: {{ required "A valid timezone required!" .Values.host.tz | quote }}
- name: KUBERNETES_POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
{{- $extraEnv := .Values.extraEnv | default list -}}
{{- $extraEnvSecrets := .Values.extraEnvSecrets | default list -}}
{{- range $extraEnv }}
- name: {{ .name | quote }}
  value: {{ include "homeserver.common.tplvalues.render" (dict "value" .value "context" $) | quote }}
{{- end }}
{{- range $extraEnvSecrets }}
- name: {{ .name | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ .secretName | quote }}
      key: {{ .secretKey | quote }}
      optional: false
{{- end }}
{{- end -}}

{{/*
Container volume mounts

Usage:
{{ include "homeserver.app.container.volumeMounts" $ }}
*/}}
{{- define "homeserver.app.container.volumeMounts" -}}
- name: empty-dir
  mountPath: /tmp
  subPath: tmp-dir
- name: empty-dir
  mountPath: /log
  subPath: log-dir
{{- $extraVolumeMounts := .Values.extraVolumeMounts | default list -}}
{{- if $extraVolumeMounts }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $extraVolumeMounts "context" .) }}
{{- end }}
{{- end -}}

{{/*
Liveness probe

Usage:
{{ include "homeserver.app.container.livenessProbe" $ }}
*/}}
{{- define "homeserver.app.container.livenessProbe" -}}
{{- $probe := .Values.livenessProbe -}}
{{- if $probe -}}
{{- $spec := $probe.spec | default .Values.global.livenessProbe -}}
{{- if $spec.enabled -}}
{{- if eq $probe.type "http" }}
httpGet:
  path: {{ $probe.path }}
  port: {{ $probe.port | default "http" }}
{{- else if eq $probe.type "tcp" }}
tcpSocket:
  port: {{ $probe.port }}
{{- else if eq $probe.type "exec" }}
exec:
  command: {{- $probe.command | toYaml | nindent 4 }}
{{- end }}
{{- $spec := omit $spec "enabled" }}
{{ $spec | toYaml }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Readiness probe

Usage:
{{ include "homeserver.app.container.readinessProbe" $ }}
*/}}
{{- define "homeserver.app.container.readinessProbe" -}}
{{- $probe := .Values.readinessProbe -}}
{{- if $probe -}}
{{- $spec := $probe.spec | default .Values.global.readinessProbe -}}
{{- if $spec.enabled -}}
{{- if eq $probe.type "http" }}
httpGet:
  path: {{ $probe.path }}
  port: {{ $probe.port | default "http" }}
{{- else if eq $probe.type "tcp" }}
tcpSocket:
  port: {{ $probe.port }}
{{- else if eq $probe.type "exec" }}
exec:
  command: {{- $probe.command | toYaml | nindent 4 }}
{{- end }}
{{- $spec := omit $spec "enabled" }}
{{ $spec | toYaml }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Startup probe

Usage:
{{ include "homeserver.app.container.startupProbe" $ }}
*/}}
{{- define "homeserver.app.container.startupProbe" -}}
{{- $probe := .Values.startupProbe -}}
{{- if $probe -}}
{{- $spec := $probe.spec | default .Values.global.startupProbe -}}
{{- if $spec.enabled -}}
{{- if eq $probe.type "http" }}
httpGet:
  path: {{ $probe.path }}
  port: {{ $probe.port | default "http" }}
{{- else if eq $probe.type "tcp" }}
tcpSocket:
  port: {{ $probe.port }}
{{- else if eq $probe.type "exec" }}
exec:
  command: {{- $probe.command | toYaml | nindent 4 }}
{{- end }}
{{- $spec := omit $spec "enabled" }}
{{ $spec | toYaml }}
{{- end -}}
{{- end -}}
{{- end -}}
