<!-- AI-TAG: root.ai-integration
     ACCESS: ai-editable
     OWNER: human
     SCOPE: global
     LAST-UPDATED: 2026-10-24
     LANG: zh-CN
-->
# AI-EDITABLE: 跨 AI 接入配置（核心文件）

> 本文件是所有 AI 的"接入说明书"。任何 AI 在读写本仓库前，**必须先完整阅读本文件**。
> 仓库：`https://github.com/Topdeckhuang/personal-ai-archive`（公开）
> 默认分支：`main`

---

## 0. 一句话原理

本仓库把"个人上下文"变成**纯文本的公开知识库**。任何具备联网或 HTTP 能力的 AI，都能在**不需要任何凭据**的情况下读取；具备写权限 Token 的 AI（或本机 CLI）还能按协议回写。因此同一份档案可以在 ChatGPT、Gemini、Claude 及各类 Agent 之间复用，不存在平台锁定。

---

## 1. AI 必须遵守的行为准则

1. **先读后答**：首次被询问个人相关问题时，至少加载 `identity/profile.md`、`workflow/communication-style.md`、`workflow/priority-rules.md`、`memory/preferences.md` 四个文件，再回复。
2. **遵守 ACCESS 权限**：见每个文件头部 `<!-- AI-TAG -->` 块。标注 `ai-readonly` 的文件**永远不能直接修改**。
3. **只追加不篡改**：`memory/` 下标注 `ai-append` 的文件只能追加条目，禁止删除或改写历史内容。
4. **不得杜撰**：档案中没有的信息，标注"待确认"，禁止用合理猜测填充个人信息。
5. **写前必答**：任何写入动作之前，必须把"拟写入内容 + 目标文件路径"复述给用户并取得明确同意。
6. **最小修改**：只改与该次任务直接相关的部分，不顺手重构、不顺手格式化其他文件。
7. **拒绝密钥**：不得要求用户为读取本公开仓库提供任何 Token 或密钥；写入才需要凭据，且凭据必须由用户自行配置。

---

## 2. 读取方式（四选一，按可用性）

### 方式 A：raw URL 直取（通用性最高，推荐）

```
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/<文件路径>
```

例：`https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/memory/preferences.md`

适合：支持联网/URL 读取的 AI；也可直接粘贴 URL 让 AI 自行抓取。

### 方式 B：GitHub REST API（可遍历目录，推荐给具备工具调用能力的 AI）

```bash
# 列出仓库全部文件路径
curl -s "https://api.github.com/repos/Topdeckhuang/personal-ai-archive/git/trees/main?recursive=1" \
  | jq -r '.tree[] | select(.type=="blob") | .path'

# 读取单个文件内容（Base64 解码）
curl -s "https://api.github.com/repos/Topdeckhuang/personal-ai-archive/contents/identity/profile.md" \
  | jq -r '.content' | base64 --decode
```

匿名调用限速 60 次/小时（读取全部约 23 个文件足够用）。

### 方式 C：MCP GitHub 连接器 / 平台原生连接器

若 AI 平台支持 MCP（Model Context Protocol）或原生 GitHub 连接器，可直接挂载本仓库，AI 会用 `get_file_contents / search_code` 等工具读取，**比粘贴 URL 更省 token**。

### 方式 D：本地克隆（本机 AI 编码助手，如 Claude Code、Cursor、Codex）

```bash
git clone https://github.com/Topdeckhuang/personal-ai-archive.git ~/personal-ai-archive
```

适合需要频繁读写的本机 Agent。

---

## 3. 按平台接入

> 说明：各平台功能持续变化，下表给出"推荐路径"。标 ⚠️ 的项目请以你账号当前实际开放的功能为准；**若某项不可用，一律退回方式 A（粘贴 raw URL）**，功能不受影响。

| 平台 | 推荐路径 | 操作步骤 | 验证状态 |
| --- | --- | --- | --- |
| **ChatGPT** | 自定义 GPT Instructions + Actions / 原生连接器 ⚠️ | 创建自定义 GPT → Instructions 粘贴第 5 节系统提示词 → Actions 填 `https://api.github.com/repos/Topdeckhuang/personal-ai-archive`（无需鉴权） | 待你实测 |
| **Gemini** | 个人上下文 / Canvas + 联网读取 ⚠️ | 把第 5 节系统提示词作为首轮提示词，附上第 4 节 URL 清单，让 Gemini 抓取 | 待你实测 |
| **Claude (Web)** | Projects Knowledge + 连接器 ⚠️ | 新建 Project → 上传本仓库 md 文件 / 挂载 GitHub 连接器 → Project Instructions 粘贴第 5 节 | 待你实测 |
| **Claude Code（本机）** | 本地克隆 + `CLAUDE.md` 软链 | `git clone` 后，在项目 `CLAUDE.md` 中加入 `@~/personal-ai-archive/README.md` 与 `@~/personal-ai-archive/workflow/communication-style.md` 引用 | 待你实测 |
| **Meta Muse / OpenAI Dots 等 Agent** | 提示词注入（方式 A） | 把第 4+5 节内容作为任务前的上下文注入；不支持联网的 Agent 则由你本地 `cat` 后粘贴 | 待你实测 |
| **任意支持 MCP 的 AI** | MCP GitHub Server | 配置只读 GitHub MCP Server，指向本仓库 | 待你实测 |

**统一兜底（一定可用）**：把第 4 节的 URL 清单 + 第 5 节系统提示词，一次性粘贴给任何 AI。

---

## 4. 标准加载 URL 清单

```
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/ai-integration.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/identity/profile.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/identity/tags.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/identity/values-and-goals.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/workflow/communication-style.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/workflow/priority-rules.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/workflow/tools.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/workflow/habits.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/memory/preferences.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/memory/decisions.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/memory/experiences.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/skills/inventory.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/skills/gaps.md
https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/skills/learning-plan.md
```

---

## 5. 通用系统提示词（复制即用）

```
你正在使用我的个人档案系统。开始任何实质工作前，请按以下顺序加载：
1. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/ai-integration.md
2. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/identity/profile.md
3. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/workflow/communication-style.md
4. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/workflow/priority-rules.md
5. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/memory/preferences.md
6. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/skills/inventory.md

行为约束：
- 严格遵循 communication-style.md 的语气与格式偏好；
- 严格遵循 priority-rules.md 的决策顺序与取舍原则；
- 档案中没有的信息必须标注"待确认"，禁止编造；
- 不得修改 ai-readonly 级别的文件；
- 任务结束后，若本次产生了新的经验或偏好，按 ai-integration.md 第 6 节的写回协议处理：
  先复述拟写入内容 + 目标文件路径，经我明确同意后再写入，并在 CHANGELOG.md 追加一条记录。
```

---

## 6. 自动更新（写回）规则

### 6.1 触发时机

满足**任一**条件时，AI 应主动提议写回：

- 你明确说出新的偏好或不喜欢某种做法（→ `memory/preferences.md`）
- 共同完成了一项重要决策（→ `memory/decisions.md`）
- 遇到了坑、踩雷、返工（→ `memory/experiences.md`）
- 学会了新工具或技能水平变化（→ `skills/inventory.md`）
- 项目完结（→ `archive/projects.md`）
- 其他零散事实（→ `memory/logs/YYYY-MM.md`）

### 6.2 分级授权（防止 AI 乱写）

| 级别 | 动作 | 是否需要确认 |
| --- | --- | --- |
| T0 | 追加日志条目到 `memory/logs/YYYY-MM.md` | 需确认（一次性授权可批量） |
| T1 | 追加到 `preferences / decisions / experiences` | **必须逐条确认** |
| T2 | 修改 `ai-editable` 类清单（tools / inventory / learning-plan） | **必须确认** |
| T3 | 修改 `ai-readonly` 类文件（identity / communication-style / priority-rules） | **禁止；只能提出修改建议** |
| T4 | 删除任何内容、重置模板、整体重构 | **禁止（人类专属操作）** |

### 6.3 写入姿势（GitHub REST API，最可靠）

```bash
OWNER=Topdeckhuang
REPO=personal-ai-archive
PATH="memory/preferences.md"
TOKEN="<你的 Personal Access Token，需 repo 权限>"

# 1) 先获取当前内容和工作区 SHA（必须带 sha，否则 API 会拒绝更新，天然防覆盖）
SHA=$(curl -s -H "Authorization: Bearer $TOKEN" \
  "https://api.github.com/repos/$OWNER/$REPO/contents/$PATH" | jq -r .sha)

# 2) 用 Python/jq 构造新内容并 PUT（content 需 Base64）
NEW=$(base64 < /tmp/new.md)
curl -X PUT -H "Authorization: Bearer $TOKEN" \
  -d "{\"message\":\"memory(preferences): 新增「输出格式」偏好\",\"content\":\"$NEW\",\"sha\":\"$SHA\"}" \
  "https://api.github.com/repos/$OWNER/$REPO/contents/$PATH"
```

**并发冲突处理**：若返回 `409 Conflict`，说明文件被改动过 → 重新 GET 取新 SHA → 把新条目追加到最新内容尾部 → 重试一次；仍失败则停止并交由人工处理。

### 6.4 本机 AI 助手写入（Claude Code / Codex / Cursor 等）

```bash
cd ~/personal-ai-archive
git pull
# 编辑对应文件（仅追加，勿改动历史条目）
git add -A
git commit -m "memory(preferences): 新增「输出格式」偏好"
git push
```

### 6.5 Commit Message 规范

```
<type>(<file>): <简述>
```

- `type`：`identity` / `workflow` / `memory` / `skills` / `archive` / `chore` / `revert`
- 例：`memory(decisions): 2026-11 技术选型记录`

每次写入**同时**在 `CHANGELOG.md` 追加一行：

```
| 2026-11-02 | memory/preferences.md | AI:Claude | 新增「输出格式」偏好 | abc1234 |
```

### 6.6 无写入能力的 AI（多数在线 Agent）

若 AI 无法调用 API，让它输出如下**标准化写回块**，你（或本机/写权限 AI）执行即可：

````markdown
```ai-writeback
target: memory/preferences.md
action: append
date: 2026-11-02
content: |
  - [2026-11-02] 偏好：技术类回答先给结论，再给步骤，不要寒暄。
source: Claude
```
````

---

## 7. 缓存与同步建议

- **缓存**：AI 会话开始时加载一次即可，单次会话内不必重复抓取。
- **刷新**：跨天的新会话建议重新加载 `memory/preferences.md` 与 `memory/logs/` 当月文件，这两处变动最频繁。
- **冲突定责**：档案与你口头指令不一致时，**以你当次的口头指令为准**，并提示"档案可能已过期，是否更新？"
- **设备同步**：任何设备上先 `git pull`，避免基于旧版本写入。

---

## 8. 故障排查

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| raw URL 404 | 路径或分支名错误 | 确认分支为 `main`，路径大小写一致 |
| API 返回 403 + rate limit | 匿名访问超限（60/h） | 换用方式 A raw URL，或加 Token（5000/h） |
| PUT 返回 409 | SHA 过期 | 重新 GET 取 SHA 后重试一次 |
| AI 说读不到内容 | 该 AI 无联网能力 | 本地 `cat` 文件全文粘贴给 AI |
| AI 擅自改了资料 | 未遵循本协议 | 按 README 第 4.3 节回退到历史 commit |

---

<!-- AI-TAG: root.ai-integration | ACCESS: ai-editable | LAST-UPDATED: 2026-10-24 | 文件结束 -->
