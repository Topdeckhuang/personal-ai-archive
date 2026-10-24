<!-- AI-TAG: memory.sync-inbox
     ACCESS: ai-append
     OWNER: ai
     SCOPE: global
     LAST-UPDATED: 2026-10-24
     LANG: zh-CN
-->
# AI-APPEND: AI 写入暂存区

> **这是唯一允许 AI 未经逐一确认即可自动追加的文件**（除 logs/ 外）。
> 用途：避免 AI 的自动写回污染正式文件，本人每周花 5 分钟审阅并归档。
> AI 写入格式：`- [YYYY-MM-DD] <建议去向文件> | <内容> | 来源:<AI 名称>`

## 待处理队列

<!-- AI 请把新条目追加到本区块末尾 -->

- [{{YYYY-MM-DD}}] preferences.md | {{拟写入的偏好内容}} | 来源:{{AI 名称}}

## 处理规则

- ✅ 确认无误 → 手动剪贴到 `preferences.md` / `decisions.md` / `experiences.md`，并删除本文件中的该行。
- ❌ 不正确 → 直接删除该行，并在 `experiences.md` 记一条"AI 理解偏差"。
- ⏳ 拿不准 → 保留到下周，附上自己的备注。

## 处理记录

| 处理日期 | 条目 | 去向 |
| --- | --- | --- |
| {{YYYY-MM-DD}} | {{条目摘要}} | {{已归档到 X / 已删除}} |
