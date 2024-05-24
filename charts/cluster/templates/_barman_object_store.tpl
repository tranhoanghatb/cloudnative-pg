{{- define "cluster.barmanObjectStoreConfig" -}}

{{- if .scope.endpointURL }}
  endpointURL: {{ .scope.endpointURL | quote }}
{{- end }}

{{- if or (.scope.endpointCA.create) (.scope.endpointCA.name) }}
  endpointCA:
    name: {{ .chartFullname }}-ca-bundle
    key: ca-bundle.crt
{{- end }}

{{- if .scope.destinationPath }}
  destinationPath: {{ .scope.destinationPath }}
{{- end }}

{{- if eq .scope.provider "s3" }}
  {{- if empty .scope.endpointURL }}
  endpointURL: "https://s3.{{ required "You need to specify S3 region if endpointURL is not specified." .scope.s3.region }}.amazonaws.com"
  {{- end }}
  {{- if empty .scope.destinationPath }}
  destinationPath: "s3://{{ required "You need to specify S3 bucket if destinationPath is not specified." .scope.s3.bucket }}{{ .scope.s3.path }}"
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-s3-creds" .chartFullname .secretSuffix) -}}
  s3Credentials:
    accessKeyId:
      name: {{ $secretName }}
      key: ACCESS_KEY_ID
    secretAccessKey:
      name: {{ $secretName }}
      key: ACCESS_SECRET_KEY
{{- else if eq .scope.provider "azure" }}
  {{- if empty .scope.destinationPath }}
  destinationPath: "https://{{ required "You need to specify Azure storageAccount if destinationPath is not specified." .scope.azure.storageAccount }}.{{ .scope.azure.serviceName }}.core.windows.net/{{ .scope.azure.containerName }}{{ .scope.azure.path }}"
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-azure-creds" .chartFullname .secretSuffix) }}
  azureCredentials:
  {{- if .scope.azure.inheritFromAzureAD }}
    inheritFromAzureAD: true
  {{- else if .scope.azure.connectionString }}
    connectionString:
      name: {{ $secretName }}
      key: AZURE_CONNECTION_STRING
  {{- else }}
    storageAccount:
      name: {{ $secretName }}
      key: AZURE_STORAGE_ACCOUNT
    {{- if .scope.azure.storageKey }}
    storageKey:
      name: {{ .chartFullname }}-{{ .secretPrefix }}-azure-creds
      key: AZURE_STORAGE_KEY
    {{- else }}
    storageSasToken:
      name: {{ .chartFullname }}-{{ .secretPrefix }}-azure-creds
      key: AZURE_STORAGE_SAS_TOKEN
    {{- end }}
  {{- end }}
{{- else if eq .scope.provider "google" }}
  {{- if empty .scope.destinationPath }}
  destinationPath: "gs://{{ required "You need to specify Google storage bucket if destinationPath is not specified." .scope.google.bucket }}{{ .scope.google.path }}"
  {{- end }}
  {{- $secretName := coalesce .scope.secret.name (printf "%s-%s-google-creds" .chartFullname .secretSuffix) }}
  googleCredentials:
    gkeEnvironment: {{ .scope.google.gkeEnvironment }}
    applicationCredentials:
      name: {{ $secretName }}
      key: APPLICATION_CREDENTIALS
{{- end -}}
{{- end -}}
