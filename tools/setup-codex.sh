#!/usr/bin/env bash
# =============================================================
# 把 personal-ai-archive 接入本机 Codex（幂等，可回滚）
#   ./tools/setup-codex.sh           安装
#   ./tools/setup-codex.sh --check   只检查安装状态
#   ./tools/setup-codex.sh --dry-run 显示将做什么，不写入
#   ./tools/setup-codex.sh --rollback 从最近一次备份恢复 AGENTS.md
#
# 它做三件事，全部有备份：
#   1. 把仓库放到 ~/personal-ai-archive（不存在则 clone，存在则 pull）
#   2. 安装桥接规则到 ~/.codex/instructions/archive-bridge.md
#   3. 向 ~/.codex/AGENTS.md 末尾追加一段指针（已有则跳过，绝不覆写原有内容）
# =============================================================
set -euo pipefail

ARCHIVE_DIR="${ARCHIVE_DIR:-$HOME/personal-ai-archive}"
REPO_URL="https://github.com/Topdeckhuang/personal-ai-archive.git"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
AGENTS="$CODEX_DIR/AGENTS.md"
BRIDGE="$CODEX_DIR/instructions/archive-bridge.md"
MARKER_BEGIN="<!-- personal-ai-archive bridge v1 begin -->"

DRY=0
ok()   { printf '  [OK]   %s\n' "$*"; }
miss() { printf '  [--]   %s\n' "$*"; }
act()  { printf '  [>>]   %s\n' "$*"; }
die()  { printf '\n  [!!] %s\n' "$*" >&2; exit 1; }

MODE="${1:-install}"
case "$MODE" in
  install) ;;
  --check) ;;
  --dry-run) DRY=1 ;;
  --rollback) ;;
  *) echo "用法: $0 [--check | --dry-run | --rollback]"; exit 2 ;;
esac

report() { # $1=标题
  printf '\n=== %s ===\n' "$1"
}

# ---------- --check ----------
if [ "$MODE" = "--check" ]; then
  report "安装状态检查（$(hostname -s)）"
  [ -d "$ARCHIVE_DIR/.git" ] && ok "仓库存在: $ARCHIVE_DIR" || miss "仓库不存在: $ARCHIVE_DIR"
  [ -f "$BRIDGE" ] && ok "桥接规则: $BRIDGE" || miss "桥接规则缺失"
  if [ -f "$AGENTS" ]; then
    grep -q "$MARKER_BEGIN" "$AGENTS" && ok "AGENTS.md 已植入指针" || miss "AGENTS.md 未植入指针"
  else
    miss "AGENTS.md 不存在: $AGENTS"
  fi
  command -v codex >/dev/null 2>&1 && ok "codex: $(codex --version 2>/dev/null | head -1)" || miss "未安装 codex"
  command -v gh >/dev/null 2>&1 && ok "gh 已安装（REST 兜底通道可用）" || miss "未安装 gh"
  exit 0
fi

# ---------- --rollback ----------
if [ "$MODE" = "--rollback" ]; then
  report "回滚 AGENTS.md"
  bak=$(ls -t "$CODEX_DIR"/AGENTS.md.backup-archive-* 2>/dev/null | head -1 || true)
  [ -n "$bak" ] || die "没有找到备份文件（$CODEX_DIR/AGENTS.md.backup-archive-*）"
  cp -p "$AGENTS" "$CODEX_DIR/AGENTS.md.before-rollback-$(date +%Y%m%d-%H%M%S)"
  cp -p "$bak" "$AGENTS"
  ok "已从 $(basename "$bak") 恢复 AGENTS.md"
  printf '  shasum: %s\n' "$(shasum -a 256 "$AGENTS" | cut -d' ' -f1)"
  exit 0
fi

report "接入 Codex（$(hostname -s)）"

# ---------- 前置检查 ----------
[ -d "$CODEX_DIR" ] || die "未找到 Codex 配置目录：$CODEX_DIR"
[ -f "$AGENTS" ]    || die "未找到 $AGENTS，请先在 Codex 里生成一次全局规则"
command -v git >/dev/null || die "需要 git"
mkdir -p "$CODEX_DIR/instructions"

# ---------- 1. 仓库 ----------
if [ -d "$ARCHIVE_DIR/.git" ]; then
  ok "仓库已存在，拉取最新"
  [ "$DRY" = 1 ] || git -C "$ARCHIVE_DIR" pull --rebase --autostash >/dev/null 2>&1 || printf '  [!] pull 失败，继续用现有副本\n'
elif [ -d "$ARCHIVE_DIR" ]; then
  ok "目录已存在但无 .git，原样使用：$ARCHIVE_DIR"
else
  if [ "$DRY" = 1 ]; then act "将 clone 到 $ARCHIVE_DIR"; else
    git clone -q "$REPO_URL" "$ARCHIVE_DIR"; ok "已 clone: $ARCHIVE_DIR"
  fi
fi

# ---------- 2. 桥接规则 ----------
SNIPPET="$ARCHIVE_DIR/integrations/codex/AGENTS-snippet.md"
SOURCE="$ARCHIVE_DIR/integrations/codex/archive-bridge.md"
[ -f "$SOURCE" ] || die "缺少 $SOURCE"
[ -f "$SNIPPET" ] || die "缺少 $SNIPPET"

if [ "$DRY" = 1 ]; then
  act "将安装 $SOURCE -> $BRIDGE"
else
  if [ -f "$BRIDGE" ] && ! diff -q "$SOURCE" "$BRIDGE" >/dev/null 2>&1; then
    cp -p "$BRIDGE" "$BRIDGE.backup-$(date +%Y%m%d-%H%M%S)"; act "旧桥接规则已备份"
  fi
  mkdir -p "$(dirname "$BRIDGE")"
  cp -p "$SOURCE" "$BRIDGE"
  ok "桥接规则已安装: $BRIDGE"
fi

# ---------- 3. AGENTS.md 追加 ----------
if grep -q "$MARKER_BEGIN" "$AGENTS" 2>/dev/null; then
  ok "AGENTS.md 已含指针，跳过（幂等）"
else
  bak="$CODEX_DIR/AGENTS.md.backup-archive-$(date +%Y%m%d-%H%M%S)"
  if [ "$DRY" = 1 ]; then
    act "将备份 $AGENTS -> $(basename "$bak")"
    act "将在 AGENTS.md 末尾追加指针（$(cat "$SNIPPET" | wc -l | tr -d ' ') 行，不改动任何现有内容）"
    act "追加内容预览："
    sed 's/^/        /' "$SNIPPET"
  else
    cp -p "$AGENTS" "$bak"
    ok "已备份 AGENTS.md -> $(basename "$bak")"
    printf '\n' >> "$AGENTS"
    cat "$SNIPPET" >> "$AGENTS"
    ok "已追加指针到 AGENTS.md"
  fi
fi

report "完成"
printf '  仓库:       %s\n' "$ARCHIVE_DIR"
printf '  规则:       %s\n' "$BRIDGE"
printf '  AGENTS.md:  %s (%s 行)\n' "$AGENTS" "$(wc -l < "$AGENTS" | tr -d ' ')"
[ "$DRY" = 1 ] && printf '  [DRY-RUN] 未做任何实际修改\n'
printf '\n  校验: %s --check\n  回滚: %s --rollback\n' "$0" "$0"
