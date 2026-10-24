#!/usr/bin/env bash
# =============================================================
# REST API 兜底通道：当 git 协议被代理/网络阻断时用它提交
# 依赖 gh（GitHub CLI）已登录且对仓库有写权限
# 用法:
#   ./tools/api-sync.sh cat        <文件>                  读取远端文件内容
#   ./tools/api-sync.sh push-file  <文件> [说明]           用本地文件内容整体覆盖远端
#   ./tools/api-sync.sh append     <文件> <一行文本>       在远端文件末尾追加一行（推荐，无冲突）
#   ./tools/api-sync.sh ls                                 列出远端全部文件路径
# 安全: 所有更新都必须携带 sha，内容被改过会 409 拒绝并自动重试一次，不会静默覆盖。
# =============================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OWNER="Topdeckhuang"
REPO="personal-ai-archive"
BRANCH="${BRANCH:-main}"
# 远端文件不存在时 gh 会返回非 0，这里必须吞掉错误，否则 set -e/pipefail 会让脚本静默退出
api_get() { gh api "repos/$OWNER/$REPO/contents/$1?ref=$BRANCH" --jq . 2>/dev/null || true; }

die()  { printf '✗ %s\n' "$*" >&2; exit 1; }
info() { printf '✓ %s\n' "$*"; }
warn() { printf '! %s\n' "$*"; }

need_file() { [ -n "${1:-}" ] || die "缺少文件路径"; }

B64_TOOL() { printf '%s' "$2" | base64 | tr -d '\n'; }

api_put() { # $1=远端路径 $2=base64内容 $3=说明 $4=sha(可空)
  local path="$1" b64="$2" msg="$3" sha="${4:-}" tmp
  tmp=$(mktemp); printf '%s' "$b64" > "$tmp"
  if [ -n "$sha" ]; then
    gh api -X PUT "repos/$OWNER/$REPO/contents/$path" \
      -f message="$msg" -F content=@"$tmp" -f sha="$sha" -f branch="$BRANCH" --jq '.commit.sha'
  else
    gh api -X PUT "repos/$OWNER/$REPO/contents/$path" \
      -f message="$msg" -F content=@"$tmp" -f branch="$BRANCH" --jq '.commit.sha'
  fi
  rm -f "$tmp"
}

cmd_cat() {
  need_file "${1:-}"
  api_get "$1" | jq -r '.content' | base64 --decode || die "读取失败: $1"
}

cmd_ls() {
  gh api "repos/$OWNER/$REPO/git/trees/$BRANCH?recursive=1" --jq '.tree[] | select(.type=="blob") | .path'
}

cmd_push_file() {
  local path="$1" msg="${2:-chore($1): update via api-sync}"
  need_file "$path"
  [ -f "$path" ] || die "本地文件不存在: $path"
  local b64 sha out
  b64=$(base64 -i "$path" | tr -d '\n')
  sha=$(api_get "$path" | jq -r '.sha // empty')
  out=$(api_put "$path" "$b64" "$msg" "$sha" 2>/dev/null) || {
    warn "首次提交失败（可能 sha 已过期），自动取新 sha 重试一次 ..."
    sha=$(api_get "$path" | jq -r '.sha // empty')
    out=$(api_put "$path" "$b64" "$msg" "$sha") || die "重试仍失败，请手动处理: $path"
  }
  info "已更新 $path -> commit ${out:0:7}"
}

cmd_append() {
  local path="$1" line="$2"
  need_file "$path"
  [ -n "$line" ] || die "追加内容不能为空。用法: ./tools/api-sync.sh append <文件> \"<一行文本>\""
  local sha content new_content new_b64 out msg
  sha=$(api_get "$path" | jq -r '.sha // empty')
  [ -n "$sha" ] || die "远端文件不存在: $path"
  content=$(api_get "$path" | jq -r '.content' | base64 --decode)
  new_content=$(printf '%s\n%s\n' "$content" "$line")
  new_b64=$(printf '%s' "$new_content" | base64 | tr -d '\n')
  msg="memory: append via api-sync"
  out=$(api_put "$path" "$new_b64" "$msg" "$sha" 2>/dev/null) || {
    warn "sha 冲突，重新拉取后重试 ..."
    sha=$(api_get "$path" | jq -r '.sha')
    content=$(api_get "$path" | jq -r '.content' | base64 --decode)
    new_b64=$(printf '%s\n%s\n' "$content" "$line" | base64 | tr -d '\n')
    out=$(api_put "$path" "$new_b64" "$msg" "$sha") || die "重试仍失败，请手动处理"
  }
  info "已追加到 $path -> commit ${out:0:7}"
}

case "${1:-}" in
  cat)        cmd_cat "${2:-}" ;;
  push-file)  cmd_push_file "${2:-}" "${3:-}" ;;
  append)     cmd_append "${2:-}" "${3:-}" ;;
  ls)         cmd_ls ;;
  *)          echo "可用命令: cat <文件> | push-file <文件> [说明] | append <文件> \"<一行文本>\" | ls" ;;
esac
