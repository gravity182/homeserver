{{- define "homeserver.common.utils.getServiceValueFromKey" -}}
{{- $splitKey := splitList "." .key -}}
{{- $value := "" -}}
{{- $latestObj := dict -}}
{{- if eq .kind "app" -}}
{{- $latestObj = (required "service definition is missing" .service) -}}
{{- else if eq .kind "database" -}}
{{- $latestObj = (required "service.db definition is missing" .service.db) -}}
{{- else if eq .kind "database-backup" -}}
{{- $latestObj = (required "service.db.backup definition is missing" .service.db.backup) -}}
{{- else -}}
{{- printf "Unknown kind of '%s'" .kind | fail -}}
{{- end -}}
{{- range $splitKey -}}
  {{- if not $latestObj -}}
    {{- printf "please review the entire path of '%s' exists in values" $.key | fail -}}
  {{- end -}}
  {{- $value = ( index $latestObj . ) -}}
  {{- $latestObj = $value -}}
{{- end -}}
{{- if $value -}}
{{- $value | toYaml -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Gets extra env var secrets for the given service
Usage:
{{ include "homeserver.common.utils.getExtraEnvSecrets" (dict "service" $service "kind" $kind) }}
*/}}
{{- define "homeserver.common.utils.getExtraEnvSecrets" -}}
{{- $value := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraEnvSecrets") | fromYamlArray -}}
{{- if $value -}}
{{- $requiredFields := list "name" "secretName" "secretKey" -}}
{{- range $i, $envSecret := $value -}}
{{- range $requiredFields -}}
{{- if not (hasKey $envSecret . ) -}}
{{- printf "extraEnvSecrets[%d] is invalid: missing a required field '%s'" $i . | fail -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $value | toYaml -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Gets extra env vars for the given service
Usage:
{{ include "homeserver.common.utils.getExtraEnv" (dict "service" $service "kind" $kind) }}
*/}}
{{- define "homeserver.common.utils.getExtraEnv" -}}
{{- $value := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraEnv") | fromYamlArray -}}
{{- if $value -}}
{{- $requiredFields := list "name" "value" -}}
{{- range $i, $env := $value -}}
{{- range $requiredFields -}}
{{- if not (hasKey $env . ) -}}
{{- printf "extraEnv[%d] is invalid: missing a required field '%s'" $i . | fail -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $value | toYaml -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Gets persistence directories for the given service
Usage:
{{ include "homeserver.common.utils.getPersistence" (dict "service" $service "kind" $kind) }}
*/}}
{{- define "homeserver.common.utils.getPersistence" -}}
{{- include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "persistence") -}}
{{- end -}}

{{/*
Gets extra volumes for the given service
Usage:
{{ include "homeserver.common.utils.getExtraVolumes" (dict "service" $service "kind" $kind) }}
*/}}
{{- define "homeserver.common.utils.getExtraVolumes" -}}
{{- include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraVolumes") -}}
{{- end -}}

{{/*
Gets extra volume mounts for the given service
Usage:
{{ include "homeserver.common.utils.getExtraVolumeMounts" (dict "service" $service "kind" $kind) }}
*/}}
{{- define "homeserver.common.utils.getExtraVolumeMounts" -}}
{{- include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "extraVolumeMounts") -}}
{{- end -}}

{{/*
Gets securityContext for the given service
Usage:
{{ include "homeserver.common.utils.getSecurityContext" (dict "service" $service "kind" $kind) }}
*/}}
{{- define "homeserver.common.utils.getSecurityContext" -}}
{{- $value := include "homeserver.common.utils.getServiceValueFromKey" (dict "service" .service "kind" .kind "key" "securityContext") | fromYaml -}}
{{- if not $value -}}
{{- printf "Security context is missing" | fail -}}
{{- end -}}
{{- $requiredFields := list "strict" -}}
{{- range $requiredFields -}}
{{- if not (hasKey $value .) -}}
{{- printf "Security context is invalid: required field '%s' is missing" . | fail -}}
{{- end -}}
{{- end -}}
{{- $value | toYaml -}}
{{- end -}}

{{/*
Generates a service url
Usage:
{{ include "homeserver.common.utils.serviceUrl" ( dict "service" $service "context" $ ) }}
{{ include "homeserver.common.utils.serviceUrl" ( dict "service" $service "scheme" "ws" "context" $ ) }}
*/}}
{{- define "homeserver.common.utils.serviceUrl" -}}
{{- printf "%s://%s:%s" (default "http" .scheme) (include "homeserver.common.names.name" (dict "service" .service "kind" "app")) (required "http port required" .service.ports.http | toString) -}}
{{- end -}}

{{/*
Generates a list of CSRF trusted origins for the specified service
Usage:
{{ include "homeserver.common.utils.ingressUrl" ( dict "service" $service "context" $ ) }}
*/}}
{{- define "homeserver.common.utils.ingressUrl" -}}
{{- if .service.ingress -}}
{{- printf "https://%s.%s" (first .service.ingress) (required "A valid .Values.ingress.domain required!" .context.Values.ingress.domain) -}}
{{- else -}}
{{- printf "Service '%s' does not have any ingress addresses" .service.name | fail -}}
{{- end -}}
{{- end -}}

{{/*
Generates and concatenates a list of CSRF trusted origins for the specified service. Default delimiter is a comma

Usage:
{{ include "homeserver.common.utils.csrfTrustedOrigins" ( dict "service" $service "delimiter" "," "context" $ ) }}
{{ include "homeserver.common.utils.csrfTrustedOrigins" ( dict "service" $service "context" $ ) }}
*/}}
{{- define "homeserver.common.utils.csrfTrustedOrigins" -}}
{{- $dst := list "localhost" "127.0.0.1" "$(KUBERNETES_POD_IP)" -}}
{{- if .service.exposed -}}
{{- range $host := .service.ingress -}}
{{- $dst = append $dst (printf "https://%s.%s" $host (required "A valid .Values.ingress.domain required!" $.context.Values.ingress.domain)) -}}
{{- end -}}
{{- if (eq .context.Values.ingress.rootService .service.name) -}}
{{- $dst = append $dst (printf "https://%s" (required "A valid .Values.ingress.domain required!" .context.Values.ingress.domain)) -}}
{{- end -}}
{{- end -}}
{{- join (default "," .delimiter) $dst -}}
{{- end -}}

{{/*
Generates and concatenates a list of allowed hosts for the specified service. Default delimiter is a comma

Usage:
{{ include "homeserver.common.utils.allowedHosts" ( dict "service" $service "delimiter" "," "context" $ ) }}
{{ include "homeserver.common.utils.allowedHosts" ( dict "service" $service "context" $ ) }}
*/}}
{{- define "homeserver.common.utils.allowedHosts" -}}
{{- $dst := list "localhost" "127.0.0.1" "$(KUBERNETES_POD_IP)" -}}
{{- $dst = append $dst (include "homeserver.common.names.name" (dict "service" .service "kind" "app")) -}}
{{- if .service.exposed -}}
{{- range $host := .service.ingress -}}
{{- $dst = append $dst (printf "%s.%s" $host (required "A valid .Values.ingress.domain required!" $.context.Values.ingress.domain)) -}}
{{- end -}}
{{- if (eq .context.Values.ingress.rootService .service.name) -}}
{{- $dst = append $dst (required "A valid .Values.ingress.domain required!" .context.Values.ingress.domain) -}}
{{- end -}}
{{- end -}}
{{- join (default "," .delimiter) $dst -}}
{{- end -}}

{{/*
Checksum a template at "path" containing a *single* resource (ConfigMap,Secret) for use in pod annotations, excluding the metadata.
Usage:
{{ include "homeserver.common.utils.checksumTemplate" ( dict "path" "/configmap.yaml" "context" $ ) }}
*/}}
{{- define "homeserver.common.utils.checksumTemplate" -}}
{{- $obj := include (print .context.Template.BasePath .path) .context | fromYaml -}}
{{ omit $obj "apiVersion" "kind" "metadata" | toYaml | sha256sum }}
{{- end -}}
