# {{ .Title }}

{{ range .Data.Pages }}
{{- if not (in (.Site.Params.excludedTypes | default (slice "page")) .Type) -}}
- [{{ .Title }}]({{ .Permalink }}) ({{ .Date.Format "2006-01-02" }})
{{- end -}}
{{ end }}