(* Copyright (c) 2026, Cargocut and the Slugline developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

open Util

let%expect_test "from_string" =
  dump "hello";
  [%expect {| hello |}]
;;

let%expect_test "from_string" =
  dump "hello world";
  [%expect {| hello-world |}]
;;

let%expect_test "from_string" =
  dump "----hello -- - - ! ; world--";
  [%expect {| hello-world |}]
;;

let%expect_test "from_string" =
  dump "Xâvier";
  [%expect {| Xavier |}]
;;

let%expect_test "from_string" =
  dump "Xâvier ou Xaviè, où se trouve-t-il ? En ỳeahlòd?";
  [%expect {| Xavier-ou-Xavie-ou-se-trouve-t-il-En-yeahlod |}]
;;

let%expect_test "empty string" =
  dump "";
  [%expect {|  |}]
;;

let%expect_test "only separators" =
  dump "----";
  [%expect {|  |}]
;;

let%expect_test "only punctuation" =
  dump "!!!;;;???";
  [%expect {|  |}]
;;

let%expect_test "whitespace only" =
  dump "   \t\n  ";
  [%expect {|  |}]
;;

let%expect_test "collapse multiple separators" =
  dump "hello   world";
  [%expect {| hello-world |}]
;;

let%expect_test "mixed separators collapse" =
  dump "hello---___   world";
  [%expect {| hello-world |}]
;;

let%expect_test "leading and trailing separators" =
  dump "---hello-world---";
  [%expect {| hello-world |}]
;;

let%expect_test "various accents" =
  dump "àáâäãå";
  [%expect {| aaaaaa |}]
;;

let%expect_test "mixed unicode sentence" =
  dump "C'était déjà l'été.";
  [%expect {| C-etait-deja-l-ete |}]
;;

let%expect_test "non latin removed" =
  dump "你好世界";
  [%expect {|  |}]
;;

let%expect_test "mixed latin and non latin" =
  dump "hello 世界";
  [%expect {| hello |}]
;;

let%expect_test "numbers preserved" =
  dump "version 2.0.1";
  [%expect {| version-2-0-1 |}]
;;

let%expect_test "mixed alphanumeric" =
  dump "abc123def";
  [%expect {| abc123def |}]
;;

let%expect_test "case preserved" =
  dump "Hello World";
  [%expect {| Hello-World |}]
;;

let%expect_test "case not preserved" =
  dump ~lowercase:true "Hello World";
  [%expect {| hello-world |}]
;;

let%expect_test "mixed case with accents" =
  dump "École Nationale";
  [%expect {| Ecole-Nationale |}]
;;

let%expect_test "mixed case with accents forced to lowercase" =
  dump ~lowercase:true "École Nationale";
  [%expect {| ecole-nationale |}]
;;

let%expect_test "idempotent" =
  let s = "Hello world!!!" in
  let slug1 = Slugline.from_string ~lowercase:false s in
  let slug2 = Slugline.to_string slug1 in
  dump slug2;
  [%expect {| Hello-world |}]
;;

let%expect_test "with subst" =
  dump "c++ guide";
  [%expect {| c-plus-plus-guide |}]
;;

let%expect_test "with subst" =
  dump "fish & chips";
  [%expect {| fish-and-chips |}]
;;

let%expect_test "with subst" =
  dump "xavier@foo.com";
  [%expect {| xavier-at-foo-com |}]
;;

let%expect_test "with subst" =
  dump "email me @home";
  [%expect {| email-me-at-home |}]
;;

let%expect_test "with subst" =
  dump "100% free";
  [%expect {| 100-percent-free |}]
;;

let%expect_test "Sharing subst/placeholder" =
  dump "  !  foo !  !";
  [%expect {| foo |}]
;;

let%expect_test "Not Sharing subst/placeholder" =
  dump ~unknown:"_" "  !  foo !  !";
  [%expect {| foo-_- |}]
;;
