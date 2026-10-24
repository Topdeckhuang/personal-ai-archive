<!-- personal-ai-archive bridge v1 begin -->
## 5. 个人档案桥接（personal-ai-archive）

个人档案仓库位于 `~/personal-ai-archive`（公开 GitHub：`Topdeckhuang/personal-ai-archive`），是跨 AI 复用的个人上下文唯一事实源。涉及身份、偏好、优先级的任务按需读 `identity/`、`workflow/`、`memory/` 下对应文件（文件内 `{{双花括号}}` 表示未填写，读到即按"待确认"处理），未读到或不完整时不替本人补充，也不修改标记 `ai-readonly` 的文件。任务产生了新的偏好、经验或决策时，候选条目先 append 到 `memory/sync-inbox.md`，并在回复中列出拟写入内容与目标文件，取得明确确认后再归档到正式文件、追加 `CHANGELOG.md` 并同步（git 不可用时改用 `tools/api-sync.sh`）。此仓库的 GitHub PAT 属 §3 受保护凭证：只从钥匙串取，不打印、不落盘、不进日志与提交。完整规则按需读 `~/.codex/instructions/archive-bridge.md`。
<!-- personal-ai-archive bridge v1 end -->
