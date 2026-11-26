# 终端

在 Windows 上执行命令并返回输出，带危险命令黑名单。

Local-Harness（Godot 版）的独立插件。**不随主程序发布**，由主程序「设置 → 插件管理」从 GitHub 下载并自动部署到 `user://plugins/terminal/`。

## 工具

- `terminal_run` —— 执行一条命令（cmd.exe /c），返回 stdout、stderr 和退出码。适合看文件、查系统信息、跑小脚本。
  - `command`: string，要执行的命令
  - `cwd`: string，可选，工作目录
  - `timeout`: int，可选，超时秒数，默认 30

## 安装

1. 打开 Local-Harness → 设置 → 插件管理 → 刷新列表
2. 找到「终端」点安装
3. 装完直接在对话里让模型调用即可（插件会出现在系统提示的工具清单里）

也可以手动：把本仓库下载解压到 `%LOCALAPPDATA%\Godot\app_userdata\Local-Harness\plugins\terminal\`。

## 结构

```
manifest.json   清单：id / 版本 / 工具定义
main.gd         extends Node，实现 run(tool, args) -> {ok, output}
```

## 许可

GPL-3.0（与主程序一致）。
