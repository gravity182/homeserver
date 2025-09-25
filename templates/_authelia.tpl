{{/*
Create Authelia chart namespace.
*/}}
{{- define "homeserver.authelia.names.namespace" -}}
{{- (index .Values "x-authelia").namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}
