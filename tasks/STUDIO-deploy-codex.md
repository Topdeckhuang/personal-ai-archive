<!-- AI-TAG: tasks.studio-deploy
     ACCESS: ai-readonly
     OWNER: human
     SCOPE: global
     LAST-UPDATED: 2026-10-25
     LANG: zh-CN
-->
# 任务书：Studio 端复刻个人 AI 档案系统 + Codex 桥接

> 适用对象：Studio 端（Mac Studio）。本任务书 + 任务指令由 Air 端生成，供 Studio 端直接执行或交给 Studio 的 AI 助手执行。
> 仓库：`https://github.com/Topdeckhuang/personal-ai-archive`（公开，无需鉴权即可 clone）。
> Air 端已完成同样部署，本报告末尾附其验证结果供对照。

---

## 0. 任务指令（复制即用，在 Studio 端终端执行）

```bash
# ① 获取仓库（公开，无需登录）
git clone https://github.com/Topdeckhuang/personal-ai-archive.git ~/personal-ai-archive

# ② 安装 Codex 桥接（幂等 / 有备份 / 可 --rollback）
~/personal-ai-archive/tools/setup-codex.sh

# ③ 验证
~/personal-ai-archive/tools/setup-codex.sh --check

# ④ 生效：重新打开 Codex 会话（AGENTS.md 不热重载）
```

> 不想先看全文？只跑上面 4 行即可。完整目标 / 范围 / 步骤 / 交付 / 风险 / 验收见下文 §1–§7。

---

## 1. 目标

1. 在 Studio 端建立与 Air 端**完全一致**的 `personal-ai-archive` 本地副本（路径 `~/personal-ai-archive`）。
2. 在 Studio 端的 **Codex** 中接入同款桥接规则，使其会话自动读取档案、并按规则写回。
3. 两端共享同一份个人上下文，可互相同步（`git pull` / `git push`）。

---

## 2. 范围

**包含（IN）**

- 克隆仓库到 `~/personal-ai-archive`。
- 运行 `tools/setup-codex.sh` 安装 Codex 桥接（向 `~/.codex/AGENTS.md` 追加指针 + 安装 `~/.codex/instructions/archive-bridge.md`）。
- 验证安装状态与一致性。

**不包含（OUT）**

- 不安装 / 配置 WorkBuddy、DeepSeek、Harness 等其他工具（它们的可用性需另行确认，见 §8 备注）。
- 不填写 252 处 `{{占位符}}`（那是本人填，不是部署任务）。
- 不上传任何 Obsidian / WeKnora / 运营大脑等外部知识库内容到本仓库（敏感，且属私有仓范畴）。
- 不做删除 / 重置 / 强推等不可逆操作。

---

## 3. 前置条件

| 项 | 要求 |
| --- | --- |
| 系统 | macOS（Studio 端） |
| git | 已安装（`git --version` 有输出） |
| Codex | 已安装且至少生成过一次全局规则（存在 `~/.codex/AGENTS.md`） |
| 网络 | 可访问 `github.com`（公开仓库 clone / pull **无需登录**） |
| 推送 / REST 兜底 | 若后续要 push，先 `gh auth login`；REST 通道需 `gh` 已登录且 PAT 仅 `personal-ai-archive` 的 Contents RW |

> 若 Studio 端**尚未初始化过 Codex**，`setup-codex.sh` 会中止并提示"未找到 `~/.codex/AGENTS.md`"——请先打开一次 Codex 让其生成全局规则，再运行本任务。

---

## 4. 执行步骤

**Step 1 — 获取仓库与安装脚本**

```bash
git clone https://github.com/Topdeckhuang/personal-ai-archive.git ~/personal-ai-archive
```

> 若 `git clone` 被网络/代理阻断：改用下载 tarball 解压到 `~/personal-ai-archive`；或仅取 `tools/setup-codex.sh` 与 `integrations/codex/` 两处文件即可（桥接不依赖全文）。

**Step 2 — 安装 Codex 桥接（幂等、有备份、可回滚）**

```bash
~/personal-ai-archive/tools/setup-codex.sh
```

脚本会：① pull 仓库最新；② 安装 `~/personal-ai-archive/integrations/codex/archive-bridge.md` → `~/.codex/instructions/archive-bridge.md`；③ 备份 `~/.codex/AGENTS.md` 后**仅追加** §5 指针。重复运行安全（已含幂等检测）。

**Step 3 — 验证**

```bash
~/personal-ai-archive/tools/setup-codex.sh --check
grep -c "personal-ai-archive" ~/.codex/AGENTS.md     # 期望 >= 1
ls -l ~/.codex/instructions/archive-bridge.md        # 期望存在
```

**Step 4 — 生效**

- **重新打开 Codex 会话**（AGENTS.md 不热重载，改动只对新会话生效）。

**Step 5 — 后续同步（每次开工前）**

```bash
git -C ~/personal-ai-archive pull --rebase --autostash
```

---

## 5. 交付要求

- [ ] `~/personal-ai-archive` 工作区干净且与 `origin/main` 同步（`git -C ~/personal-ai-archive status --short` 应为空或仅待填占位符无改动）。
- [ ] `~/.codex/AGENTS.md` 仅以**纯追加**方式新增指针（差分应为 `49a50,55`，0 删除），并生成备份 `AGENTS.md.backup-archive-<时间戳>`。
- [ ] `~/.codex/instructions/archive-bridge.md` 与仓库 `integrations/codex/archive-bridge.md` **内容一致**。
- [ ] `setup-codex.sh --check` 输出全部 `[OK]`。
- [ ] Studio 端新开 Codex 会话，问"我的职业是什么"——应回答"待确认"（占位符未填时）或档案内容（填后）。

---

## 6. 风险与回滚

| 风险 | 处置 |
| --- | --- |
| Studio 已有自定义 `~/.codex/AGENTS.md` | 脚本先备份（`AGENTS.md.backup-archive-*`）再追加，**不覆盖**任何原有内容 |
| clone / pull 失败（网络） | 改用 tarball 或仅取必要文件；脚本提供 `--dry-run` 预览 |
| 桥接后想撤销 | `~/personal-ai-archive/tools/setup-codex.sh --rollback` 从最近备份恢复；或 `cp ~/.codex/AGENTS.md.backup-archive-<ts> ~/.codex/AGENTS.md` |
| 误填占位符 | 仓库有 main 保护规则（禁强推 / 禁删分支），`git revert` 即可回到历史版本 |

---

## 7. 验收清单

- [ ] Step 1 克隆成功，路径 `~/personal-ai-archive`
- [ ] Step 2 安装输出 `[OK] 桥接规则已安装` 与 `[OK] 已追加指针到 AGENTS.md`
- [ ] Step 3 三项验证全部通过
- [ ] Step 4 新开 Codex 会话后，能按档案规则回答个人相关问题
- [ ] 两端 `git -C ~/personal-ai-archive rev-parse HEAD` 一致

---

## 8. 备注（任务书外，仅给本人）

- 本任务书**只覆盖"档案系统 + Codex 桥接"**。已核实（2026-10-25，Air 端实际状态）：
  - **Codex**：✅ 已桥接本仓库（`~/.codex/AGENTS.md` 纯追加指针 + `~/.codex/instructions/archive-bridge.md`），见附录取证。
  - **WorkBuddy**：✅ 本会话即运行于 Air 端，经 `gh` 读写本仓库（仓库即由其搭建）。
  - **DeepSeek（军师）**：⚠️ 工具链本地存在（`junshi` / `junshi-ask` / `dsh`），依赖 `DEEPSEEK_API_KEY`；但**未与本仓库建立任何桥接**（脚本零引用），需另派任务接入。
  - **Harness（司穹 / deepseek-harness）**：⚠️ 本地存在完整 monorepo（`~/Documents/部署/deepseek-harness`）+ `.app` 封装；但**未与本仓库建立桥接**，需另派任务接入。
  - 结论：四件套中**仅 Codex 已对接本仓库**；DeepSeek / Harness 可用但未接线，不属于本任务书范围。
- 仓库当前是空壳（252 处占位符未填），本任务**不产生任何真实个人内容**。真实知识沉淀（Obsidian / WeKnora 等）是独立的后续任务，敏感内容应进私有仓（你若把本仓设为私密，可单独上传蒸馏/浓缩内容）。

---

## 附：Air 端已完成部署（对照基准）

| 项 | Air 端状态 |
| --- | --- |
| 路径 | `~/personal-ai-archive`（git clone，工作区干净） |
| Codex 版本 | `codex-cli 0.153.4`（MacBook Air 15' M4） |
| 桥接规则 | `~/.codex/instructions/archive-bridge.md` 已装，与仓库 diff 一致 |
| AGENTS.md | §5 指针已植入，**纯追加 6 行 / 0 删除**，备份 `AGENTS.md.backup-archive-20261024-150614` |
| 幂等验证 | 重复安装只会跳过，无重复追加 |
| 仓库 HEAD | 与 Studio 完成后应一致（见 §7 验收） |
