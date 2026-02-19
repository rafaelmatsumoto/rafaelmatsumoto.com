---
title: {{ .Title }}
date: {{ .Date.Format "2006-01-02T15:04:05Z07:00" }}
{{- if .Description }}
description: {{ .Description }}
{{- end }}
{{- if .Params.tags }}
tags:
{{- range .Params.tags }}
  - {{ . }}
{{- end }}
{{- end }}
---

{{ .RawContent }}