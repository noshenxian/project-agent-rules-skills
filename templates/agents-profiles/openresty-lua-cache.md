## OpenResty Lua Cache Plugin Rules

This project aims to implement a Lua cache plugin on top of OpenResty. The generic agent workflow still comes from the earlier parts of `AGENTS.md`; this section only adds OpenResty/Lua cache-specific constraints.

### Project Startup Routing

- When starting a plugin project from zero, use `superpowers:brainstorming` first, then route through gstack `/office-hours` and `/plan-eng-review`.
- When a full project plan is needed, use `/autoplan`; before implementation, still use `superpowers:writing-plans` to split the work into verifiable small steps.
- For implementation or bug fixes, use `superpowers:test-driven-development` or `superpowers:systematic-debugging`.
- For performance, cache hit ratio, latency, or throughput concerns, use `/benchmark`.
- For security, authorization, cache poisoning, or cross-user data leakage concerns, use `/cso`.
- Before delivery, use `/review` and `/qa` or `/qa-only`; before release, use `/ship`.

### Design Constraints

- Define the cache key explicitly: whether method, host, URI, query, headers, and body hash participate must be documented in the design or README.
- Define the cache policy: TTL, stale-while-revalidate, bypass, purge, negative caching, error fallback, and cache stampede protection.
- Define the cache store: `lua_shared_dict`, disk cache, upstream Redis, or a combined approach. Do not introduce an external service by default.
- Define OpenResty phase responsibilities: `access_by_lua*`, `rewrite_by_lua*`, `content_by_lua*`, `header_filter_by_lua*`, `body_filter_by_lua*`, and `log_by_lua*`.
- Start with the smallest runnable plugin: read config, generate key, read cache, fetch upstream, write cache, and expose basic metrics.

### Risk Boundaries

- Do not cache user-specific, Cookie-bearing, Authorization-bearing, or private responses as public cache unless key isolation and authorization boundaries are explicitly designed.
- Do not ignore `Cache-Control`, `Set-Cookie`, status codes, or response size limits.
- Do not implement upstream refill without concurrency protection; prevent cache stampedes.
- Do not claim the plugin is usable after Lua unit tests only; require OpenResty/Nginx-level integration verification.

### Recommended Tests

- Prefer the project's existing test method. From zero, consider Test::Nginx or repeatable OpenResty integration test scripts.
- Cover at least: hit, miss, TTL expiry, bypass, purge, upstream error, concurrent refill, and key isolation across headers and query strings.
- Performance verification should record baseline latency, hit latency, upstream latency, and error rate under high concurrency.
