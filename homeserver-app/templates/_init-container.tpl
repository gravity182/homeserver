{{/*
Returns a utility image name used by init containers.
Usage:
{{ include "homeserver.common.initContainer.image.utility" . }}
*/}}
{{- define "homeserver.common.initContainer.image.utility" -}}
{{- "chainguard/bash:latest" -}}
{{- end -}}

{{/*
Returns a git image name used by init containers.
Usage:
{{ include "homeserver.common.initContainer.image.git" . }}
*/}}
{{- define "homeserver.common.initContainer.image.git" -}}
{{- "alpine/git:latest" -}}
{{- end -}}

{{/*
Fixes volume permissions.
Usage:
{{ include "homeserver.app.initContainer.volumePermissions" ( dict "volumes" (list "volume1" "volume2" ) "context" $ ) }}
*/}}
{{- define "homeserver.app.initContainer.volumePermissions" -}}
{{- if .volumes }}
- name: volume-permissions
  image: {{ include "homeserver.common.initContainer.image.utility" . | quote }}
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
          && chown -R $CHOWN_UID:$CHOWN_GID $PATHS \
          && chmod -R a=,ug+rX,u+w $PATHS \
          && echo "------------------------------" \
          && echo "Updated permissions:" \
          && ls -land $PATHS
  env:
    {{- $paths := list }}
    {{- range $volume := .volumes }}
    {{- $paths = append $paths (printf "/mnt/%s" $volume) }}
    {{- end }}
    - name: PATHS
      value: {{ join " " $paths | quote }}
    - name: CHOWN_UID
      value: {{ required "A valid UID required!" .context.Values.host.uid | toString | quote }}
    - name: CHOWN_GID
      value: {{ required "A valid GID required!" .context.Values.host.gid | toString | quote }}
  securityContext:
    readOnlyRootFilesystem: false
    runAsNonRoot: false
    runAsUser: 0
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      add:
        - CHOWN
      drop:
        - ALL
  volumeMounts:
  {{- range $volume := .volumes }}
    - name: {{ kebabcase $volume | quote }}
      mountPath: {{ printf "/mnt/%s" $volume | quote }}
  {{- end }}
{{- end }}
{{- end -}}
