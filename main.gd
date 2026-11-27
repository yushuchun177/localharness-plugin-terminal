extends Node
## 终端插件 · local-harness
## 工具：terminal_run(command, cwd?, timeout?)
##
## 中文优先的三个细节：
## 1. 命令通过 UTF-16 的 .ps1 传给 PowerShell，中文参数不会在 cmd 那层被 GBK 解码弄坏；
## 2. 先 chcp 65001，让 cmd 内部工具输出 UTF-8；
## 3. 结果写进 UTF-8 文件再读回来，绕开控制台编码。
## 危险命令走黑名单直接拒绝。执行期间界面会卡住（同步调用），默认超时 30 秒。

const DENY := [
	"format ", "format.com", "diskpart", "rd /s", "rd/s", "rmdir /s",
	"del /f /s", "del/f/s", "shutdown", "cipher /w", "bcdedit",
	"reg delete", "takeown /f", "net user",
]



func _pref(key: String, def_value):
	var ml := Engine.get_main_loop()
	var prefs = ml.root.get_node_or_null("/root/PluginPrefs") if ml != null else null
	if prefs == null:
		return def_value
	return prefs.get_value("terminal", key, def_value)

func run(tool: String, args: Dictionary) -> Dictionary:
	if tool != "terminal_run":
		return {"ok": false, "output": "未知工具：%s" % tool}
	var cmd := str(args.get("command", "")).strip_edges()
	if cmd == "":
		return {"ok": false, "output": "command 不能为空"}
	var low := cmd.to_lower()
	var extra := str(_pref("extra_deny", "")).split(",")
	for e in extra:
		var ee := e.strip_edges().to_lower()
		if ee != "" and low.find(ee) >= 0:
			return {"ok": false, "output": "命令被你的插件设置拦截（包含 %s）" % ee}
	for bad in DENY:
		if low.find(bad) >= 0:
			return {"ok": false, "output": "命令被安全策略拦截（包含 %s）" % bad}

	var timeout := float(args.get("timeout", int(_pref("timeout", 30))))
	var out_file := OS.get_temp_dir().path_join("lh_term_%d.txt" % randi())
	var ps_file := OS.get_temp_dir().path_join("lh_term_%d.ps1" % randi())

	var script := _ps_script(cmd, out_file)
	var f := FileAccess.open(ps_file, FileAccess.WRITE)
	if f == null:
		return {"ok": false, "output": "写临时脚本失败"}
	f.store_buffer(PackedByteArray([0xFF, 0xFE]))
	f.store_buffer(script.to_utf16_buffer())
	f.close()

	var pid := OS.create_process("powershell.exe", PackedStringArray([
		"-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", ps_file]), false)
	if pid <= 0:
		return {"ok": false, "output": "进程启动失败"}

	var t0 := Time.get_ticks_msec()
	var timed_out := false
	while OS.is_process_running(pid):
		if (Time.get_ticks_msec() - t0) / 1000.0 > timeout:
			timed_out = true
			OS.kill(pid)
			break
		OS.delay_msec(40)

	var text := ""
	if FileAccess.file_exists(out_file):
		var rf := FileAccess.open(out_file, FileAccess.READ)
		if rf:
			text = rf.get_as_text()
		DirAccess.remove_absolute(out_file)
	DirAccess.remove_absolute(ps_file)
	if timed_out:
		return {"ok": false, "output": "命令超时（%.0f 秒）已终止。\n%s" % [timeout, text]}
	if text.length() > 8000:
		text = text.substr(0, 8000) + "\n…（输出过长，已截断）"
	return {"ok": true, "output": text if text.strip_edges() != "" else "（无输出）"}


func _ps_script(cmd: String, out_file: String) -> String:
	# PowerShell 字符串里双引号要写成反引号转义
	var inner := cmd.replace("`", "``").replace("\"", "`\"")
	return """
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$out = & cmd.exe /c "chcp 65001 >nul & CMDLINE" 2>&1 | Out-String
[System.IO.File]::WriteAllText('OUTFILE', $out, [System.Text.Encoding]::UTF8)
""".replace("CMDLINE", inner).replace("OUTFILE", out_file.replace("'", "''"))
