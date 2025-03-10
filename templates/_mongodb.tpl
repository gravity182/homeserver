{{/*
Create a config map with common mongodb scripts.
Usage:
{{ include "homeserver.common.mongodb.scripts" ( dict "service" $service "context" $ ) }}
*/}}
{{- define "homeserver.common.mongodb.scripts" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ printf "%s-mongodb-common-scripts" ( include "homeserver.common.names.name" ( dict "service" .service "kind" "database" ) ) | quote }}
  namespace: {{ include "homeserver.common.names.namespace" .context | quote }}
  labels: {{- include "homeserver.common.labels.standard" ( dict "service" .service "kind" "database" "context" .context ) | nindent 4 }}
data:
  startup-probe.sh: |
    #!/bin/bash
    exec mongosh --port $MONGODB_PORT_NUMBER --eval 'if (!(db.hello().isWritablePrimary || db.hello().secondary)) { throw new Error("Not ready") }'
  readiness-probe.sh: |
    #!/bin/bash
    # Run the proper check depending on the version
    [[ $(mongod -version | grep "db version") =~ ([0-9]+\.[0-9]+\.[0-9]+) ]] && VERSION=${BASH_REMATCH[1]}
    . /opt/bitnami/scripts/libversion.sh
    VERSION_MAJOR="$(get_sematic_version "$VERSION" 1)"
    VERSION_MINOR="$(get_sematic_version "$VERSION" 2)"
    VERSION_PATCH="$(get_sematic_version "$VERSION" 3)"
    readiness_test='db.isMaster().ismaster || db.isMaster().secondary'
    if [[ ( "$VERSION_MAJOR" -ge 5 ) || ( "$VERSION_MAJOR" -ge 4 && "$VERSION_MINOR" -ge 4 && "$VERSION_PATCH" -ge 2 ) ]]; then
        readiness_test='db.hello().isWritablePrimary || db.hello().secondary'
    fi
    exec mongosh --port $MONGODB_PORT_NUMBER --eval "if (!(${readiness_test})) { throw new Error(\"Not ready\") }"
  ping-mongodb.sh: |
    #!/bin/bash
    exec mongosh --port $MONGODB_PORT_NUMBER --eval "db.adminCommand('ping')"
{{- end -}}
