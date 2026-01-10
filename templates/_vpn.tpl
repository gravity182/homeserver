{{/*
Get VPN secret reference.

Usage:
{{ include "homeserver.common.vpn.secretRef" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.common.vpn.secretRef" -}}
{{- $serviceSecretRef := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "vpn.secretRef") -}}
{{- $serviceSecretKey := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "vpn.secretKey") -}}
{{- if and $serviceSecretRef $serviceSecretKey -}}
  {{- $serviceSecretRef -}}
{{- else if or $serviceSecretRef $serviceSecretKey -}}
  {{- printf "Service '%s': vpn.secretRef and vpn.secretKey must be both defined" .service.name | fail -}}
{{- else -}}
  {{- required "A valid .Values.vpn.secretRef required!" .context.Values.vpn.secretRef -}}
{{- end -}}
{{- end -}}

{{/*
Get VPN secret key.

Usage:
{{ include "homeserver.common.vpn.secretKey" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.common.vpn.secretKey" -}}
{{- $serviceSecretRef := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "vpn.secretRef") -}}
{{- $serviceSecretKey := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "key" "vpn.secretKey") -}}
{{- if and $serviceSecretRef $serviceSecretKey -}}
  {{- $serviceSecretKey -}}
{{- else if or $serviceSecretRef $serviceSecretKey -}}
  {{- printf "Service '%s': vpn.secretRef and vpn.secretKey must be both defined" .service.name | fail -}}
{{- else -}}
  {{- required "A valid .Values.vpn.secretKey required!" .context.Values.vpn.secretKey -}}
{{- end -}}
{{- end -}}

{{/*
VPN sidecar.

Usage:
{{ include "homeserver.common.vpn.sidecar" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.common.vpn.sidecar" }}
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
        {{- if .context.Values.vpn.sysModule }}
        - "SYS_MODULE"
        {{- end }}
  resources: {{- include "homeserver.common.resources.preset" (dict "type" "2xnano") | nindent 4 }}
  env:
    - name: PUID
      value: {{ required "A valid UID required!" .context.Values.host.uid | quote }}
    - name: PGID
      value: {{ required "A valid GID required!" .context.Values.host.gid | quote }}
    - name: TZ
      value: {{ required "A valid timezone required!" .context.Values.host.tz | quote }}
  volumeMounts:
    - name: wireguard-conf
      mountPath: /config/wg_confs/wg0.conf
      subPath: {{ include "homeserver.common.vpn.secretKey" (dict "service" .service "context" .context) }}
      readOnly: true
    {{- if .context.Values.vpn.sysModule }}
    - name: lib-modules
      mountPath: /lib/modules
    {{- end }}
{{- end }}

{{/*
VPN volumes.

Usage:
{{ include "homeserver.common.vpn.volumes" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.common.vpn.volumes" }}
- name: wireguard-conf
  secret:
    defaultMode: 0600
    secretName: {{ include "homeserver.common.vpn.secretRef" (dict "service" .service "context" .context) }}
    optional: false
{{- if .context.Values.vpn.sysModule }}
- name: lib-modules
  hostPath:
    path: /lib/modules
    type: Directory
{{- end }}
{{- end }}

{{/*
VPN sysctls.

Usage:
{{ include "homeserver.common.vpn.securityContext.sysctls" . }}
*/}}
{{- define "homeserver.common.vpn.securityContext.sysctls" }}
- name: net.ipv4.conf.all.src_valid_mark
  value: "1"
{{- end }}

{{/*
VPN container for bjw-s format.

Usage:
{{ include "homeserver.vpn.container.bjws" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.vpn.container.bjws" -}}
wireguard:
  image:
    repository: lscr.io/linuxserver/wireguard
    tag: latest
    pullPolicy: IfNotPresent
  restartPolicy: Always
  securityContext:
    privileged: false
    allowPrivilegeEscalation: false
    runAsNonRoot: false
    readOnlyRootFilesystem: false
    capabilities:
      add:
        - NET_ADMIN
        {{- if .context.Values.vpn.sysModule }}
        - SYS_MODULE
        {{- end }}
  env:
    - name: PUID
      value: "1001"
    - name: PGID
      value: "1001"
    - name: TZ
      value: {{ .context.Values.host.tz | default "UTC" | quote }}
  resources: {{- include "homeserver.common.resources.preset" (dict "type" "2xnano") | nindent 4 }}
{{- end -}}

{{/*
VPN persistence entries for bjw-s format.

Usage:
{{ include "homeserver.vpn.persistence.bjws" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.vpn.persistence.bjws" -}}
wireguard-conf:
  type: secret
  name: {{ include "homeserver.common.vpn.secretRef" (dict "service" .service "context" .context) }}
  defaultMode: 0600
  advancedMounts:
    main:
      wireguard:
        - path: /config/wg_confs/wg0.conf
          subPath: {{ include "homeserver.common.vpn.secretKey" (dict "service" .service "context" .context) }}
          readOnly: true
{{- if .context.Values.vpn.sysModule }}
lib-modules:
  type: hostPath
  hostPath: /lib/modules
  hostPathType: Directory
  advancedMounts:
    main:
      wireguard:
        - path: /lib/modules
          readOnly: true
{{- end }}
{{- end -}}

{{/*
VPN sysctls for bjw-s pod securityContext.

Usage:
{{ include "homeserver.vpn.sysctls.bjws" (dict "service" $service "context" $) }}
*/}}
{{- define "homeserver.vpn.sysctls.bjws" -}}
- name: net.ipv4.conf.all.src_valid_mark
  value: "1"
{{- end -}}
