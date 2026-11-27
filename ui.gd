extends VBoxContainer
## 终端 —— 这个页面是插件自己提供的界面。
## 界面全部由插件自己拼，主程序只提供积木。

func build(plugin_id: String) -> void:
	add_theme_constant_override("separation", 12)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	add_child(PluginUI.section("执行设置"))
	add_child(PluginUI.slider_row(plugin_id, "timeout", "最长执行时间", 5, 120, 5, "秒", 30,
		"超过这个时间会被强制结束"))
	add_child(PluginUI.str_field(plugin_id, "extra_deny", "额外禁止的命令", "",
		"逗号分隔，例如 format,diskpart；留空只用内置黑名单"))

	add_child(PluginUI.section("试一下"))
	add_child(PluginUI.action_row("列一下当前目录", "安全命令，看看有没有权限", "执行 dir",
		func(): return Plugins.invoke("terminal_run", {"command": "dir /b"})))
	add_child(PluginUI.overview(plugin_id))
	add_child(PluginUI.permissions_section(plugin_id))
	add_child(PluginUI.doc_section(plugin_id))
