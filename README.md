# 儿童肠套叠超声影像AI辅助诊断平台

面向医院诊疗场景，提供患者管理、超声影像上传、AI 辅助检测、结果展示与报告打印的一站式平台，辅助临床医生诊断儿童肠套叠。

- 源码地址：<https://github.com/usr-com/Intelligent-Intussusception-Detection-Platform.git>
- 技术栈：FastAPI + SQLAlchemy + SQLite + JWT（后端）｜ Vue 3 + Element Plus + Vite（前端）
- 依赖管理：**uv**（Python） + **pnpm**（前端）

## 环境要求

| 项 | 要求 |
|---|---|
| 系统 | Windows 10 / 11（脚本为 .bat；Mac/Linux 请手敲命令） |
| Python | **由 uv 自动管理**（`backend/pyproject.toml` 要求 3.11–3.14，推荐 3.12） |
| uv | **必需**：https://docs.astral.sh/uv/ |
| Node.js | **20 LTS**（pnpm 12 需要 Node ≥18） |
| pnpm | **必需**：`npm install -g pnpm`（或 `corepack enable`） |
| Git LFS | 拉取模型权重需要（`git lfs install` + `git lfs pull`） |
| 磁盘 | 依赖 + 权重约 4 GB |
| 网络 | 首次安装依赖 / 拉取权重需要联网；跑起来后纯本地 |

安装 uv / pnpm：

```powershell
# uv
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
# 或：winget install --id=astral-sh.uv -e

# pnpm（需要 Node.js 已安装）
npm install -g pnpm
```

## 快速开始

### 方式一：双击脚本（推荐）

1. `1-install.bat` —— `uv sync` 安装后端依赖、`pnpm install` 安装前端依赖、生成 `.env`、校验权重
2. `2-install-algorithm.bat` —— 可选，只做算法栈自检（依赖已在第 1 步装好）
3. `3-start.bat` —— 打开两个窗口：后端 :8000、前端 :5173，并自动打开浏览器

登录账号：

- 管理员：`admin / admin123`
- 医生：`doctor / doctor123`

> 前端生产构建：双击 `build.bat`（等价于 `cd frontend && pnpm run build`，产物在 `frontend/dist/`）。

### 方式二：命令行

#### 1. 启动后端（uv）

```bash
cd backend
uv sync                                  # 创建 .venv 并安装全部依赖（含 torch CPU）
uv run uvicorn main:app --host 127.0.0.1 --port 8000 --reload
```

API 文档：<http://127.0.0.1:8000/docs>

> `uv sync` 会同时安装 Web 依赖与算法依赖（torch / torchvision / ultralytics / opencv-python / pydicom 等），
> 其中 torch 已配置为官方 **CPU** 源，不会误装 2.5GB 的 CUDA 版本。

#### 2. 启动前端（pnpm）

```bash
cd frontend
pnpm install
pnpm run dev
```

打开 <http://localhost:5173>（Vite 已把 `/api` 代理到 `http://127.0.0.1:8000`）。

#### 3. 构建前端产物

```bash
cd frontend
pnpm run build        # 产物在 frontend/dist/
pnpm run preview      # 本地预览构建产物
```

#### 4. 运行测试

```bash
# 后端（pytest；httpx 已包含在 uv 的 dev 依赖组）
cd backend
uv run pytest tests -v

# 前端（单元测试 vitest）
cd frontend
pnpm test
```

## 依赖管理（uv / pnpm）

本项目统一使用 **uv 管理 Python 依赖、pnpm 管理前端依赖**，不再手写 pip / npm 的虚拟环境步骤。

### 后端（uv）

| 文件 | 作用 |
|---|---|
| `backend/pyproject.toml` | 依赖声明、dev 依赖组、PyTorch CPU 源配置 |
| `backend/uv.lock` | 锁定全部 Python 依赖版本 |
| `backend/.python-version` | 固定 Python 3.12 |

常用命令（均在 `backend/` 目录下执行）：

```bash
uv sync                 # 安装/同步依赖（含 dev 组）
uv sync --no-dev        # 只装运行时依赖
uv add <pkg>            # 新增运行时依赖并更新 pyproject + uv.lock
uv add --dev <pkg>      # 新增开发依赖
uv lock                 # 仅更新锁文件
uv run <cmd>            # 在项目环境中执行命令，如 uv run python -m algorithm.selftest
```

> `backend/requirements.txt` 与 `backend/algorithm/requirements-algorithm.txt` 是**历史清单**，保留用于参考/兼容；
> 实际安装以 `pyproject.toml` + `uv.lock` 为准。

### 前端（pnpm）

| 文件 | 作用 |
|---|---|
| `frontend/package.json` | 依赖与脚本；`packageManager` 固定 pnpm 版本 |
| `frontend/pnpm-lock.yaml` | 锁定全部前端依赖版本 |
| `frontend/pnpm-workspace.yaml` | 放行 esbuild / core-js / vue-demi 的构建脚本 |

常用命令（均在 `frontend/` 目录下执行）：

```bash
pnpm install            # 安装依赖（CI 用 pnpm install --frozen-lockfile）
pnpm add <pkg>          # 新增依赖
pnpm add -D <pkg>       # 新增开发依赖
pnpm run dev            # 开发服务器
pnpm run build          # 生产构建 → dist/
pnpm test               # vitest
```

## 模型权重（Git LFS）

- 权重位于 `backend/algorithm/weights/`，共 **21 个文件（约 253.5 MB）**。
- 仓库通过 `.gitattributes` 将 `backend/algorithm/weights/**` 纳入 **Git LFS**；克隆后执行：

```bash
git lfs install
git lfs pull
```

- 校验完整性：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify-weights.ps1
```

正常应显示 21 个权重 MD5 全部通过。若提示「LFS 指针」，说明权重没有拉取完整。

## 功能概览

| 模块 | 说明 |
|------|------|
| 登录认证 | 医生 / 管理员分角色登录，JWT 认证 |
| 患者管理 | 录入、搜索、分页、状态与检测次数汇总、导出 CSV |
| 影像上传 | 拖拽/多选批量上传（JPG/PNG/BMP/DICOM），逐张自动检测并显示进度 |
| 去标识裁剪 | 上传时可选择**自动**（YOLO 模型去除患者信息条/参数栏/刻度条）或**手动框选**裁剪；`POST /api/images/{id}/crop` |
| AI 检测 | 分类（阳性/阴性/质量不佳）、置信度、严重度、治疗建议、多分类概率 |
| 检测结果 | 影像 + 诊断分析对照展示，含模型名/版本/推理耗时 |
| 检测历史 | 同一患者多次检测时间线、前后对比、按分类/患者筛选、导出 CSV |
| 报告打印 | 生成带医院抬头的检查报告，可导出 PDF |
| 审计日志 | 记录操作人/时间/对象/来源 IP（仅管理员），支持筛选与导出 |
| 系统统计 | 患者统计、检测统计（阳性/阴性占比、平均置信度） |

## 生产环境配置（安全必需）

平台默认使用「开发占位密钥」，仅用于本地跑通。部署到医院内网前请设置以下环境变量：

| 环境变量 | 说明 | 默认（本地开发） |
|---------|------|----------------|
| `JWT_SECRET_KEY` | JWT 签名密钥，**生产必须设置**且用长度≥32 的随机字符串 | 开发占位密钥（会告警） |
| `ALLOWED_ORIGINS` | 允许跨域的前端源，多个用逗号分隔，**不要用 `*`** | `http://localhost:5173,http://127.0.0.1:5173` |
| `LOCAL_TIMEZONE` | 医院所在时区（用于"今日"统计边界） | `Asia/Shanghai` |
| `DATABASE_URL` | 数据库连接串 | `sqlite:///.../app.db` |
| `UPLOAD_DIR` | 影像存储目录 | 项目根目录下的 `uploads/` |

> 可用 `backend/.env.example` 作为模板，复制为 `.env` 并填上实际值（后端启动时会自动加载 `.env`）。

示例（Windows，临时设置）：

```powershell
$env:JWT_SECRET_KEY = "请换成一段至少32位的随机字符串"
$env:ALLOWED_ORIGINS = "http://your-frontend-host:port"
cd backend
uv run uvicorn main:app --host 0.0.0.0 --port 8000
```

权限说明：普通医生只能编辑/删除**自己录入**的患者与自己上传的影像；管理员可管理全部数据。仅管理员可修改系统设置。

### 审计日志

平台会记录每位医护人员的操作（登录、新增/编辑/删除患者、上传/删除影像、发起检测、修改设置），含时间、操作人、来源 IP、对象和详情。管理员登录后，左侧菜单可进入「审计日志」页查看与搜索、按日期范围筛选、导出 CSV；后端接口为 `GET /api/audit` 与 `GET /api/audit/export`（仅管理员可访问）。

### 数据库迁移（Alembic）

平台已内置 Alembic 用于管理数据库结构变更。新增表/字段时：

```bash
cd backend
uv run alembic revision --autogenerate -m "描述"
uv run alembic upgrade head
```

> 项目启动仍会通过 `create_all` + 幂等补列保证旧库可用，Alembic 供团队在结构演进时使用。

## 项目结构

```
intussusception-platform/
│
├── 1-install.bat / 2-install-algorithm.bat / 3-start.bat
├── build.bat                          前端生产构建（pnpm）
├── _backend.cmd / _frontend.cmd       上面脚本内部调用的启动单元（uv / pnpm）
├── scripts/verify-weights.ps1         权重完整性校验
│
├── backend/                           
│   ├── main.py                        应用入口：启动建表/种子数据、CORS、注册所有路由
│   ├── config.py                      配置：数据库、上传目录、JWT、时区、CORS 白名单
│   ├── database.py                    数据库引擎/会话 + ensure_columns（旧库自动补列）
│   ├── models.py                      数据库表（ORM 模型）
│   ├── schemas.py                     接口的请求/响应结构（Pydantic）
│   ├── auth.py                        JWT 认证 + 权限控制
│   ├── pyproject.toml                 Python 依赖声明（uv）
│   ├── uv.lock                        Python 依赖锁定（uv）
│   ├── .python-version                固定 Python 3.12
│   │
│   ├── routers/                       
│   │   ├── auth.py                    登录 / 当前用户
│   │   ├── patients.py                患者 CRUD、统计、导出
│   │   ├── images.py                  影像上传/获取/删除、同步检测
│   │   ├── detection_tasks.py         异步检测任务（提交 + 轮询）
│   │   ├── results.py                 检测结果、统计、导出
│   │   ├── settings.py                系统设置（仅管理员可改）
│   │   └── audit.py                   审计日志、导出
│   │
│   ├── services/                      
│   │   ├── detection.py               检测编排（调算法 → 校验 → 落库）
│   │   ├── detection_tasks.py         异步任务管理（后台线程 + 状态）
│   │   ├── cropping.py                去标识裁剪服务
│   │   ├── result_images.py           标注图存取
│   │   └── audit.py                   审计埋点
│   │
│   ├── algorithm/                     
│   │   ├── interface.py               算法接口定义（输入/输出契约）
│   │   ├── pipeline.py                适配层：检测 + 分类 + 预后串成唯一入口
│   │   ├── team_model.py              预后模型实现
│   │   ├── model_core.py              OBB 检测策略 / 标定 / 标注图
│   │   ├── auto_crop.py               B 超整帧自动裁剪
│   │   └── weights/                   模型权重（Git LFS，21 个文件）
│   │
│   ├── alembic/                       数据库迁移（改表结构不丢数据）
│   ├── tests/                         后端自动化测试（pytest）
│   ├── tools/                         评测 / 校验工具
│   ├── requirements.txt               （历史清单，保留兼容；实际以 pyproject.toml 为准）
│   └── .env.example                   环境变量模板
│
├── frontend/                          
│   ├── src/
│   │   ├── views/                     页面（一个页面对应一个路由）
│   │   ├── components/                复用组件（布局/上传/影像查看/结果卡/报告）
│   │   ├── api/                       接口封装（统一走 axios 实例）
│   │   ├── router/index.js            路由配置 + 登录/管理员守卫
│   │   ├── stores/                    Pinia 状态（auth 登录态、settings 设置）
│   │   ├── utils/                     工具（时间处理、主题）
│   │   ├── styles/theme.css           双主题设计变量
│   │   ├── main.js                    前端入口
│   │   └── App.vue                    根组件
│   │
│   ├── public/                        静态资源（医院 logo 等）
│   ├── index.html
│   ├── vite.config.js                 构建 / 开发服务器 / 代理配置
│   ├── package.json                   前端依赖与脚本
│   ├── pnpm-lock.yaml                 前端依赖锁定（pnpm）
│   └── pnpm-workspace.yaml            pnpm 构建脚本白名单
│
├── docs/                              
│   ├── 算法接入说明.md                  给算法团队的对接文档
│   ├── 平台介绍与使用说明.html           平台介绍页（platform-intro.html）
│   └── screenshots/                   介绍页用的界面截图
│
├── README.md
├── .gitignore
└── .gitattributes                     ← 权重走 Git LFS
```

### 架构分层（后端）

```
routers/   接口层  ── 只做"收请求、返回响应、鉴权"，不写业务逻辑
    ↓
services/  业务层  ── 真正的业务编排（检测流程、任务调度、审计埋点）
    ↓
algorithm/ 算法层  ── 只负责"看图 → 给结果"，可被算法团队整体替换
```

职责分离、层与层解耦：算法层可独立开发与替换，接口层不含业务逻辑，便于分工与维护。

## 常见问题

**`uv sync` 很慢或失败？**
首次需要下载依赖（torch 约 100–200MB）。网络受限时可配置代理/镜像后重试；`uv.lock` 已锁定版本，重试会复用缓存。

**`pnpm install` 报 `ERR_PNPM_IGNORED_BUILDS`？**
`frontend/pnpm-workspace.yaml` 已显式放行 `esbuild` / `core-js` / `vue-demi`。若仍出现，在 `frontend/` 下执行
`pnpm approve-builds` 选择这三个包。

**Node 版本过低（`??=` 语法错误 / esbuild 启动失败）？**
Vite 5 需要 Node ≥18，建议 Node 20 LTS。

**第一次点「检测」卡了 1 分多钟？**
正常：检测与预后模型首次加载约 60–90 秒（服务启动后会在后台预热）。之后单张推理在秒级。

**权重文件缺失 / 很小（Git LFS 指针）？**
在仓库根目录执行 `git lfs install && git lfs pull`，然后运行 `scripts\verify-weights.ps1` 校验。

**换机器后如何重建环境？**
`cd backend && uv sync`、`cd frontend && pnpm install` 即可（锁文件已提交）；数据库与 `uploads/` 需单独备份迁移。
