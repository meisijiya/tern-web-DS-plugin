# WebDS

把 `chat.deepseek.com` 变成 Tern 里一个常驻的浏览器块：状态栏点一下打开（已开会聚焦），站内链接一律收进这个块。

登录态由 Tern 浏览器块共享的网站数据区保存，登录一次即可跨重启；插件本身不存任何凭据。细节见 [`GLOSSARY.md`](GLOSSARY.md) 与 [`docs/adr/`](docs/adr)。

## 安装

```bash
tern plugin link D:/26code/tern-web-DS-plugin
tern plugin list      # deepseek-web … window ready
```

改动 `main.luau` 后 `tern plugin reload deepseek-web`。

## 用法

| 入口 | 行为 |
| --- | --- |
| 状态栏 `WebDS` | 打开 DeepSeek（右侧裂分）；已打开则聚焦 |
| 命令面板 › `WebDS: Open DeepSeek` | 同上 |
| 点击 `*.deepseek.com` 链接 | 在 DeepSeek 块里打开；块内点击按原样处理 |

## 依赖的 Tern 能力

- `cx:open(url, "beside")` 打开浏览器块，`cx.session:panes()` 找已有块
- `cx.browser:call{op="goto"}` 让已有的块跟着链接走
- `tern.chrome.status`、`tern.command`、`tern.route.link` 注册入口
