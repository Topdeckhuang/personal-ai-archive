<!-- AI-TAG: integrations.codex.bridge
     ACCESS: ai-readonly
     OWNER: human
     SCOPE: global
     LAST-UPDATED: 2026-10-24
     LANG: zh-CN
-->
# 星昀个人档案桥接规则（Codex 专用）

> 本文件由 `~/personal-ai-archive/tools/setup-codex.sh` 安装到 `~/.codex/instructions/archive-bridge.md`。
> 属于**按需读**参考：`AGENTS.md` 每轮只加载其中一小段指针，细节在本文件。
> 修改本文件前请同步更新仓库内的 `integrations/codex/archive-bridge.md`，保持两端一致。

---

## 1. 档案在哪里

| 项 | 值 |
| --- | --- |
| 本地 canonical 路径 | `~/personal-ai-archive`（用 `ARCHIVE_DIR` 环境变量可覆盖） |
| 远端 | https://github.com/Topdeckhuang/personal-ai-archive （**公开**） |
| 默认分支 | `main` |
| 同步脚本 | `tools/sync.sh`（git）、`tools/api-sync.sh`（REST 兜底） |

**读取优先级**：本地文件存在且近期同步过 → 读本地；否则读远端 raw URL
（`https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/<路径>`）。

## 2. 什么时候必须读

| 触发 | 读什么 |
| --- | --- |
| 涉及个人身份、职业、目标 | `identity/profile.md`、`identity/values-and-goals.md` |
| 决定回答语气、格式、详略 | `workflow/communication-style.md` |
| 给建议、做取舍、排优先级 | `workflow/priority-rules.md` |
| 判断技术栈、环境、命令怎么写 | `workflow/tools.md` |
| 复用既有偏好、避免推翻旧决定 | `memory/preferences.md`、`memory/decisions.md` |
| 判断解释深度（要不要讲基础） | `skills/inventory.md` |

**不要在自然问答、短检索、纯代码任务里为读而读**——省额度，见 `AGENTS.md` §1 节流要求。

## 3. 硬规则（映射到你已有的硬门）

1. **不编造**：档案里没有的信息标注"待确认"，禁止用合理猜测填充个人信息、偏好或决策。
2. **占位符不是事实**：文件中 `{{双花括号}}` 处尚未填写，读到即表示该字段未知，**不得据此回答**。
3. **ACCESS 权限**——每文件头部 `<!-- AI-TAG: ... ACCESS: ... -->` 为准：
   | ACCESS | Codex 能否改 |
   | --- | --- |
   | `ai-readonly` | ❌ 禁止修改（`identity/`、`workflow/communication-style.md`、`workflow/priority-rules.md` 属此类） |
   | `ai-append` | ✅ 只能在文件末尾追加，`memory/` 下文件皆是；禁止删除或改写历史条目 |
   | `ai-editable` | ✅ 可增删改，但需本人确认 + `CHANGELOG.md` 留痕 |
4. **Token 处置**：此处的 GitHub PAT 属 §3 安全硬门覆盖的受保护凭证。只从钥匙串取
   （`security find-generic-password -s gh-archive-pat -w`），**不打印、不落文件、不进日志、不进 commit**。

## 4. 写回流程（任务收尾时）

```
有新偏好/经验/决策
      ↓
① 候选条目 append 到 ~/personal-ai-archive/memory/sync-inbox.md
      ↓
② 在回复中列出「拟写入内容 + 目标文件」，等明确确认
      ↓
③ 确认后剪贴到 preferences.md / decisions.md / experiences.md
      ↓
④ CHANGELOG.md 追加一行留痕，然后同步
```

- **未确认不动正式文件**，`memory/sync-inbox.md` 与 `memory/logs/` 是唯一可先落地的暂存区。
- 禁止删除任何历史条目；过期的偏好标记"已废弃"而非删除。
- 同步方式（按顺序尝试）：

```bash
~/personal-ai-archive/tools/sync.sh pull
~/personal-ai-archive/tools/sync.sh push "memory: <简述>"
# git 不可用时改用 REST 通道：
~/personal-ai-archive/tools/api-sync.sh append memory/同步文件路径 "<一行内容>"
```

## 5. 与其他 AI 的关系

同一份档案同时服务 ChatGPT / Gemini / Claude / 各类 Agent，**Codex 不是档案的所有者，只是读写端之一**。
因此：不要在本仓库内定义只有 Codex 能理解的私有约定；一切格式保持纯 Markdown + `AI-TAG` 头部。
跨通用接入方式见仓库 `ai-integration.md`；多端施工图见 `docs/knowledge-sync-plan.md`。

## 6. 校验安装是否正确

```bash
grep -c "personal-ai-archive" ~/.codex/AGENTS.md      # 期望 >= 1（已植入指针）
ls -l ~/.codex/instructions/archive-bridge.md         # 期望存在
~/personal-ai-archive/tools/setup-codex.sh --check    # 期望全部 [OK]
```
