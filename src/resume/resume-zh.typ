#import "@preview/basic-resume:0.2.9": *

#let name = "谢非"
#let location = "北京"
#let email = "joey.xf@gmail.com"
#let phone = "+86 13693554167"
#let personal-site = "154839.xyz"

#show: resume.with(
  author: name,
  location: location,
  email: email,
  phone: phone,
  personal-site: personal-site,
  github: "github.com/xcaptain",
  accent-color: "#26428b",
  font: ("Noto Sans SC", "PingFang SC"),
  font-size: 10.5pt,
  paper: "a4",
  author-position: left,
  personal-info-position: left,
  lang: "zh",
)

#text(size: 9.5pt)[
  AI 应用 / Agent 工程师，12 年软件开发经验：2024 年起做 agent 产品与 AI SaaS，此前做 Web3 公链与 NFT 交易平台
]

== 工作经历

#work(
  title: "独立开发者（全栈 / AI）",
  location: "远程",
  company: "自由职业",
  dates: dates-helper(start-date: "2024.01", end-date: "至今"),
)
- 硅谷初创公司 realstack（核心工程师）：使用 Next.js 构建物业管理与数据分析系统，并将 AI 能力接入业务流程。
- intuipay（全栈工程师）：使用 Next.js、Cloudflare Workers 与区块链构建 Web3 捐赠平台。

#work(
  title: "后端工程师",
  location: "远程",
  company: "Alienswap (alienswap.xyz)",
  dates: dates-helper(start-date: "2023.03", end-date: "2023.12"),
)
- 与 Reservoir 团队协作构建支持交易合约的 NFT 索引系统，并持续向开源社区反馈问题与改进。
- 设计并实现中心化 NFT 交易所，并帮助一个电影 NFT 项目成功完成铸造与发行。

#work(
  title: "区块链工程师",
  location: "远程",
  company: "DeeperNetwork (deeper.network)",
  dates: dates-helper(start-date: "2021.08", end-date: "2022.11"),
)
- Rust 维护 Substrate 公链 Deeper Chain；Node.js 开发设备挖矿；Python 扩展 Polkascan 做自定义区块检索。

#work(
  title: "后端工程师",
  location: "北京",
  company: "石墨文档 (shimo.im)",
  dates: dates-helper(start-date: "2020.04", end-date: "2021.08"),
)
- 使用 Go 和 Node.js 为石墨文档 SaaS 开发后端功能，并与运维团队为私有化部署版本构建性能与运维工具。

#work(
  title: "后端工程师 → 联合创始人",
  location: "北京 / 中国",
  company: "7k7k 小游戏 · 瓜子二手车 · 碗趣科技",
  dates: dates-helper(start-date: "2014.07", end-date: "2020.03"),
)
- 2014.07–2016.05 后端工程师（7k7k）：使用 PHP 开发网页游戏平台后端。
- 2016.05–2018.03 后端工程师（瓜子）：使用 PHP 开发二手车交易业务系统。
- 2018.03–2020.03 联合创始人（碗趣）：与两位合伙人创立 HTML5 小游戏公司，曾拿下高铁游戏板块订单。

== 个人项目

#project(
  name: "Taskpost — 网页版通用 agent",
  url: "taskpost.org",
  dates: dates-helper(start-date: "2026.09", end-date: "至今"),
)
- 无需本地环境，跑在 Cloudflare Workers + Containers 上，支持文件读写、命令执行、联网搜索与只读分享。

#project(
  name: "phi — 基于 pi 架构实现的最小 coding agent",
  url: "github.com/xcaptain/phi",
  dates: dates-helper(start-date: "2026.07", end-date: "至今"),
)
- C\# 实现 agent loop、可替换 Provider、上下文压缩、会话持久化、双 UI 与插件热重载，单元测试覆盖。

#project(
  name: "SparkPin — 网页评论与标注 SaaS",
  url: "sparkpin.xyz",
  dates: dates-helper(start-date: "2026.03", end-date: "至今"),
)
- 2 行代码接入任意站点，SvelteKit + Cloudflare Workers + 多租户鉴权；用 CSS 定位器确定高亮位置。

#project(
  name: "MyPod Space — 网页转播客浏览器扩展",
  dates: "2025.01",
)
- ONNX 本地运行 Kokoro TTS，网页转播客 RSS；上架 #link("https://chromewebstore.google.com/detail/mypod-space/bpjkhpggekhbjofkapefhjidgkbomkel")[Chrome] / #link("https://microsoftedge.microsoft.com/addons/detail/mypod-space/hidhdmfkcncniamhjjhenbngmdbbolmp")[Edge] 商店。

#v(0.8em)
*开源*：#link("https://github.com/casbin/casbin-rs")[casbin-rs] 社区导师与核心贡献者，2019 — 2021；实现 Rust 核心授权与 PR 审查。

== 技能
- *编程语言*: TypeScript/JavaScript, Go, Rust, Python, C\#, PHP, Solidity
- *AI / LLM*: coding agent 架构（agent loop、tool calling、上下文压缩）、LLM API 集成、本地推理（ONNX）
- *Web / 全栈*: Next.js, SvelteKit, Tailwind, Node.js, Cloudflare Workers, Drizzle, better-auth, Git, CI/CD
- *区块链*: Substrate, EVM, NFT 索引, 智能合约、交易平台

#v(0.35em)
*教育*：南昌大学 · 信息与计算科学 学士 #h(1fr) 2010.09 — 2014.07
