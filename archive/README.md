<!-- AI-TAG: archive.index
     ACCESS: ai-editable
     OWNER: human
     SCOPE: on-demand
     LAST-UPDATED: 2026-10-24
     LANG: zh-CN
-->
# AI-EDITABLE: archive 目录索引

**本目录放"已经过去、但不想丢"的东西**。

| 文件/目录 | 内容 | AI 何时读取 |
| --- | --- | --- |
| [projects.md](./projects.md) | 已完结项目清单：目标、结论、可复用的东西 | 了解我的实战背景时 |
| [old-documents/](./old-documents/) | 过期方案、停用草稿、旧版档案 | 几乎不用，仅供追溯 |

## 规则

- **只增不改**：归档一旦完成不再编辑；发现问题就在下方追加一条"补充说明"。
- **去敏**：项目描述里不要出现客户机密、内部数据。
- **可丢弃存档**：超过 2 年且从未被读取的内容，可从本目录删除（这是极少数允许删除的地方，删除前先在 CHANGELOG 说明）。

## 归档操作

```bash
# 新建一份归档：复制 projects.md 里的项目模板，填写后提交
git add -A && git commit -m "archive: 归档 XX 项目" && git push
```
