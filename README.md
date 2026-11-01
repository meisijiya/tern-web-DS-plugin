# WebDS

把 `chat.deepseek.com` 变成 Tern 里每个 tab 一个的浏览器块：状态栏点一下在当前 tab 旁打开（该 tab 已有则聚焦），站内链接收进当前 tab 的这个块。

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
| 状态栏 `WebDS` | 在当前 tab 右侧裂分打开 DeepSeek；该 tab 已有面板则聚焦（不同 tab 各一份，可同时躺在几个 agent 旁） |
| 命令面板 › `WebDS: Open DeepSeek` | 同上 |
| 点击 `*.deepseek.com` 链接 | 收进该点击所在 tab 的面板；块内点击按原样处理 |

## 依赖的 Tern 能力

- `cx:open(url, "beside")` 打开浏览器块，`cx.session:panes()` 找已有块
- `cx.browser:call{op="goto"}` 让已有的块跟着链接走
- `tern.chrome.status`、`tern.command`、`tern.route.link` 注册入口
