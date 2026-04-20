(lang dune 3.20)
(name slugline)
(version dev)
(generate_opam_files)
(using mdx 0.4)
(maintenance_intent "(latest)")

(source (github cargocut/slugline))
(license BSD-3-Clause)
(authors
  "d-plaindoux <d.plaindoux@free.fr>"
  "xhtmlboi <xhtmlboi@gmail.com>"
  "xvw <xaviervdw@gmail.com>"
  "msp <spawnmick@gmail.com>"
  "grm <grimfw@gmail.com>")
(maintainers
  "d-plaindoux <d.plaindoux@free.fr>"
  "xhtmlboi <xhtmlboi@gmail.com>"
  "xvw <xaviervdw@gmail.com>"
  "msp <spawnmick@gmail.com>"
  "grm <grimfw@gmail.com>")

(package
 (name slugline)
 (synopsis "A very small (and portable) slugifier implementation")
 (description "A very small (and portable) slugifier implementation")
 (depends
  (ocaml (>= 5.0.0))

  ;; test setup
  (ppx_expect (and :with-test (>= 0.17.3)))
  (mdx (and :with-test  (>= 2.5.1)))

  ;; dev setup
  (utop :with-dev-setup)
  (ocamlformat :with-dev-setup)
  (ocp-indent :with-dev-setup)
  (merlin :with-dev-setup)
  (ocaml-lsp-server :with-dev-setup)))
