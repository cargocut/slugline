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
