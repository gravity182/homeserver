{{/*
Returns a utility image name used by init containers.
Usage:
{{ include "homeserver.common.initContainer.utility-image" . }}
*/}}
{{- define "homeserver.common.initContainer.utility-image" -}}
{{- "chainguard/bash:latest" -}}
{{- end -}}

{{/*
Returns a git image name used by init containers.
Usage:
{{ include "homeserver.common.initContainer.git-image" . }}
*/}}
{{- define "homeserver.common.initContainer.git-image" -}}
{{- "alpine/git:latest" -}}
{{- end -}}

{{/*
Changes volume permissions.
Usage:
{{ include "homeserver.common.initContainer.volumePermissions" ( dict "volumes" (list "volume1" "volume2" ) "context" $ ) }}
*/}}
{{- define "homeserver.common.initContainer.volumePermissions" -}}
{{- if .volumes }}
- name: volume-permissions
  image: {{ include "homeserver.common.initContainer.utility-image" . | quote }}
  imagePullPolicy: IfNotPresent
  command:
    - /bin/bash
    - -ec
    - |
        IFS=" "
        echo "Current permissions:" \
          && ls -land $PATHS \
          && echo "------------------------------" \
          && echo "Changing volume permissions..." \
          && chown -R {{ printf "%s:%s" (required "A valid UID required!" .context.Values.host.uid | toString) (required "A valid GID required!" .context.Values.host.gid | toString) }} $PATHS \
          && chmod -R a=,ug+rX,u+w $PATHS \
          && echo "------------------------------" \
          && echo "Updated permissions:" \
          && ls -land $PATHS
  env:
    {{- $paths := list }}
    {{- range $volume := .volumes }}
    {{- $paths = append $paths (printf "/tmp/%s" $volume) }}
    {{- end }}
    - name: PATHS
      value: {{ join " " $paths | quote }}
  securityContext:
    seLinuxOptions: {}
    privileged: false
    allowPrivilegeEscalation: false
    runAsUser: 0
    seccompProfile:
      type: "RuntimeDefault"
  volumeMounts:
  {{- range $volume := .volumes }}
    - name: {{ $volume | quote }}
      mountPath: {{ printf "/tmp/%s" $volume | quote }}
  {{- end }}
{{- end }}
{{- end -}}
