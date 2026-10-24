# M2 架构设计、环境搭建与代码入仓

日期：2026-10-24。执行依据为《软件工程-敏捷DevOps开发方法》大作业 V1.1 的 **1.2 大作业要求**、**1.4 评分标准**（代码托管 / 开发提交项）与代码托管相关章节，以及《个人博客大作业-M1-kickoff》的里程碑表、《软件工程大作业-个人博客开发手册》的「阶段划分」与「各阶段操作」。本文将 M2 落实为本轮的边界、交接与验证顺序，不新增需求，也不替代 CodeArts 平台上的真实状态与 M1 的完成记录。

## 1 当前起点与本轮结果

M1 已完成：需求文档（12 条用户故事）、CodeArts「规划 / 工作项 / 迭代」三环节、5 张截图归档，M1 判定完成。M2 未完成：本地环境（JDK8 / Maven / MySQL / Redis）未验证、`dblog` 数据库未建、代码尚未进入 CodeArts 代码托管。

本轮 M2 只完成三件事：① 本地环境跑通（前台 8443、后台 8085 可访问且可登录）；② 数据库 `dblog` 建库并导入初始数据（22 张表）；③ 代码进入 CodeArts 代码托管。M2 的出口是「本地可运行 + 数据就绪 + 代码入仓且有平台证据」，**不表示博客功能已改造、也不表示已部署上线**（功能改造属 M3/M4，部署属 M6）。

排期：W2，2026-11-02 ~ 11-08。里程碑定位如下，M2 是承上启下的一环：

| 里程碑 | 周次 / 日期 | 主题 | 对应评分 |
|---|---|---|---|
| M1 | W1 10-26~11-01 | 需求分析与项目规划 | 15% ✅ |
| **M2** | **W2 11-02~11-08** | **架构设计与环境搭建、代码入仓库** | **报告素材 + 开发提交前置** |
| M3 | W3 11-09~11-15 | 迭代1：登录/文章/评论 + 代码检查 | 开发提交 5% + 代码检查 5% |

日期为排期建议，不替代依赖与实际验证结果。本地环境未跑通前，不得据本文声称 M2 已完成。

## 2 两人任务与文件边界

下表是 M2 的分工建议，用于交接，不代表吴凯阳已接受任务。R 为建议实施者，A 为最终验收 / 集成负责人，C 为应协作核验的人；尚未实际指派的 A 写「待团队指定」，不自动认领。本地环境与 CodeArts 仓库由一名实际指定成员串行维护，避免多人同时改动同一环境或同一仓库配置。

| 子任务 | 建议 R / A / C | 依赖与具体交付 | 文件边界与验收归属 |
|---|---|---|---|
| M2.1 环境准备 | R：秦庆泽；A：待团队指定；C：吴凯阳 | 确认 JDK8 / Maven / MySQL / Redis 安装与版本；配置 Maven 阿里云镜像 | 本地环境；版本与路径记录进 `evidence/M2/` |
| M2.2 数据库建库 | R：秦庆泽；A：待团队指定；C：吴凯阳 | 导入 `dblog.sql` + `init_data.sql`，建 22 张表并写入初始数据 | MySQL 平台；`show tables` 截图归档 |
| M2.3 本地启动验证 | R：秦庆泽；A：待团队指定；C：吴凯阳 | `mvn clean package` 编译；启动 blog-web(8443) / blog-admin(8085)；root 登录 | 本地运行环境；截图归档 |
| M2.4 架构与数据库设计文档 | R：吴凯阳；A：待团队指定；C：秦庆泽 | 产出架构说明（多模块结构、22 张表说明、技术栈、部署拓扑） | `docs/architecture.md` 由吴凯阳维护，秦庆泽只评审 |
| M2.5 代码入 CodeArts | R：秦庆泽；A：待团队指定；C：吴凯阳 | CodeArts 代码托管导入 GitHub 仓库（或本地 `git push`） | CodeArts 平台；仓库首页截图归档 |
| M2.6 证据留痕与记录 | R：两人；A：秦庆泽；C：两人 | 5 张截图归档 `evidence/M2/`；阶段进度按事实同步 | `docs/evidence/M2/`；两人共同保证可追溯 |

**文件边界与敏感信息约定**：

- 数据库密码等敏感配置**不写入** `application-center.yml` 提交，改用环境变量 `ONEBLOG_DATASOURCE_PASSWORD` 覆盖；`application-center.yml` 的本地改动不提交。
- `.workbuddy/`、`output/` 已在 `.gitignore` 忽略，工具内部产物不进仓库。
- CodeArts 仓库与 GitHub 仓库保持同步，后续以 CodeArts 为主托管（用于评分留痕）；导入方式在实施前核对 CodeArts 当前界面，不把本文的菜单名写成已存在。

## 3 开始实现前的接口检查单

### 3.1 软件版本基线

- JDK **必须 1.8**（SpringBoot 2.3.5 对 11+ 兼容性差）；Maven 3.3+；MySQL 5.6+；Redis 可用。
- 三项版本确认（`java -version` / `mvn -v` / `mysql --version`）结果记录进 `evidence/M2/`，作为报告素材。
- 若版本不符，先修正再用，不允许在 JDK 版本不符的情况下宣称编译通过。

### 3.2 数据库契约

- 库名 `dblog`，字符集 `utf8mb4`，共 **22 张表**。
- 建表脚本：`docs/docker/mysql/dblog.sql`（自带 `CREATE DATABASE dblog` 与 `use dblog`）；初始数据：`docs/docker/mysql/init_data.sql`。
- **`docs/db/*.sql` 是占位文件**（内容只指向 docker/mysql），禁止误用。
- 验证：`use dblog; show tables;` 应返回 22 张表。

### 3.3 配置契约

- 配置文件：`blog-core/src/main/resources/config/application-center.yml`。
- 数据库默认 `127.0.0.1:3306/dblog`、`root/root`；Redis `127.0.0.1:6379`、database=1、密码空。
- 本地密码与默认不一致时，用环境变量 `ONEBLOG_DATASOURCE_PASSWORD` 覆盖，**不改文件、不提交密码**。

### 3.4 启动与访问契约

- 前台 `blog-web` 端口 **8443**，后台 `blog-admin` 端口 **8085**，启动类 `BlogWebApplication`。
- 后台账号：超级管理员 `root/123456`、普通管理员 `admin/123456`、评论审核 `comment-admin/123456`。
- 启动链路：`mvn clean package -Dmaven.test.skip=true` → `java -jar blog-web/target/blog-web.jar`。
- 端口冲突时先排查占用进程，不擅自改端口掩盖问题。

### 3.5 代码仓库契约

- CodeArts 项目「DBlog」→ 代码 → 代码托管，来源为 `https://github.com/qinlove-hub/DBlog.git`（main 分支）。
- 导入后须确认：仓库内可见全部模块、提交历史、README 与 `软工大作业/` 目录。
- 后续提交遵循 `CONTRIBUTING.md` 的分支与提交规范。

## 4 交给成员的可复制提示词

> 说明：以下两段提示词用于交接，先核对实际分工，不把任务表当作另一方已接受。第一段设计为**可全程托管**——把它整段发给 AI，AI 即可按步骤执行 M2 的环境搭建、建库、启动与代码入仓，并在每步留证据。

### 给秦庆泽：环境搭建、建库、启动与代码入仓（全程托管）

```text
你是我在「个人博客大作业」M2 阶段的执行助手，请按以下边界与顺序，全程帮我完成本地环境搭建、数据库建库、项目启动与代码入仓。项目源码在 C:/Users/qinqingze/Desktop/DBlog（OneBlog/DBlog，SpringBoot 2.3.5 + JDK8 + MySQL + Redis + Shiro + Freemarker，Maven 多模块）。先读 软工大作业/docs/M1-完成记录与验收清单.md 与 软工大作业/docs/M2-环境搭建保姆级清单.md 了解上下文，再开始。

执行边界：只在本地环境与本机操作，不改动与 M2 无关的源码；不把数据库密码等敏感信息写入 application-center.yml；不 reset/clean/stash 现有未提交改动（blog-core/.../application-center.yml、blog-web/pom.xml 是本地改动，需保留）；每完成一步先自检结果，再进入下一步；任何命令报错，保留完整报错原文再判断，不猜测、不跳过。

按以下顺序执行并逐步验证：
1) 环境确认：java -version 必须 1.8；mvn -v；mysql --version；redis-cli ping 返回 PONG。任一不符先修，并在 软工大作业/evidence/M2/ 记录版本。
2) 建库：在项目根执行 mysql -u root -p < docs/docker/mysql/dblog.sql，再执行 mysql -u root -p < docs/docker/mysql/init_data.sql（注意用 docs/docker/mysql 下的脚本，不要用 docs/db 的占位文件）；执行 mysql -u root -p -e "use dblog; show tables;" 确认 22 张表。
3) 配置核对：检查 blog-core/src/main/resources/config/application-center.yml 的数据库与 Redis 地址；若本地密码不是 root，用环境变量 ONEBLOG_DATASOURCE_PASSWORD 覆盖，不改文件。
4) 编译：mvn clean package -Dmaven.test.skip=true，确认 BUILD SUCCESS（首次构建慢时建议先配 Maven 阿里云镜像）。
5) 启动：java -jar blog-web/target/blog-web.jar，等待 Started BlogWebApplication；访问 http://127.0.0.1:8443 确认能看到文章首页；另起 blog-admin 或按其端口 8085 访问后台，用 root/123456 登录确认成功。
6) 代码入仓：进入华为云 CodeArts 项目「DBlog」→ 代码 → 代码托管 → 新建仓库 → 导入仓库，来源填 https://github.com/qinlove-hub/DBlog.git；若导入失败，改为本地 git remote add codearts <CodeArts仓库地址> 后 git push codearts main，但不要覆盖或强推。
7) 留证：按 M2 清单第 8 节，把 编译成功、前台首页、后台登录、数据库22表、CodeArts仓库 五张截图存入 软工大作业/evidence/M2/，命名 M2-01~M2-05。

每步完成后向我报告：实际执行的命令、真实结果（成功/失败原文）、截图位置、以及是否还有未满足项。不要预填“已通过”，不要编造不存在的菜单或命令。全部完成后输出一份 M2 完成情况小结，标注哪些条件已满足、哪些仍未验证。
```

### 给吴凯阳：架构与数据库设计文档、证据整理

```text
请为「个人博客大作业」M2 阶段撰写架构与数据库设计文档，本提示用于交接，先核对实际分工（架构文档归你，环境搭建与平台配置归秦庆泽），不把任务表当作秦庆泽已接受。先读 软工大作业/docs/requirements.md、软工大作业/docs/M1-完成记录与验收清单.md、软工大作业/docs/M2-环境搭建保姆级清单.md，以及项目根目录的 pom.xml 与各模块源码结构。

本轮范围是 M2.4：产出 软工大作业/docs/architecture.md，至少包含：① 系统总体架构（前后台分离方式、Maven 多模块 blog-core/admin/web/file/codegen 各自职责）；② 技术选型说明（SpringBoot 2.3.5、JDK8、MySQL、Redis、Shiro、Freemarker、Bootstrap3 及版本约束）；③ 数据库设计（22 张表分类说明：biz_article 等业务表、sys_user/role/resources 等权限表、sys_config 配置表，列出关键表字段与关系）；④ 部署拓扑（本地运行 8443/8085 与后续 ECS 部署的关系）；⑤ 与需求文档 12 条用户故事的对应关系。

边界：本轮只写架构与数据库设计文档，不改代码、不建库、不部署、不操作 CodeArts。输出 Markdown，先给章节大纲让秦庆泽确认，再逐节展开；数据库表说明以 docs/docker/mysql/dblog.sql 的真实建表语句为准，不臆造字段。写完后自查：22 张表是否覆盖、模块职责是否清晰、是否与技术栈版本一致。文档存为 软工大作业/docs/architecture.md。
```

## 5 验证层次、证据与退出

| 层次 | 本阶段应验证 | 证据与状态边界 |
|---|---|---|
| 1 编译与构建核验 | Maven 依赖解析、模块编译、打包产物 | `mvn clean package` 的 BUILD SUCCESS 输出与产物路径；编译通过不等于运行通过 |
| 2 运行时核验 | 前台 8443 可访问并有文章、后台 8085 可登录 | 真实浏览器截图；仅启动日志不算 |
| 3 数据与仓库核验 | `dblog` 22 表与初始数据、CodeArts 仓库含完整代码 | `show tables` 截图、CodeArts 仓库首页截图；本地仓库存在不等于 CodeArts 已导入 |
| 4 证据留痕 | 5 张截图归档、命名规范、可追溯 | 截图存 `evidence/M2/`，与报告引用一致 |

每次记录：实际负责人、修改文件 / 平台操作、对应评分项、日期、截图位置、失败原因与限制。不预填验收通过，不编造尚不存在的菜单或命令。

M2 整阶段退出需同时满足：

1. `mvn clean package` 编译通过（BUILD SUCCESS），产物可运行。
2. 前台 `http://127.0.0.1:8443` 可访问并显示文章首页。
3. 后台 `http://127.0.0.1:8085` 可用 `root/123456` 登录成功。
4. `dblog` 数据库有 22 张表且已导入初始数据。
5. CodeArts 代码托管中可见完整代码（导入成功或本地 push 成功）。
6. 5 张截图归档到 `evidence/M2/`，阶段进度记录按事实同步。

本轮「环境搭建完成」的判据是：本地运行、数据库、代码入仓三项均有真实结果与截图，可供交接且已自核验；在上述退出条件全部满足前，M2 状态保持「进行中」或「待验证」，不进入 M3。
