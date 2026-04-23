#import "@preview/basic-resume:0.2.9": *

#let name = "Joey Xie"
#let location = "China"
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
  font: "New Computer Modern",
  paper: "us-letter",
  author-position: left,
  personal-info-position: left,
)

== Education

#edu(
  institution: "Nanchang University",
  location: "Nanchang, China",
  dates: dates-helper(start-date: "Sep 2010", end-date: "Jul 2014"),
  degree: "Bachelor's Degree in Information and Computing Science",
)
- Studied core mathematics curriculum and computer science fundamentals.

== Work Experience

#work(
  title: "Independent Developer",
  location: "Remote",
  company: "Freelance",
  dates: dates-helper(start-date: "Jan 2024", end-date: "Present"),
)
- Core engineer in a US real estate startup, building a property management and data analysis system in Next.js and AI.
- Full stack engineer at intuipay, built a web3 donation platform using Next.js, cloudflare and blockchains.
- Built SparkPin, a web annotation/comment plugin for precise comments on text and images with a full-stack SvelteKit + Tailwind CSS architecture.

#work(
  title: "Backend Engineer",
  location: "Remote",
  company: "Alienswap (alienswap.xyz)",
  dates: dates-helper(start-date: "Mar 2023", end-date: "Dec 2023"),
)
- Collaborated with the Reservoir team to build an NFT indexing system supporting exchange contracts while continuously contributing feedback to the open-source ecosystem.
- Designed and implemented a centralized NFT exchange.
- Delivered minting and launch support for a movie NFT project.

#work(
  title: "Blockchain Engineer",
  location: "Remote",
  company: "DeeperNetwork (deeper.network)",
  dates: dates-helper(start-date: "Aug 2021", end-date: "Nov 2022"),
)
- Developed and maintained Deeper Chain, a Substrate-based public blockchain, in Rust.
- Developed and maintained mining programs for Deeper client devices in Node.js.
- Extended the open-source Polkascan blockchain explorer in Python.
- Became an early adopter and contributor to Parity's Substrate Archive indexing service.

#work(
  title: "Backend Engineer",
  location: "China",
  company: "Shimo (shimo.im)",
  dates: dates-helper(start-date: "Apr 2020", end-date: "Aug 2021"),
)
- Delivered backend features for the Shimo Docs SaaS product using Go and Node.js.
- Worked with DevOps to build performance and operations tooling for private deployment editions.

#work(
  title: "Co-Founder",
  location: "China",
  company: "Wanqu Technology",
  dates: dates-helper(start-date: "Mar 2018", end-date: "Mar 2020"),
)
- Co-founded a startup focused on HTML5 mini-games with two partners.

#work(
  title: "Backend Engineer",
  location: "China",
  company: "Guazi (guazi.com)",
  dates: dates-helper(start-date: "May 2016", end-date: "Mar 2018"),
)
- Developed backend business systems in PHP.

#work(
  title: "Backend Engineer",
  location: "China",
  company: "7k7k Games (7k7k.com)",
  dates: dates-helper(start-date: "Jul 2014", end-date: "May 2016"),
)
- Developed backend business systems in PHP.

== Open Source

#project(
  name: "casbin-rs",
  role: "Community Mentor & Core Contributor",
  dates: dates-helper(start-date: "Mar 2019", end-date: "May 2021"),
)
- Implemented core authorization capabilities in the Rust ecosystem.
- Mentored contributors and reviewed community pull requests.

== Skills
- *Languages*: Rust, Go, TypeScript/JavaScript, Python, PHP, Node.js, Solidity
- *Blockchain*: Substrate, NFT infrastructure, indexing systems, smart contract integration, TON ecosystem
- *Frameworks & Tools*: SvelteKit, Svelte, Blazor, Tailwind CSS, Git, Linux/Unix