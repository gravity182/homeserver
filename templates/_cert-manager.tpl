{{/*
Annotations used on ingress/gateway resources.

Usage:
{{- include "homeserver.cert-manager.ingress.annotations" . | nindent 2 }}
*/}}
{{- define "homeserver.cert-manager.ingress.annotations" -}}
cert-manager.io/cluster-issuer: letsencrypt-cert-issuer
{{- end -}}
