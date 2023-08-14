# hello_ocamls


## 项目配置

**使用 dune 构建 OCaml 项目时，至少需要两个配置文件：**

1. dune-project 文件，包含项目范围的配置数据。这是一个非常小的：

```
(lang dune 3.4)
```

2. dune 文件，其中包含实际的【构建指令】。一个项目可能有多个，具体取决于源的组织。

```
(executable (name bmodule))
```