{{- define "homeserver.labels" }}
  app.kubernetes.io/part-of: "homeserver"
  app.kubernetes.io/managed-by: "{{ .Release.Service }}"
  helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end }}

{{- define "homeserver.vpn.wg-sidecar" }}
  - name: wireguard
    image: lscr.io/linuxserver/wireguard:latest
    imagePullPolicy: IfNotPresent
    restartPolicy: Always
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_MODULE"]
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
        subPath: {{ .Values.vpn.secretKey }}
        readOnly: false
      - name: lib-modules
        mountPath: /lib/modules
{{- end }}

{{- define "homeserver.vpn.wg-volumes" }}
  - name: wireguard-conf
    secret:
      secretName: {{ .Values.vpn.secretRef }}
      optional: false
  - name: lib-modules
    hostPath:
      path: /lib/modules
      type: Directory
{{- end }}

{{- define "homeserver.vpn.wg-sysctls" }}
  - name: net.ipv4.conf.all.src_valid_mark
    value: "1"
{{- end }}
