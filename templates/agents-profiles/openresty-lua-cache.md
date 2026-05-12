## OpenResty Lua 缓存插件规则

本项目目标是基于 OpenResty 实现一套 Lua 缓存插件。通用代理流程仍以本文件前文为准；本节只补充 OpenResty/Lua 缓存领域约束。

### 项目启动路由

- 从 0 启动插件项目时，先走 `superpowers:brainstorming`，再按 gstack 路由使用 `/office-hours` 和 `/plan-eng-review`。
- 需要完整项目计划时，使用 `/autoplan`；但实现前仍必须用 `superpowers:writing-plans` 拆成可验证的小步骤。
- 涉及实现或 bugfix 时，使用 `superpowers:test-driven-development` 或 `superpowers:systematic-debugging`。
- 涉及性能、缓存命中率、延迟、吞吐时，使用 `/benchmark`。
- 涉及安全、权限、缓存污染或跨用户数据泄漏时，使用 `/cso`。
- 交付前使用 `/review` 和 `/qa` 或 `/qa-only`；发版前使用 `/ship`。

### 设计约束

- 明确缓存 key：method、host、uri、query、headers、body hash 是否参与，必须写入设计文档或 README。
- 明确缓存策略：TTL、stale-while-revalidate、bypass、purge、负缓存、错误降级和缓存击穿保护。
- 明确缓存存储：`lua_shared_dict`、磁盘缓存、上游 Redis，或组合方案；不要默认引入外部服务。
- 明确 OpenResty phase：`access_by_lua*`、`rewrite_by_lua*`、`content_by_lua*`、`header_filter_by_lua*`、`body_filter_by_lua*`、`log_by_lua*` 各自承担什么职责。
- 默认先做最小可运行插件：读配置、生成 key、查缓存、回源、写缓存、暴露基础指标。

### 风险红线

- 不允许把带用户身份、Cookie、Authorization 或私有响应的数据缓存成公共缓存，除非设计明确隔离 key 和权限边界。
- 不允许忽略 `Cache-Control`、`Set-Cookie`、状态码和响应大小限制。
- 不允许在没有并发保护的情况下实现回源写缓存，避免缓存击穿。
- 不允许只做 Lua 单元测试就声称插件可用；必须有 OpenResty/Nginx 级集成验证。

### 推荐测试

- 优先使用项目已有测试方式；从 0 开始时优先考虑 Test::Nginx 或可重复的 OpenResty 集成测试脚本。
- 至少覆盖：命中、未命中、TTL 过期、bypass、purge、上游错误、并发回源、不同 header/query 的 key 隔离。
- 性能验证至少记录基线延迟、命中后延迟、回源延迟和高并发下错误率。
