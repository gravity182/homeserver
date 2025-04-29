{{/*
Security context for containers.
Usage:
{{ include "homeserver.common.container.securityContext" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "homeserver.common.container.securityContext" -}}
{{- if (include "homeserver.common.utils.getSecurityContext" (dict "service" .service "kind" .kind) | fromYaml).strict }}
{{ include "homeserver.common.securityContext.strict" .context }}
{{- else }}
{{ include "homeserver.common.securityContext.lenient" .context }}
{{- end }}
{{- end -}}

{{/* Resources for containers.
Usage:
{{ include "homeserver.common.container.resources" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "homeserver.common.container.resources" -}}
{{- if .context.Values.resources.enabled -}}
{{- $preset := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "resourcesPreset") -}}
{{- if not $preset -}}
{{- printf "Resources preset is missing" | fail -}}
{{- end -}}
{{- if not (eq $preset "none") -}}
{{ include "homeserver.common.resources.preset" (dict "type" $preset) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Env from for containers.
Usage:
{{ include "homeserver.common.container.envFrom" (dict "service" $service "kind" "app" "context" $) }}
{{ include "homeserver.common.container.envFrom" (dict "context" $) }}
*/}}
{{- define "homeserver.common.container.envFrom" -}}
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $extraEnvFromCM := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraEnvFromCM") -}}
{{- $extraEnvFromSecret := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraEnvFromSecret") -}}
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
{{- end -}}

{{/* Env vars for containers.
Usage:
{{ include "homeserver.common.container.env" (dict "service" $service "kind" "app" "context" $) }}
{{ include "homeserver.common.container.env" (dict "context" $) }}
*/}}
{{- define "homeserver.common.container.env" -}}
- name: TZ
  value: {{ required "A valid timezone required!" .context.Values.host.tz | quote }}
- name: KUBERNETES_POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $extraEnv := include "homeserver.common.utils.getExtraEnv" (dict "service" .service "kind" .kind) | fromYamlArray -}}
{{- $extraEnvSecrets := include "homeserver.common.utils.getExtraEnvSecrets" (dict "service" .service "kind" .kind) | fromYamlArray -}}
{{- range $extraEnv }}
- name: {{ .name | quote }}
  value: {{ include "homeserver.common.tplvalues.render" (dict "value" .value "context" $.context) | quote }}
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
{{- end -}}

{{/*
Volume mounts for containers.
Usage:
{{ include "homeserver.common.container.volumeMounts" (dict "service" $service "kind" "app" "context" $) }}
{{ include "homeserver.common.container.volumeMounts" (dict "context" $) }}
*/}}
{{- define "homeserver.common.container.volumeMounts" -}}
- name: empty-dir
  mountPath: /tmp
  subPath: tmp-dir
- name: empty-dir
  mountPath: /log
  subPath: log-dir
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $extraVolumeMounts := include "homeserver.common.utils.getExtraVolumeMounts" (dict "service" .service "kind" .kind) -}}
{{- if $extraVolumeMounts }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $extraVolumeMounts "context" .context) }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Liveness probe based on the HTTP GET method.
Usage:
{{ include "homeserver.common.container.livenessProbe.httpGet" (dict "service" $service "path" "/healthcheck" "context" $) }}
*/}}
{{- define "homeserver.common.container.livenessProbe.httpGet" -}}
{{- $livenessProbe := default .context.Values.livenessProbe .service.livenessProbe }}
{{- if $livenessProbe.enabled -}}
{{- $livenessProbe := omit $livenessProbe "enabled" -}}
httpGet:
  path: {{ .path }}
  port: http
{{ include "homeserver.common.tplvalues.render" (dict "value" $livenessProbe "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Liveness probe based on the exec method.
Usage:
{{ include "homeserver.common.container.livenessProbe.exec" (dict "service" $service "command" (list "/usr/bin/miniflux" "-healthcheck" "auto") "context" $) }}
*/}}
{{- define "homeserver.common.container.livenessProbe.exec" -}}
{{- $livenessProbe := default .context.Values.livenessProbe .service.livenessProbe }}
{{- if $livenessProbe.enabled -}}
{{- $livenessProbe := omit $livenessProbe "enabled" -}}
exec:
  command: {{- toYaml .command | nindent 4 }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $livenessProbe "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Liveness probe based on the TCP socket method.
Usage:
{{ include "homeserver.common.container.livenessProbe.tcpSocket" (dict "service" $service "port" "8000" "context" $) }}
*/}}
{{- define "homeserver.common.container.livenessProbe.tcpSocket" -}}
{{- $livenessProbe := default .context.Values.livenessProbe .service.livenessProbe }}
{{- if $livenessProbe.enabled -}}
{{- $livenessProbe := omit $livenessProbe "enabled" -}}
tcpSocket:
  port: {{ .port }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $livenessProbe "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Readiness probe based on the HTTP GET method.
Usage:
{{ include "homeserver.common.container.readinessProbe.httpGet" (dict "service" $service "path" "/healthcheck" "context" $) }}
*/}}
{{- define "homeserver.common.container.readinessProbe.httpGet" -}}
{{- $readinessProbe := default .context.Values.readinessProbe .service.readinessProbe }}
{{- if $readinessProbe.enabled -}}
{{- $readinessProbe := omit $readinessProbe "enabled" -}}
httpGet:
  path: {{ .path }}
  port: http
{{ include "homeserver.common.tplvalues.render" (dict "value" $readinessProbe "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Readiness probe based on the exec method.
Usage:
{{ include "homeserver.common.container.readinessProbe.exec" (dict "service" $service "command" (list "/usr/bin/miniflux" "-healthcheck" "auto") "context" $) }}
*/}}
{{- define "homeserver.common.container.readinessProbe.exec" -}}
{{- $readinessProbe := default .context.Values.readinessProbe .service.readinessProbe }}
{{- if $readinessProbe.enabled -}}
{{- $readinessProbe := omit $readinessProbe "enabled" -}}
exec:
  command: {{- toYaml .command | nindent 4 }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $readinessProbe "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Readiness probe based on the TCP socket method.
Usage:
{{ include "homeserver.common.container.readinessProbe.tcpSocket" (dict "service" $service "port" "8000" "context" $) }}
*/}}
{{- define "homeserver.common.container.readinessProbe.tcpSocket" -}}
{{- $readinessProbe := default .context.Values.readinessProbe .service.readinessProbe }}
{{- if $readinessProbe.enabled -}}
{{- $readinessProbe := omit $readinessProbe "enabled" -}}
tcpSocket:
  port: {{ .port }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $readinessProbe "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Startup probe based on the HTTP GET method.
Usage:
{{ include "homeserver.common.container.startupProbe.httpGet" (dict "service" $service "path" "/healthcheck" "context" $) }}
*/}}
{{- define "homeserver.common.container.startupProbe.httpGet" -}}
{{- $startupProbe := default .context.Values.startupProbe .service.startupProbe }}
{{- if $startupProbe.enabled -}}
{{- $startupProbe := omit $startupProbe "enabled" -}}
httpGet:
  path: {{ .path }}
  port: http
{{ include "homeserver.common.tplvalues.render" (dict "value" $startupProbe "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Startup probe based on the exec method.
Usage:
{{ include "homeserver.common.container.startupProbe.exec" (dict "service" $service "command" (list "/usr/bin/miniflux" "-healthcheck" "auto") "context" $) }}
*/}}
{{- define "homeserver.common.container.startupProbe.exec" -}}
{{- $startupProbe := default .context.Values.startupProbe .service.startupProbe }}
{{- if $startupProbe.enabled -}}
{{- $startupProbe := omit $startupProbe "enabled" -}}
exec:
  command: {{- toYaml .command | nindent 4 }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $startupProbe "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Startup probe based on the TCP socket method.
Usage:
{{ include "homeserver.common.container.startupProbe.tcpSocket" (dict "service" $service "port" "8000" "context" $) }}
*/}}
{{- define "homeserver.common.container.startupProbe.tcpSocket" -}}
{{- $startupProbe := default .context.Values.startupProbe .service.startupProbe }}
{{- if $startupProbe.enabled -}}
{{- $startupProbe := omit $startupProbe "enabled" -}}
tcpSocket:
  port: {{ .port }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $startupProbe "context" .context) }}
{{- end -}}
{{- end -}}
