<!-- AI-TAG: docs.knowledge-sync-plan
     ACCESS: ai-editable
     OWNER: human
     SCOPE: global
     LAST-UPDATED: 2026-10-24
     LANG: zh-CN
-->
# AI-EDITABLE: 知识同步与多端衔接详细方案

> 本文是 [ai-integration.md](../ai-integration.md) 的配套施工图。
> 回答两个问题：**新知识怎么流进仓库** 与 **手机/平板/多台电脑/多个 AI 怎么共享同一份档案**。
> 状态标记：✅ 已在本机实测｜⚙️ 已写好待你启用｜❓ 需你实测确认｜🚫 明确不推荐

---

## 0. 结论先行

整套体系只用一条核心规则治理：**Git 仓库是唯一事实源（Single Source of Truth）**，所有端都遵守「先拉后写 + 追加优先」。

- **写入侧**：一切新知识的终点都是 commit，因此天然可审计、可回退。
- **读取侧**：一切端（人 / AI / 手机）都读同一个 raw 地址，因此不存在「哪份是最新的」。
- **冲突侧**：把"修改"尽量降级为"追加"，冲突概率趋近于零（详见 §4）。

落地分三阶段，**P0 今天就能用，不需要任何额外部署**；P1/P2 按你的时间再推进。

| 阶段 | 能力 | 依赖 | 投入 |
| --- | --- | --- | --- |
| **P0** | 多端读一致 + 本机半自动写 + 手机可读可改 | 无（已有 GitHub App） | 15 分钟配置 |
| **P1** | 一键同步脚本 + Token 入钥匙串 + 月度自动归档 | fine-grained PAT、GitHub Actions | 30 分钟 |
| **P2** | 手机随手 Input（邮件/快捷指令转存）、AI 直写回、私有分层仓 | 中转 endpoint、私有仓 | 按需，需你确认后再做 |

---

## 1. 数据流全景

```
写入端                     通道                      事实源              读取端
────────────────────────────────────────────────────────────────────────────
本机 AI 助手 ── git push ────────┐
（Claude Code/Cursor/Codex）     │
                                 │
网页 AI ── REST PUT API ─────────┤                                  ChatGPT
（ChatGPT Action / 插件）         │                                  Gemini
                                 │                                  Claude
手机录入 ── 邮件/快捷指令 ────────┼──▶ GitHub repo ──▶ raw URL ───▶ Meta Muse
（→ 中转 endpoint）               │    (唯一事实源)    REST API       OpenAI Dots
                                 │                   MCP            本机 AI
平板/另一台电脑 ── git ───────────┤                                  手机浏览器
                                 │                                  你自己
本人手改 ── GitHub 网页/App ──────┘
                                 ▲
                          Actions 定时任务
                    （建月度模板 / 周度提醒 issue）
```

**关键原则**：写入端可以多，但**通道必须收口到 commit**。禁止任何端把内容只存在自己本地。

---

## 2. P0：今天就能用的闭环（无额外部署）

### 2.1 多端读取一致性

所有端读同一个入口，**不需要任何凭据**：

| 端 | 怎么用 |
| --- | --- |
| 任意 AI（网页/App） | 粘贴 `ai-integration.md` 里的「标准加载 URL 清单」 ✅ 已实测 raw HTTP 200 |
| 手机浏览器 | 直接打开 raw URL；存成书签 / 加到主屏 |
| 另一台电脑 | `git clone https://github.com/Topdeckhuang/personal-ai-archive.git` |
| 本机 Claude Code | 在项目 `CLAUDE.md` 引用 `@~/personal-ai-archive/memory/preferences.md` |

### 2.2 多端写入：**今天最低成本的做法**

| 端 | 做法 | 状态 |
| --- | --- | --- |
| 手机 / 平板 | GitHub 官方 App 或浏览器打开仓库 → 点文件 → 铅笔图标编辑 → Commit changes | ⚙️ 零配置，立即可用 |
| iOS 进阶 | Working Copy App（付费买断）：本地编辑 md + 一键 push，体验远好过网页 | ⚙️ 可选 |
| 另一台电脑 | 正常 `git pull` → 编辑 → `git commit` → `git push` | ✅ |
| 网页 AI（不能调 API） | 让它输出 `ai-writeback` 代码块（协议见 ai-integration §6.6），你粘到任意能 push 的端 | ✅ |

### 2.3 约定：每天/每周两次手动同步

在每台电脑上固定两个动作（后面 P1 会用脚本自动化）：

```bash
git pull                 # 开始干活前：拉最新
# ...编辑...
git add -A && git commit -m "<type>(<file>): <简述>" && git push   # 结束联网前：推上去
```

---

## 3. P1：半自动同步（推荐本周做完）

### 3.1 一键同步脚本 `tools/sync.sh`

已提供 ⚙️（尚未在你的机器上实跑）：

```bash
cd ~/personal-ai-archive

./tools/sync.sh pull                      # 拉最新（自动 rebase）
./tools/sync.sh push "memory: 补本周偏好"  # 自动 pull → commit → push
./tools/sync.sh status                    # 看落后/领先多少个提交
./tools/sync.sh track identity/profile.md # 看某个文件的全部修改历史
./tools/sync.sh revert identity/profile.md a1b2c3d   # 单文件回到指定版本
./tools/sync.sh newlog                    # 为下个月生成空日志模板
```

设计要点：

- `push` **强制先 pull**，从根上避免 non-fast-forward 冲突。
- 落后于远端时自动 `--rebase --autostash`，不会丢你的未提交改动。
- `revert` 是**单文件级**回退，不会牵连其他文件（AI 改错时最常见场景）。
- 所有 destructive 操作都需要你显式传参数，脚本不做任何自动删除。

### 3.2 Token 治理（给 AI 写回权限时才需要）

**读取永远不需要 Token。** 只有"让 AI 替你写回"时才需要。

1. 打开 https://github.com/settings/personal-access-tokens/new 创建 **Fine-grained token**
2. Repository access：`Only select repositories` → 只勾 `personal-ai-archive`
3. Permissions：`Contents: Read and write`（**仅此一项**）+ `Metadata: Read-only`
4. 有效期选 90 天（到期前 GitHub 会提醒轮换）
5. 存进 macOS 钥匙串，**不要写进文件或 shell 配置**：

```bash
security add-generic-password -a "personal-ai-archive" -s "gh-archive-pat" -w
# 弹出输入框粘贴 Token；之后脚本这样取用：
security find-generic-password -s "gh-archive-pat" -w
```

**安全红线**：Token 只用于这一个仓库；一旦怀疑泄露，立刻 https://github.com/settings/tokens 撤销（Revoke），已泄露的 commit 历史按 README §4.3 回退。

### 3.3 GitHub Actions：月度模板 + 周度提醒

已写好 ⚙️ `.github/workflows/weekly-digest.yml`，每周一 10:00（UTC+8）自动：

1. 若下个月的 `memory/logs/YYYY-MM.md` 不存在，用 `docs/_templates/month-log.md` 自动生成并提交；
2. 给你开一个 `maintenance` issue，提醒"归档 `memory/sync-inbox.md`（约 5 分钟）"。

启用方式：仓库 → Settings → Actions → 勾选 *Allow all actions*（默认已开）。首次运行可手动触发：Actions 页 → Archive Weekly → Run workflow。
**注意**：公开的 schedule 定时任务在仓库 60 天无活动后会被 GitHub 暂停，届时手动跑一次即可恢复；❓ 该定时行为需你实测确认。

### 3.4 代理/网络受限环境的兜底 `tools/api-sync.sh`

在某些网络环境（公司 CI、受限代理）`git push` 走不通时，用 REST API 通道直接提交，绕过 git 协议：

```bash
./tools/api-sync.sh push-file identity/profile.md
./tools/api-sync.sh append memory/sync-inbox.md "- [2026-10-24] preferences.md | 偏好：结论先行 | 来源:Claude"
./tools/api-sync.sh cat identity/profile.md
```

它依赖 `gh`（GitHub CLI），内部自动取 sha 再 PUT，天然防覆盖；返回 409 会自动重新取 sha 重试一次。
✅ 本次仓库初始化**就是用这条通道完成的**（本机 `git push` 被代理返回 `CONNECT tunnel failed 502`）。

---

## 4. 冲突为什么几乎不会发生（设计要点）

大多数"记忆同步"系统会崩在冲突上。这里用三条设计消解掉：

| 机制 | 说明 |
| --- | --- |
| **追加优先** | `memory/` 下文件规定只能 append-only。两个端同时加内容 = 两条不同行的 append，Git 自动合并；只在极罕见"改同一行"时才 manual resolve |
| **PUT 必带 sha** | REST API 更新文件内容时必须传当前 blob sha，内容被改过就 409 拒绝 → 不会静默覆盖 |
| **写前先拉** | `sync.sh push` 强制 pull；脚本层杜绝"用旧版本强推" |

真出现冲突时：

```bash
./tools/sync.sh pull            # 自动 rebase
grep -rn "<<<<<<<" .            # 若有人为冲突标记，逐个打开按取舍保留
# 修好后：
./tools/sync.sh push "fix: 解决 XX 冲突"
```

---

## 5. P2（按需）：随手 Input 与自动写回

> 这一节全部**需要你确认后我才动手**，因为都涉及新凭据或新账单/配额。

### 5.1 手机随手记 → 自动入库

| 方案 | 机制 | 代价 | 我的评价 |
| --- | --- | --- | --- |
| A. 邮件转存 | 发件到指定邮箱 → 本机定时任务/Actions 拉信 → append 到 `memory/sync-inbox.md` | 需要一个邮箱 + 定时任务 | 最省事，天然跨平台；本机已有 Agent Mail 连接器可用 ❓ 需确权后接线 |
| B. iOS 快捷指令 | Shortcuts 文本 → 调用中转 HTTP endpoint → PUT contents API | 需要部署（云函数 / WorkBuddy 托管服务） | 体验最好（1 次点击），但要维护一个公网 endpoint |
| C. Working Copy / GitHub App | 手动编辑 push | 0（已在 P0） | 够用，但记的是"内容"不是"念头"，容易懒 |
| 🚫 D. 直接給 AI 你的 PAT 放手机里 | — | — | 不推荐：明文 Token 落地 + 权限不可控 |

### 5.2 AI 自动写回

按 `ai-integration.md` §6.2 的 **T0–T4 分级授权**执行，建议初期只开：

- T0：`memory/logs/YYYY-MM.md` 追加（可一次性授权，允许连续写入）
- 其余 T1/T2：**逐条确认**
- T3（identity / communication-style / priority-rules）与 T4（删除/重置）：**永远禁止 AI 执行**

给 AI 的 Token 用 §3.2 的 fine-grained token（仅 Contents RW），并按季度轮换。

### 5.3 隐私分层（推荐最终形态）

```
Topdeckhuang/personal-ai-archive           公开：可给任何 AI 读的非敏感档案
Topdeckhuang/personal-ai-archive-private   私有：健康、财务、家庭、商业机密
```

- 公开仓**只放索引与占位提示**，敏感正文写进私有仓并在公开仓写一行"详见私有仓 XXX 章节"。
- 私有仓读取需要PAT（raw URL 也要带鉴权），因此**只给本机/可信赖的工具读**，不要塞进网页 AI 对话。
- ⚠️ 注意：Fine-grained PAT 对私有仓同样生效，务必单独发 Token、单独轮换。

---

## 6. 日常运维节奏（建议）

| 频率 | 动作 | 预计耗时 |
| --- | --- | --- |
| 每次开始前 | `./tools/sync.sh pull` | 5 秒 |
| 每天结束 | 把当天新念头 append 到 `memory/logs/YYYY-MM.md` → push | 2 分钟 |
| 每周 | 归档 `memory/sync-inbox.md`（AI 暂存）→ 更新 `skills/inventory.md` | 10 分钟 |
| 每月 | `./tools/sync.sh newlog`；复审 `identity/` 与 `workflow/` | 20 分钟 |
| 每季度 | 轮换 PAT；把过期内容移入 `archive/` | 15 分钟 |

---

## 7. 验收清单（做完一项勾一项）

**P0**

- [ ] 手机浏览器能打开 raw URL 并看到档案内容
- [ ] 手机上用 GitHub App 成功改一行并 commit（验证多端写入）
- [ ] 至少 1 个 AI（ChatGPT/Claude 任一）粘贴提示词后能正确说出你的职业

**P1**

- [ ] 创建 fine-grained PAT 并存入 macOS 钥匙串
- [ ] `./tools/sync.sh status` 在本机跑通
- [ ] Actions 首次手动触发成功，收到周度提醒 issue
- [ ] 本机验证 `git push -f` 被保护规则拒绝（预期失败）

**P2**

- [ ] 选定手机录入方案（A/B/C）并跑通一次
- [ ] 选定是否启用 AI 自动写回（建议先只开 T0）
- [ ] 决定是否新建私有分层仓

---

## 8. 已知限制（说在前面）

| 项 | 现状 |
| --- | --- |
| `git push` | 在受限代理环境下会失败（`CONNECT tunnel failed 502`），此时走 `tools/api-sync.sh` ✅ 已验证可行 |
| Actions 定时任务 | GitHub 对 60 天无活动仓库会暂停 schedule；❓ 待实测 |
| 各 AI 平台连接器 | 版本差异大，`ai-integration.md` §3 标 ⚠️ 者需你实测；不可用一律退回 raw URL，不影响功能 |
| 脚本实机运行 | `tools/sync.sh`、`tools/api-sync.sh` 已通过语法检查 ⚙️，但未在你的机器上实际执行各分支；建议先在非关键文件上试跑 |
| 私有仓 | 尚未创建，需你确认后再做 |

---

<!-- AI-TAG: docs.knowledge-sync-plan | ACCESS: ai-editable | LAST-UPDATED: 2026-10-24 | 文件结束 -->
