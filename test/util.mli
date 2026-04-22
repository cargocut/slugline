(* Copyright (c) 2026, Cargocut and the Slugline developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

val dump
  :  ?lowercase:bool
  -> ?mapping:Slugline.Mapping.t
  -> ?sep:string
  -> ?unknown:string
  -> string
  -> unit
