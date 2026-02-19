# All tags

{{ range .Data.Terms.Alphabetical }}
- [{{ .Name }}]({{ $.Site.LanguagePrefix | absURL }}{{ $.Data.Plural }}/{{ .Name | urlize }}/) ({{ .Count }} posts)
{{ end }}