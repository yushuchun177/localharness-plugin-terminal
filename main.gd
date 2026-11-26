extends Node
## 终端插件 · local-harness
## 工具：terminal_run(command, cwd?, timeout?)
##
## 实现要点：
## - 用 cmd.exe /c 把输出重定向到临时文件，再用 create_process + 轮询读回来，
##   这样才能真正实现超时（OS.execute 是阻塞的，没法中断）
## - 危险命令走黑名单直接拒绝
## - 执行期间界面会卡住（同步调用），所以默认超时只有 30 秒

const DENY := [
	"format ", "format.com", "diskpart", "rd /s", "rd/s", "rmdir /s",
	"del /f /s", "del/f/s", "shutdown", "cipher /w", "bcdedit",
	"reg delete", "takeown /f", "net user",
]


func run(tool: String, args: Dictionary) -> Dictionary:
	if tool != "terminal_run":
		return {"ok": false, "output": "未知工具：%s" % tool}
	var cmd := str(args.get("command", "")).strip_edges()
	if cmd == "":
		return {"ok": false, "output": "command 不能为空"}
	var low := cmd.to_lower()
	for bad in DENY:
		if low.find(bad) >= 0:
			return {"ok": false, "output": "命令被安全策略拦截（包含 %s）" % bad}

	var timeout := float(args.get("timeout", 30))
	var tmp := OS.get_temp_dir().path_join("lh_term_%d.txt" % randi())
	var full := "%s > \"%s\" 2>&1" % [cmd, tmp]
	var pid := OS.create_process("cmd.exe", PackedStringArray(["/c", full]), false)
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
	if FileAccess.file_exists(tmp):
		var f := FileAccess.open(tmp, FileAccess.READ)
		if f:
			text = f.get_as_text()
		DirAccess.remove_absolute(tmp)
	if timed_out:
		return {"ok": false, "output": "命令超时（%.0f 秒）已终止。\n%s" % [timeout, text]}
	if text.length() > 8000:
		text = text.substr(0, 8000) + "\n…（输出过长，已截断）"
	return {"ok": true, "output": text if text.strip_edges() != "" else "（无输出）"}
