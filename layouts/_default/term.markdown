# Posts tagged "{{ .Title }}"

{{ range .Data.Pages }}
- [{{ .Title }}]({{ .Permalink }}) ({{ .Date.Format "2006-01-02" }})
{{ end }}