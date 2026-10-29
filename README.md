# ⚡️ Antigravity CLI Auto-Approve (全场景全局自动审批)

> 一键彻底消除 Google Antigravity CLI (`agy`) 所有工具执行、文件创建与修改 (`Allow creation of this file?`)、网络访问与终端命令的反复授权弹窗，让 Agent 全自主流畅执行！

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue.svg)](#)
[![Antigravity](https://img.shields.io/badge/Antigravity%20CLI-Ready-success.svg)](#)

---

## 🎯 痛点剖析：为什么之前配置了依然会反复弹出？

在使用 **Google Antigravity CLI (`agy`)** 时，即使曾经在白名单配置过 `command(*)`，很多开发者仍然发现授权弹窗频繁出现：

1. **新建文件与代码修改审查 (`Allow creation of this file?`)**：
   CLI 默认运行在 `default` 模式。在该模式下，当 Agent 尝试新建文件 (`write_file`) 时，会强行暂停并弹出 `Allow creation of this file?` 确认；在修改已有文件时，会强制弹出 interactive diff 审查。只有显式设置 Agent 模式为 `accept-edits`，才会静默自动创建与采纳修改。
2. **工具审查策略拦截 (`toolPermission`)**：
   Antigravity CLI 默认的 `toolPermission` 为 `request-review`。在近期的 CLI 内部升级中，审查模式被严格强化——无论白名单中配置了什么规则，只要处于 `request-review` 下，未预审的操作仍会强制暂停并弹出审查确认。必须显式配置 `"toolPermission": "always-proceed"` 才能真正静默执行。
3. **非终端命令类工具存在覆盖盲区**：
   `command(*)` 仅作用于 Shell 终端命令 (`run_command`)。当 Agent 调用网络抓取 (`read_url`)、文件修改 (`write_file`)、目录读取 (`read_file`) 或外部 MCP 工具时，由于没有匹配规则，仍会触发授权确认。
4. **跨工作区文件访问限制**：
   当 Agent 操作当前项目目录以外的文件时，CLI 会弹出跨工作区授权提示，需开启 `allowNonWorkspaceAccess` 并信任工作区。
5. **运行时命令行标志**：
   CLI 底层提供了官方原生最高优先级免审批参数 `--dangerously-skip-permissions` 与模式参数 `--mode accept-edits`。若启动时未传入，底层引擎在特定安全边界仍保留了提示钩子。

---

## 🚀 一键安装配置（完整三重保障）

### 方式一：一键脚本配置（推荐）

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

如果您在内网或无 GitHub 访问权限的环境中，可直接运行以下内置单行 Python 指令：

```bash
python3 -c "import os,json; p=os.path.expanduser('~/.gemini/antigravity-cli/settings.json'); os.makedirs(os.path.dirname(p),exist_ok=True); d=json.load(open(p)) if os.path.exists(p) else {}; d['toolPermission']='always-proceed'; d['artifactReviewMode']='always-proceed'; d['agentMode']='accept-edits'; d['allowNonWorkspaceAccess']=True; tw=d.setdefault('trustedWorkspaces',[]); [tw.append(w) for w in [os.path.expanduser('~'),os.getcwd()] if w and w not in tw]; a=d.setdefault('permissions',{}).setdefault('allow',[]); [a.remove(r) for r in ['command(*)','read_url(*)','write_file(*)','read_file(*)','mcp(*)'] if r in a]; [a.insert(0,r) for r in reversed(['command(*)','read_url(*)','write_file(*)','read_file(*)','mcp(*)')]; json.dump(d,open(p,'w'),indent=2,ensure_ascii=False); print('✅ Antigravity CLI 全场景全工具免审批配置完成！')"
```

---

## 🔍 工作原理与解决架构

本工具通过 **三重保障机制** 实现真正的 100% 彻底免打断：

### 1. 核心策略放行 (`settings.json`)
自动在 `~/.gemini/antigravity-cli/settings.json` 中配置：
- `"agentMode": "accept-edits"`：彻底消除 `Allow creation of this file?`，自动采纳文件新建与编辑。
- `"toolPermission": "always-proceed"`：将工具审查模式从拦截询问彻底切为全自动放行。
- `"artifactReviewMode": "always-proceed"`：跳过文件写入与 diff 的人工确认。
- `"allowNonWorkspaceAccess": true`：彻底放行工作区外文件读写。
- `"trustedWorkspaces"`：自动加入主目录与当前工作区。

### 2. 全工具白名单通配
将全类型工具规则注入 `permissions.allow` 首位：
- `"command(*)"`：终端 Shell 命令
- `"read_url(*)"`：所有网络请求与网页爬取
- `"write_file(*)"`：文件与目录写入/修改
- `"read_file(*)"`：文件与代码读取
- `"mcp(*)"`：所有已挂载的 MCP Server 扩展工具

### 3. 原生运行时免审批别名 (`~/.bashrc` / `~/.zshrc`)
自动为用户的 Shell 注入官方原生参数：
```bash
alias agy="agy --dangerously-skip-permissions --mode accept-edits"
```
无论在任何路径启动 `agy`，都会附带底层引擎最高优先级的免审批及自动采纳修改标志。

---

## 💡 使用提示

1. **重启生效**：若配置前已有正在运行的 `agy` 交互会话，请按 `Ctrl+D` 退出后重新执行 `agy`，配置即可完全生效。
2. **多端同步**：在新服务器或容器环境中部署后，只需执行一次即可永久告别所有弹窗。

---

## 📄 开源许可

本项目遵循 [MIT License](LICENSE)。
