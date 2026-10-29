#!/usr/bin/env bash
# ==============================================================================
# Antigravity CLI Auto-Approve Installer
# ⚡️ 一键自动配置 Google Antigravity CLI (agy) 全局工具、代码与命令免审批
# GitHub: https://github.com/Level6me/antigravity-auto-approve
# ==============================================================================

set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}"
echo "=================================================================="
echo "   🚀 Antigravity CLI (agy) 全局全自动免审批一键配置工具"
echo "=================================================================="
echo -e "${NC}"

SETTINGS_DIR="$HOME/.gemini/antigravity-cli"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

# 1. 确保配置目录存在
if [ ! -d "$SETTINGS_DIR" ]; then
    echo -e "${BLUE}📁 创建 Antigravity CLI 配置目录: ${SETTINGS_DIR}${NC}"
    mkdir -p "$SETTINGS_DIR"
fi

# 2. 检查 Python 3 环境
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ 未检测到 Python 3，请先安装 Python 3 后再运行本脚本。${NC}"
    exit 1
fi

# 3. 执行安全的 JSON 注入
python3 - << 'EOF'
import os
import sys
import json
import shutil

path = os.path.expanduser('~/.gemini/antigravity-cli/settings.json')
data = {}

if os.path.exists(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        backup_path = path + ".bak"
        shutil.copyfile(path, backup_path)
        print(f"⚠️ 现有的 settings.json 解析异常，已为您备份至 {backup_path}")
        data = {}

# 1. 设置免审批核心策略
data["toolPermission"] = "always-proceed"
data["artifactReviewMode"] = "always-proceed"
data["agentMode"] = "accept-edits"
data["allowNonWorkspaceAccess"] = True

# 2. 自动信任当前用户主目录与工作区
trusted = data.setdefault("trustedWorkspaces", [])
home_dir = os.path.expanduser("~")
cwd = os.getcwd()
for ws in [home_dir, cwd]:
    if ws and ws not in trusted:
        trusted.append(ws)

# 3. 确保 permissions.allow 存在并注入全量工具通配符
if 'permissions' not in data or not isinstance(data['permissions'], dict):
    data['permissions'] = {}

if 'allow' not in data['permissions'] or not isinstance(data['permissions']['allow'], list):
    data['permissions']['allow'] = []

allow_list = data['permissions']['allow']

rules = [
    "command(*)",
    "read_url(*)",
    "write_file(*)",
    "read_file(*)",
    "mcp(*)"
]

for r in reversed(rules):
    if r in allow_list:
        allow_list.remove(r)
    allow_list.insert(0, r)

# 回写配置
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("✨ 已成功注入核心策略配置：")
print("   - toolPermission: 'always-proceed' (工具执行免审查)")
print("   - artifactReviewMode: 'always-proceed' (差异预览免确认)")
print("   - agentMode: 'accept-edits' (自动创建/采纳文件修改，免除 'Allow creation of this file?')")
print("   - allowNonWorkspaceAccess: true (跨目录文件访问免确认)")
print("   - permissions.allow: command(*), read_url(*), write_file(*), read_file(*), mcp(*)")
EOF

# 4. 配置 Shell 别名 (自动附加原生 --dangerously-skip-permissions 与 --mode accept-edits)
ALIAS_CMD='alias agy="agy --dangerously-skip-permissions --mode accept-edits"'

for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ]; then
        if grep -q "alias agy=" "$rc"; then
            sed -i 's|alias agy=.*|'"$ALIAS_CMD"'|g' "$rc"
            echo -e "${BLUE}🔧 已更新 $rc 中的免审批启动别名${NC}"
        else
            echo "" >> "$rc"
            echo "# Added by antigravity-auto-approve" >> "$rc"
            echo "$ALIAS_CMD" >> "$rc"
            echo -e "${BLUE}🔧 已为 $rc 添加原生免审批启动别名${NC}"
        fi
    fi
done

echo -e "${GREEN}${BOLD}"
echo "=================================================================="
echo "✅ 配置完成！Antigravity CLI 已开启全场景全自动免审批。"
echo "=================================================================="
echo -e "${NC}"
echo -e "${YELLOW}💡 提示：${NC}"
echo -e "   1. 终端命令、代码新建与修改 (write_file/edit_file)、网页抓取 (read_url) 与 MCP 工具均已静默放行；"
echo -e "   2. 彻底免除 'Allow creation of this file?' 及代码差异确认弹窗；"
echo -e "   3. 终端启动别名已配置为原生参数 --dangerously-skip-permissions --mode accept-edits；"
echo -e "   4. 若当前终端已有正在运行的 agy 会话，请按 ${CYAN}Ctrl+D${NC} 退出后重新启动 agy 即可生效。"
echo ""
