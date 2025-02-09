---
title: "如何用substrate框架搭建一条自己的区块链"
publishDate: "19 Dec 2024"
description: "本文将介绍一下如何用substrate框架搭建一条自定义区块链。substrate是一个很流行的做公链的框架，模块化设计，对新手应该比较友好"
tags: ["blockchain", "web3", "tutorial"]
draft: true
---

在[上篇博客](/posts/build-a-proxy-on-blockchain) 中写到了我想要搭建一个基于区块链的代理服务。这篇文章就先记录一下我是如何学习使用 substrate 框架来做链的。

## 什么是区块链

网上有很多介绍。在我看来区块链就是一个分布式数据库，这个数据库保存的是每个地址的余额。提供了最基本的 transfer 方法来转移用户的余额。跟我们在银行里的余额有什么区别呢？就是银行里的余额只是余额表里的一条记录。有各种程序能修改这个值，正常情况下这些修改都是对的，比如说我们在网上买了一件100块钱商品，调用银行卡接口付费了，那么卡里的余额就要减少100块。有没有可能银行里有个黑客，篡改了自己的余额，然后去ATM机提现跑路了呢？理论上是有可能的。区块链如何解决这个记录被坏人篡改的问题的呢？这就涉及到密码学的知识。要转账必须要本人的私钥签名才行。直接改库的行为也被禁止了，因为有一堆节点在验算账单，一个节点的数据库改了，其他节点是不认可这个改动的。

还有很多其他的知识，比如说 p2p 网络，代币经济学，共识算法等，这些知识知道个大概就行。

## 什么是 substrate

substrate 是parity公司在开发自己的 polkadot 区块链时，使用到的一个框架，他们为了让普通人也可以快速搭建一条区块链出来，在设计的时候用到了模块化的方法。polkadot 主网是在2020年上线的，在这之前要想自己开发一条区块链很复杂，一般是选择一条现有的链的代码库，改改。比如说改 bitcoin，或者是改 ethereum 的代码。这种二次开发就很困难，虽然是开源的，但是人家团队在开发的时候就没考虑要给别的项目用，如果不是很熟悉代码库的话，改起来还是很容易出错的。

parity 开源出 substrate 框架后，做链就简单多了，不再是 fork一个几百万行代码的代码库，找各种配置文件改，而是按照模版，写几百行代码就可以跑一个简单的区块链起来。如果发现自己缺什么再加什么。

我不是bitcoin、ethereum的核心开发者，我不知道他们的代码库咋改，我只是想做一条公链验证我的想法，因此就选择了 substrate。

## 学习步骤

官方给出了一个[学习步骤](https://docs.substrate.io/tutorials/build-a-blockchain/) 大致是：

1. 本地跑一个单节点测试网
2. 本地跑一个2节点测试网
3. 用自己生成的key在本地跑2个节点的测试网
4. 授权新的节点加入本地测试网
5. 升级本地测试网

按照官方这个教程操作一下，搞明白后应该就能开始自建区块链了。后续添加、删除节点这块要好好演练下，这步不理解好，未来自己的链有新的节点要加入就会有问题。

我是使用 [https://github.com/paritytech/polkadot-sdk-minimal-template.git](https://github.com/paritytech/polkadot-sdk-minimal-template.git) 这个模版库来演练官方教程的，克隆到本地，所有操作都在这个文件夹下进行。

### 本地跑一个单节点测试网

构建可执行文件

```bash
cargo build
```

官方的教程是执行 `cargo build --release`，我本地测试发现加上 `--release` 耗时会比较长，所以还是不加好，到时候部署线上的时候肯定要加。编译出来的文件在 `target/debug` 下，我本地这个文件夹 27G 大，真可怕。


运行节点：

```bash
./target/debug/minimal-template-node --dev
```

如果看到如下输出就说明一切正常。

```
WARNING: No public address specified, validator node may not be reachable.
                                Consider setting `--public-addr` to the public IP address of this node.
                                This will become a hard requirement in future versions.
WARNING: No public address specified, validator node may not be reachable.
                                Consider setting `--public-addr` to the public IP address of this node.
                                This will become a hard requirement in future versions.
2024-12-19 17:26:31 Substrate Node    
2024-12-19 17:26:31 ✌️  version 0.1.0-3004222b11e    
2024-12-19 17:26:31 ❤️  by Parity Technologies <admin@parity.io>, 2017-2024    
2024-12-19 17:26:31 📋 Chain specification: Development    
2024-12-19 17:26:31 🏷  Node name: curvy-eggnog-3039    
2024-12-19 17:26:31 👤 Role: AUTHORITY    
2024-12-19 17:26:31 💾 Database: RocksDb at /var/folders/sb/mnlwx83j1hl4pyt_45h1psph0000gn/T/substratex8CN2y/chains/dev/db/full    

2024-12-19 17:26:40 🏆 Imported #2 (0xd43f…a502 → 0x4e2b…f61a)    
2024-12-19 17:26:43 🙌 Starting consensus session on top of parent 0x4e2be1b30c42ab7c2a2092cfaf6a2529444a3391fd66593ee7070830c9d1f61a (#2)    
2024-12-19 17:26:43 🎁 Prepared block for proposing at 3 (8 ms) [hash: 0x312264b04d99d78f9fc3ff4e49a76587addbc28ebe1925f51dafd03c40c52fa3; parent_hash: 0x4e2b…f61a; extrinsics (1): [0xb022…a525]    
2024-12-19 17:26:43 Consensus with no RPC sender success: CreatedBlock { hash: 0x312264b04d99d78f9fc3ff4e49a76587addbc28ebe1925f51dafd03c40c52fa3, aux: ImportedAux { header_only: false, clear_justification_requests: false, needs_justification: false, bad_justification: false, is_new_best: true }, proof_size: 0 }    
2024-12-19 17:26:43 🏆 Imported #3 (0x4e2b…f61a → 0x3122…2fa3)    
2024-12-19 17:26:44 💤 Idle (0 peers), best: #3 (0x3122…2fa3), finalized #3 (0x3122…2fa3), ⬇ 0 ⬆ 0   
```

这段日志说明了：

1. Role: AUTHORITY 说明这个节点是验证人节点
2. Chain specification: Development 说明这个节点是使用的开发环墫的规格
3. Node name: curvy-eggnog-3039 说明这个节点的名字是 curvy-eggnog-3039
4. Database: RocksDb at /var/folders/sb/mnlwx83j1hl4pyt_45h1psph0000gn/T/substratex8CN2y/chains/dev/db/full 说明这个节点的数据库是 RocksDb，路径是 /var/folders/sb/mnlwx83j1hl4pyt_45h1psph0000gn/T/substratex8CN2y/chains/dev/db/full
5. Imported #3 (0x4e2b…f61a → 0x3122…2fa3) 说明这个节点已经同步到了区块高度为3的区块。说是说同步，因为只有一个节点，这个区块就是它自己生成的，没跟其他节点进行共识。

到这里就差不多了，这个环境一般是用来测试节点里的代码对不对，比如我想把代理集成到区块链，我就可以这么启动链，然后看看 8080 端口有没开，能不能正常处理代理请求。

### 本地跑一个2节点测试网

上面一个节点没有网络这个概念，2节点就算是有网络了，我造的区块可以同步给你，你造的块同步给我，2个节点的网络跑通了，那么扩展到3个、4个乃至更多节点的思路也是一样的。



