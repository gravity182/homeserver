{{/*
Create cert-manager chart namespace.
*/}}
{{- define "homeserver.cert-manager.names.namespace" -}}
{{- (index .Values "cert-manager").namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Annotations used on gateway resources.

Usage:
{{- include "homeserver.cert-manager.ingress.annotations" . | nindent 2 }}
*/}}
{{- define "homeserver.cert-manager.ingress.annotations" -}}
cert-manager.io/cluster-issuer: homeserver-cert-issuer
{{- end -}}
