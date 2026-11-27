# 终端 / Terminal

在 Windows 上执行命令，把标准输出和退出码返回给模型。带危险命令黑名单。

Run commands on Windows and return output, with a dangerous-command denylist.

> Local-Harness（Godot 版）的独立插件。不随主程序发布，由主程序
> 「设置 → 插件管理」从 GitHub 下载并自动部署到 `user://plugins/terminal/`。

## 安装

1. 打开 Local-Harness → 设置 → 插件管理 → 刷新列表
2. 找到「终端」点「安装」
3. 装好后在侧栏底部点同名按钮，里面是这个插件自己的设置页

手动安装：把本仓库下载解压到 `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\terminal\`

## 工具

- `terminal_run` —— 执行一条命令（cmd.exe /c），返回 stdout、stderr 和退出码。适合看文件、查系统信息、跑小脚本。（高危）
  - `command`: string，要执行的命令
  - `cwd`: string，可选，工作目录
  - `timeout`: int，可选，超时秒数，默认 30

## 命令

- `/sh dir` —— 执行一条命令

## 设置项

- **默认超时（秒）**（`timeout`，默认 `30`）命令超过这个时间会被强制结束
- **额外禁止的命令**（`extra_deny`，默认 ``）逗号分隔，例如 format,diskpart；留空表示只用内置黑名单

## 权限

每个工具都能在插件设置页里单独开关。关掉之后它不会出现在模型的工具清单里，
就算模型硬要调用也会被主程序拒绝。协议里用 `level` 标了风险等级：

- `read` 只读：不会改动任何东西
- `act` 会产生操作：会读写文件、联网或占用设备
- `danger` 高危：会操作你的系统

## 怎么用

装好后直接在对话里提需求，例如：“执行一条命令（cmd.exe /c），返回 stdout、stderr 和退出码。适合看文件、查系统信息、跑小脚本。”

模型会输出一行 ```tool 协议块，宿主解析后执行，再把结果喂回模型。
也可以直接用斜杠命令，不经过模型。

## 许可

GPL-3.0（与主程序一致）。完整协议文本见仓库根目录的 [LICENSE](LICENSE)。

---

# Terminal

Run commands on Windows and return output, with a dangerous-command denylist.

> An independent plugin for **Local-Harness (Godot edition)**. It is not bundled with the
> app; the app downloads it from this repository into `user://plugins/terminal/` and hot-loads it.

## Install

1. Local-Harness → Settings → Plugins → Refresh
2. Find "Terminal" and click Install
3. Open it from the button at the bottom of the sidebar for its own settings page

Manual: unzip this repo into `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\terminal\`

## Tools

- `terminal_run` — 执行一条命令（cmd.exe /c），返回 stdout、stderr 和退出码。适合看文件、查系统信息、跑小脚本。 (dangerous)
  - `command`: string，要执行的命令
  - `cwd`: string，可选，工作目录
  - `timeout`: int，可选，超时秒数，默认 30

## Commands

- `/sh dir` — 执行一条命令

## Settings

- **默认超时（秒）** (`timeout`, default `30`) 命令超过这个时间会被强制结束
- **额外禁止的命令** (`extra_deny`, default ``) 逗号分隔，例如 format,diskpart；留空表示只用内置黑名单

## Permissions

Every tool can be toggled individually on the plugin settings page. A disabled tool is
removed from the model's tool list and rejected by the host even if the model still calls it.
`level` in the manifest marks the risk:

- `read` — no side effects
- `act` — reads/writes, network or devices
- `danger` — controls your system

## Usage

Just ask in the chat, e.g. “执行一条命令（cmd.exe /c），返回 stdout、stderr 和退出码。适合看文件、查系统信息、跑小脚本。”

The model emits a ```tool block, the host executes it and feeds the result back.
You can also use the slash commands above, which skip the model entirely.

## License

GPL-3.0 (same as the host app). Full text: [LICENSE](LICENSE).
