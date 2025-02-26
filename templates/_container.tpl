{{/*
Security context for containers.
Usage:
{{ include "common.container.securityContext" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "common.container.securityContext" -}}
seLinuxOptions: {}
privileged: false
allowPrivilegeEscalation: false
{{- if (include "common.utils.getSecurityContext" (dict "service" .service "kind" .kind) | fromYaml).strict }}
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
{{ include "common.container.resources" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "common.container.resources" -}}
{{- if .context.Values.resources.enabled -}}
{{- $preset := include "common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "resourcesPreset") -}}
{{- if not $preset -}}
{{- printf "Resources preset is missing" | fail -}}
{{- end -}}
{{- if not (eq $preset "none") -}}
{{ include "common.resources.preset" (dict "type" $preset) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Env from for containers.
Usage:
{{ include "common.container.envFrom" (dict "service" $service "kind" "app" "context" $) }}
{{ include "common.container.envFrom" (dict "context" $) }}
*/}}
{{- define "common.container.envFrom" -}}
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $extraEnvFromCM := include "common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraEnvFromCM") -}}
{{- $extraEnvFromSecret := include "common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraEnvFromSecret") -}}
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
{{ include "common.container.env" (dict "service" $service "kind" "app" "context" $) }}
{{ include "common.container.env" (dict "context" $) }}
*/}}
{{- define "common.container.env" -}}
- name: TZ
  value: {{ required "A valid timezone required!" .context.Values.host.tz | quote }}
{{- if and (hasKey . "service") (hasKey . "kind") -}}
{{- $extraEnv := include "common.utils.getExtraEnv" (dict "service" .service "kind" .kind) | fromYamlArray -}}
{{- $extraEnvSecrets := include "common.utils.getExtraEnvSecrets" (dict "service" .service "kind" .kind) | fromYamlArray -}}
{{- range $extraEnv }}
- name: {{ .name | quote }}
  value: {{ include "common.tplvalues.render" (dict "value" .value "context" $.context) | quote }}
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
{{ include "common.container.volumeMounts" (dict "service" $service "kind" "app" "context" $) }}
*/}}
{{- define "common.container.volumeMounts" -}}
{{- if (include "common.utils.getSecurityContext" (dict "service" .service "kind" .kind) | fromYaml).strict }}
- name: empty-dir
  mountPath: /tmp
  subPath: tmp-dir
- name: empty-dir
  mountPath: /log
  subPath: log-dir
{{- end }}
{{- $extraVolumeMounts := include "common.utils.getExtraVolumeMounts" (dict "service" .service "kind" .kind) -}}
{{- if $extraVolumeMounts }}
{{ include "common.tplvalues.render" (dict "value" $extraVolumeMounts "context" .context) }}
{{- end }}
{{- end -}}
