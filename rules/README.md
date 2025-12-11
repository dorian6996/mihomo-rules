# ZKEEN Rules для Mihomo/Clash Meta

Автоматически сгенерированные правила из ZKEEN dat файлов.

## 📁 Структура

```
rules/
├── geoip/           # GeoIP правила (IP/CIDR)
│   ├── cn.txt       # Текстовый формат
│   ├── cn.yaml      # YAML формат (payload)
│   ├── cn.mrs       # MRS формат (через mihomo)
│   ├── ru.txt
│   ├── ru.yaml
│   └── ru.mrs
├── geosite/         # GeoSite правила (домены)
│   ├── cn.txt
│   ├── cn.yaml
│   ├── cn.mrs
│   ├── youtube.txt
│   ├── youtube.yaml
│   └── youtube.mrs
└── example_usage.md # Примеры использования
```

## 🎯 Назначение форматов

1. **TXT** - для просмотра и ручного использования
2. **YAML** - формат `payload:` для прямого использования в rule-providers
3. **MRS** - бинарный формат (создается ТОЛЬКО через `mihomo convert-ruleset`)

## ⚙️ Автоматизация

Обновление каждые 6 часов через GitHub Actions.

## 📝 Источники

- GeoIP: https://github.com/jameszeroX/zkeen-ip
- GeoSite: https://github.com/jameszeroX/zkeen-domains

Последнее обновление: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
