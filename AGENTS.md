# AGENTS.md

本文件定义当前目录下 AI 代理协作的通用规则。除非用户另有明确要求，所有代理都应优先遵守本文件。

## 基本约定

- 始终使用简体中文回复用户。
- 先理解目标，再行动。遇到不明确的需求时，优先从现有文件、README、目录结构和上下文中推断；只有关键决策无法安全推断时才向用户提问。
- 保持改动小而聚焦。不要顺手重构无关代码、修改无关文件或引入与任务无关的新工具。
- 尊重用户已有改动。不要回滚、覆盖或清理自己未创建的变更，除非用户明确要求。
- 优先使用仓库已有约定、脚手架、命令和文档；没有约定时再采用通用最佳实践。

## Skills 使用规则

本目录关注“AI 接管开发”的流程实验，应把 skills 视为代理能力扩展与流程约束的主要入口。

- 每次会话开始或处理任何用户请求前，先运行：
  `~/.codex/superpowers/.codex/superpowers-codex bootstrap`
- 只要有较小概率存在适用 skill，必须加载并阅读该 skill，不能只凭记忆、名称或描述行事。
- 加载 superpowers skill 使用：
  `~/.codex/superpowers/.codex/superpowers-codex use-skill <skill-name>`
- 如果用户点名某个 skill，必须使用它；如果 skill 缺失或无法读取，说明原因并采用最接近的替代方案继续。
- 同时存在多个适用 skill 时，按顺序使用：
  1. 流程类 skill，例如需求澄清、计划、调试、TDD、验证。
  2. 领域类 skill，例如前端、后端、CI/CD、数据库、文档、设计。
  3. 工具类 skill，例如脚手架、生成器、部署、自动化命令。
- 使用 skill 后，简短说明“已读取哪个 skill，以及用它约束什么工作”。
- 如果 skill 要求创建任务清单、测试先行、系统化调试或完成前验证，必须执行，不得以任务简单为理由跳过。
- 用户说明的是目标和约束，不代表可以跳过 skill 要求的流程。即使用户只说“改一下”“修一下”“评估一下”，仍要按适用 skill 的流程执行。

## 编写或维护 Skill 的原则

当任务是创建、修改、整理或评估 skill 时，遵循以下规则：

- skill 应解决可复用的问题，而不是记录一次性经验。
- 描述字段只写触发条件，不写流程摘要，避免代理只读描述而跳过正文。
- 名称使用清晰、可搜索、动作导向的短横线格式。
- 正文优先短小、可扫描，重型参考资料或脚本放到独立文件。
- 需要约束行为的 skill 要明确常见误用、红旗信号和禁止绕过方式。
- 新 skill 或重要修改必须按 RED-GREEN-REFACTOR 处理：
  1. RED：先设计压力场景或验证场景，观察没有该 skill 时代理会如何失败。
  2. GREEN：只写能覆盖这些失败的最小 skill 内容。
  3. REFACTOR：继续寻找新的绕过方式或误用方式，并补上明确约束。
- 没有失败场景或验证证据，不要声称 skill 已经可用。

## gstack 使用规则

`gstack` 在本目录中用于项目骨架、架构分层和工程结构设计；`superpowers skills` 用于约束代理工作流程。两者职责不同，不要混用。

- 中大型产品、功能或项目从 0 开始时，gstack 官方主流程是：`/office-hours` -> 计划评审 -> 实现 -> `/review` -> `/qa` -> `/ship` -> 部署验证。不要跳过前置的需求和计划阶段直接搭骨架。
- 如果本机没有安装 gstack，不要擅自联网安装。先检查 `~/gstack`、`~/.codex/skills`、本地可用 slash command 或本地 skill；确认缺失后再告诉用户需要安装，并给出推荐命令：`git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/gstack && cd ~/gstack && ./setup --host codex`。
- gstack 可能使用短命令，例如 `/qa`，也可能使用命名空间命令，例如 `/gstack-qa`。遵循本机安装配置；如果不确定，先查本地 gstack skills 或询问用户。
- 在 Codex 环境中，优先加载与 slash command 对应的 `gstack-*` skill，例如 `/qa` 对应 `gstack-qa`，加载命令为：`~/.codex/superpowers/.codex/superpowers-codex use-skill gstack-qa`。如果它们不是 superpowers skill，而是本地 slash command，则按本机 gstack 安装后的实际入口执行；如果自动发现失败，说明情况，并按官方文档手动查找对应 skill 内容。
- 当 superpowers 和 gstack 同时适用时，先执行 superpowers 流程类 skill 来约束工作方式，再执行 gstack 产品、设计、架构或交付 skill 来处理具体阶段。如果 gstack skill 已覆盖同类评审，不重复跑同类流程；只补缺失的检查。
- 使用 `gstack` 前，先确认需求边界、目标平台、运行方式、数据存储、测试方式和部署目标；信息不足时先列出假设，不要直接生成复杂骨架。
- 不要为了使用 `gstack` 而引入不必要的框架、服务或依赖。项目骨架应服务于当前最小可运行示例。
- 如果实际使用 `gstack` 生成或调整项目结构，必须记录使用的命令、生成的关键文件、后续需要人工确认的架构决策。
- 当 `gstack` 输出与本文件、README 或用户明确要求冲突时，以用户要求和本文件为准，再手动调整生成结果。

### gstack skill 路由

按任务场景明确选择 gstack skill：

| 场景 | 必用或优先使用 |
| --- | --- |
| 新想法、需求很模糊、担心被 AI 带偏 | `/office-hours` |
| 用户要求从 0 做产品、功能或项目骨架 | 先 `/office-hours`，再 `/autoplan` |
| 已有功能想法，需要判断范围、野心、最小可行版本 | `/plan-ceo-review` |
| 需要完整计划流水线，不想手动逐个评审 | `/autoplan` |
| 需要定架构、数据流、模块边界、边界条件、测试矩阵 | `/plan-eng-review` |
| 需要 UI/UX 计划评审 | `/plan-design-review` |
| 需要从零建立设计系统或产品视觉方向 | `/design-consultation` |
| 需要多个视觉方案并比较取舍 | `/design-shotgun` |
| 需要生成生产质量 HTML 或前端界面草稿 | `/design-html` |
| 代码已有改动，需要找生产级风险、完整性缺口 | `/review` |
| 遇到 bug、测试失败、线上异常，需要根因调查 | `/investigate` |
| 需要打开网页、截图、点击、验证真实页面状态 | `/browse` |
| 需要测试登录态或 authenticated 页面 | 先 `/setup-browser-cookies`，再 `/browse` 或 `/qa` |
| 需要端到端测试并允许自动修复 | `/qa` |
| 只要测试报告，不允许自动改代码 | `/qa-only` |
| 需要视觉审计和自动修复 UI 问题 | `/design-review` |
| 需要安全审计、威胁建模、OWASP/STRIDE 检查 | `/cso` |
| 需要性能基线、Core Web Vitals、前后对比 | `/benchmark` |
| 准备发 PR、同步 main、跑测试、检查覆盖率 | `/ship` |
| PR 已批准，需要合并、部署、验证生产健康 | 先 `/setup-deploy`，再 `/land-and-deploy` |
| 部署后需要监控错误、性能和页面失败 | `/canary` |
| 代码已发布，需要同步 README、架构文档、变更记录 | `/document-release` |
| 需要审查开发者体验、上手路径、文档是否真实 | 计划阶段用 `/plan-devex-review`，真实流程用 `/devex-review` |
| 需要安全防护，避免破坏性命令或限制编辑范围 | `/careful`、`/freeze`；需要两者时用 `/guard` |
| 需要保存或恢复跨会话上下文 | 保存用 `/context-save`，恢复用 `/context-restore` |
| 需要维护项目记忆或跨机器记忆 | `/learn`、`/setup-gbrain`、`/sync-gbrain` |
| 需要另一个模型或代理给独立二次意见 | `/codex`；当前环境无法直接调用时，要说明限制并给出可替代评审方式 |

### gstack 使用顺序

- 从 0 到计划：`/office-hours` -> `/autoplan`，必要时单独补 `/plan-ceo-review`、`/plan-design-review`、`/plan-eng-review`。
- 从计划到实现：先确认计划产物和未决问题，再实现；实现期间仍遵守 `Skills 使用规则` 中的 TDD、调试和验证要求。
- 从实现到交付：`/review` -> `/qa` 或 `/qa-only` -> `/ship`。
- 从交付到线上：`/setup-deploy` -> `/land-and-deploy` -> `/canary` -> `/document-release`。
- 小改动不强制使用完整 gstack 流程；但只要涉及产品方向、架构、真实浏览器验证、QA、发版或部署，就必须按上面的路由选择对应 skill。

## 开发流程

- 阅读 `README.md` 和相关文件后再实现。
- 搜索文件优先使用 `rg` 或 `rg --files`。
- 修改文件优先使用补丁方式，避免无关格式化和大范围机械改写。
- 新增功能或修复缺陷时，优先考虑测试；如果项目尚无测试框架，至少提供可重复的验证命令或手工验证步骤。
- 调试时先复现问题，再定位根因，最后做最小修复。不要在没有证据的情况下猜测式改动。
- 涉及项目骨架、脚手架或工程结构时，按 `gstack 使用规则` 处理；涉及代理流程、需求澄清、计划、调试、测试和验证时，按 `Skills 使用规则` 处理。

## 验证与交付

- 完成前运行与改动相关的验证命令；如果无法运行，说明原因。
- 回复用户时说明改了哪些文件、解决了什么问题、如何验证。
- 不夸大结果。没有运行测试就不要声称测试通过。
- 如果留下后续风险或待办，明确列出，不把它们隐藏在总结里。

## 当前目录定位

当前目录用于从 0 构建“AI 接管开发”的最小示例：用 `superpowers skills` 管流程，用 `gstack` 管项目骨架。因此，本目录中的文档和代码应优先服务于：

- 让 AI 代理更稳定地理解需求。
- 让开发过程更可验证、可复用、可交接。
- 让项目结构和流程约束足够清晰，避免 AI 自行发散。
