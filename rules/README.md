# ZKEEN Rules for Mihomo/Clash Meta

Автоматически сгенерированные правила из ZKEEN dat файлов.

## 📁 Структура

Каждый набор правил доступен в трех форматах:
- `.txt` - текстовый формат
- `.yaml` - YAML формат `payload:` 
- `.mrs` - MRS формат (для rule-providers)

## 🎯 Доступные наборы правил

### GeoIP (IP/CIDR):
- **akamai** (251 правил)
- **amazon** (4564 правил)
- **cdn77** (171 правил)
- **cloudflare** (844 правил)
- **cn** (1 правил)
- **colocrossing** (308 правил)
- **contabo** (334 правил)
- **digitalocean** (174 правил)
- **discord** (5 правил)
- **fastly** (36 правил)
- **gcore** (345 правил)
- **google** (96 правил)
- **hetzner** (90 правил)
- **linode** (247 правил)
- **mega** (14 правил)
- **meta** (46 правил)
- **oracle** (710 правил)
- **ovh** (545 правил)
- **ru** (12805 правил)
- **scaleway** (12 правил)
- **telegram** (7 правил)
- **vultr** (123 правил)
- **youtube** (8 правил)

### GeoSite (домены):
- **bypass** (1 правил)
- **cn** (1 правил)
- **domains** (540 правил)
- **other** (827 правил)
- **politic** (163 правил)
- **youtube** (12 правил)

## 🔧 Использование

### MRS формат (рекомендуется):
```yaml
rule-providers:
  geoip_cn:
    type: http
    behavior: ipcidr
    url: "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/rules/geoip/cn.mrs"
    interval: 86400
  
  geosite_cn:
    type: http
    behavior: domain
    url: "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/rules/geosite/cn.mrs"
    interval: 86400
```

### YAML формат:
```yaml
rule-providers:
  geoip_cn:
    type: http
    behavior: ipcidr
    url: "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/rules/geoip/cn.yaml"
    interval: 86400
```

## ⚙️ Автоматическое обновление

Обновляется каждые 6 часов.

Последнее обновление: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
