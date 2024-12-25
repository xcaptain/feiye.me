---
title: "学习部署solana智能合约"
publishDate: "23 Dec 2024"
description: "上周研究了一下在区块链上部署代理软件，然后公开代理节点的可行性，最终方案是使用智能合约来管理费用，这篇文章将总结一下如何部署和测试solana program"
tags: ["solana", "web3", "proxy"]
draft: true
---

在 [上周的博客](/posts/build-a-proxy-on-blockchain) 里面提到了将代理服务部署到区块链上的想法，然后提出了3个可行的方案，最后我考虑是使用智能合约比较简单。目前所有的区块链中，gas费用最低的链是solana，因此本文将学习一下如何部署 solana program，搭建本地环境，以及如何测试等等。

## 安装solana开发环境

文档见：[https://solana.com/docs/intro/installation](https://solana.com/docs/intro/installation) 总之就是要下载 `solana`, `avm`, `solana` 是用来本地跑区块链测试节点的，也能用来连接测试网获取空投的测试币
`avm` 是用来编译 rust 代码的，solana 的智能合约是用 rust 写的

查看当前节点的配置：

```bash
solana config get
```

默认连的是mainnet，切换到测试网

```bash
solana config set --url https://api.devnet.solana.com
```

创建一个本地的测试账号。

```bash
solana-keygen new
```

账号信息会保存到 `~/.config/solana/id.json` 文件中，可以通过 `solana-keygen pubkey` 查看账号地址。也可以通过 `solana address` 查看。

获取测试币

```bash
solana airdrop 5
```

这时候账户里就有余额了，`solana balance` 查看余额。

## 创建一个 solana program

文档见：[https://solana.com/docs/programs/anchor](https://solana.com/docs/programs/anchor)

```shell
# build合约
anchor build

# 测试，会开启一个新的本地测试节点
anchor test
# or
anchor test --skip-local-validator # 使用已经开启的本地测试节点

anchor deploy # 部署到 Anchor.toml 里面指定的 cluster
```

部署合约的手续费很低，但是要放一部分sol到新的合约里面维持存储，所以实际还是会消耗多一点sol的。想要将这些币拿回来可以销毁合约，如：

```shell
solana program close 8qQvDDfGT6TFDkJaEfGNkDSt3BqkNZpdCHnrq1nKwTaH --bypass-warning
```
