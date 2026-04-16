# idle-erp 增强TDD工作流设计方案

## TL;DR

> **目标**: 扩展标准TDD流程，在每次改动时自动识别并运行可能受影响的已有测试，防止破坏现有逻辑
>
> **实现方式**: Git hooks自动触发 + 编译依赖分析识别相关测试
>
> **预期效果**: 每次commit/push前自动验证不破坏已有测试

---

## 背景问题

标准TDD流程 (Red-Green-Refactor):
```
1. 写新功能测试 (RED)
2. 写实现让测试通过 (GREEN)
3. 重构
```

**问题**: 只验证新功能，没有验证是否破坏已有逻辑

---

## 工作流设计

### 整体流程

```
┌─────────────────────────────────────────────────────────────┐
│  开发者: git commit / git push                              │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  1. 改动影响分析                                        │
│     - 识别改动涉及的文件 (git diff)                          │
│     - 编译依赖分析 → 确定相关测试                           │
│     - 生成"受影响测试列表"                               │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  2. 运行受影响测试 (Safety Net)                           │
│     - 如果无受影响测试 → 直接通过                            │
│     - 如果有受影响测试 → 运行并验证                            │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────┴──────────┐
        ▼                    ▼
┌──────────────┐      ┌──────────────┐
  测试失败     │      测试通过    │
    STOP      │        │          ▼
  分析原因     │  ┌──────────────┐  ┌──────────────┐
  修复后再试   │  │ git commit │  │ git push   │
└──────────────┘  │  成功     │  │  成功     │
                   └──────────────┘  └──────────────┘
```

### 核心组件

#### 组件1: 改动影响分析器 (ImpactAnalyzer)

**输入**: 改动的源文件列表
**输出**: 可能受影响的Test文件列表

**分析策略**: 编译依赖分析

```
改动文件: src/main/java/.../CameraMonitorCmdService.java
    │
    ├─→ 分析import语句
    │   import com.qudian.idle.erp.domain.wms.aggregate.monitor.CameraMonitor;
    │   import com.qudian.idle.erp.domain.wms.repository.CameraMonitorRepository;
    │
    ├��→ 查找这些类被哪些测试引用
    │   CameraMonitorRepository → CameraMonitorCmdServiceTest (mock)
    │
    └─→ 生成受影响测试列表
        - CameraMonitorCmdServiceTest
```

#### 组件2: Git Hooks集成

**pre-commit hook** (推荐):
- 在每次commit前运行受影响测试
- 更频繁的安全检查
- 快速反馈

**pre-push hook**:
- 在push到远程前运行
- 更全面的检查
- 适合CI集成

#### 组件3: 测试运行器 (TDDTestRunner)

- 解析Maven测试结果
- 生成可读报告
- 判断是否阻止操作

---

## 实现方案

### Step 1: 创建影响分析脚本

文件: `.githooks/tdd-impact-analyzer.sh`

```bash
#!/bin/bash
# 用途: 分析改动文件，找到可能受影响的测试
# 输入: 改动的源文件列表
# 输出: 受影响的Test文件列表

# 分析策略1: 包路径匹配
# 同包名下的Test文件

# 分析策略2: import依赖分析
# 分析改动文件的import，查找被mock的类对应的测试

# 分析策略3: 编译依赖树
# 使用dependency:tree分析模块依赖
```

### Step 2: 创建测试运行脚本

文件: `.githooks/tdd-test-runner.sh`

```bash
#!/bin/bash
# 用途: 运行指定的测试并报告结果
# 输入: Test文件列表 (逗号分隔)
# 输出: 测试结果报告

# 调用Maven运行测试
# 解析结果
# 判断是否失败
```

### Step 3: 安装Git Hook

文件: `.githooks/pre-commit`

```bash
#!/bin/bash
# TDD Pre-Commit Hook
# 在commit前自动运行受影响测试

# 1. 获取改动的文件
changed_files=$(git diff --name-only --cached --diff-filter=ACM)

# 2. 分析受影响测试
impacted_tests=$(.githooks/tdd-impact-analyzer.sh "$changed_files")

# 3. 运行测试
.githooks/tdd-test-runner.sh "$impacted_tests"

# 4. 根据结果决定是否允许commit
if [ $? -ne 0 ]; then
    echo "❌ 测试失败，请修复后再commit"
    exit 1
fi

echo "✅ 所有测试通过"
exit 0
```

### Step 4: 配置Git使用本地hooks

```bash
# 方案A: 设置core.hooksPath
git config core.hooksPath .githooks

# 方案B: 创建symlink
# ln -s ../../.githooks/pre-commit .git/hooks/pre-commit
```

---

## 验收标准

- [ ] 改动文件后，执行commit操作时自动触发测试
- [ ] 测试失败时，commit被阻止
- [ ] 测试通过时，commit正常完成
- [ ] 报告清晰地显示哪些测试被运行、结果如何

---

## 可选增强

### 增强1: 增量测试运行

使用Maven的增量编译和测试运行:
```bash
# 只编译改动的模块
mvn compile -pl <module>

# 只运行相关测试
mvn test -Dtest="**/RelatedTest.java"
```

### 增强2: 测试缓存

- 记录上次测试结果
- 只运行"可能受影响"的测试
- 跳过确定不受影响的测试

### 增强3: 并行运行

```bash
# Maven平行测试
mvn test -T 4
```

### 增强4: 测试覆盖集成

如果需要更精确的分析，可以集成:
- JaCoCo: 代码覆盖分析
- PIT: 突变测试

---

---

## 实施计划 (TODOs)

### Wave 1: 创建 .githooks 目录和核心脚本

- [ ] 1. 创建目录 `.githooks/`
- [ ] 2. 创建 `tdd-impact-analyzer.sh` - 改动影响分析脚本
- [ ] 3. 创建 `tdd-test-runner.sh` - 测试运行脚本

### Wave 2: Git Hooks集成

- [ ] 4. 创建 `pre-commit` hook
- [ ] 5. 配置Git使用 `core.hooksPath`

### Wave 3: 测试验证

- [ ] 6. 本地测试验证工作流
- [ ] 7. 迭代修复问题

---

## 实际执行命令

执行以下命令开始实施:

```bash
# 使用Sisyphus执行计划
/start-work enhanced-tdd-workflow
```

---

## 文件清单

| 文件 | 用途 |
|------|------|
| `.githooks/tdd-impact-analyzer.sh` | 改动影响分析器 |
| `.githooks/tdd-test-runner.sh` | 测试运行器 |
| `.githooks/pre-commit` | Git commit hook |
| `.githooks/pre-push` | Git push hook (可选) |
| `.githooks/tdd.conf` | 配置文件 |

---

## 具体实现代码

### tdd-impact-analyzer.sh (初版)

```bash
#!/bin/bash
# tdd-impact-analyzer.sh
# 用途: 分析改动文件，找到可能受影响的测试
# 输入: 改动文件列表 (newline分隔)
# 输出: 受影响的Test类名 (逗号分隔)

set -e

# 临时文件
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 解析输入
CHANGED_FILES="$1"
if [ -z "$CHANGED_FILES" ]; then
    # 从stdin读取
    CHANGED_FILES=$(cat)
fi

# 分析策略: 包路径匹配
# 将 main/java 路径转换为 test/java 路径
# 并查找对应的Test文件

IMPACTED_TESTS=""

while read -r file; do
    # 跳过非Java源文件
    if [[ ! "$file" =~ \.java$ ]]; then
        continue
    fi
    
    # 跳过测试文件本身 (避免循环)
    if [[ "$file" =~ /src/test/ ]]; then
        continue
    fi
    
    # 提取包路径
    # src/main/java/com/qudian/idle/erp/web/service/wms/...
    # → com.qudian.idle.erp.web.service.wms
    
    # 转换为测试路径
    # src/test/java/com/qudian/idle/erp/web/service/wms/...Test.java
    
    # 简单策略: 同目录下的*Test.java
    DIR=$(dirname "$file")
    BASE=$(basename "$file" .java)
    
    # 查找同目录下的Test文件
    TEST_DIR=$(echo "$DIR" | sed 's|/src/main/|/src/test/|')
    
    if [ -d "$TEST_DIR" ]; then
        TESTS=$(find "$TEST_DIR" -name "${BASE}Test.java" -o -name "*Test.java" 2>/dev/null || true)
        for test in $TESTS; do
            test_name=$(basename "$test" .java)
            if [ -n "$test_name" ]; then
                if [ -z "$IMPACTED_TESTS" ]; then
                    IMPACTED_TESTS="$test_name"
                else
                    IMPACTED_TESTS="$IMPACTED_TESTS,$test_name"
                fi
            fi
        done
    fi
done <<< "$CHANGED_FILES"

# 去重
IMPACTED_TESTS=$(echo "$IMPACTED_TESTS" | tr ',' '\n' | sort -u | tr '\n' ',' | sed 's/,$//')

echo "$IMPACTED_TESTS"
```

### tdd-test-runner.sh (初版)

```bash
#!/bin/bash
# tdd-test-runner.sh
# 用途: 运行指定的测试并报告结果
# 输入: Test类名列表 (逗号分隔)
# 输出: 测试结果

set -e

TESTS="$1"
MODULE="idle-erp-web"  # 默认模块，可配置

if [ -z "$TESTS" ]; then
    echo "No tests to run"
    exit 0
fi

echo "🧪 Running impacted tests: $TESTS"

# 运行测试
mvn test -pl "$MODULE" -Dtest="$TESTS" -q 2>&1 | tee "$TEMP_DIR/test-output.log"

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -ne 0 ]; then
    echo "❌ Tests FAILED"
    exit 1
fi

echo "✅ All tests passed"
exit 0
```

---

## 技术细节

### 依赖分析方案

方案1: 使用AST解析 (推荐)
```java
// 解析改动文件的import语句
// 查找这些类被哪些测试使用
// 返回测试文件列表
```

方案2: 使用Maven
```bash
mvn dependency:tree -Dincludes=... 
```

方案3: 简单匹配
```bash
# 包路径匹配
# src/main/java/com/qudian/.../service/...
# → src/test/java/com/qudian/.../service/...
```

### 测试运行方案

```bash
# 单��块测试
mvn test -pl idle-erp-web -Dtest="CameraMonitorCmdServiceTest"

# 多个测试
mvn test -pl idle-erp-web -Dtest="Test1,Test2,Test3"

# 模块内所有测试
mvn test -pl idle-erp-web -q
```