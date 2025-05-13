{{/*
Return a resource request/limit object based on a given preset.
Usage:
{{ include "homeserver.common.resources.preset" (dict "type" "nano") -}}
*/}}
{{- define "homeserver.common.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except 2xnano/xlarge/2xlarge/3xlarge sizes)*/}}
{{- $presets := dict
  "2xnano" (dict
      "requests" (dict "cpu" "25m" "memory" "32Mi")
      "limits" (dict "cpu" "50m" "memory" "64Mi")
   )
  "xnano" (dict
      "requests" (dict "cpu" "50m" "memory" "64Mi")
      "limits" (dict "cpu" "75m" "memory" "96Mi")
   )
  "nano" (dict
      "requests" (dict "cpu" "100m" "memory" "128Mi")
      "limits" (dict "cpu" "150m" "memory" "192Mi")
   )
  "micro" (dict
      "requests" (dict "cpu" "250m" "memory" "256Mi")
      "limits" (dict "cpu" "375m" "memory" "384Mi")
   )
  "small" (dict
      "requests" (dict "cpu" "500m" "memory" "512Mi")
      "limits" (dict "cpu" "750m" "memory" "768Mi")
   )
  "medium" (dict
      "requests" (dict "cpu" "500m" "memory" "1024Mi")
      "limits" (dict "cpu" "750m" "memory" "1536Mi")
   )
  "large" (dict
      "requests" (dict "cpu" "1.0" "memory" "2048Mi")
      "limits" (dict "cpu" "1.5" "memory" "3072Mi")
   )
  "xlarge" (dict
      "requests" (dict "cpu" "1.0" "memory" "3072Mi")
      "limits" (dict "cpu" "3.0" "memory" "6144Mi")
   )
  "2xlarge" (dict
      "requests" (dict "cpu" "1.0" "memory" "3072Mi")
      "limits" (dict "cpu" "6.0" "memory" "12288Mi")
   )
 }}
{{- if hasKey $presets .type -}}
{{- index $presets .type | toYaml -}}
{{- else -}}
{{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .type (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}
