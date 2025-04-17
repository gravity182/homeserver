{{/*
Strict security context. Allows running exclusively as a non-root user with a read-only root filesystem.
Usage:
{{ include "homeserver.common.securityContext.strict" . }}
*/}}
{{- define "homeserver.common.securityContext.strict" -}}
seLinuxOptions: {}
privileged: false
allowPrivilegeEscalation: false
runAsUser: {{ required "A valid UID required!" .Values.host.uid }}
runAsGroup: {{ required "A valid GID required!" .Values.host.gid }}
runAsNonRoot: true
readOnlyRootFilesystem: true
capabilities:
  drop: ["ALL"]
seccompProfile:
  type: "RuntimeDefault"
{{- end -}}

{{/*
Lenient security context. Allows running as a root user.
Usage:
{{ include "homeserver.common.securityContext.lenient" . }}
*/}}
{{- define "homeserver.common.securityContext.lenient" -}}
seLinuxOptions: {}
runAsNonRoot: false
readOnlyRootFilesystem: false
seccompProfile:
  type: "RuntimeDefault"
{{- end -}}
