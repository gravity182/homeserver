{{/*
Security context for containers.
Usage:
{{ include "homeserver.common.container.securityContext" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "homeserver.common.container.securityContext" -}}
seLinuxOptions: {}
privileged: false
allowPrivilegeEscalation: false
{{- if (include "homeserver.common.utils.getSecurityContext" (dict "service" .service "kind" .kind) | fromYaml).strict }}
runAsUser: {{ required "A valid UID required!" .context.Values.host.uid }}
runAsGroup: {{ required "A valid GID required!" .context.Values.host.gid }}
runAsNonRoot: true
readOnlyRootFilesystem: true
capabilities:
  drop: ["ALL"]
{{/* Unfortunately some images have very limited support for running containers as non-root or read-only */}}
{{- else }}
runAsNonRoot: false
readOnlyRootFilesystem: false
capabilities:
  add: ["CHOWN", "SETUID", "SETGID", "FSETID"]
{{- end }}
seccompProfile:
  type: "RuntimeDefault"
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
*/}}
{{- define "homeserver.common.container.volumeMounts" -}}
{{- if (include "homeserver.common.utils.getSecurityContext" (dict "service" .service "kind" .kind) | fromYaml).strict }}
- name: empty-dir
  mountPath: /tmp
  subPath: tmp-dir
- name: empty-dir
  mountPath: /log
  subPath: log-dir
{{- end }}
{{- $extraVolumeMounts := include "homeserver.common.utils.getExtraVolumeMounts" (dict "service" .service "kind" .kind) -}}
{{- if $extraVolumeMounts }}
{{ include "homeserver.common.tplvalues.render" (dict "value" $extraVolumeMounts "context" .context) }}
{{- end }}
{{- end -}}
