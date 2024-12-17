---
title: "在区块链上部署代理节点"
publishDate: "17 Dec 2024"
description: "上周在配置本地代理的时候产生了一个点子就是能不能把代理节点放到区块链上，这样就不需要到处去买机场服务，找到最快的线路最便宜的节点，尤其是某个机场被封锁的话，基本所有节点就废了"
tags: ["blockchain", "web3", "proxy"]
draft: true
---

在[上周的博客](/posts/journal/2024-12-102024-12-15)中讲到了这个想法，这几天有时间打算来验证一下。

## 方案设计

区块链上的VPN有很多实现，能不能不自建区块链，而是使用现有的区块链来实现呢？

要复用现有的区块链如：ETH、SOL, polkadot，就需要先实现一个管理费用的智能合约，部署到区块链上，然后让VPN节点定时跟这个合约交互，获取最新的代理信息。

这个过程有一个重要的问题就是不能处理恶意诈骗问题。比如说节点 A 在智能合约上注册自己为服务器节点，节点 B 通过智能合约获取到节点 A 的信息，但是节点 A 并没有提供服务，这个时候节点 B 就会损失一定的费用，更有甚者如果节点A是恶意节点，那么节点B的数据可能会被窃取，或者流量费用被篡改。

智能合约没法解决这个恶意节点的问题。

### 将代理软件集成到区块链节点上

上面讨论了如果区块链节点跟代理节点分开的话，会有恶意节点的问题，那么我们可以将代理软件集成到区块链节点上，这样就不会有恶意节点的问题了。如果有人作恶部署了一个恶意节点，区块链的特性会让这个节点没法连上网络。

用 `polkadot-sdk` 来实现这个区块链是最简单的，polkadot节点在连上 p2p 网络的时候，会检测 peer 的版本，如果版本不对就连不上。

## 部署一个 polkadot 本地测试网络

下载官方的教程项目

```bash
git clone git@github.com:paritytech/polkadot-sdk-minimal-template.git

cargo build
```

很久没跑过rust项目了，这个程序在我的 Macbook pro M2 上面大概要7分钟才能编译完，每次修改代码要重新编译，但是幸运的是只要 20s 就能增量编译好。


## 在 client 中加入代理服务器的代码

一般的教程都是不建议自己修改client的，大部分都建议自定义 runtime，所谓的runtime其实跟智能合约没差别，都是编译为wasm后保存到区块链上，使用的时候能够调用这个wasm。在 polkadot 中client做的是链下的事情，比如说连 p2p 网络，收集交易，暴露 telemetry 等等。因为我要给这个节点多加一个代理服务器的功能，所以我选择在client中加入代理服务器的代码。

找到 `node/src/service.rs`

```rust ins={22..31}
if config.offchain_worker.enabled {
    task_manager.spawn_handle().spawn(
        "offchain-workers-runner",
        "offchain-worker",
        sc_offchain::OffchainWorkers::new(sc_offchain::OffchainWorkerOptions {
            runtime_api_provider: client.clone(),
            is_validator: config.role.is_authority(),
            keystore: Some(keystore_container.keystore()),
            offchain_db: backend.offchain_storage(),
            transaction_pool: Some(OffchainTransactionPoolFactory::new(
                transaction_pool.clone(),
            )),
            network_provider: Arc::new(network.clone()),
            enable_http_requests: true,
            custom_extensions: |_| vec![],
        })
        .run(client.clone(), task_manager.spawn_handle())
        .boxed(),
    );
}

task_manager.spawn_handle().spawn("http-proxy", "start http proxy", async {
    new_http_server();
    // 每5s打印一个 hello world
    let mut i = 0;
    loop {
        i += 1;
        futures_timer::Delay::new(std::time::Duration::from_secs(5)).await;
        println!("hello world, i={}", i);
    }
}.boxed());
```

代码加到这里，然后测试运行一下，发现真的每5s都会答应出上面的日志来，说明加的位置是对的。接下来就是要把真实的代理服务器代码加进去。

## 如何实现一个 socks5 代理


