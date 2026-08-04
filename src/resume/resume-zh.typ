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
  accent-color: "#26428b",
  font: "Noto Sans SC",
  paper: "us-letter",
  author-position: left,
  personal-info-position: left,
)

== 教育

#edu(
  institution: "南昌大学",
  location: "江西南昌",
  dates: dates-helper(start-date: "Sep 2010", end-date: "Jul 2014"),
  degree: "信息与计算科学学士学位",
)
- 学习数学，编程语言，程序设计，算法等课程

== 工作经历

#work(
  title: "独立开发者",
  location: "远程",
  company: "自由职业",
  dates: dates-helper(start-date: "Jan 2024", end-date: "Present"),
)
- 在一家美国房地产初创公司担任核心工程师，使用 Next.js 和 AI 构建物业管理和数据分析系统。
- 在 intuipay 担任全栈工程师，使用 Next.js、Cloudflare 和区块链构建 Web3 捐赠平台。
- phi 编程代理，参考流行的 pi coding agent 使用 C\# 从头边学习边开发，目前可以自己给自己修改代码

#work(
  title: "后端工程师",
  location: "远程",
  company: "Alienswap (alienswap.xyz)",
  dates: dates-helper(start-date: "Mar 2023", end-date: "Dec 2023"),
)
- 与 Reservoir 团队合作构建支持交易合约的 NFT 索引系统，同时持续为开源生态贡献反馈。
- 设计并实现了一个中心化 NFT 交易所。

#work(
  title: "区块链工程师",
  location: "远程",
  company: "DeeperNetwork (deeper.network)",
  dates: dates-helper(start-date: "Aug 2021", end-date: "Nov 2022"),
)
- 使用 Rust 开发和维护基于 Substrate 的公有链 Deeper Chain。
- 使用 Node.js 开发和维护 Deeper 客户端设备的挖矿程序。
- 使用 Python 扩展开源的 Polkascan 区块链浏览器。

#work(
  title: "后端工程师",
  location: "北京",
  company: "石墨文档 (shimo.im)",
  dates: dates-helper(start-date: "Apr 2020", end-date: "Aug 2021"),
)
- 使用 Go 和 Node.js 为石墨文档 SaaS 产品开发后端功能。
- 与运维团队合作，为私有部署版本构建性能和运维工具。

#work(
  title: "联合创始人",
  location: "中国",
  company: "碗趣科技",
  dates: dates-helper(start-date: "Mar 2018", end-date: "Mar 2020"),
)
- 与两位合伙人共同创立了一家专注于 HTML5 小游戏的初创公司。

#work(
  title: "后端工程师",
  location: "北京",
  company: "瓜子二手车 (guazi.com)",
  dates: dates-helper(start-date: "May 2016", end-date: "Mar 2018"),
)
- 使用 PHP 开发瓜子二手车的后端业务系统。

#work(
  title: "后端工程师",
  location: "北京",
  company: "7k7k 小游戏 (7k7k.com)",
  dates: dates-helper(start-date: "Jul 2014", end-date: "May 2016"),
)
- 使用 PHP 开发 7k7k 游戏的后端业务系统。

== 开源项目

#project(
  name: "casbin-rs",
  role: "社区导师与核心贡献者",
  dates: dates-helper(start-date: "Mar 2019", end-date: "May 2021"),
)
- 在 Rust 生态系统中实现了核心授权功能。
- 指导贡献者并审查社区拉取请求。

== 技能
- *编程语言*: Rust, Go, TypeScript/JavaScript, Python, PHP, C\#, Solidity
- *区块链*: Substrate, NFT, 索引系统, 智能合约, TON 生态
- *框架与工具*: SvelteKit, Svelte, Cloudflare, Blazor, Tailwind CSS, Git, Linux/Unix