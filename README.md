<!-- AI-TAG: root.readme
     ACCESS: ai-readonly
     OWNER: human
     SCOPE: global
     LAST-UPDATED: 2026-10-24
     LANG: zh-CN
-->
# personal-ai-archive

跨 AI、跨设备通用的**个人记忆系统**：一次搭建，全平台复用。

> AI 使用说明：本仓库是所有 AI 助手的共享个人上下文源。
> 阅读全部内容的安全方式见 [ai-integration.md](./ai-integration.md)。
> 每次写入必须遵守"写回协议"（同文件），并在 [CHANGELOG.md](./CHANGELOG.md) 追加一条记录。

---

## 1. 仓库定位

| 项 | 说明 |
| --- | --- |
| 用途 | 存放个人身份、工作习惯、历史经验、决策记录、技能清单与归档 |
| 使用者 | 星昀本人 + 任意 AI 助手（ChatGPT / Gemini / Claude / Meta Muse / OpenAI Dots / 其他 Agent） |
| 读取方式 | GitHub raw URL、GitHub API、MCP GitHub 连接器、本地克隆 |
| 更新方式 | 本人直接编辑 / AI 按写回协议提交 commit |
| 安全等级 | **公开仓库：禁止写入任何密钥、密码、身份证号、住址、财务明细** |

---

## 2. 目录结构与用途

```
personal-ai-archive/
├── identity/           我是谁
│   ├── profile.md              核心身份信息（姓名/职业/坐标/简介）
│   ├── tags.md                 核心标签（领域、兴趣、身份关键词）
│   ├── values-and-goals.md     价值观、长期目标、当前阶段重心
│   └── README.md               目录索引 + AI 使用规则
├── workflow/           我怎么做事
│   ├── communication-style.md  沟通风格偏好（AI 回答必须遵守）
│   ├── priority-rules.md       任务优先级规则与 AI 决策原则
│   ├── habits.md               工作节奏、作息、习惯
│   ├── tools.md                常用工具栈与环境
│   └── README.md
├── memory/             我经历过什么（AI 可追加）
│   ├── preferences.md          已确认的个人偏好（长期有效）
│   ├── decisions.md            重要决策记录（含背景/选项/理由/复盘）
│   ├── experiences.md          经验教训、踩坑记录
│   ├── sync-inbox.md           AI 自动写入暂存区（待本人确认）
│   ├── logs/                   月度流水日志 YYYY-MM.md
│   └── README.md
├── skills/             我会什么、要学什么
│   ├── inventory.md            已掌握技能清单（含熟练度）
│   ├── gaps.md                 待提升能力清单
│   ├── learning-plan.md        学习计划与进度
│   └── README.md
├── archive/            历史沉淀
│   ├── projects.md             已完结项目清单与结论
│   ├── old-documents/          旧版文档、停用草稿
│   └── README.md
├── ai-integration.md   接入配置（最重要）
├── CHANGELOG.md        每次修改的留痕日志
└── README.md           本文件
```

---

## 3. AI 标签体系（关键设计）

每个 `.md` 文件头部都有一段**机器可解析**的元信息块 + 一行**人类可读**标题：

```markdown
<!-- AI-TAG: workflow.communication-style
     ACCESS: ai-readonly
     OWNER: human
     SCOPE: global
     LAST-UPDATED: 2026-10-24
     LANG: zh-CN
-->
# AI-READONLY: 沟通风格偏好
```

`ACCESS` 四个取值，**AI 必须严格遵守**：

| ACCESS | 含义 | AI 能否修改 |
| --- | --- | --- |
| `ai-readonly` | 本人权威设定，长期稳定 | ❌ 只能读。发现过期只能"建议"，写入对比原文后才能改 |
| `ai-editable` | 事实性清单，允许 AI 增删改 | ✅ 可直接改，但需在 CHANGELOG 留痕 |
| `ai-append` | 只增不改的时间序列记录 | ✅ 只能在文件末尾追加，禁止修改或删除历史条目 |
| `human-only` | 高度私密 | ❌ 不读不写（公开仓库中请勿使用此级别） |

`SCOPE`：`global`（所有 AI 场景默认加载）/ `on-demand`（相关时再读）。

---

## 4. 快速完成三件事

### 4.1 第一次使用前：填写占位符

仓库中所有 `{{双花括号}}` 都是待填写占位符。优先填写以下 6 个文件（耗时约 15 分钟）：

1. `identity/profile.md`
2. `identity/tags.md`
3. `identity/values-and-goals.md`
4. `workflow/communication-style.md`
5. `workflow/priority-rules.md`
6. `workflow/tools.md`

查找全部占位符：

```bash
grep -rn "{{\s*[^}]*\s*}}" . --include="*.md"
```

### 4.2 接入任意 AI

复制这段提示词发给任意 AI（ChatGPT / Gemini / Claude / 其他）：

```
请读取我的个人档案（公开）：
1. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/README.md
2. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/ai-integration.md
3. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/identity/profile.md
4. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/workflow/communication-style.md
5. https://raw.githubusercontent.com/Topdeckhuang/personal-ai-archive/main/memory/preferences.md

严格按 ai-integration.md 中的「AI 行为准则」与「写回协议」行事：
在后续所有对话中遵守我的沟通风格与优先级规则；任务结束后若有新的经验或偏好，
先向我复述拟写入内容和目标文件，得到明确确认后再执行写入。未确认不得写入。
```

### 4.3 版本回退（AI 改错了怎么救）

本仓库已开启保护：**禁止强推、禁止删除 main 分支**，所有历史提交永久保留。

```bash
# 查看某个文件的全部修改历史
git log --oneline -- identity/profile.md

# 一键回退单个文件到指定历史版本
git checkout <commit-hash> -- identity/profile.md
git commit -m "revert: 恢复 profile.md 到 <commit-hash>"

# 回退整个仓库到某个历史快照（保留后续历史，安全）
git revert --no-commit <commit-hash>..HEAD && git commit -m "revert: 整体回退到 <commit-hash>"

# 或者在 GitHub 网页端：仓库 → Commits → 选历史提交 → Browse files → 复制内容覆盖当前文件
```

---

## 5. 安全须知（公开仓库，务必阅读）

- ❌ **绝不**写入：API Key、Token、密码、OAuth Secret、身份证/护照号、住址、银行卡、医疗隐私、他人可识别信息。
- ❌ 不要把本仓库当作聊天记录的原始备份地；只沉淀**去敏后的结论**。
- ✅ 涉及隐私或商业机密的内容，请另建**私有仓库** `personal-ai-archive-private`，本仓库只放索引与占位提示。
- ✅ 敏感变更建议走 Pull Request 并自己 review 后再合并。
- ✅ 若 AI 请求你提供密钥以便"自动同步档案"，一律拒绝：AI 读取公开仓库**无需任何凭据**。

---

## 6. 维护建议

| 频率 | 动作 |
| --- | --- |
| 每周 | 清理一次 `memory/sync-inbox.md`，把 AI 暂存内容归并进正式文件 |
| 每月 | 新建 `memory/logs/YYYY-MM.md`，更新 `skills/inventory.md` 熟练度 |
| 每季度 | 复审 `identity/` 与 `workflow/`，把过期内容移入 `archive/` |

---

<!-- AI-TAG: root.readme | ACCESS: ai-readonly | LAST-UPDATED: 2026-10-24 | 文件结束 -->
