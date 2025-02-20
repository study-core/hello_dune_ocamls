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




## 备注

要调用 dune ，您需要有两个文件：

 - 一个用于整个项目的 dune-project 文件，
 - 以及一个配置特定目录的 dune 文件。
 
这是一个单目录项目，因此我们只需要其中一个，但更实际的项目将有一个 dune-project 和许多 dune 文件。


最简单的是， dune-project 只是指定正在使用的 dune 配置语言的版本。

一个 dune 文件来声明我们想要构建的可执行文件及其依赖的库。

**注意：**

> dune-project: 一个项目一个构建文件

> dune: 一个文件夹一个  (每个[需要]某种构建的目录都必须包含一个 dune 文件)



OCaml 附带两个编译器： ocamlopt 本机代码编译器和 ocamlc 字节码编译器。使用 ocamlc 编译的程序由虚拟机解释，而使用 ocamlopt 编译的程序则编译为机器代码以在特定操作系统和处理器架构上运行。使用 dune 时，以 .bc 结尾的目标将构建为字节码可执行文件，而以 .exe 结尾的目标将构建为本机代码。


除了性能之外，两个编译器生成的可执行文件具有几乎相同的行为。有几件事需要注意。首先，字节码编译器 
 ocamlc 可以在更多的架构上使用，并且拥有一些本机代码所没有的工具。字节码编译器也比本机代码编译器更快。


为了运行字节码可执行文件，您通常需要在相关系统上安装 OCaml。但这并不是严格要求的，因为您可以使用 -custom 编译器标志构建具有嵌入式运行时的字节码可执行文件。


一般来说，生产可执行文件通常应使用本机代码编译器构建。

