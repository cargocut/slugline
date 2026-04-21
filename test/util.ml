(* Copyright (c) 2026, Cargocut and the Slugline developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

let dump ?mapping ?sep ?unknown s =
  s
  |> Slugline.from_string ?mapping ?sep ?unknown
  |> Slugline.to_string
  |> print_endline
;;
