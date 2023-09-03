


# 资料


[hashicorp raft 源码](https://github.com/hashicorp/raft)
[hashicorp github](https://github.com/hashicorp)

[raft 论文](https://raft.github.io/raft.pdf)
[raft 网站](https://raft.github.io/)
[raft-grpc-example](https://github.com/Jille/raft-grpc-example)
[stcache: a raft example](https://cloud.tencent.com/developer/article/1183490)
[stcache source](https://github.com/KunTjz/stcache)



[What are your thoughts on the Go programming language?](https://news.ycombinator.com/item?id=24887521)
[hashicorp 知乎](https://www.zhihu.com/people/hashicorpchina)






# raft 的实现


## data structure


```go
type raftState struct {
    currentTerm       uint64
    commitIndex       uint64
    lastApplied       uint64
    lastLock          sync.Mutex
    lastSnapshotIndex uint64
    lastSnapshotTerm  uint64
    lastLogIndex      uint64
    lastLogTerm       uint64
    routinesGroup     sync.WaitGroup
    state             RaftState
}
```



```go
type Raft struct {
    raftState
    protocolVersion                 ProtocolVersion
    applyCh                         chan *logFuture
    conf                            atomic.Value
    confReloadMu                    sync.Mutex
    fsm                             FSM
    fsmMutateCh                     chan interface{}
    fsmSnapshotCh                   chan *reqSnapshotFuture
    lastContact                     time.Time
    lastContactLock                 sync.RWMutex
    leaderAddr                      ServerAddress
    leaderID                        ServerID
    leaderLock                      sync.RWMutex
    leaderCh                        chan bool
    leaderState                     leaderState
    candidateFromLeadershipTransfer bool
    localID                         ServerID
    localAddr                       ServerAddress
    logger                          Logger
    logs                            LogStore
    configurationChangeCh           chan *configurationChangeFuture
    configurations                  configurations
    latestConfiguration             atomic.Value
    rpcCh                           <-chan RPC
    shutdown                        bool
    shutdownCh                      chan struct{}
    shutdownLock                    sync.Mutex
    snapshots                       SnapshotStore
    userSnapshotCh                  chan *userSnapshotFuture
    userRestoreCh                   chan *userRestoreFuture
    stable                          StableStore
    trans                           Transport
    verifyCh                        chan *verifyFuture
    configurationsCh                chan *configurationsFuture
    bootstrapCh                     chan *bootstrapFuture
    observersLock                   sync.RWMutex
    observers                       map[uint64]*Observer
    leadershipTransferCh            chan *leadershipTransferFuture
    leaderNotifyCh                  chan struct{}
    followerNotifyCh                chan struct{}
    mainThreadSaturation            *saturationMetric
}
```


```go
type leaderState struct {
    leadershipTransferInProgress int32
    commitCh                     chan struct{}
    commitment                   *commitment
    inflight                     *list.List
    replState                    map[ServerID]*followerReplication
    notify                       map[*verifyFuture]struct{}
    stepDown                     chan struct{}
}
```




## main goroutine



main goroutine: handles leadership and RPC requests
- runFollower
- runCandidate
- runLeader



###  runFollower


```go
type configurations struct {
    committed      Configuration
    committedIndex uint64
    latest         Configuration
    latestIndex    uint64
}
```




Follower 关注的主要channel
- r.shutdownCh: shutdown raft节点后退出
- r.rpcCh: 处理rpc请求
- r.configurationsCh: 获取configurations
- heartbeatTimer: randomTimeout timer by HeartbeatTimeout 
	- 通过raft.lastContact判断是否超时，未超时则继续follower的循环
	- 判断configurations状况
		- r.configurations.latestIndex == 0:  继续follower的循环
		- r.configurations.latestIndex == r.configurations.committedIndex && !hasVote(r.configurations.latest, r.localID): 继续follower的循环
		- hasVote: 转换为Candidate角色，退出follower循环
		- !hasVote: 继续follower的循环
- r.bootstrapCh: attempt an initial bootstrap
	- usage
		- Called on an un-bootstrapped Raft instance after it has been created.
		- Should only be called at the beginning of time for the cluster with an identical configuration listing all Voter servers.
	- 原理: BootstrapCluster()
		- Make sure the cluster is in a clean state
			- no logs
			- no snapshots
			- no stable CurrentTerm
		- store log entry: Index: 1, Term: 1, Data: configuration
		- stable CurrentTerm : 1
		- lastLogIndex: 1, lastLogTerm: 1
		- fill configurations fields by the log entry
	- 初始化时: bootstrapCh未触发时，heartbeatTimer会继续follower循环
		- 原因是: bootstrapCh未触发时，configuration.Servers中，本节点的hasVote是false
- Follower的总结
	- follower是每个server启动时的状态
	- heartbeatTimer
		- 未超时: 继续follower循环
		- 超时: 当r.configurations.latestIndex > 0 && hasVote 满足，server从Follower转换为Candidate
	- 通过r.rpcCh处理rpc请求
	- bootstrapCh
		- 非main goroutine, 通过 BootstrapCluster ，发送configuration.Servers 给 r.bootstrapCh
		- follower 处理 r.bootstrapCh，完成server节点configuration的改变





## runCandidate

Candidate 的处理流程
- r.rpcCh
	- Candidate可以处理vote request
- voteCh
	- 通过 electSelf 进行投票， voteCh的来源
	- 通过 voteCh 获得投票结果
		- 当 vote.Term > r.getCurrentTerm()时，本server节点放弃选举，转换为Follower
		- 当满足voters/2 + 1个投票结果时，本server节点被选举为Leader节点


## runLeader



Leader 的处理流程
- setupLeaderState
	- leaderState: commitCh commitment inflight replState notify stepDown
- Cleanup state on step down: 通过defer埋点回收逻辑
- startStopReplication
	- start asynchronous replication to new peers
		- 开启 r.replicate goroutine
	- stop replication to removed peers
