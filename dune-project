(lang dune 3.20)

(name windtrap-test-repro)

(generate_opam_files)

(implicit_transitive_deps false)

(pin
 (url
  "git+https://github.com/invariant-hq/windtrap.git#d97cc3a1a6e93ebd7ce4ac71c48eee267e4726a5")
 (package
  (name windtrap))
 (package
  (name ppx_windtrap)))

(package
 (name windtrap-test-repro)
 (depends
  (ocaml
   (>= 5.2))
  ppx_expect
  ppx_windtrap
  windtrap))
