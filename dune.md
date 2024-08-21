# dune 的使用


## 简单项目示例


#### 创建项目目录 `mixtli`

```
mkdir mixtli; cd mixtli   # mixtli 即是 项目名称
```

#### 创建四个文件： dune-project 、 dune 、 cloud.ml 和 wmo.ml

#### 编写 dune-project 文件

```
(lang dune 3.7)                 指定所需 Dune 版本
(package (name wmo-clouds))     项目构建的包的名称
```

#### 编写 dune 文件


```
(executable
  (name cloud)                  表示文件 cloud.ml 包含可执行文件
  (public_name nube))           表示可以使用名称 nube 来提供可执行文件    即，可以在文件根目录执行 opam exec -- dune exec nube
```

#### 编写 wmo.ml 文件

```ml
(* wmo.ml 文件本身即是 Wmo 模块 *)

module Stratus = struct                     (* 定义 Stratus 子模块 *)
  let nimbus = "Nimbostratus (Ns)"
end

module Cumulus = struct                     (* 定义 Cumulus 子模块 *)
  let nimbus = "Cumulonimbus (Cb)"
end
```

#### 编写 cloud.ml 文件

```ml
(* 入口函数，也是可执行文件入口 *)
let () =
  Wmo.Stratus.nimbus |> print_endline;
  Wmo.Cumulus.nimbus |> print_endline
```

#### 目录结构

```
├── dune
├── dune-project
├── cloud.ml
└── wmo.ml
```


#### 运行

```
opam exec -- dune exec nube   # nube 就是 dune 中定义好的     可执行命令的名称
```

#### dune 编译项目后的二进制

Dune 将其创建的文件存储在名为 _build 的目录中。在使用 Git 管理的项目中，应忽略 _build 目录

```
echo _build >> .gitignore
```

#### 查看项目模块结构


在项目根目录输入:

```
dune describe
```



## Libraries 定义

(方便起见，我们继续上述 mixtli 项目中操作)

#### 创建 lib 目录 (不是必须的，这为了方便演示)


```
mkdir lib
```

#### 编写 lib/dune 文件

```
(library (name wmo))      这里我们故意 定义 和项目根目录 wmo.ml 文件同名的模块名 (为了下面的演示)
```

#### 编写几个 ml 文件


```ml
(* lib/cumulus.mli *)
val nimbus : string

(* lib/cumulus.ml *)
let nimbus = "Cumulonimbus (Cb)"

(* lib/stratus.mli *)
val nimbus : string

(* lib/stratus.ml *)
let nimbus = "Nimbostratus (Ns)"

(* 这时候，需要将项目根目录的 wmo.ml 删除掉,否则将会造成冗余冲突 *)
(* lib 目录中找到的所有模块都捆绑到 Wmo 模块中 *)
```

#### 修改系那个木根目录 dune 文件

```
(executable
  (name cloud)
  (public_name nube)
  (libraries wmo))         声明 Wmo
```


#### 手动编写 Libraries 的 [包装模块]


默认情况下，当 Dune 将 [模块(应该是子模块)] 捆绑到库中时，它们会自动包装到 [模块(应该是父模块)] 中。

当然，我们可以手动编写包装文件 (包装器文件 必须与 库同名)。


如： 上述中，我们可以 保留项目根目录的 `wmo.ml` 文件，只不过内容中需要修改为: 

```ml
(* = 号左侧， module Cumulus 表示模块 Wmo 包含一个名为 Cumulus 的子模块 *)
(* = 号右侧， Cumulus 指的是文件 lib/cumulus.ml 中定义的模块 *)
module Cumulus = Cumulus        
module Stratus = Stratus 

(* 当库目录包含包装器模块 (此处为 wmo.ml ) 时，它是唯一公开的 *)
(* 该目录中未出现在包装器模块中的所有其他基于文件的模块都是私有的 *)
```


**包装模块的作用**


1. 能使同一子模块在对外和对内使用不同名称: `module CumulusCloud = Cumulus` 
        其中 `CumulusCloud` 是定义在 wmo.ml 包装模块中的 `Cumulus` 子模块名 [对外]
        而 `Cumulus` 是 `lib/cumulus.ml` 文件定义的子模块名 [对内]
2. 对外暴露由 functor 函子产生的模块, 如: 模块 `StringSet = Set.Make(String)`
3. 将相同的接口类型应用于多个模块, 无需重复文件 
4. 隐藏掉不被列出来的其他子模块 (未被定义在 `wmo.ml` 文件中的其他 `lib/xxx.ml` 子模块) 


对于 [3.] 的应用, 如下:  

```ml
(* 上述 lib/cumulus.mli 和 lib/status.mli 中定义的接口类型是一致的, 造成了冗余, 我们可以通过下列形式整合 *)

(* 删除文件 lib/cumulus.mli 和 lib/status.mli *)

(* wmo.mli *)
module type Nimbus = sig
  val nimbus : string
end

module CumulusCloud : Nimbus
module StratusCloud : Nimbus

(* wmo.ml *)
module type Nimbus = sig
  val nimbus : string
end

module CumulusCloud = Cumulus
module StratusCloud = Stratus

```


#### 补充 

默认情况下，Dune 从与 dune 文件位于同一目录中的模块构建库，但它不会查看子目录。

即：[dune 只会构建同目录下的 `xx.ml` 文件生成的子模块，而不会处理同目录下的 `子目录` 中的 `xxx.ml` 子模块] 这就很尬, 大型项目这是不灵活的

可以使用下面的方式: 

```ml
(* 有点像 rust 的目录中的 mod.rs 含义 *)

(* 我们创建子目录并将文件移至其中 *)

(* mkdir lib/cumulus lib/stratus        # 创建子目录 cumulus 和 stratus *)

(* mv lib/cumulus.ml lib/cumulus/m.ml   # 移动文件内容 *)
(* mv lib/stratus.ml lib/stratus/m.ml   # 移动文件内容 *)


(* wmo.ml *)
module type Nimbus = sig
  val nimbus : string
end

module CumulusCloud = Cumulus.M
module StratusCloud = Stratus.M
```

修改 dune 文件


```
(include_subdirs qualified)     指定使用 [子目录]
(library (name wmo))
```

