# GLOSSARY

本项目的领域术语与边界；实现细节在 README 与 ADR 里。

## Browser block

Tern 原生的网页块（Windows 上渲染于 WebView2）。由内置命令 `new_browser_block`、`cx:open(url)` 或 `tern browser` 打开，**不是**插件块：插件只负责触发它、给它地址、按链接导航它。

## Website data store（网站数据区）

浏览器块共用的浏览器数据（cookie、localStorage、缓存）落点：`%LOCALAPPDATA%\so.stencil.tern\WebView2\EBWebView`。

- Windows 上**所有**浏览器块始终共用一个数据区（`settings.browser_data` 的 `Repository` / `Session` 只在 macOS 与 Linux 生效）。
- 它与系统 Chrome、ego 浏览器的 profile **不互通**：共用的只是 Tern 自己的块之间。

## WebDS

本插件（`plugin.toml` 的 `id = "deepseek-web"`）：在浏览器块里打开并复用 `chat.deepseek.com`，并把站内链接收进这个块。
