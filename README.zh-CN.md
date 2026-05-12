# project-agent-rules

[English](README.md)

`project-agent-rules` 是一个 Codex skill，用于创建和维护项目级 `AGENTS.md` 规则。

它不依赖固定项目模板，而是使用上下文驱动流程：先阅读项目，识别技术栈和风险，再选择合适的 superpowers/gstack 路由，最后只写 `AGENTS.md` 中的项目专用部分。

本项目把 `superpowers` 和 `gstack` 视为核心依赖：superpowers 提供 AI 工作流纪律，gstack 提供产品、架构、QA、发布和部署流程。

## 为什么需要它

`fastapi-service`、`nextjs-app`、`openresty-lua-cache` 这类固定 profile 很难覆盖真实项目。真实项目经常混合多个运行时、服务、部署目标和风险类型。

这个 skill 把可复用逻辑集中在一个地方：

- 先阅读真实项目，再写规则
- 保留通用 `AGENTS.md` 内容
- 只更新带标记的项目专用 section
- 为后续代理路由到正确的 superpowers 和 gstack 流程
- 要求具体的验证门禁，而不是模糊的“注意测试”

## 安装

先安装必需依赖：

- superpowers: https://github.com/obra/superpowers
- gstack: https://github.com/garrytan/gstack

克隆仓库并复制 skill 到 Codex skills 目录：

```bash
git clone git@github.com:noshenxian/project-agent-rules-skills.git
cd project-agent-rules-skills
mkdir -p ~/.codex/skills
cp -R skills/project-agent-rules ~/.codex/skills/
```

如果本地已存在该 skill，显式替换：

```bash
rm -rf ~/.codex/skills/project-agent-rules
cp -R skills/project-agent-rules ~/.codex/skills/
```

## 使用

在目标项目中让 Codex 使用该 skill：

```text
Use project-agent-rules to generate project-specific AGENTS.md rules for this repo.
Read the project first, identify stack/risk/test/deploy signals, then update only the PROJECT_AGENT_RULES section.
```

如果环境通过命令暴露 skills，按名称加载：

```text
project-agent-rules
```

安装 superpowers 后，也可以通过 Codex wrapper 加载：

```bash
~/.codex/superpowers/.codex/superpowers-codex use-skill project-agent-rules
```

如果 superpowers 或 gstack 缺失，应先停止并安装缺失依赖，再生成规则。本项目不把普通本地 checklist 当作等价替代。

生成的 section 形态如下：

```markdown
<!-- PROJECT_AGENT_RULES_START -->
## Project-Specific Agent Rules

### Project Signals
[stack, runtime, domain, risks, delivery target]

### Required Routing
[superpowers and gstack routing for this project]

### Engineering Rules
[architecture, testing, safety, performance, deployment constraints]

### Verification Gates
[commands or manual checks required before completion]
<!-- PROJECT_AGENT_RULES_END -->
```

确定性应用生成 section：

```bash
skills/project-agent-rules/scripts/apply-agents-section.sh /path/to/AGENTS.md /path/to/section.md
```

脚本会拒绝不安全的 marker 状态，包括缺失成对 marker、重复 section 或 marker 顺序反转。

## 旧版 Profile 辅助脚本

仓库还包含 `scripts/init-agents.sh`，可快速复制基础 `AGENTS.md` 并追加固定 profile。它适合引导初始化；真实项目优先使用 skill 驱动流程。

列出 profiles：

```bash
scripts/init-agents.sh --list
```

初始化 OpenResty/Lua cache plugin 示例：

```bash
scripts/init-agents.sh ../openresty-lua-cache-plugin openresty-lua-cache
```

## 测试

运行 skill 验证套件：

```bash
scripts/test_project_agent_rules_skill.sh
```

测试覆盖：

- skill frontmatter 和必需章节
- bundled scripts 的 shell 语法
- 无 marker 时追加 section
- 有 marker 时替换 section
- marker 不匹配时失败且不修改用户内容
- canonical 文件保持英文，中文仅放在本地化文档

额外 shell 语法检查：

```bash
sh -n scripts/init-agents.sh
sh -n scripts/test_project_agent_rules_skill.sh
sh -n skills/project-agent-rules/scripts/apply-agents-section.sh
```

## 要求

- Codex skills runtime
- superpowers
- gstack
- POSIX `sh`
- `awk`, `grep`, `sed`, `cp`, `mkdir`
- 测试脚本需要 `rg`
