{{- define "rsds.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: rsds
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}
