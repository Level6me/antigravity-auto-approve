# ⚡️ Antigravity CLI Auto-Approve (终端命令一键自动审批)

> 一键配置 Google Antigravity CLI (`agy`)，彻底消除每次执行终端命令时反复弹出的 `Run this command?` 四项选择弹窗，让 Agent 全自主流畅执行！

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue.svg)](#)
[![Antigravity](https://img.shields.io/badge/Antigravity%20CLI-Ready-success.svg)](#)

---

## 🎯 痛点背景

在使用 **Google Antigravity CLI (`agy`)** 进行 AI 辅助编程时，每当 Agent 准备运行终端命令（如 `cat`、`git`、`ls`、`python` 等），CLI 都会打断执行并在终端中弹窗询问：

```text
Run this command?
> 1. Yes, run command
  2. Yes, and always allow for commands that start with '...' in this conversation
  3. Yes, and always allow for commands that start with '...' (Persist to settings.json)
  4. No, and always deny for ...
```

### 为什么即使选了“保存”依然会反复弹出？
Antigravity 默认的白名单是基于**精确命令前缀匹配**的。即使你选择了选项 3（写入 `settings.json`），只要后续命令的工具名、参数或脚本路径稍有变化，CLI 依然无法命中白名单，从而频繁弹出这 4 个选项，严重打断心流与自动化工作流。

---

## 🚀 一键安装配置

### 方式一：在线脚本一键配置（推荐）

在任何终端中直接粘贴执行以下命令：

```bash
curl -fsSL https://raw.githubusercontent.com/Level6me/antigravity-auto-approve/main/install.sh | bash
```

或者使用短别名：

```bash
curl -fsSL https://raw.githubusercontent.com/Level6me/antigravity-auto-approve/main/auto_approve.sh | bash
```

---

### 方式二：纯单行离线指令（无需联网）

如果您在无外部网络或无法访问 GitHub 的环境中，可直接运行以下内置单行 Python 指令：

```bash
python3 -c "import os,json; p=os.path.expanduser('~/.gemini/antigravity-cli/settings.json'); os.makedirs(os.path.dirname(p),exist_ok=True); d=json.load(open(p)) if os.path.exists(p) else {}; a=d.setdefault('permissions',{}).setdefault('allow',[]); 'command(*)' in a or a.insert(0,'command(*)'); json.dump(d,open(p,'w'),indent=2,ensure_ascii=False); print('✅ Antigravity CLI 自动审批配置完成！')"
```

---

## 🔍 工作原理

脚本会自动解析并修改 Antigravity CLI 的配置文件：
`~/.gemini/antigravity-cli/settings.json`

将底层原生支持的全局通配符规则 `"command(*)"` 插入到 `permissions.allow` 白名单的首位：

```json
{
  "permissions": {
    "allow": [
      "command(*)",
      "read_url(*)"
    ]
  }
}
```

配置完成后，所有由 Agent 发起的终端命令都将自动静默放行，无需任何人工确认。

---

## 💡 使用提示

1. **会话重启**：如果配置时您已打开了正在运行中的 `agy` 终端会话，请按 `Ctrl+D` 退出后重新启动 `agy`，新配置即可完全生效。
2. **多设备同步**：在新机器或远程服务器上部署 Antigravity CLI 后，只需运行一次上述一行命令即可免除后续所有弹窗。

---

## 🔄 如何恢复 / 撤回

如果您后续需要重新启用严格的权限询问，运行以下命令即可将通配规则移除：

```bash
python3 -c "import os,json; p=os.path.expanduser('~/.gemini/antigravity-cli/settings.json'); d=json.load(open(p)); a=d.get('permissions',{}).get('allow',[]); 'command(*)' in a and a.remove('command(*)'); json.dump(d,open(p,'w'),indent=2); print('已恢复默认权限确认模式。')"
```

---

## 📄 开源许可

本项目遵循 [MIT License](LICENSE)。
