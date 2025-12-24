(lang dune 3.3)

(name hello_ocamls)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name hello_ocamls)
 (synopsis "OCaml learning project with PPX extensions")
 (description "A comprehensive OCaml learning project demonstrating PPX extensions")
 (depends
  ocaml
  dune
  ppxlib
  core
  ppx_deriving
  ppx_inline_test
  ppx_expect)
 (tags
  (topics "ocaml" "ppx" "learning" "metaprogramming")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
