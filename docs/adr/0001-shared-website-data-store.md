# 0001 DeepSeek 的登录态交给 Tern 的共享网站数据区

## 状态

已采纳。

## 背景

WebDS 需要一个「点一下就能用已登录账号」的 DeepSeek 面板。可选载体有三类：

1. 系统默认浏览器（Chrome / 外部应用）：登录态现成，但不再是 Tern 里的面板。
2. Tern 浏览器块 + 命名 profile（`settings.browser_profiles`）。
3. Tern 浏览器块 + 默认共享数据区（`browser_data = shared`）。

## 决策

选 3：插件不创建 profile、不改 `browser_data`，直接打开浏览器块。

## 理由

- `settings.browser_data` 的 `Repository` / `Session` 只在 macOS 与 Linux 生效；Windows 上所有浏览器块本来就共用数据区，profile 参数没有可依赖的语义。
- 共享数据区在磁盘上是持久目录（`%LOCALAPPDATA%\so.stencil.tern\WebView2\EBWebView`），登录一次即可跨 Tern 重启。
- 插件不写任何凭据：登录由用户在页面里完成，插件只负责把同一个页面再打开一次。

## 后果

- 与系统 Chrome、ego 浏览器的登录态**不互通**，DeepSeek 需要在 Tern 里单独登录一次。
- 清空该目录等于登出所有站点的 Tern 侧会话。
- 若将来 Tern 让 profile 在 Windows 生效，再评估是否要给 WebDS 单独分栏。
