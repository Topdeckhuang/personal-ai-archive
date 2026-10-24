<!-- AI-TAG: memory.index
     ACCESS: ai-append
     OWNER: shared
     SCOPE: global
     LAST-UPDATED: 2026-10-24
     LANG: zh-CN
-->
# AI-APPEND: memory 目录索引

**本目录回答"我经历过什么"**，是整个系统里唯一允许 AI 持续写入的区域。

## 文件清单

| 文件 | ACCESS | 放什么 | 谁写 |
| --- | --- | --- | --- |
| [preferences.md](./preferences.md) | `ai-append` | 已确认的个人偏好，长期有效 | 本人 / AI（须逐条确认） |
| [decisions.md](./decisions.md) | `ai-append` | 重要决策：背景 → 选项 → 选择 → 理由 → 复盘 | 本人 / AI（须确认） |
| [experiences.md](./experiences.md) | `ai-append` | 踩坑、返工、失败教训 | 本人 / AI（须确认） |
| [sync-inbox.md](./sync-inbox.md) | `ai-append` | AI 自动写入暂存区，待主人确认后再归档 | AI 可直接写 |
| [logs/](./logs/) | `ai-append` | 按月归档的流水日志 `YYYY-MM.md` | 本人 / AI（可批量授权） |

## 写入铁律

1. **只追加**：所有 `ai-append` 文件只许在末尾加条目，**禁止删除或修改历史条目**（保留修改史才能回溯）。
2. **带日期**：每条以 `- [YYYY-MM-DD]` 开头。
3. **写前确认**：除 `logs/` 与 `sync-inbox.md` 外，AI 写入前必须复述内容并取得本人同意。
4. **去敏**：公开仓库，禁止写入他人可识别信息与任何私密细节。
5. **留痕**：写入同时在根目录 `CHANGELOG.md` 追加一行。
6. **过期处理**：失效的偏好不删除，标记为 `状态：已废弃`，并注明取代它的新条目。

## 每月一次的清理流程

```bash
git pull
# 1) 把 sync-inbox.md 中确认过的条目剪贴到 preferences/decisions/experiences
# 2) 建立下个月的 logs/YYYY-MM.md（复制上月模板，清空内容）
# 3) git add -A && git commit -m "memory: 2026-11 月度归档" && git push
```
