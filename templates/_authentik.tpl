{{/*
Create Authentik chart namespace.
*/}}
{{- define "homeserver.authentik.names.namespace" -}}
{{- .Values.authentik.namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}
