# gmall 电商离线数仓项目


## 项目概述

本项目构建了一个完整的电商离线数据仓库，涵盖用户行为日志和业务数据的全量/增量采集、HDFS 数据同步、Hive 数仓分层建模（ODS → DIM/DWD → DWS → ADS）、DolphinScheduler 工作流调度及 Superset 可视化展示。

### 数据流概览

```
用户行为: jar模拟 → Flume采集(hd:102) → Kafka(topic_log) → Flume消费(hd:104) → HDFS
业务数据: MySQL(gmall) ─┬─ Maxwell(binlog) → Kafka(topic_db) → Flume消费(hd:104) → HDFS
                        └─ DataX(全量) → HDFS
                                       ↓
                              Hive 数仓分层
                              ODS → DIM/DWD → DWS → ADS
                                       ↓
                              DolphinScheduler 定时调度
                                       ↓
                              MySQL 报表 → Superset 可视化
```

## 技术栈

| 组件 | 版本 | 说明 |
|------|------|------|
| Hadoop | 3.x | HDFS + YARN 集群，3节点 |
| Hive | 3.1.3 | 数据仓库，引擎可切换 Spark |
| Spark | 3.3.1 | Hive on Spark 计算引擎 |
| Kafka | 2.x | 消息队列，topic_log + topic_db |
| Flume | 1.10.1 | 日志采集 + 数据同步通道 |
| Maxwell | 1.x | MySQL binlog 实时采集 |
| DataX | 3.x | MySQL → HDFS 全量同步 |
| DolphinScheduler | 2.0.5 | DAG 工作流调度 |
| Superset | 最新 | 数据可视化 |
| Zookeeper | 3.4.6+ | 分布式协调服务 |

## 集群规划

| 主机 | hadoop102 | hadoop103 | hadoop104 |
|------|-----------|-----------|-----------|
| HDFS | NameNode, DataNode | DataNode | SecondaryNameNode, DataNode |
| YARN | NodeManager | ResourceManager, NodeManager | NodeManager |
| Zookeeper | ✓ | ✓ | ✓ |
| Kafka | ✓ | ✓ | ✓ |
| Flume(日志采集) | ✓ | | |
| Flume(消费) | | | ✓ |
| Maxwell | ✓ | | |
| Hive/Spark | ✓ | | |
| DataX | ✓ | | |
| DolphinScheduler | Master,Worker,API,Alert | Worker | Worker |
| Superset | ✓ | | |

## 数仓分层

| 层次 | 名称 | 表数 | 说明 |
|------|------|------|------|
| **ODS** | 原始数据层 | 31张 | 全量(17) + 增量(13) + 日志(1)，gzip压缩 |
| **DIM** | 维度层 | 9张 | 商品/用户/地区/日期/活动/优惠券等维度，orc+snappy |
| **DWD** | 明细层 | 10张 | 事务事实表/周期快照/累积快照，orc+snappy |
| **DWS** | 汇总层 | 13张 | 按数据域-粒度-业务过程-周期聚合，orc+snappy |
| **ADS** | 应用层 | 16张 | 最终报表指标，导出至 MySQL |

### 数据域划分

| 数据域 | 业务过程 | 事实表 |
|--------|----------|--------|
| 交易域 | 加购、下单、支付、退款、确认收货 | dwd_trade_cart_add_inc / dwd_trade_order_detail_inc / dwd_trade_pay_detail_suc_inc / dwd_trade_cart_full / dwd_trade_trade_flow_acc |
| 流量域 | 页面浏览、页面跳转 | dwd_traffic_page_view_inc |
| 用户域 | 注册、登录 | dwd_user_register_inc / dwd_user_login_inc |
| 互动域 | 收藏 | dwd_interaction_favor_add_inc |
| 工具域 | 优惠券使用 | dwd_tool_coupon_used_inc |

## 目录结构

```
gmall-offline-warehouse/
├── scripts/                  # ETL Shell 脚本（14个核心脚本）
│   ├── ods/                  # ODS层数据装载
│   ├── dim/                  # 维度表装载
│   ├── dwd/                  # DWD层数据装载
│   ├── dws/                  # DWS层汇总计算
│   ├── ads/                  # ADS层报表计算
│   ├── mysql/                # MySQL同步/导出
│   └── bin/                  # 集群辅助脚本
├── conf/                     # 配置文件
│   ├── flume/                # Flume 采集/消费配置
│   ├── datax/                # DataX 同步配置（17张全量表）
│   ├── hive-site.xml         # Hive Metastore 配置
│   ├── spark-defaults.conf   # Spark 运行参数
│   └── maxwell.properties    # Maxwell 采集配置
├── sql/                      # Hive 建表语句
│   ├── ods/                  # 31张ODS表
│   ├── dim/                  # 9张维度表
│   ├── dwd/                  # 10张DWD事实表
│   ├── dws/                  # 13张DWS汇总表
│   └── ads/                  # 16张ADS报表表
├── dolphinscheduler/         # DolphinScheduler 部署配置
├── README.md
└── .gitignore
```

## 快速部署

### 前置要求

- CentOS 7 三节点集群（hadoop102/103/104）
- JDK 1.8.0_212
- MySQL 5.7+

### 部署步骤

1. **环境准备**
   - 配置 SSH 免密登录、集群分发脚本 xsync/xcall
   - 安装 JDK，配置环境变量

2. **基础组件安装**
   - Hadoop 3.x 集群（HDFS + YARN）
   - Zookeeper 集群
   - Kafka 集群

3. **数据采集通道**
   - 部署 Flume 日志采集（hadoop102）
   - 部署 Maxwell binlog 采集
   - 部署 DataX 全量同步
   - 部署 Flume 消费通道（hadoop104）

4. **数据仓库建设**
   - 部署 Hive 3.1.3，配置 Spark 引擎
   - 执行 sql/ 目录下各层建表语句
   - 运行 scripts/ 下 ETL 脚本完成数据装载

5. **任务调度**
   - 部署 DolphinScheduler 2.0.5
   - 配置工作流，定时调度 ETL 脚本

6. **可视化**
   - 部署 Superset
   - ADS 结果导出至 MySQL，配置 Dashboard


## License

MIT
