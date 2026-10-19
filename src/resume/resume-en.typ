#import "@preview/basic-resume:0.2.9": *

#let name = "Joey Xie"
#let location = "Beijing, China"
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
  font: "New Computer Modern",
  paper: "us-letter",
  author-position: left,
  personal-info-position: left,
  lang: "en",
)

#set par(justify: false)

#v(0.2em)
#text(size: 9.5pt)[
  AI Application / Agent Engineer with 12 years of software development experience: building agent products and AI SaaS since 2024; previously Web3 public chains and NFT trading platforms.
]

== Work Experience

#work(
  title: "Independent Developer (Full-stack / AI)",
  location: "Remote",
  company: "Freelance",
  dates: dates-helper(start-date: "Jan 2024", end-date: "Present"),
)
- Core engineer at realstack: property management and data analysis system with Next.js and AI.
- Full-stack engineer at intuipay: Web3 donation platform with Next.js, Cloudflare Workers, and blockchains.

#work(
  title: "Backend Engineer",
  location: "Remote",
  company: "Alienswap (alienswap.xyz)",
  dates: dates-helper(start-date: "Mar 2023", end-date: "Dec 2023"),
)
- Built an NFT indexing system with Reservoir supporting exchange contracts; contributed upstream feedback.
- Designed and implemented a centralized NFT exchange; supported a movie NFT project's minting and launch.

#work(
  title: "Blockchain Engineer",
  location: "Remote",
  company: "DeeperNetwork (deeper.network)",
  dates: dates-helper(start-date: "Aug 2021", end-date: "Nov 2022"),
)
- Maintained Deeper Chain (Substrate/Rust) and mining programs (Node.js); extended Polkascan (Python).

#work(
  title: "Backend Engineer",
  location: "Beijing, China",
  company: "Shimo (shimo.im)",
  dates: dates-helper(start-date: "Apr 2020", end-date: "Aug 2021"),
)
- Delivered Shimo Docs backend features in Go/Node.js; built performance and ops tooling for private deployments.

#work(
  title: "Backend Engineer → Co-Founder",
  location: "Beijing / China",
  company: "7k7k Games · Guazi · Wanqu Technology",
  dates: dates-helper(start-date: "Jul 2014", end-date: "Mar 2020"),
)
- Jul 2014 – May 2016, Backend Engineer (7k7k): developed game backend services in PHP.
- May 2016 – Mar 2018, Backend Engineer (Guazi): developed used-car business systems in PHP.
- Mar 2018 – Mar 2020, Co-Founder (Wanqu): co-founded an HTML5 mini-games startup with two partners.

== Selected Projects

#project(
  name: "Taskpost — browser-based general agent",
  url: "taskpost.org",
  dates: dates-helper(start-date: "Sep 2026", end-date: "Present"),
)
- Browser-based agent on Cloudflare Workers + Containers: file read/write, commands, web search, read-only sharing.

#project(
  name: "phi — minimal coding agent based on pi architecture",
  url: "github.com/xcaptain/phi",
  dates: dates-helper(start-date: "Jul 2026", end-date: "Present"),
)
- C\# coding agent: agent loop, replaceable providers, context compaction, session persistence, desktop + TUI, plugin hot-reload; unit-tested.

#project(
  name: "SparkPin — web comment and annotation SaaS",
  url: "sparkpin.xyz",
  dates: dates-helper(start-date: "Mar 2026", end-date: "Present"),
)
- Two-line embed for any site; SvelteKit + Cloudflare Workers + multi-tenant auth; CSS-based highlight locator.

#project(
  name: "MyPod Space — web-to-podcast browser extension",
  dates: "Jan 2025",
)
- Local Kokoro TTS via ONNX; turns web pages into podcast RSS; published on #link("https://chromewebstore.google.com/detail/mypod-space/bpjkhpggekhbjofkapefhjidgkbomkel")[Chrome] and #link("https://microsoftedge.microsoft.com/addons/detail/mypod-space/hidhdmfkcncniamhjjhenbngmdbbolmp")[Edge] stores.

#v(0.8em)
*Open Source*: #link("https://github.com/casbin/casbin-rs")[casbin-rs], Community Mentor & Core Contributor, 2019 – 2021; core Rust authorization and PR review.

== Skills
- *Languages*: TypeScript/JavaScript, Go, Rust, Python, C\#, PHP, Solidity
- *AI / LLM*: agent architecture (loop, tool calling, context compaction), LLM APIs, ONNX inference
- *Web / Full-stack*: Next.js, SvelteKit, Tailwind, Node.js, Cloudflare Workers, Drizzle, better-auth
- *Blockchain*: Substrate, EVM, NFT indexing, smart contracts, trading platforms
- *Tools*: Git, Linux/Unix, CI/CD

#v(0.35em)
*Education*: Nanchang University — B.S. in Information and Computing Science #h(1fr) Sep 2010 – Jul 2014
