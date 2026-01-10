{{/*
Get VPN secret reference.

Usage:
{{ include "homeserver.app.vpn.secretRef" $ }}
*/}}
{{- define "homeserver.app.vpn.secretRef" -}}
{{- $serviceSecretRef := (.Values.vpn).secretRef | default "" -}}
{{- $serviceSecretKey := (.Values.vpn).secretKey | default "" -}}
{{- if and $serviceSecretRef $serviceSecretKey -}}
  {{- $serviceSecretRef -}}
{{- else if or $serviceSecretRef $serviceSecretKey -}}
  {{- printf "Service '%s': vpn.secretRef and vpn.secretKey must be both defined" .Values.name | fail -}}
{{- else -}}
  {{- required "A valid .Values.global.vpn.secretRef required!" .Values.global.vpn.secretRef -}}
{{- end -}}
{{- end -}}

{{/*
Get VPN secret key.

Usage:
{{ include "homeserver.app.vpn.secretKey" $ }}
*/}}
{{- define "homeserver.app.vpn.secretKey" -}}
{{- $serviceSecretRef := (.Values.vpn).secretRef | default "" -}}
{{- $serviceSecretKey := (.Values.vpn).secretKey | default "" -}}
{{- if and $serviceSecretRef $serviceSecretKey -}}
  {{- $serviceSecretKey -}}
{{- else if or $serviceSecretRef $serviceSecretKey -}}
  {{- printf "Service '%s': vpn.secretRef and vpn.secretKey must be both defined" .Values.name | fail -}}
{{- else -}}
  {{- required "A valid .Values.global.vpn.secretKey required!" .Values.global.vpn.secretKey -}}
{{- end -}}
{{- end -}}

{{/*
VPN sidecar.

Usage:
{{ include "homeserver.app.vpn.sidecar" $ }}
*/}}
{{- define "homeserver.app.vpn.sidecar" }}
- name: wireguard
  image: lscr.io/linuxserver/wireguard:latest
  imagePullPolicy: IfNotPresent
  restartPolicy: Always  # this makes it a native sidecar
  securityContext:
    seLinuxOptions: {}
    privileged: false
    allowPrivilegeEscalation: false
    runAsNonRoot: false
    readOnlyRootFilesystem: false
    seccompProfile:
      type: "RuntimeDefault"
    capabilities:
      add:
        - "NET_ADMIN"
        {{- if .Values.global.vpn.sysModule }}
        - "SYS_MODULE"
        {{- end }}
  resources: {{- include "homeserver.common.resources.preset" (dict "type" "2xnano") | nindent 4 }}
  env:
    - name: PUID
      value: {{ required "A valid UID required!" .Values.host.uid | quote }}
    - name: PGID
      value: {{ required "A valid GID required!" .Values.host.gid | quote }}
    - name: TZ
      value: {{ required "A valid timezone required!" .Values.host.tz | quote }}
  volumeMounts:
    - name: wireguard-conf
      mountPath: /config/wg_confs/wg0.conf
      subPath: {{ include "homeserver.app.vpn.secretKey" $ }}
      readOnly: true
    {{- if .Values.global.vpn.sysModule }}
    - name: lib-modules
      mountPath: /lib/modules
    {{- end }}
{{- end }}

{{/*
VPN volumes.

Usage:
{{ include "homeserver.app.vpn.volumes" $ }}
*/}}
{{- define "homeserver.app.vpn.volumes" }}
- name: wireguard-conf
  secret:
    defaultMode: 0600
    secretName: {{ include "homeserver.app.vpn.secretRef" $ }}
    optional: false
{{- if .Values.global.vpn.sysModule }}
- name: lib-modules
  hostPath:
    path: /lib/modules
    type: Directory
{{- end }}
{{- end }}

{{/*
VPN sysctls.

Usage:
{{ include "homeserver.app.vpn.securityContext.sysctls" $ }}
*/}}
{{- define "homeserver.app.vpn.securityContext.sysctls" }}
- name: net.ipv4.conf.all.src_valid_mark
  value: "1"
{{- end }}
