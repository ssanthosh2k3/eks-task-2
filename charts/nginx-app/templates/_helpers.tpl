{{- define "nginx-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nginx-app.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "nginx-app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
