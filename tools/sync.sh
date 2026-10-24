#!/usr/bin/env bash
# =============================================================
# personal-ai-archive 多端同步助手
# 用法:
#   ./tools/sync.sh pull                       拉取最新（自动 rebase + autostash）
#   ./tools/sync.sh push  "提交说明"            自动 pull -> commit -> push
#   ./tools/sync.sh status                     查看与远端领先的/落后的提交
#   ./tools/sync.sh track  <文件>               查看某文件的全部修改历史
#   ./tools/sync.sh revert <文件> <commit>      把单个文件回退到指定版本
#   ./tools/sync.sh newlog                     为下个月生成空的月度日志模板
#   ./tools/sync.sh conflicts                  扫描冲突标记
# 设计原则: push 前强制 pull；不做任何自动删除；破坏性操作必须显式传参。
# =============================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; DIM=$'\033[2m'; RST=$'\033[0m'
info() { printf '%s\n' "${GRN}✓${RST} $*"; }
warn() { printf '%s\n' "${YLW}!${RST} $*"; }
die()  { printf '%s\n' "${RED}✗${RST} $*" >&2; exit 1; }
need() { [ $# -ge 1 ] && [ -n "$1" ] || die "$2"; }

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

cmd_pull() {
  info "拉取远端 [$BRANCH] ..."
  if ! git pull --rebase --autostash origin "$BRANCH"; then
    warn "拉取失败。若本机 git 网络被阻断（常见于代理环境），改用 REST API 通道："
    printf '    %s\n' "./tools/api-sync.sh cat <文件路径>"
    exit 1
  fi
  info "已同步到 $(git rev-parse --short HEAD)"
}

cmd_push() {
  local msg="$1"
  need "$msg" "提交说明不能为空。用法: ./tools/sync.sh push \"<type>(<file>): <简述>\""
  [ -n "$(git status --porcelain)" ] || die "没有待提交的改动"

  info "提交前先拉取远端，避免冲突 ..."
  git pull --rebase --autostash origin "$BRANCH" >/dev/null || die "拉取失败，请先解决冲突（见 ./tools/sync.sh conflicts）"

  git add -A
  git commit -m "$msg"
  if git push origin "$BRANCH"; then
    info "已推送 $(git rev-parse --short HEAD)"
  else
    warn "git push 失败（代理环境的典型症状是 CONNECT tunnel failed 502）。"
    printf '    可改用 REST API 通道：%s\n' "./tools/api-sync.sh push-file <文件路径>"
    printf '    （提交已在本地完成，数据不会丢）\n'
    exit 1
  fi
  echo "${DIM}提示: 记得在 CHANGELOG.md 追加一行修改留痕${RST}"
}

cmd_status() {
  git fetch origin "$BRANCH" >/dev/null 2>&1 || warn "无法连接远端，显示的是本地缓存状态"
  local ahead behind
  ahead=$(git rev-list --left-right --count "origin/$BRANCH...HEAD" 2>/dev/null | awk '{print $2}' || echo "?")
  behind=$(git rev-list --left-right --count "origin/$BRANCH...HEAD" 2>/dev/null | awk '{print $1}' || echo "?")
  printf '分支 %s | 落后远端 %s 个提交 | 领先远端 %s 个提交\n' "$BRANCH" "${behind:-?}" "${ahead:-?}"
  echo
  git status --short
}

cmd_track() {
  local f="$1"
  need "$f" "用法: ./tools/sync.sh track <文件路径>"
  info "[$f] 的修改历史："
  git log --date=short --pretty=format:'  %h  %ad  %s' -- "$f" || true
  echo
}

cmd_revert() {
  local f="$1" c="${2:-}"
  need "$f" "用法: ./tools/sync.sh revert <文件路径> <commit>"
  need "$c" "缺少 commit 哈希。用 ./tools/sync.sh track <文件> 查看历史"
  git cat-file -e "$c" 2>/dev/null || die "commit 不存在: $c"
  warn "即将把 [$f] 恢复到 $c 的版本，当前内容会被覆盖（但历史仍可找回）"
  git show "$c:$f" > "$f"
  info "已从 $c 恢复 $f，请 diff 确认后提交："
  printf '    %s\n' "git diff -- $f"
  printf '    %s\n' "./tools/sync.sh push \"revert: 恢复 $f 到 $c\""
}

cmd_newlog() {
  local next f tmpl
  next=$(date -v+1m +%Y-%m 2>/dev/null || date -u -d "+1 month" +%Y-%m)
  f="memory/logs/${next}.md"
  tmpl="docs/_templates/month-log.md"
  [ -f "$f" ] && die "$f 已存在"
  [ -f "$tmpl" ] || die "缺少模板 $tmpl"
  sed "s/{{YYYY-MM}}/${next}/g" "$tmpl" > "$f"
  info "已生成 $f，填好后执行："
  printf '    %s\n' "./tools/sync.sh push \"chore(memory): 新建 ${next} 月度日志\""
}

cmd_conflicts() {
  local found
  found=$(grep -rln "^\(<<<<<<<\|=======\|>>>>>>>\)" --exclude-dir=.git . || true)
  if [ -n "$found" ]; then
    warn "以下文件存在冲突标记，请手动处理："
    printf '    %s\n' $found
  else
    info "没有发现冲突标记"
  fi
}

case "${1:-status}" in
  pull)      cmd_pull ;;
  push)      cmd_push "${2:-}" ;;
  status)    cmd_status ;;
  track)     cmd_track "${2:-}" ;;
  revert)    cmd_revert "${2:-}" "${3:-}" ;;
  newlog)    cmd_newlog ;;
  conflicts) cmd_conflicts ;;
  *)         echo "可用命令: pull | push <msg> | status | track <file> | revert <file> <commit> | newlog | conflicts" ;;
esac
