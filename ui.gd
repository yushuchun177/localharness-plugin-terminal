extends VBoxContainer
## 本插件的设置界面 —— 由插件自己提供，主程序只负责挂载。
## 想改这个插件在这里长什么样、有哪些开关，改这个文件即可。

func build(plugin_id: String) -> void:
	add_theme_constant_override("separation", 10)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(PluginUI.title("终端"))
	add_child(PluginUI.hint("让模型在你电脑上执行命令行。危险命令内置拦截，你也可以自己加规则。"))
	add_child(PluginUI.section("行为"))
	add_child(PluginUI.int_field(plugin_id, "timeout", "默认超时（秒）", 30,
		"命令跑太久会被强制结束，防止卡死"))
	add_child(PluginUI.str_field(plugin_id, "extra_deny", "额外禁止的命令", "",
		"逗号分隔，例如 format,diskpart；留空只用内置黑名单"))
	add_child(PluginUI.section("能力开关"))
	add_child(PluginUI.hint("每一项都能单独关掉；关掉后模型看不到这个能力，也调用不了。"))
	for t in Plugins.tools_of(plugin_id):
		var tname := str(t.get("name", ""))
		var human := tname
		var desc := str(t.get("description", ""))
		if tname == "terminal_run":
			human = "执行命令"
			desc = "在 cmd 里跑一条命令并拿回输出"
		add_child(PluginUI.perm_row(tname, human, desc, bool(t.get("dangerous", false))))
	add_child(PluginUI.readme_box(plugin_id))
